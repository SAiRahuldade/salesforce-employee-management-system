@isTest
public class ProjectControllerTest {

    @testSetup
    static void setup() {
        List<Project__c> testProjects = new List<Project__c>();
        testProjects.add(new Project__c(
            Name = 'Alpha Project',
            Status__c = 'Ongoing',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30)
        ));
        testProjects.add(new Project__c(
            Name = 'Beta Project',
            Status__c = 'Planned',
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(60)
        ));
        insert testProjects;
    }

    @isTest
    static void testGetProjects() {
        Test.startTest();
        List<Project__c> result = ProjectController.getProjects();
        Test.stopTest();

        Assert.areEqual(2, result.size(), 'Should return 2 projects');
    }

    @isTest
    static void testSearchProjects() {
        Test.startTest();
        List<Project__c> searchResultAll = ProjectController.searchProjects('');
        List<Project__c> searchResultFiltered = ProjectController.searchProjects('Alpha');
        Test.stopTest();

        Assert.areEqual(2, searchResultAll.size(), 'Empty search term should return all projects');
        Assert.areEqual(1, searchResultFiltered.size(), 'Search for Alpha should return 1 project');
        Assert.areEqual('Alpha Project', searchResultFiltered[0].Name);
    }

    @isTest
    static void testSaveProject() {
        Project__c newProj = new Project__c(
            Name = 'Gamma Project',
            Status__c = 'Planned',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(90)
        );

        Test.startTest();
        ProjectController.saveProject(newProj);
        Test.stopTest();

        List<Project__c> projects = [SELECT Id FROM Project__c WHERE Name = 'Gamma Project'];
        Assert.areEqual(1, projects.size(), 'Gamma Project should have been inserted');
    }

    @isTest
    static void testDeleteProject() {
        Project__c beta = [SELECT Id FROM Project__c WHERE Name = 'Beta Project' LIMIT 1];

        Test.startTest();
        ProjectController.deleteProject(beta.Id);
        Test.stopTest();

        List<Project__c> projects = [SELECT Id FROM Project__c WHERE Id = :beta.Id];
        Assert.areEqual(0, projects.size(), 'Beta Project should have been deleted');
    }
}
