public with sharing class EmplopyeeTriggerHandler {
    public EmplopyeeTriggerHandler() {}
    

    public static void createUsersForEmployees(List<Employee__c> employeeList){

        List<User> userList = new List<User>();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];

        for(Employee__c emp : employeeList){
            User newUser = new User();
            newUser.FirstName = emp.First_Name__c;
            newUser.LastName = emp.Last_Name__c;
            newUser.Email = emp.Email__c;
            newUser.IsActive = emp.Is_Active__c;
            String alias = (emp.First_Name__c.substring(0,1) + emp.Last_Name__c.substring(0, Math.min(5, emp.Last_Name__c.length()))).toLowerCase();
            newUser.Alias = alias;
            //newUser.Username = emp.Email__c;
            newUser.Username = emp.Email__c.replace('@', '.' + String.valueOf(Datetime.now().getTime()) + '@');

            newUser.TimeZoneSidKey = 'Asia/Kolkata';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.ProfileId = profile.Id;
            userList.add(newUser);

        }

        if(!userList.isEmpty()){
            insert userList;
        
            // Send email with Login Info to users created
            List<Messaging.SingleEmailMessage> welcomeEmails = new List<Messaging.SingleEmailMessage>();
        
            for (User u : userList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { u.Email });
                mail.setSubject('Welcome to Time Tracking App');
                mail.setPlainTextBody(
                    'Hi ' + u.FirstName + ',\n\n' +
                    'Your Salesforce account has been created.\n' +
                    'Username: ' + u.Username + '\n\n' +
                    'Please check your email for login instructions.\n\n' +
                    'Regards,\nAdmin'
                );
                welcomeEmails.add(mail);
            }
            Messaging.sendEmail(welcomeEmails);
        }
        


        //Update Employee with User ID
        List<Employee__c> toUpdate = new List<Employee__c>();
        for (Integer i = 0; i < userList.size(); i++) {
            Employee__c emp = employeeList[i];
            emp.UserID__c = userList[i].Id;
            toUpdate.add(emp);
        }
        update toUpdate;

    }
}