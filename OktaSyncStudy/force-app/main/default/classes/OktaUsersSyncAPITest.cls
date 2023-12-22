/*************************************************************************************************************
 * @name			OktaUsersSyncAPITest
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			14 / 11 / 2023
 * @description		Test class for OktaUsersSyncAPI.cls
**************************************************************************************************************/
@isTest
public with sharing class OktaUsersSyncAPITest {

    private static String url = '/services/apexrest/syncUser/*';
    
    @TestSetup
    static void makeData(){
        Account generalAccount = new Account(Name = 'General Account');
        insert generalAccount;
    }

    @isTest
    static void verifyOktaRequestTest() {
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.response = response;
        RestContext.request = request;
        request.httpMethod = 'GET';
        request.requestURI = URL;
        request.addHeader('X-Okta-Verification-Challenge', 'qwe123eeq');
        OktaUsersSyncAPI.verifyOktaRequest();
        String responseString = '{"verification":"qwe123eeq"}';
        Assert.areEqual(responseString, response.responseBody.toString());
    }

    @isTest
    static void createContactTest() {
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'CreateOktaUserJSON' LIMIT 1];
        Account generalAccount = [SELECT Id FROM Account WHERE Name = 'General Account' LIMIT 1];
        String jsonStr = staticResource.body.toString();
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.response = res;
        RestContext.request = request;
        request.httpMethod = 'POST';
        request.requestURI = URL;
        request.requestBody = Blob.valueof(jsonStr);
        OktaUsersSyncAPI.processUser();
        Test.stopTest();
        Contact contact = [SELECT Id, AccountId, LastOktaEvent__c FROM Contact LIMIT 1];
        Assert.isTrue(contact.AccountId == generalAccount.Id, 'Contact should be assigned to General Account');
        Id userId = [SELECT Id FROM User WHERE ContactId = :contact.Id]?.Id;
        Assert.isNull(userId, 'User should not created when Contact accout is "General Account"');
    }

    @isTest
    static void createContactWithUserTest() {
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'CreateOktaUserJSON' LIMIT 1];
        Account testCompanyAccount = new Account(Name = 'Test Company', Website = 'test.io');
        insert testCompanyAccount;
        String jsonStr = staticResource.body.toString();
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.response = res;
        RestContext.request = request;
        request.httpMethod = 'POST';
        request.requestURI = URL;
        request.requestBody = Blob.valueof(jsonStr);
        OktaUsersSyncAPI.processUser();
        Test.stopTest();
        Contact contact = [SELECT Id, AccountId, LastOktaEvent__c FROM Contact LIMIT 1];
        Assert.isTrue(contact.AccountId == testCompanyAccount.Id, 'Contact should be assigned to Test Company Account');
        Id userId = [SELECT Id FROM User WHERE ContactId = :contact.Id]?.Id;
        Assert.isNotNull(userId, 'User should be created when Contact accout is not "General Account"');
    }

    @isTest
    static void updateContactWithUserTest() {
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'UpdateOktaUserJSON' LIMIT 1];
        Account testCompanyAccount = new Account(Name = 'Test Company', Website = 'test.io');
        insert testCompanyAccount;
        Contact contact = new Contact(
            AccountId = testCompanyAccount.Id,
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.io'
        );
        insert contact;
        String jsonStr = staticResource.body.toString();
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.response = res;
        RestContext.request = request;
        request.httpMethod = 'POST';
        request.requestURI = URL;
        request.requestBody = Blob.valueof(jsonStr);
        OktaUsersSyncAPI.processUser();
        Test.stopTest();
        Contact updatedContact = [SELECT Id, AccountId, LastOktaEvent__c FROM Contact LIMIT 1];
        Assert.isTrue(updatedContact.AccountId == testCompanyAccount.Id, 'Contact should be assigned to Test Company Account');
        Assert.areEqual('Update Okta User', updatedContact.LastOktaEvent__c, 'Last Okta event shold be equal to "Update Okta User"');
        Id userId = [SELECT Id FROM User WHERE ContactId = :updatedContact.Id]?.Id;
        Assert.isNotNull(userId, 'User should be created when Contact accout is not "General Account"');
    }

    @isTest
    static void updateContactWithoutUserTest() {
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'UpdateOktaUserJSON' LIMIT 1];
        Account generalAccount = [SELECT Id FROM Account WHERE Name = 'General Account' LIMIT 1];
        Contact contact = new Contact(
            AccountId = generalAccount.Id,
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.io'
        );
        insert contact;
        String jsonStr = staticResource.body.toString();
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.response = res;
        RestContext.request = request;
        request.httpMethod = 'POST';
        request.requestURI = URL;
        request.requestBody = Blob.valueof(jsonStr);
        OktaUsersSyncAPI.processUser();
        Test.stopTest();
        Contact updatedContact = [SELECT Id, AccountId, LastOktaEvent__c FROM Contact LIMIT 1];
        Assert.isTrue(updatedContact.AccountId == generalAccount.Id, 'Contact should be assigned to Test Company Account');
        Assert.areEqual('Update Okta User', updatedContact.LastOktaEvent__c, 'Last Okta event shold be equal to "Update Okta User"');
        Id userId = [SELECT Id FROM User WHERE ContactId = :updatedContact.Id]?.Id;
        Assert.isNull(userId, 'User should not be created when Contact accout is "General Account"');
    }

    @isTest
    static void deactivateUserTest() {
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'DeactivateOktaUserJSON' LIMIT 1];
        String jsonStr = staticResource.body.toString();
        Account generalAccount = [SELECT Id FROM Account WHERE Name = 'General Account' LIMIT 1];
        Profile profile = [SELECT Id FROM Profile WHERE Name='Community User' LIMIT 1];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Contact contact = new Contact(
                AccountId = generalAccount.Id,
                FirstName = 'John',
                LastName = 'Doe',
                Email = 'john.doe@test.io'
            );
            insert contact;
            User user = new User(
                Username = contact.Email,
                FirstName = contact.FirstName,
                LastName = contact.LastName,
                Alias = contact.FirstName.substring(0,2) + contact.LastName.substring(0,2),
                Email = contact.Email,
                ContactId = contact.Id,
                ProfileId = profile.Id,
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                IsActive = true,
                FederationIdentifier = contact.ExternalId__c
            );
            Database.insert(user);
        }
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.response = response;
        RestContext.request = request;
        request.httpMethod = 'POST';
        request.requestURI = URL;
        request.requestBody = Blob.valueof(jsonStr);
        OktaUsersSyncAPI.processUser();
        Test.stopTest();
        Contact updatedContact = [SELECT Id, AccountId, LastOktaEvent__c FROM Contact LIMIT 1];
        Assert.areEqual('Deactivate Okta User', updatedContact.LastOktaEvent__c);
        User deactivatedUser = [SELECT Id, IsActive FROM User WHERE ContactId = :updatedContact.Id LIMIT 1];
        Assert.isFalse(deactivatedUser.IsActive, 'User should be deactivated');
    }
}