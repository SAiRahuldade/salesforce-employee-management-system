@isTest
public class EmployeeControllerTest {

    @testSetup
    static void setup() {
        List<Employee__c> testEmployees = new List<Employee__c>();
        testEmployees.add(new Employee__c(
            Name = 'Alice Smith',
            Email__c = 'alice@example.com',
            Department__c = 'HR',
            Salary__c = 50000,
            Status__c = 'Active'
        ));
        testEmployees.add(new Employee__c(
            Name = 'Bob Jones',
            Email__c = 'bob@example.com',
            Department__c = 'IT',
            Salary__c = 75000,
            Status__c = 'Active'
        ));
        insert testEmployees;
    }

    @isTest
    static void testGetEmployees() {
        Test.startTest();
        List<Employee__c> result = EmployeeController.getEmployees();
        Test.stopTest();

        Assert.areEqual(2, result.size(), 'Should return 2 employees');
        Assert.areEqual('Alice Smith', result[0].Name, 'First employee should be Alice Smith (alphabetical)');
    }

    @isTest
    static void testSearchEmployees() {
        Test.startTest();
        List<Employee__c> searchResultAll = EmployeeController.searchEmployees('');
        List<Employee__c> searchResultFiltered = EmployeeController.searchEmployees('Bob');
        Test.stopTest();

        Assert.areEqual(2, searchResultAll.size(), 'Empty search term should return all employees');
        Assert.areEqual(1, searchResultFiltered.size(), 'Search for Bob should return 1 employee');
        Assert.areEqual('Bob Jones', searchResultFiltered[0].Name);
    }

    @isTest
    static void testCreateEmployee() {
        Employee__c newEmp = new Employee__c(
            Name = 'Charlie Brown',
            Email__c = 'charlie@example.com',
            Department__c = 'Sales',
            Salary__c = 45000,
            Status__c = 'Active'
        );

        Test.startTest();
        EmployeeController.createEmployee(newEmp);
        Test.stopTest();

        List<Employee__c> employees = [SELECT Id FROM Employee__c WHERE Name = 'Charlie Brown'];
        Assert.areEqual(1, employees.size(), 'Charlie Brown should have been inserted');
    }

    @isTest
    static void testUpdateEmployee() {
        Employee__c alice = [SELECT Id, Salary__c FROM Employee__c WHERE Name = 'Alice Smith' LIMIT 1];
        alice.Salary__c = 55000;

        Test.startTest();
        EmployeeController.updateEmployee(alice);
        Test.stopTest();

        Employee__c updatedAlice = [SELECT Salary__c FROM Employee__c WHERE Id = :alice.Id];
        Assert.areEqual(55000, updatedAlice.Salary__c, 'Salary should be updated to 55000');
    }

    @isTest
    static void testDeleteEmployee() {
        Employee__c bob = [SELECT Id FROM Employee__c WHERE Name = 'Bob Jones' LIMIT 1];

        Test.startTest();
        EmployeeController.deleteEmployee(bob.Id);
        Test.stopTest();

        List<Employee__c> employees = [SELECT Id FROM Employee__c WHERE Id = :bob.Id];
        Assert.areEqual(0, employees.size(), 'Bob should have been deleted');
    }
}
