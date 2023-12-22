/*************************************************************************************************************
 * @name			DeactivateUserProcessor
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			10 / 11 / 2023
 * @description		Deactivation process
**************************************************************************************************************/
public with sharing class DeactivateUserProcessor implements OktaUserProcessorInterface {
    public void processOktaUser(List<OktaRequestWrapper.Events> eventList) {
        String displayMessage = eventList[0].displayMessage;
        Set<String> contactEmailSet = new Set<String>();
        for (OktaRequestWrapper.Events event : eventList) {
            for (OktaRequestWrapper.Actor actor : event.target) {
                System.debug(' KM ====>  event target ' + event.target);
                contactEmailSet.add(actor.alternateId);
                // actorByEmaillMap.put(actor.alternateId, actor);
                // companyDomainSet.add(actor.alternateId.split('@').get(1));
            }
        }
        List<User> userToUpdateList = new List<User>();
        List<Contact> contactToUpdateList = new List<Contact>();
System.debug(' KM ====>  contactEmailSet ' + contactEmailSet);
        for (User communityUser : [SELECT Id
                                    , IsActive
                                    , IsPortalEnabled
                                    , ContactId
                                   FROM User
                                   WHERE Contact.Email IN :contactEmailSet
                                    AND Profile.Name = 'Community User'
                                    WITH SECURITY_ENFORCED])
        {
            System.debug(' KM ====>  communityUser ' + communityUser);
            if (communityUser.IsActive || communityUser.IsPortalEnabled) {
                communityUser.IsActive = false;
                communityUser.IsPortalEnabled = false;
                userToUpdateList.add(communityUser);
                contactToUpdateList.add(new Contact(
                    Id = communityUser.ContactId,
                    LastOktaEvent__c = displayMessage
                ));
            }
        }
        System.debug(' KM ====>   userToUpdateList' + userToUpdateList);
        if (!userToUpdateList.isEmpty()) {
            
            Database.update(userToUpdateList);
        }
        updateContacts(JSON.serialize(contactToUpdateList));
    }

    
    private static void updateContacts(String contactToUpdateListJSON) {
        List<Contact> contactToUpdateList = (List<Contact>) JSON.deserialize(contactToUpdateListJSON, List<Contact>.class);
        System.debug(' KM ====>   contactToUpdateList' + contactToUpdateList);
        if (!contactToUpdateList.isEmpty()) {
            
            Database.update(contactToUpdateList);
        }
    }
    
    // public void processOktaUser(OktaRequestWrapper.Events event) {
    //     OktaRequestWrapper.Actor target = event.target[0];
    //     List<User> communityUserList = [
    //         SELECT Id
    //             , IsActive
    //             , IsPortalEnabled
    //             , ContactId
    //         FROM User 
    //         WHERE Contact.Email = :target.alternateId 
    //             AND Profile.Name = 'Community User' 
    //         LIMIT 1];
    //     if (communityUserList.isEmpty()) {
    //         return;
    //     }
    //     User communityUser = communityUserList[0];
    //     if (communityUser.IsActive || communityUser.IsPortalEnabled) {
    //         communityUser.IsActive = false;
    //         communityUser.IsPortalEnabled = false;
    //         Database.update(communityUser);
    //         updateContact(communityUser.ContactId, event.displayMessage);
    //     } 
    // }

    // @future
    // private static void updateContact(Id contactId,String lastOktaEvent) {
    //     Contact contactToUpdate = new Contact(
    //         Id = contactId,
    //         LastOktaEvent__c = lastOktaEvent
    //     );
    //     Database.update(contactToUpdate);
    // }
}