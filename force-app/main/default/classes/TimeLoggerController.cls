public with sharing class TimeLoggerController {

    @AuraEnabled(cacheable=true)
    public static List<Project__c> getAssignedProjects() {
        try {
            // Get the current user's Employee record
            List<Employee__c> empList = [
                SELECT Id FROM Employee__c 
                WHERE UserID__c = :UserInfo.getUserId() 
                LIMIT 1
            ];

            if (empList.isEmpty()) return new List<Project__c>();
            Id empId = empList[0].Id;

            // Fetch assigned projects via Project_Assignment__c
            List<Project_Assignment__c> assignments = [
                SELECT Project__r.Id, Project__r.Name 
                FROM Project_Assignment__c 
                WHERE Employee__c = :empId
            ];

            List<Project__c> projectList = new List<Project__c>();
            for (Project_Assignment__c pa : assignments) {
                if (pa.Project__r != null) {
                    projectList.add(pa.Project__r);
                }
            }

            return projectList;

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching assigned projects: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createTimeLog(Id projectId, String startTime, String endTime, String comment) {
        try {
            List<Employee__c> empList = [
                SELECT Id 
                FROM Employee__c 
                WHERE UserID__c = :UserInfo.getUserId() 
                LIMIT 1
            ];

            if (empList.isEmpty()) {
                throw new AuraHandledException('No matching Employee record found.');
            }


            Time_Log__c log = new Time_Log__c(
                Employee__c = empList[0].Id,
                Project__c = projectId,
                Log_Date__c = Date.today(),
                Start_Time__c = convertToDateTime(startTime),
                End_Time__c = convertToDateTime(endTime),        
                Description__c = comment
            );

            insert log;

        } catch (Exception e) {
            throw new AuraHandledException('Error creating time log: ' + e.getMessage());
        }
    }

    private static Datetime convertToDateTime(String timeStr) {
        List<String> parts = timeStr.split(':');
        Integer hour = Integer.valueOf(parts[0]);
        Integer minute = Integer.valueOf(parts[1]);
        return Datetime.newInstance(Date.today(), Time.newInstance(hour, minute, 0, 0));
    }
    
    
}