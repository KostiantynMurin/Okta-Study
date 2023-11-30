/*************************************************************************************************************
 * @name			UpsertUserProcessor
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			10 / 11 / 2023
 * @description		Upsert process
**************************************************************************************************************/
public without sharing class UpsertUserProcessor implements OktaUserProcessorInterface {

    private static final String GENERAL_ACCOUNT = 'General Account';
    private Boolean isGeneralAccountRelated = false;
    
    public void processOktaUser(List<OktaRequestWrapper.Events> eventList) {
        String displayMessage = eventList[0].displayMessage;
        Profile profile = [SELECT Id FROM Profile WHERE Name='Community User' LIMIT 1];
        Map<String, OktaRequestWrapper.Actor> actorByEmaillMap = new Map<String, OktaRequestWrapper.Actor>();
        Set<String> companyDomainSet = new Set<String>();
        for (OktaRequestWrapper.Events event : eventList) {
            for (OktaRequestWrapper.Actor actor : event.target) {
                actorByEmaillMap.put(actor.alternateId, actor);
                companyDomainSet.add(actor.alternateId.split('@').get(1));
            }
        }
        // OktaRequestWrapper.Actor target = event.target[0];
        // String externalId = target.id;
        // String email = target.alternateId;
        //Account account = obtainAccount(email.split('@').get(1));
        Map<String, Account> accontByWebsiteMap = obtainAccounts(companyDomainSet);
        
        // List<Contact> contactList = [
        //     SELECT Id
        //         , FirstName
        //         , LastName
        //         , Email
        //         , AccountId
        //         , Account.Name
        //         , ExternalId__c
        //         , LastOktaEvent__c
        //     FROM Contact 
        //     //WHERE Email = :email
        //     WHERE Email IN :actorByEmaillMap.keySet()
        //     LIMIT 1];

        List<Contact> contactToInsertList = new List<Contact>();
        List<Contact> contactToUpdateList = new List<Contact>();
        List<User> userToInsertList = new List<User>();
        for (Contact contact : [SELECT Id
                                    , FirstName
                                    , LastName
                                    , Email
                                    , AccountId
                                    , Account.Name
                                    , ExternalId__c
                                    , LastOktaEvent__c
                                    , (SELECT Id FROM Users)
                                FROM Contact
                                WHERE Email IN :actorByEmaillMap.keySet()])
        {
            String webSite = contact.Email.split('@').get(1);
            Account contactAccount = contact.AccountId != null && accontByWebsiteMap.containsKey(webSite)
                ? accontByWebsiteMap.get(webSite)
                : accontByWebsiteMap.get(GENERAL_ACCOUNT);
            Boolean needUser = contact.AccountId == null || contactAccount.Name != GENERAL_ACCOUNT;
            updateContact(actorByEmaillMap.get(contact.Email), displayMessage, contact, contactAccount);
            System.debug(' KM ====>  Contact ' + contact.LastOktaEvent__c );
            contactToUpdateList.add(contact);
            if (needUser && contact.Users.isEmpty()) {
                userToInsertList.add(createUser(contact, profile.Id));
            }
            actorByEmaillMap.remove(contact.Email);
            // if (actorByEmaillMap.containsKey(contact.Email)) {
            //     actorByEmaillMap.remove(contact.Email);
            // }
        }
        if (!contactToUpdateList.isEmpty()) {
            Database.update(contactToUpdateList);
        }
        System.debug(' KM ====>   actorByEmaillMap ' + actorByEmaillMap);
        for (OktaRequestWrapper.Actor actor : actorByEmaillMap.values()) {
            String webSite = actor.alternateId.split('@').get(1);
            Account contactAccount = accontByWebsiteMap.containsKey(webSite)
                ? accontByWebsiteMap.get(webSite)
                : accontByWebsiteMap.get(GENERAL_ACCOUNT);
                contactToInsertList.add(createContact(actor, displayMessage, contactAccount.Id));
        }
        if (!contactToInsertList.isEmpty()) {
            Database.insert(contactToInsertList);
            for (Contact contact : contactToInsertList) {
                String webSite = contact.Email.split('@').get(1);
                if (accontByWebsiteMap.containsKey(webSite)) {
                    userToInsertList.add(createUser(contact, profile.Id));
                }
            }
        }
        if (!userToInsertList.isEmpty()) {
            Database.insert(userToInsertList);
        }

        // for (Contact contactToUpdate : contactToUpdateList) {
        //     User userToInsert = updateContact(target, displayMessage, contact, account)
        // }
        

        // if (contactList.isEmpty()) {
        //     createUser(
        //         createContact(target, event.displayMessage, account.Id)
        //     );
        // } else {
        //     updateContact(target, event.displayMessage, contactList[0], account);
        // }
    }

    private Map<String, Account> obtainAccounts(Set<String> companyDomainSet) {
        Map<String, Account> accountByWebsiteMap = new Map<String, Account>();
        for (Account account : [SELECT Id, Name, Website FROM Account WHERE Website IN :companyDomainSet OR Name = :GENERAL_ACCOUNT]) {
            if (account.Name == GENERAL_ACCOUNT) {
                accountByWebsiteMap.put(GENERAL_ACCOUNT, account);
            } else {
                accountByWebsiteMap.put(account.Website, account);
            }
        }
        return accountByWebsiteMap;
    }

    // private Account obtainAccount(String webSite) {
    //     Account searchAccount;
    //     Account generalAccount;
    //     for (Account account : [SELECT Id, Name, Website FROM Account WHERE Website = :webSite OR Name = :GENERAL_ACCOUNT]) {
    //         if (account.Website == webSite) {
    //             searchAccount = account;
    //             break;
    //         }
    //         if (account.Name == GENERAL_ACCOUNT) {
    //             generalAccount = account;
    //         }
    //     }
    //     if (searchAccount != null) {
    //         return searchAccount;
    //     }
    //     this.isGeneralAccountRelated = true;
    //     return generalAccount;
    // }

    private Contact createContact(OktaRequestWrapper.Actor target, String displayMessage, Id accountId) {
        return new Contact(
            AccountId = accountId,
            FirstName = target.displayName.substring(0, target.displayName.indexOf(' ')),
            LastName = target.displayName.substring(target.displayName.indexOf(' '), target.displayName.length()),
            Email = target.alternateId,
            ExternalId__c = target.Id,
            LastOktaEvent__c = displayMessage
        );
        //Database.insert(contact);
        //return contact;
    }

    private User createUser(Contact contact, Id profileId){
        return new User(
            Username = contact.Email,
            FirstName = contact.FirstName,
            LastName = contact.LastName,
            Alias = contact.FirstName.substring(0,2) + contact.LastName.substring(0,2),
            Email = contact.Email,
            ContactId = contact.Id,
            ProfileId = profileId,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            FederationIdentifier = contact.ExternalId__c
        );
    }

    // private void createUser(Contact contact) {
    //     if (this.isGeneralAccountRelated) {
    //         return;
    //     }
    //     Profile profile = [SELECT Id FROM Profile WHERE Name='Community User' LIMIT 1];
    //     User user = new User(
    //         Username = contact.Email,
    //         FirstName = contact.FirstName,
    //         LastName = contact.LastName,
    //         Alias = contact.FirstName.substring(0,2) + contact.LastName.substring(0,2),
    //         Email = contact.Email,
    //         ContactId = contact.Id,
    //         ProfileId = profile.Id,
    //         EmailEncodingKey = 'UTF-8',
    //         TimeZoneSidKey = 'America/Los_Angeles',
    //         LocaleSidKey = 'en_US',
    //         LanguageLocaleKey = 'en_US',
    //         IsActive = true,
    //         FederationIdentifier = contact.ExternalId__c
    //     );
    //     Database.insert(user);
    // }

    // private void updateContact(OktaRequestWrapper.Actor target, String displayMessage, Contact contact, Account account) {
    //     Boolean needUser = contact.AccountId == null && !this.isGeneralAccountRelated || contact.Account.Name != GENERAL_ACCOUNT;
    //     contact.FirstName = target.displayName.substring(0, target.displayName.indexOf(' '));
    //     contact.LastName = target.displayName.substring(target.displayName.indexOf(' '), target.displayName.length());
    //     contact.ExternalId__c = target.Id;
    //     contact.LastOktaEvent__c = displayMessage;
    //     if (String.isBlank(contact.AccountId)) {
    //         contact.AccountId = account.Id;
    //     }
    //     Database.update(contact);
    //     if (needUser) {
    //         checkUser(contact);
    //     }
    // }

    private void updateContact(OktaRequestWrapper.Actor target, String displayMessage, Contact contact, Account account) {
        contact.FirstName = target.displayName.substring(0, target.displayName.indexOf(' '));
        contact.LastName = target.displayName.substring(target.displayName.indexOf(' '), target.displayName.length());
        contact.ExternalId__c = target.Id;
        contact.LastOktaEvent__c = displayMessage;
        if (String.isBlank(contact.AccountId)) {
            contact.AccountId = account.Id;
        }
    }

    // private void checkUser(Contact contact) {
    //     Id userId = [SELECT Id FROM User WHERE ContactId = :contact.Id LIMIT 1]?.Id;
    //     if (userId == null) {
    //         createUser(contact);
    //     }
    // }
}