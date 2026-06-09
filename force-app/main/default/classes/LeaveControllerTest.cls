@isTest
public class LeaveControllerTest {

    @testSetup
    static void setup() {
        Employee__c emp = new Employee__c(
            Name = 'John Doe',
            Email__c = 'john.doe@example.com',
            Department__c = 'IT',
            Salary__c = 30000,
            Status__c = 'Active'
        );
        insert emp;

        Leave_Request__c leave = new Leave_Request__c(
            Employee__c = emp.Id,
            Leave_Type__c = 'Sick Leave',
            Start_Date__c = Date.today().addDays(2),
            End_Date__c = Date.today().addDays(4),
            Reason__c = 'Fever',
            Status__c = 'Pending'
        );
        insert leave;
    }

    @isTest
    static void testGetLeaveRequests() {
        Test.startTest();
        List<Leave_Request__c> result = LeaveController.getLeaveRequests();
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Should return 1 leave request');
        Assert.areEqual('John Doe', result[0].Employee__r.Name, 'Employee Name relation should be queried');
    }

    @isTest
    static void testSaveLeaveRequest() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'John Doe' LIMIT 1];
        Leave_Request__c leave = new Leave_Request__c(
            Employee__c = emp.Id,
            Leave_Type__c = 'Casual Leave',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(12),
            Reason__c = 'Personal work',
            Status__c = 'Pending'
        );

        Test.startTest();
        LeaveController.saveLeaveRequest(leave);
        Test.stopTest();

        List<Leave_Request__c> leaves = [SELECT Id FROM Leave_Request__c WHERE Leave_Type__c = 'Casual Leave'];
        Assert.areEqual(1, leaves.size(), 'Casual Leave request should be saved');
    }

    @isTest
    static void testDeleteLeaveRequest() {
        Leave_Request__c leave = [SELECT Id FROM Leave_Request__c LIMIT 1];

        Test.startTest();
        LeaveController.deleteLeaveRequest(leave.Id);
        Test.stopTest();

        List<Leave_Request__c> leaves = [SELECT Id FROM Leave_Request__c WHERE Id = :leave.Id];
        Assert.areEqual(0, leaves.size(), 'Leave request should be deleted');
    }
}
