# **Time Tracker App \- Salesforce Lightning Solution**

## **Project Overview**

The **Time Tracker App** is a custom Salesforce solution built to allow employees to log their daily working hours against specific projects. It enables time tracking, reporting, access control, and automated reminders for missed logs — all in a secure and scalable Lightning experience.

---

## **Key Features Implemented**

### **1\. Lightning App**

* Custom App: `Time Tracker App`

* Provides a unified UI for employees and managers to track time entries.

### **2\. Custom Data Model**

* **Employee\_\_c**: Custom object representing an employee (linked to a User)

* **Project\_\_c**: Represents projects employees can be assigned to

* **Time\_Log\_\_c**: Records daily hours logged per project

* **Project\_Assignment\_\_c**: Junction object between Employee and Project

### **3\. LWC Component: `timeLogger`**

* Allows employees to:

  * Select projects

  * Log start/end time

  * Enter comments

  * Add multiple entries

* Validates total hours do not exceed 8 hours per day

* Uses Apex controller to fetch and insert time logs

### **4\. Apex Controller**

* `TimeLoggerController.cls`: Handles project retrieval and time log insertion with validation

* Test class with `System.runAs()` covers controller functionality

### **5\. Scheduled Flow \- Missed Log Notification**

* Runs daily at 7 AM

* Checks if active employees logged time for **yesterday**

* Sends email reminders if no entry found

### **6\. Record Sharing Flow**

* On creation of `Time_Log__c`, a Flow:

  * Shares the record with the assigned employee (UserID\_\_c)

  * Shares it with their manager if `Manager__c` is set

### **7\. Access Control**

* OWD set to **Private** for `Project__c` and `Time_Log__c`

* Sharing handled via Flow based on Employee-User linkage

### **8\. Reports**

* **Daily Time Logged by Employee**

* **Monthly Time per Project**

* **Project-Wise Contribution Summary**

* **Time Log Change History** (Field Tracking Enabled)

---

## **Deployment Info**

* Code and metadata stored under `force-app/main/default`

* Compatible with Salesforce DX project structure

* Deployment guide included in `deployment-notes.md`

---

 **Test Coverage**

* Full test class for Apex controller

* Covers time logging, validations, and user scenarios

---

## **Security and Validation**

* 8-hour daily work limit enforced at UI and Apex level

* Access restricted via sharing and OWD

* Notifications ensure data accuracy and compliance

---

