@isTest
public class DashboardControllerTest {

    @testSetup
    static void setup() {
        // Create Employees in different departments and statuses
        List<Employee__c> testEmployees = new List<Employee__c>{
            new Employee__c(Name = 'Alice', Email__c = 'alice@test.com', Department__c = 'IT', Salary__c = 50000, Status__c = 'Active'),
            new Employee__c(Name = 'Bob', Email__c = 'bob@test.com', Department__c = 'HR', Salary__c = 60000, Status__c = 'Active'),
            new Employee__c(Name = 'Charlie', Email__c = 'charlie@test.com', Department__c = 'Finance', Salary__c = 70000, Status__c = 'Inactive'),
            new Employee__c(Name = 'David', Email__c = 'david@test.com', Department__c = 'Sales', Salary__c = 40000, Status__c = 'Active')
        };
        insert testEmployees;

        // Create Projects in different statuses
        List<Project__c> testProjects = new List<Project__c>{
            new Project__c(Name = 'Proj 1', Status__c = 'Planned', Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(10)),
            new Project__c(Name = 'Proj 2', Status__c = 'Ongoing', Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(20)),
            new Project__c(Name = 'Proj 3', Status__c = 'Completed', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(-1))
        };
        insert testProjects;

        // Create Assignment
        Assignment__c assign = new Assignment__c(
            Employee__c = testEmployees[0].Id,
            Project__c = testProjects[0].Id,
            Allocation__c = 50
        );
        insert assign;

        // Create Attendance
        Attendance__c att = new Attendance__c(
            Employee__c = testEmployees[0].Id,
            Check_In_Time__c = DateTime.now(),
            Status__c = 'Present'
        );
        insert att;

        // Create Leave Requests
        List<Leave_Request__c> testLeaves = new List<Leave_Request__c>{
            new Leave_Request__c(
                Employee__c = testEmployees[0].Id, 
                Leave_Type__c = 'Sick Leave', 
                Start_Date__c = Date.today().addDays(5), 
                End_Date__c = Date.today().addDays(7),
                Reason__c = 'Test reason',
                Status__c = 'Pending'
            ),
            new Leave_Request__c(
                Employee__c = testEmployees[1].Id, 
                Leave_Type__c = 'Casual Leave', 
                Start_Date__c = Date.today().addDays(10), 
                End_Date__c = Date.today().addDays(12),
                Reason__c = 'Test reason',
                Status__c = 'Approved'
            )
        };
        insert testLeaves;
    }

    @isTest
    static void testGetDashboardStats() {
        Test.startTest();
        DashboardController.DashboardStats stats = DashboardController.getDashboardStats();
        Test.stopTest();

        // Employee assertions
        Assert.areEqual(4, stats.totalEmployees, 'Total Employees count mismatch');
        Assert.areEqual(3, stats.activeEmployees, 'Active Employees count mismatch');
        Assert.areEqual(1, stats.inactiveEmployees, 'Inactive Employees count mismatch');
        Assert.areEqual(1, stats.deptITEmployees, 'IT Employees count mismatch');
        Assert.areEqual(1, stats.deptHREmployees, 'HR Employees count mismatch');
        Assert.areEqual(1, stats.deptFinanceEmployees, 'Finance Employees count mismatch');
        Assert.areEqual(1, stats.deptSalesEmployees, 'Sales Employees count mismatch');

        // Project assertions
        Assert.areEqual(3, stats.totalProjects, 'Total Projects count mismatch');
        Assert.areEqual(1, stats.plannedProjects, 'Planned Projects count mismatch');
        Assert.areEqual(1, stats.ongoingProjects, 'Ongoing Projects count mismatch');
        Assert.areEqual(1, stats.completedProjects, 'Completed Projects count mismatch');

        // Assignment, Attendance and Leaves assertions
        Assert.areEqual(1, stats.totalAssignments, 'Total Assignments count mismatch');
        Assert.areEqual(1, stats.todayAttendance, 'Today\'s Attendance count mismatch');
        Assert.areEqual(1, stats.pendingLeaves, 'Pending Leaves count mismatch');
        Assert.areEqual(1, stats.approvedLeaves, 'Approved Leaves count mismatch');
    }
}
