public with sharing class ProjectService {

    // GET ALL PROJECTS
    public static List<Project__c> getAllProjects() {
        return [
            SELECT Id, Name, Status__c, Start_Date__c, End_Date__c
            FROM Project__c
            ORDER BY CreatedDate DESC
        ];
    }

    // SEARCH PROJECTS
    public static List<Project__c> searchProjects(String key) {

        return [
            SELECT Id, Name, Status__c, Start_Date__c, End_Date__c
            FROM Project__c
            WHERE Name LIKE :('%' + key + '%')
            ORDER BY Name
        ];
    }

    // CREATE / UPDATE PROJECT
    public static void saveProject(Project__c p) {
        upsert p;
    }

    // DELETE PROJECT
    public static void deleteProject(Id projectId) {
        delete [SELECT Id FROM Project__c WHERE Id = :projectId];
    }
}