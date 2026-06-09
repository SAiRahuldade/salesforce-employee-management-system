@isTest
public class AttendanceTriggerTest {

    @testSetup
    static void setup() {
        Employee__c emp = new Employee__c(
            Name = 'John Doe',
            Email__c = 'john@example.com',
            Department__c = 'IT',
            Salary__c = 30000,
            Status__c = 'Active'
        );
        insert emp;

        Attendance__c yesterdayAtt = new Attendance__c(
            Employee__c = emp.Id,
            Check_In_Time__c = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(9, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(17, 0, 0, 0)),
            Status__c = 'Present'
        );
        insert yesterdayAtt;
    }

    @isTest
    static void testInsertValidAttendance() {
        Employee__c emp = [SELECT Id FROM Employee__c LIMIT 1];

        Attendance__c att = new Attendance__c(
            Employee__c = emp.Id,
            Check_In_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0)),
            Status__c = 'Present'
        );

        Test.startTest();
        insert att;
        Test.stopTest();

        Attendance__c inserted = [SELECT Id, Date__c FROM Attendance__c WHERE Date__c = :Date.today() LIMIT 1];
        Assert.areNotEqual(null, inserted.Id);
        Assert.areEqual(Date.today(), inserted.Date__c, 'Date__c should be auto-derived from Check_In_Time__c');
    }

    @isTest
    static void testInvalidCheckInOutTimes() {
        Employee__c emp = [SELECT Id FROM Employee__c LIMIT 1];

        Attendance__c att = new Attendance__c(
            Employee__c = emp.Id,
            Check_In_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0)),
            Status__c = 'Present'
        );

        Test.startTest();
        try {
            insert att;
            Assert.fail('Should have failed because Check Out is before Check In');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Check Out Time must be after Check In Time.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertDuplicateAttendance() {
        Employee__c emp = [SELECT Id FROM Employee__c LIMIT 1];

        Attendance__c att = new Attendance__c(
            Employee__c = emp.Id,
            Check_In_Time__c = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(10, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(15, 0, 0, 0)),
            Status__c = 'Present'
        );

        Test.startTest();
        try {
            insert att;
            Assert.fail('Should have failed because duplicate daily attendance');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Attendance already exists for this employee on this date.'));
        }
        Test.stopTest();
    }
}
