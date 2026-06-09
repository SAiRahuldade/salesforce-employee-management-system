# 💼 Salesforce Employee Management System (EMS)

An end-to-end Salesforce DX application designed to streamline internal human resource operations. It provides comprehensive tools to manage employee records, track project assignments, log daily attendance, manage leave requests, and view real-time organizational analytics.

---

## 🚀 Key Features

* **Employee Directory**
  * Manage employee profiles including Name, Email, Status (`Active`/`Inactive`), and Salary.
  * Validation rules to prevent duplicate email registrations and negative salaries.
* **Project & Assignment Tracking**
  * Track project lifecycles (`Planned`, `Ongoing`, `Completed`).
  * Assign employees to projects using a custom junction object with designated roles and allocation percentages.
* **Attendance Tracking**
  * Log daily check-in and check-out times.
  * Automatic calculation of attendance status (`Present`, `Absent`, `Half-Day`).
* **Leave Management**
  * Apply for various leave types (Sick, Casual, Earned, Maternity).
  * Request submission, approval, and rejection workflows.
* **HR Analytics Dashboard**
  * A rich, interactive Lightning Web Component (LWC) dashboard.
  * Real-time metrics and KPIs (Total Employees, Projects, Active/Inactive counts).
  * Visual SVG chart segments (Donut charts for status distribution, column charts for department distribution, and horizontal status bars).

---

## 📊 Custom Data Model (Schema)

The application uses the following custom objects:

1. **Employee (`Employee__c`)**
   * Fields: `Name` (Text), `Email__c` (Email, unique validation), `Department__c` (Picklist: `IT`, `HR`, `Finance`, `Sales`), `Salary__c` (Currency), `Status__c` (Picklist: `Active`, `Inactive`), `Joining_Date__c` (Date), `Phone__c` (Phone).
2. **Project (`Project__c`)**
   * Fields: `Name` (Text), `Description__c` (Long Text), `Start_Date__c` (Date), `End_Date__c` (Date), `Status__c` (Picklist: `Planned`, `Ongoing`, `Completed`).
3. **Assignment (`Assignment__c`)**
   * Junction object mapping Employees to Projects.
   * Fields: `Employee__c` (Lookup), `Project__c` (Lookup), `Role__c` (Picklist), `Allocation__c` (Percent).
4. **Attendance (`Attendance__c`)**
   * Fields: `Employee__c` (Lookup), `Date__c` (Date), `Check_In_Time__c` (DateTime), `Check_Out_Time__c` (DateTime), `Status__c` (Picklist: `Present`, `Absent`, `Half-Day`).
5. **Leave Request (`Leave_Request__c`)**
   * Fields: `Employee__c` (Lookup), `Leave_Type__c` (Picklist), `Start_Date__c` (Date), `End_Date__c` (Date), `Reason__c` (Text), `Status__c` (Picklist: `Pending`, `Approved`, `Rejected`).

---

## 🛠️ Architecture & Codebase Overview

### Lightning Web Components (LWC)
* `employeeList`: The main directory table and management console to create/edit/delete employee files.
* `hrDashboard`: The analytics dashboard rendering organization-wide metrics and visual charts.
* `attendanceLeave`: UI interface to log daily attendance and submit/review leave requests.
* `projectList`: UI console to manage projects and allocate assignments.

### Apex Backend Controllers & Services
* `EmployeeController.cls` / `EmployeeService.cls`: Handles fetching, searching, creating, and updating employee records.
* `DashboardController.cls`: Computes aggregated statistics for the LWC dashboard via optimized SOQL queries.
* `AttendanceController.cls`: Handles attendance check-in/check-out logs.
* `LeaveController.cls`: Manages leave request creation and updates.

### Apex Triggers & Handlers
* `EmployeeTrigger.trigger` / `EmployeeTriggerHandler.cls`: Performs duplicate email checks and salary validation before records hit the database.
* `AttendanceTrigger.trigger` / `AttendanceTriggerHandler.cls`: Automatically manages attendance state transitions.
* `AssignmentTrigger.trigger` / `AssignmentTriggerHandler.cls`: Validates project resource allocation logic.

---

## ⚙️ Setup and Deployment

### 1. Authorize your Org
Authorize your scratch org or developer sandbox:
```bash
sf org login web -a ems-org
```

### 2. Deploy Metadata to Org
Deploy the source code (classes, triggers, custom objects, layouts, tabs, and LWC components):
```bash
sf project deploy start
```

### 3. Run Unit Tests
To verify deployment integrity and execute Apex tests:
```bash
sf apex run test --test-level RunLocalTests
```

---

## 🧪 Testing and Coverage
The project includes comprehensive test suites coverage for all Apex classes and triggers:
* `EmployeeControllerTest.cls`
* `EmployeeTriggerTest.cls`
* `DashboardControllerTest.cls`
* `AttendanceControllerTest.cls`
* `LeaveControllerTest.cls`
* `ProjectControllerTest.cls`
* `AssignmentTriggerTest.cls`
