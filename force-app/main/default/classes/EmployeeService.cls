public with sharing class EmployeeService {

    public static List<Employee__c> getAllEmployees() {

        return [
            SELECT Id, Name, Email__c, Department__c, Salary__c, Status__c
            FROM Employee__c
            ORDER BY Name
        ];
    }

    public static List<Employee__c> searchEmployees(String searchTerm) {

        if (String.isBlank(searchTerm)) {
            return getAllEmployees();
        }

        return [
            SELECT Id, Name, Email__c, Department__c, Salary__c, Status__c
            FROM Employee__c
            WHERE Name LIKE :('%' + searchTerm + '%')
            ORDER BY Name
        ];
    }
}