@isTest
public class TimeLoggerControllerTest {

    @isTest
    static void testGetAssignedProjects() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create user
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser001@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User001',
            FirstName = 'Test001',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'testuser_' + System.currentTimeMillis() + '@example.com'
        );
        insert testUser;

        System.runAs(testUser) {
            // Insert Employee linked to current user
            Employee__c emp = new Employee__c(
                First_Name__c = 'Test001',
                Last_Name__c = 'User001',
                Email__c = 'testuser001@example.com',
                Role__c = 'Employee',
                Is_Active__c = true,
                UserID__c = UserInfo.getUserId()
            );
            insert emp;

            // Create project
            Project__c proj = new Project__c(Name = 'Test Project', Start_Date__c = Date.today());
            insert proj;

            // Assign employee to project
            Project_Assignment__c assignment = new Project_Assignment__c(
                Employee__c = emp.Id,
                Project__c = proj.Id
            );
            insert assignment;

            // Test the method
            List<Project__c> projects = TimeLoggerController.getAssignedProjects();
            System.assertNotEquals(null, projects, 'Project list should not be null');
            System.assertEquals(1, projects.size(), 'One assigned project expected');
        }
    }

    @isTest
    static void testCreateTimeLog() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser002@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User002',
            FirstName = 'Test002',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'testuser_' + System.currentTimeMillis() + '@example.com'
        );
        insert testUser;

        System.runAs(testUser) {
            Employee__c emp = new Employee__c(
                First_Name__c = 'Test002',
                Last_Name__c = 'User002',
                Email__c = 'testuser002@example.com',
                Role__c = 'Employee',
                Is_Active__c = true,
                UserID__c = UserInfo.getUserId()
            );
            insert emp;

            Project__c proj = new Project__c(Name = 'Test Project 2', Start_Date__c = Date.today());
            insert proj;

            Project_Assignment__c assignment = new Project_Assignment__c(
                Employee__c = emp.Id,
                Project__c = proj.Id
            );
            insert assignment;

            String starttime = '09:00';
            String endtime = '13:00';
            String comment = 'Worked on testing';

            Test.startTest();
            TimeLoggerController.createTimeLog(proj.Id, starttime, endtime, comment);
            Test.stopTest();

            List<Time_Log__c> logs = [SELECT Id, Description__c FROM Time_Log__c];
            System.assertEquals(1, logs.size(), 'Time log should be inserted');
            System.assertEquals('Worked on testing', logs[0].Description__c);
        }
    }
}