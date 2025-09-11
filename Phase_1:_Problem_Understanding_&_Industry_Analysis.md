# CharityConnect CRM – Donor Transparency & Engagement Platform

## Phase 1: Problem Understanding & Industry Analysis

**Industry:** Non-Profit / Charity (Crowdfunding & Donations)  
**Project Type:** Salesforce CRM Implementation (Admin + Developer)  
**Target Users:** Donors, NGO Staff/Admins, Beneficiaries  

---

## Problem Statement

Non-profits struggle to build trust and engage donors due to:

* Scattered donation records in Excel/Sheets.  
* Limited visibility into how donations are utilized.  
* No reward system for recurring or loyal donors.  
* Manual effort in sending updates, receipts, and impact reports.  

This leads to **low donor retention, inefficiency, and declining trust**.  

---

## Goal

Develop a Salesforce-based platform that:

* Centralizes donors, donations, campaigns, and beneficiaries.  
* Provides **real-time donation tracking and impact reports**.  
* Introduces **innovative engagement features** (Smart Cart, Loyalty Points, Badges, Forecasting).  
* Automates thank-you emails, festive donation drives, and reminders.  
* Enhances transparency through dashboards and donor profiles.  

---

## Requirement Gathering

### Business Needs

* Centralized platform for NGO staff and donors.  
* Automated donation tracking + communication.  
* Gamification features to retain donor interest.  
* Impact-driven dashboards for staff and donors.  

### Functional Requirements

* **Donor Object** → details, donation history, loyalty points.  
* **Campaign Object** → fundraising goals, progress.  
* **Beneficiary Object** → supported communities/individuals.  
* **Donation Object** → links Donor → Campaign → Beneficiary.  
* **Smart Donor Cart** → select multiple campaigns, auto-total.  
* **Donor Loyalty Points & Badges** → points for each donation, auto-badges via automation.  
* **Impact Forecasting** → formulas & dashboard to show future impact.  
* **Festive Campaign Triggers** → seasonal auto-reminders.  

### Non-Functional Requirements

* Mobile-friendly via Salesforce app.  
* Role-based access (Donor, NGO Staff, Admin).  
* Scalable for thousands of donors.  
* Easy UI using Lightning App Builder + LWCs.  

---

## Stakeholder Analysis

| Stakeholder   | Needs / Responsibilities                                                                     |
| ------------- | -------------------------------------------------------------------------------------------- |
| Donors        | Donate easily, see real-time impact, earn rewards (points & badges), forecast future impact. |
| NGO Staff     | Create/manage campaigns, track donations, run festive drives, update beneficiaries.          |
| Beneficiaries | Receive support, provide updates, connect transparently with donors.                         |
| Admin         | Manage setup, security, permissions, and ensure compliance.                                  |

---

## Business Process Mapping

### Current Manual Process

* Donations recorded in Excel.  
* Donors informed via manual email/WhatsApp.  
* Reports created monthly with delays.  
* No systematic loyalty/reward tracking.  

### Proposed Salesforce Process

1. Donor selects multiple campaigns → added to **Impact Cart**.  
2. Total donation auto-calculates → stored as Donation record(s).  
3. **Thank-you email** sent automatically.  
4. Recurring reminders + festive campaign appeals triggered by Flow.  
5. Donor earns **Loyalty Points** → when thresholds met, **Badges auto-assigned**.  
6. **Impact Forecasting** shows how future pledges translate into meals/benefits.  
7. Dashboards auto-refresh to show real-time donor & campaign performance.  

---

## Industry-Specific Use Cases

* **Smart Donor Cart** → e-commerce-like donation experience.  
* **Donation Transparency Dashboard** → live usage of funds.  
* **Gamification with Loyalty Points & Badges** → motivates donors.  
* **Impact Forecasting** → future impact visualization.  
* **Festive Campaign Triggers** → seasonal drives like “This Diwali, sponsor a meal.”  

---

## AppExchange Exploration

* **Nonprofit Success Pack (NPSP):** Base framework for NGO donation tracking.  
* **Conga Composer:** Auto-generate donation receipts.  
* **FormAssembly:** Custom donor registration forms.  
* **SurveyMonkey:** Collect donor feedback post-campaign.  

---


