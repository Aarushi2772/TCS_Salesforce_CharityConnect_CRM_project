public with sharing class CharityConnectController {

    // Simple wrapper used for cart items from LWC
    public class CartItem {
        @AuraEnabled public Id campaignId;
        @AuraEnabled public Decimal amount;
    }

    // Badge response wrapper
    public class BadgeInfo {
        @AuraEnabled public Integer loyaltyPoints;
        @AuraEnabled public List<Donor_Badge__c> badges;
        @AuraEnabled public Integer nextMilestone;
        public BadgeInfo(Integer pts, List<Donor_Badge__c> b, Integer nm) {
            this.loyaltyPoints = pts; this.badges = b; this.nextMilestone = nm;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Campaign__c> getActiveCampaigns() {
        // Return useful fields; only active campaigns
        return [
            SELECT Id, Name, Goal__c, Amount_Raised__c, StartDate__c, EndDate__c, Status__c
            FROM Campaign__c
            WHERE Status__c = 'Active'
            ORDER BY EndDate__c ASC NULLS LAST
            LIMIT 200
        ];
    }

    @AuraEnabled(cacheable=true)
    public static BadgeInfo getDonorBadgeInfo(Id donorId) {
        if (donorId == null) return new BadgeInfo(0, new List<Donor_Badge__c>(), 100);
        // Loyalty points field on Donor__c
        Donor__c d = [SELECT Id, Loyalty_Points__c FROM Donor__c WHERE Id = :donorId LIMIT 1];
        Integer points = d.Loyalty_Points__c == null ? 0 : Integer.valueOf(d.Loyalty_Points__c);
        List<Donor_Badge__c> badges = [
            SELECT Id, Badge_Type__c, Earned_Date__c
            FROM Donor_Badge__c
            WHERE Donor__c = :donorId
            ORDER BY Earned_Date__c DESC
            LIMIT 10
        ];
        // Next milestone (example): next 100-point milestone
        Integer nextMilestone = ((points / 100) + 1) * 100;
        return new BadgeInfo(points, badges, nextMilestone);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getCampaignProgress(Set<Id> campaignIds) {
        Map<String, Decimal> result = new Map<String, Decimal>();
        if (campaignIds == null || campaignIds.isEmpty()) return result;
        for (Campaign__c c : [
            SELECT Id, Goal__c, Amount_Raised__c
            FROM Campaign__c
            WHERE Id IN :campaignIds
        ]) {
            Decimal goal = (c.Goal__c == null) ? 0 : c.Goal__c;
            Decimal raised = (c.Amount_Raised__c == null) ? 0 : c.Amount_Raised__c;
            result.put(String.valueOf(c.Id), raised);
            // Note: only returning raised here; LWC will fetch goal separately if needed.
        }
        return result;
    }

    // Process impact cart: creates Donation__c records for each cart item
    @AuraEnabled
    public static List<Id> processImpactCart(Id donorId, List<CartItem> items) {
        if (donorId == null) {
            throw new AuraHandledException('Donor Id is required.');
        }
        if (items == null || items.isEmpty()) {
            throw new AuraHandledException('Cart is empty.');
        }

        List<Donation__c> toInsert = new List<Donation__c>();
        for (CartItem ci : items) {
            Donation__c d = new Donation__c();
            d.Donor__c = donorId;
            d.Campaign__c = ci.campaignId;
            d.Donation_Amount__c = ci.amount;
            d.Donation_Status__c = 'Pending';
            toInsert.add(d);
        }

        insert toInsert;

        // Optionally update campaign rollups: naive approach (better via trigger/flow)
        // We'll update Amount_Raised__c on Campaign__c by summing inserted donation amounts grouped by campaign
        Map<Id, Decimal> sumMap = new Map<Id, Decimal>();
        for (Donation__c d : toInsert) {
            sumMap.put(d.Campaign__c, sumMap.get(d.Campaign__c) == null ? d.Donation_Amount__c : sumMap.get(d.Campaign__c) + d.Donation_Amount__c);
        }
        List<Campaign__c> campsToUpdate = new List<Campaign__c>();
        for (Id cId : sumMap.keySet()) {
            Campaign__c c = new Campaign__c(Id = cId);
            // caution: this will overwrite if you rely on triggers; ideally use roll-up summaries
            c.Amount_Raised__c = (sumMap.get(cId) == null ? 0 : sumMap.get(cId)) + ([
                SELECT Amount_Raised__c FROM Campaign__c WHERE Id = :cId LIMIT 1
            ][0].Amount_Raised__c == null ? 0 : [
                SELECT Amount_Raised__c FROM Campaign__c WHERE Id = :cId LIMIT 1
            ][0].Amount_Raised__c);
            campsToUpdate.add(c);
        }
        if (!campsToUpdate.isEmpty()) {
            try {
                update campsToUpdate;
            } catch (Exception ex) {
                // swallow or log; not fatal for donor creation
                System.debug('Could not update campaigns: ' + ex.getMessage());
            }
        }

        List<Id> createdIds = new List<Id>();
        for (Donation__c d : toInsert) createdIds.add(d.Id);
        return createdIds;
    }
}
