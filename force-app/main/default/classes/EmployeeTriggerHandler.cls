public class EmployeeTriggerHandler {

    public static void validateSalary(List<Employee__c> employees) {

        for(Employee__c emp : employees) {

            if(emp.Salary__c != null && emp.Salary__c < 0) {

                emp.addError('Salary cannot be negative.');
            }
        }
    }

    public static void validateDuplicateEmail(List<Employee__c> employees) {

        Set<String> emailSet = new Set<String>();

        for(Employee__c emp : employees) {
            if(emp.Email__c != null) {
                emailSet.add(emp.Email__c);
            }
        }

        Map<String, Employee__c> existingEmployees = new Map<String, Employee__c>();

        for(Employee__c emp : [
            SELECT Id, Email__c
            FROM Employee__c
            WHERE Email__c IN :emailSet
        ]) {
            existingEmployees.put(emp.Email__c, emp);
        }

        for(Employee__c emp : employees) {

            if(emp.Email__c != null && existingEmployees.containsKey(emp.Email__c)) {

                // THIS IS THE FIX
                // Before: was flagging the record against itself during update
                // Now: skips if the existing record with that email IS the same record
                if(existingEmployees.get(emp.Email__c).Id != emp.Id) {

                    emp.addError('Employee with this email already exists.');
                }
            }
        }
    }
}