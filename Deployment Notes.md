# **Deployment Notes \- Time Tracker App**

This guide outlines all necessary post-deployment steps to ensure the Time Tracker App runs correctly after metadata deployment via SFDX.

---

## **Prerequisites**

* A Salesforce org with **API access** (Developer Edition, Sandbox, or Production)

* A user with **System Administrator** profile

* Salesforce CLI installed (`sfdx`)

---

## **Deployment Instructions**

### **1\. Deploy Metadata**

sfdx force:source:deploy \-p force-app/main/default \-u \<your-org-alias\>

Or use VS Code’s "Deploy to Org" command from the context menu.

---

**Post-Deployment Configuration**

### **2\. Assign Required Permissions**

* Ensure the active user has access to:

  * All custom objects: `Employee__c`, `Project__c`, `Time_Log__c`, `Project_Assignment__c`

  * Apex class: `TimeLoggerController`

  * LWC: `timeLogger`

  * Flows

### **3\. Set Field-Level Security**

* Make sure fields like `Log_Date__c`, `Start_Time__c`, `End_Time__c`, and `UserID__c` are visible to the appropriate profiles.

### **4\. Set OWD (Organization-Wide Defaults)**

* `Time_Log__c`: **Private**

* `Project__c`: **Private**

---

## **Flows to Activate**

### **5\. Activate Record Sharing Flow**

* Label: `Time Log Record Sharing`

* Ensure it runs **after insert** of `Time_Log__c`

* Confirms records are shared with both:

  * Assigned employee’s UserID\_\_c

  * Manager’s UserID\_\_c (if populated)

### **6\. Activate Scheduled Flow \- Missed Time Log Reminder**

* Flow: `Missed_Log_Notification`

* Runs daily at **7 AM**

* Make sure **Email Deliverability** is set to **All Emails**

---

## **Reports & Dashboards**

### **7\. Review or Recreate Reports (Optional)**

* Confirm the following reports exist or re-create:

  * `Daily Time Logged by Employee`

  * `Monthly Time per Project`

  * `Project-wise Contribution Summary`

  * `Time Log Change History`

---

## **Test Data Suggestions**

* Create 1 `Employee__c` with `UserID__c` set to your user

* Create 1 `Project__c`

* Assign the project using `Project_Assignment__c`

* Log time using the LWC component

---

## **Known Considerations**

* Welcome emails on user creation are sent via `Messaging.sendEmail()`

* Time validation (max 8 hours/day) is enforced via LWC and Apex

* Users without a related Employee record won’t see projects

