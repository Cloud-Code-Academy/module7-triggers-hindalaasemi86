trigger OpportunityTrigger on Opportunity (before update, before delete) {
if (Trigger.isUpdate) {
    for (Opportunity opp :Trigger.new) {
        if (opp.Amount != null && opp.Amount <= 5000) {
            opp.addError('Opportunity amount must be greater than 5000');
        }
    }
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : Trigger.old) {
        accountIds.add(opp.AccountId);
    }
    Map<Id, Contact> accountToCEOContactMap = new Map<Id, Contact>();
    List<Contact> ceoContacts = [
        SELECT Id, AccountId, Title 
        FROM Contact 
        WHERE AccountId IN :accountIds AND Title = 'CEO'
    ];

    // Map each Account to its CEO contact
    for (Contact contact : ceoContacts) {
        accountToCEOContactMap.put(contact.AccountId, contact);
    }
    // Loop through each Opportunity and set the Primary Contact to the CEO contact if found
    for (Opportunity opp : Trigger.new) {
        if (accountToCEOContactMap.containsKey(opp.AccountId)) {
            opp.Primary_Contact__c = accountToCEOContactMap.get(opp.AccountId).Id;
        }
    }
}
if (Trigger.isDelete) {
     // Collect account IDs from the opportunities to be deleted
     Set<Id> accountIds = new Set<Id>();
     for (Opportunity opp : Trigger.old) {
         accountIds.add(opp.AccountId);
     }
    
     // Query for the related accounts with industry details
     Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);
 
     for (Opportunity opp : Trigger.old) {
         // Check if the opportunity is Closed Won and the associated account is in the 'Banking' industry
         if (opp.StageName == 'Closed Won' && accountMap.containsKey(opp.AccountId) && accountMap.get(opp.AccountId).Industry == 'Banking') {
             opp.addError('Cannot delete closed opportunity for a banking account that is won');
         }
     }
}
}