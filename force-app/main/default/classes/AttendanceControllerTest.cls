@isTest
public class AttendanceControllerTest {

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

        Attendance__c att1 = new Attendance__c(
            Employee__c = emp.Id,
            Check_In_Time__c = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(9, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(17, 0, 0, 0)),
            Status__c = 'Present'
        );
        insert att1;
    }

    @isTest
    static void testGetAttendances() {
        Test.startTest();
        List<Attendance__c> result = AttendanceController.getAttendances();
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Should return 1 attendance record');
        Assert.areEqual('John Doe', result[0].Employee__r.Name, 'Employee Name relation should be queried');
    }

    @isTest
    static void testSaveAttendance() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'John Doe' LIMIT 1];
        Attendance__c att = new Attendance__c(
            Employee__c = emp.Id,
            Check_In_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0)),
            Status__c = 'Present'
        );

        Test.startTest();
        AttendanceController.saveAttendance(att);
        Test.stopTest();

        List<Attendance__c> attendances = [SELECT Id FROM Attendance__c WHERE Date__c = :Date.today()];
        Assert.areEqual(1, attendances.size(), 'Attendance for today should be saved');
    }

    @isTest
    static void testDeleteAttendance() {
        Attendance__c att = [SELECT Id FROM Attendance__c LIMIT 1];

        Test.startTest();
        AttendanceController.deleteAttendance(att.Id);
        Test.stopTest();

        List<Attendance__c> attendances = [SELECT Id FROM Attendance__c WHERE Id = :att.Id];
        Assert.areEqual(0, attendances.size(), 'Attendance should be deleted');
    }

    @isTest
    static void testGetAttendanceByEmployee() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'John Doe' LIMIT 1];

        Test.startTest();
        List<Attendance__c> result = AttendanceController.getAttendanceByEmployee(emp.Id);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Should return 1 attendance record for John Doe');
    }
}
