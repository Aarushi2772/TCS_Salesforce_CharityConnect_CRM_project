import { LightningElement, api, track } from 'lwc';
import getDonorBadgeInfo from '@salesforce/apex/CharityConnectController.getDonorBadgeInfo';

export default class DonorBadgeDisplay extends LightningElement {
    @api donorId;
    @track badgeInfo;
    @track isLoading = false;
    @track error;

    connectedCallback() {
        this.refresh();
    }

    async refresh() {
        if (!this.donorId) return;
        this.isLoading = true;
        try {
            const data = await getDonorBadgeInfo({ donorId: this.donorId });
            this.badgeInfo = data;
            this.error = undefined;
        } catch (err) {
            this.error = err.body ? err.body.message : 'Error loading badges';
            this.badgeInfo = undefined;
        } finally {
            this.isLoading = false;
        }
    }

    get progressPercent() {
        if (!this.badgeInfo || !this.badgeInfo.loyaltyPoints) return 0;
        const pts = this.badgeInfo.loyaltyPoints;
        const next = this.badgeInfo.nextMilestone || (Math.floor(pts/100)+1)*100;
        const prevMilestone = next - 100;
        if (next === prevMilestone) return 0;
        const progress = ((pts - prevMilestone) / (next - prevMilestone)) * 100;
        return Math.round(progress);
    }
}
