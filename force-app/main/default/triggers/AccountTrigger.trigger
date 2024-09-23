trigger AccountTrigger on Account (before insert , after insert) {
   
    if (Trigger.isBefore) {
    for (Account acc : Trigger.new) {
        if (acc.Type == null) {
            acc.Type = 'Prospect';
        }
        if (acc.ShippingStreet != null || acc.ShippingCity != null || acc.ShippingState != null || acc.ShippingPostalCode != null || acc.ShippingCountry != null) {
            acc.BillingCity =acc.ShippingCity;
            acc.BillingCountry =acc.ShippingCountry;
            acc.BillingStreet=acc.ShippingStreet;
            acc.BillingState=acc.ShippingState;
            acc.BillingPostalCode=acc.ShippingPostalCode;
        }
        if (acc.Phone != null || acc.Website != null || acc.Fax !=null) {
            acc.Rating ='Hot';
        }
    }
}
        // After Insert Logic: Create a Contact for the new Accounts
    if (Trigger.isAfter) {
        List<Contact> contactsToInsert = new List<Contact>();
        // Create a new Contact with the default values and associate it with the Account
        for (Account acc : Trigger.new) {
            Contact defaultContact = new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = acc.Id
            );
            contactsToInsert.add(defaultContact);
        }

        // Insert the new Contacts
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}