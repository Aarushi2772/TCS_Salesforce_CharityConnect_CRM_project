import { LightningElement, track, wire, api } from 'lwc';
import getActiveCampaigns from '@salesforce/apex/CharityConnectController.getActiveCampaigns';
import processImpactCart from '@salesforce/apex/CharityConnectController.processImpactCart';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SmartDonorCart extends LightningElement {
    @api donorId; // Pass in logged-in donor id if available
    @track campaigns = [];
    @track amountMap = {}; // { campaignId: amount }
    @track selected = new Set();
    @track totalAmount = 0;
    @track isLoading = false;
    @track error;

    connectedCallback() {
        // donorId can be set by parent or via context (not included here)
    }

    @wire(getActiveCampaigns)
    wiredCampaigns({ error, data }) {
        if (data) {
            this.campaigns = data;
            // initialize amountMap with empty values
            for (let c of data) {
                this.amountMap[c.Id] = 0;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error;
            this.campaigns = [];
        }
    }

    handleSelect(event) {
        // Using custom checkbox: get data-id
        const campaignId = event.target.dataset.id;
        const checked = event.target.checked;
        if (checked) {
            this.selected.add(campaignId);
        } else {
            this.selected.delete(campaignId);
        }
        this.calculateTotal();
    }

    handleAmountChange(event) {
        const campaignId = event.target.dataset.id;
        let val = parseFloat(event.target.value);
        if (isNaN(val) || val < 0) val = 0;
        this.amountMap = { ...this.amountMap, [campaignId]: val };
        // if amount > 0 and not selected, mark selected
        if (val > 0) this.selected.add(campaignId);
        this.calculateTotal();
    }

    calculateTotal() {
        let sum = 0;
        for (let campId of this.selected) {
            const amt = this.amountMap[campId] || 0;
            sum += parseFloat(amt);
        }
        this.totalAmount = sum.toFixed(2);
    }

    get isCheckoutDisabled() {
        return this.selected.size === 0 || parseFloat(this.totalAmount) <= 0 || !this.donorId;
    }

    async handleCheckout() {
        if (this.isCheckoutDisabled) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Unable to proceed', message: 'Select campaigns and enter amount', variant: 'error' }));
            return;
        }
        this.isLoading = true;
        const cartItems = [];
        for (let campId of this.selected) {
            const amt = this.amountMap[campId] || 0;
            if (amt > 0) {
                cartItems.push({ campaignId: campId, amount: amt });
            }
        }

        try {
            const result = await processImpactCart({ donorId: this.donorId, items: cartItems });
            this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: 'Donation(s) created', variant: 'success' }));
            // optionally navigate to donation records or clear cart
            this.selected = new Set();
            for (let key in this.amountMap) this.amountMap[key] = 0;
            this.calculateTotal();
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: err.body ? err.body.message : 'Error processing cart', variant: 'error' }));
        } finally {
            this.isLoading = false;
        }
    }
}
