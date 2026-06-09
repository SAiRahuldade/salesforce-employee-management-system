public class AssignmentTriggerHandler {

    public static void validateDuplicateAssignment(
        List<Assignment__c> assignments
    ) {

        Set<Id> employeeIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();

        for(Assignment__c a : assignments){
            employeeIds.add(a.Employee__c);
            projectIds.add(a.Project__c);
        }

        List<Assignment__c> existingAssignments = [
            SELECT Id, Employee__c, Project__c
            FROM Assignment__c
            WHERE Employee__c IN :employeeIds
            AND Project__c IN :projectIds
        ];

        for(Assignment__c newAssignment : assignments){

            for(Assignment__c existing : existingAssignments){

                if(newAssignment.Employee__c == existing.Employee__c &&
                   newAssignment.Project__c == existing.Project__c){

                    newAssignment.addError(
                        'Employee is already assigned to this project.'
                    );
                }
            }
        }
    }
    public static void validateAllocationLimit(
    List<Assignment__c> assignments
) {

    Set<Id> employeeIds = new Set<Id>();

    for(Assignment__c a : assignments) {
        if(a.Employee__c != null) {
            employeeIds.add(a.Employee__c);
        }
    }

    Map<Id, Decimal> currentAllocationMap =
        new Map<Id, Decimal>();

    for(Assignment__c existing : [
        SELECT Employee__c, Allocation__c
        FROM Assignment__c
        WHERE Employee__c IN :employeeIds
    ]) {

        Decimal currentTotal =
            currentAllocationMap.containsKey(existing.Employee__c)
            ? currentAllocationMap.get(existing.Employee__c)
            : 0;

        currentAllocationMap.put(
            existing.Employee__c,
            currentTotal + existing.Allocation__c
        );
    }

    for(Assignment__c a : assignments) {

        Decimal currentTotal =
            currentAllocationMap.containsKey(a.Employee__c)
            ? currentAllocationMap.get(a.Employee__c)
            : 0;

        Decimal newTotal =
            currentTotal + a.Allocation__c;

        if(newTotal > 100) {

            a.addError(
                'Employee allocation cannot exceed 100%.'
            );
        }
    }
}
}