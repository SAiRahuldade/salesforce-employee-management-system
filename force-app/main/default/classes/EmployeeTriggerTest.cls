@isTest
public class EmployeeTriggerTest {

    @testSetup
    static void setup() {
        Employee__c emp = new Employee__c(
            Name = 'Alice Smith',
            Email__c = 'alice@example.com',
            Department__c = 'HR',
            Salary__c = 50000,
            Status__c = 'Active'
        );
        insert emp;
    }

    @isTest
    static void testInsertValidEmployee() {
        Employee__c emp = new Employee__c(
            Name = 'Bob Jones',
            Email__c = 'bob@example.com',
            Department__c = 'IT',
            Salary__c = 75000,
            Status__c = 'Active'
        );

        Test.startTest();
        insert emp;
        Test.stopTest();

        Employee__c inserted = [SELECT Id FROM Employee__c WHERE Name = 'Bob Jones' LIMIT 1];
        Assert.areNotEqual(null, inserted.Id);
    }

    @isTest
    static void testInsertNegativeSalary() {
        Employee__c emp = new Employee__c(
            Name = 'Bob Jones',
            Email__c = 'bob@example.com',
            Department__c = 'IT',
            Salary__c = -100,
            Status__c = 'Active'
        );

        Test.startTest();
        try {
            insert emp;
            Assert.fail('Should have thrown an exception for negative salary');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Salary cannot be negative.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertDuplicateEmail() {
        Employee__c emp = new Employee__c(
            Name = 'Alice Second',
            Email__c = 'alice@example.com',
            Department__c = 'Finance',
            Salary__c = 60000,
            Status__c = 'Active'
        );

        Test.startTest();
        try {
            insert emp;
            Assert.fail('Should have thrown an exception for duplicate email');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Employee with this email already exists.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateEmailDuplicate() {
        Employee__c bob = new Employee__c(
            Name = 'Bob Jones',
            Email__c = 'bob@example.com',
            Department__c = 'IT',
            Salary__c = 75000,
            Status__c = 'Active'
        );
        insert bob;

        bob.Email__c = 'alice@example.com';

        Test.startTest();
        try {
            update bob;
            Assert.fail('Should have thrown an exception for duplicate email on update');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Employee with this email already exists.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateOwnRecordEmail() {
        Employee__c alice = [SELECT Id, Email__c FROM Employee__c WHERE Email__c = 'alice@example.com' LIMIT 1];
        alice.Salary__c = 52000;

        Test.startTest();
        update alice;
        Test.stopTest();

        Employee__c updated = [SELECT Salary__c FROM Employee__c WHERE Id = :alice.Id];
        Assert.areEqual(52000, updated.Salary__c);
    }
}
