public class AccountHandler {
    private static Boolean isRunning = false;

    public static void handleAfter(List<Account> newAccounts) {
        if (isRunning) return;
        isRunning = true;

        // RecordTypeId senza SOQL (più efficiente e sicuro)
        Id nis2EntityRecordTypeId =
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('NIS2_Entity')?.getRecordTypeId();

        if (nis2EntityRecordTypeId == null) {
            isRunning = false;
            return;
        }

        List<Contenitore_File__c> contenitoriToInsert = new List<Contenitore_File__c>();
        Map<Id, Contenitore_File__c> accountToContenitore = new Map<Id, Contenitore_File__c>();

        for (Account acc : newAccounts) {
            if (acc.RecordTypeId == nis2EntityRecordTypeId &&
                (acc.NIS2Docs_Punto_di_Contatto__c == null ||
                 acc.NIS2Docs_Referente_CSIRT__c == null ||
                 acc.NIS2Docs_Storyboard_Organization__c == null)) {

                Contenitore_File__c c = new Contenitore_File__c(Account__c = acc.Id);
                contenitoriToInsert.add(c);
                accountToContenitore.put(acc.Id, c);
            }
        }

        if (contenitoriToInsert.isEmpty()) {
            isRunning = false;
            return;
        }

        insert contenitoriToInsert;

        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : newAccounts) {
            Contenitore_File__c c = accountToContenitore.get(acc.Id);
            if (c == null) continue;

            Account upd = new Account(Id = acc.Id);

            // Se vuoi SOLO il primo campo nullo, usa else-if come facevi tu.
            if (acc.NIS2Docs_Punto_di_Contatto__c == null)       upd.NIS2Docs_Punto_di_Contatto__c = c.Id;
            if (acc.NIS2Docs_Referente_CSIRT__c == null)         upd.NIS2Docs_Referente_CSIRT__c = c.Id;
            if (acc.NIS2Docs_Storyboard_Organization__c == null) upd.NIS2Docs_Storyboard_Organization__c = c.Id;

            accountsToUpdate.add(upd);
        }

        if (!accountsToUpdate.isEmpty()) update accountsToUpdate;

        isRunning = false;
    }
}
