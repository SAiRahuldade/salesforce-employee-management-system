@isTest
public class AssignmentTriggerTest {

    @testSetup
    static void setup() {
        Employee__c emp = new Employee__c(
            Name = 'John Doe',
            Email__c = 'john@example.com',
            Department__c = 'IT',
            Salary__c = 40000,
            Status__c = 'Active'
        );
        insert emp;

        Project__c proj1 = new Project__c(
            Name = 'Project Alpha',
            Status__c = 'Ongoing',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30)
        );
        Project__c proj2 = new Project__c(
            Name = 'Project Beta',
            Status__c = 'Ongoing',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30)
        );
        insert new List<Project__c>{proj1, proj2};

        Assignment__c assign = new Assignment__c(
            Employee__c = emp.Id,
            Project__c = proj1.Id,
            Allocation__c = 40
        );
        insert assign;
    }

    @isTest
    static void testInsertValidAssignment() {
        Employee__c emp = [SELECT Id FROM Employee__c LIMIT 1];
        Project__c proj2 = [SELECT Id FROM Project__c WHERE Name = 'Project Beta' LIMIT 1];

        Assignment__c assign = new Assignment__c(
            Employee__c = emp.Id,
            Project__c = proj2.Id,
            Allocation__c = 50
        );

        Test.startTest();
        insert assign;
        Test.stopTest();

        List<Assignment__c> assignments = [SELECT Id FROM Assignment__c WHERE Project__c = :proj2.Id];
        Assert.areEqual(1, assignments.size());
    }

    @isTest
    static void testInsertDuplicateAssignment() {
        Employee__c emp = [SELECT Id FROM Employee__c LIMIT 1];
        Project__c proj1 = [SELECT Id FROM Project__c WHERE Name = 'Project Alpha' LIMIT 1];

        Assignment__c assign = new Assignment__c(
            Employee__c = emp.Id,
            Project__c = proj1.Id,
            Allocation__c = 10
        );

        Test.startTest();
        try {
            insert assign;
            Assert.fail('Should have failed because of duplicate assignment');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Employee is already assigned to this project.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertExceedAllocationLimit() {
        Employee__c emp = [SELECT Id FROM Employee__c LIMIT 1];
        Project__c proj2 = [SELECT Id FROM Project__c WHERE Name = 'Project Beta' LIMIT 1];

        Assignment__c assign = new Assignment__c(
            Employee__c = emp.Id,
            Project__c = proj2.Id,
            Allocation__c = 70
        );

        Test.startTest();
        try {
            insert assign;
            Assert.fail('Should have failed because allocation exceeds 100%');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Employee allocation cannot exceed 100%.'));
        }
        Test.stopTest();
    }
}
