public with sharing class EmployeeController {

    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getEmployees() {
        return EmployeeService.getAllEmployees();
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee__c> searchEmployees(String searchTerm) {
        return EmployeeService.searchEmployees(searchTerm);
    }

    @AuraEnabled
    public static void createEmployee(Employee__c emp) {
        insert emp;
    }

    // ✅ ADD THIS
    @AuraEnabled
    public static void updateEmployee(Employee__c emp) {
        update emp;
    }

    // ✅ ADD THIS
    @AuraEnabled
    public static void deleteEmployee(Id empId) {
        delete [SELECT Id FROM Employee__c WHERE Id = :empId];
    }
}