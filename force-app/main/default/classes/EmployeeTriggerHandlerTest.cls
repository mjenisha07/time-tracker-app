@isTest
public class EmployeeTriggerHandlerTest {

    @testSetup
    static void setupData() {
        // Create necessary test data
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create dummy employee records
        List<Employee__c> empList = new List<Employee__c>();

        for (Integer i = 1; i <= 5; i++) {
            empList.add(new Employee__c(
                First_Name__c = 'TestFirst' + i,
                Last_Name__c = 'LastName' + i,
                Email__c = 'testuser' + i + '@test.com',
                Role__c = (i / 2 == 0) ? 'Manager' : 'Employee',
                Is_Active__c = true
            ));
        }
        insert empList;
    }

    @isTest
    static void testCreateUsersForEmployees() {
        // Fetch employees inserted in testSetup
        List<Employee__c> employees = [SELECT Id, First_Name__c, Last_Name__c, Email__c, Role__c,Is_Active__c FROM Employee__c WHERE Is_Active__c = TRUE];

        Test.startTest();
        EmplopyeeTriggerHandler.createUsersForEmployees(employees);
        Test.stopTest();

        // Re-fetch employee records
        List<Employee__c> updatedEmployees = [SELECT Id, UserID__c FROM Employee__c WHERE UserID__c != NULL];
        System.assertEquals(5, updatedEmployees.size(), 'Five employees should be updated with User IDs');

        // Check if users are created
        List<User> createdUsers = [SELECT Id, FirstName, LastName, Username, Email FROM User WHERE Email LIKE 'testuser%@test.com'];
        System.assertEquals(5, createdUsers.size(), 'Five User records should be created');
    }

}