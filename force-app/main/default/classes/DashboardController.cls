public with sharing class DashboardController {

    public class DashboardStats {
        @AuraEnabled public Integer totalEmployees {get;set;}
        @AuraEnabled public Integer activeEmployees {get;set;}
        @AuraEnabled public Integer inactiveEmployees {get;set;}
        @AuraEnabled public Integer totalProjects {get;set;}
        @AuraEnabled public Integer plannedProjects {get;set;}
        @AuraEnabled public Integer ongoingProjects {get;set;}
        @AuraEnabled public Integer completedProjects {get;set;}
        @AuraEnabled public Integer totalAssignments {get;set;}
        @AuraEnabled public Integer todayAttendance {get;set;}
        @AuraEnabled public Integer pendingLeaves {get;set;}
        @AuraEnabled public Integer approvedLeaves {get;set;}
        
        // Department-wise counts
        @AuraEnabled public Integer deptITEmployees {get;set;}
        @AuraEnabled public Integer deptHREmployees {get;set;}
        @AuraEnabled public Integer deptFinanceEmployees {get;set;}
        @AuraEnabled public Integer deptSalesEmployees {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();

        // 1. Employee stats (grouped by Status and Department)
        stats.totalEmployees = 0;
        stats.activeEmployees = 0;
        stats.inactiveEmployees = 0;
        stats.deptITEmployees = 0;
        stats.deptHREmployees = 0;
        stats.deptFinanceEmployees = 0;
        stats.deptSalesEmployees = 0;

        for (AggregateResult ar : [
            SELECT Status__c, Department__c, COUNT(Id) cnt 
            FROM Employee__c 
            GROUP BY Status__c, Department__c
        ]) {
            String status = (String)ar.get('Status__c');
            String dept = (String)ar.get('Department__c');
            Integer count = (Integer)ar.get('cnt');
            
            stats.totalEmployees += count;
            if (status == 'Active') {
                stats.activeEmployees += count;
            } else if (status == 'Inactive') {
                stats.inactiveEmployees += count;
            }
            
            if (dept == 'IT') {
                stats.deptITEmployees += count;
            } else if (dept == 'HR') {
                stats.deptHREmployees += count;
            } else if (dept == 'Finance') {
                stats.deptFinanceEmployees += count;
            } else if (dept == 'Sales') {
                stats.deptSalesEmployees += count;
            }
        }

        // 2. Project stats (grouped by Status)
        stats.totalProjects = 0;
        stats.plannedProjects = 0;
        stats.ongoingProjects = 0;
        stats.completedProjects = 0;

        for (AggregateResult ar : [
            SELECT Status__c, COUNT(Id) cnt 
            FROM Project__c 
            GROUP BY Status__c
        ]) {
            String status = (String)ar.get('Status__c');
            Integer count = (Integer)ar.get('cnt');
            
            stats.totalProjects += count;
            if (status == 'Planned') {
                stats.plannedProjects += count;
            } else if (status == 'Ongoing') {
                stats.ongoingProjects += count;
            } else if (status == 'Completed') {
                stats.completedProjects += count;
            }
        }

        // 3. Assignment count
        stats.totalAssignments = [SELECT COUNT() FROM Assignment__c];

        // 4. Today's Attendance count
        stats.todayAttendance = [SELECT COUNT() FROM Attendance__c WHERE Date__c = TODAY];

        // 5. Leave Request stats (grouped by Status)
        stats.pendingLeaves = 0;
        stats.approvedLeaves = 0;

        for (AggregateResult ar : [
            SELECT Status__c, COUNT(Id) cnt 
            FROM Leave_Request__c 
            GROUP BY Status__c
        ]) {
            String status = (String)ar.get('Status__c');
            Integer count = (Integer)ar.get('cnt');
            
            if (status == 'Pending') {
                stats.pendingLeaves += count;
            } else if (status == 'Approved') {
                stats.approvedLeaves += count;
            }
        }

        return stats;
    }
}
