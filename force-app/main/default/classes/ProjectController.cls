public with sharing class ProjectController {

    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProjects() {
        return ProjectService.getAllProjects();
    }

    @AuraEnabled(cacheable=true)
    public static List<Project__c> searchProjects(String key) {
        return ProjectService.searchProjects(key);
    }

    @AuraEnabled
    public static void saveProject(Project__c p) {
        ProjectService.saveProject(p);
    }

    @AuraEnabled
    public static void deleteProject(Id projectId) {
        ProjectService.deleteProject(projectId);
    }
}