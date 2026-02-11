@IsTest
public class AccountHandlerTest {

    private static Id getNis2RecordTypeId() {
        Schema.RecordTypeInfo rti =
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NIS2_Entity');
        System.assertNotEquals(
            null, rti,
            'RecordType Account.NIS2_Entity non trovato o non attivo. Crealo/attivalo prima di eseguire i test.'
        );
        return rti.getRecordTypeId();
    }

    @IsTest
    static void testBulkInsert_creaUnContenitorePerAccount_e_valorizzaCampo() {
        Id nis2RtId = getNis2RecordTypeId();

        Integer n = 50;
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < n; i++) {
            accs.add(new Account(Name = 'Bulk NIS2 ' + i, RecordTypeId = nis2RtId));
        }

        Test.startTest();
        insert accs;
        Test.stopTest();

        Set<Id> accIds = new Set<Id>();
        for (Account a : accs) accIds.add(a.Id);

        // Verifico campo valorizzato
        List<Account> reloaded = [
            SELECT Id, NIS2Docs_Punto_di_Contatto__c
            FROM Account
            WHERE Id IN :accIds
        ];
        Set<Id> contenitoreIds = new Set<Id>();
        for (Account a : reloaded) {
            System.assertNotEquals(null, a.NIS2Docs_Punto_di_Contatto__c, 'Ogni account deve avere il campo popolato.');
            contenitoreIds.add(a.NIS2Docs_Punto_di_Contatto__c);
        }

        // Verifico che esistano i contenitori e siano legati all’account giusto
        List<Contenitore_File__c> conts = [
            SELECT Id, Account__c
            FROM Contenitore_File__c
            WHERE Id IN :contenitoreIds
        ];
        System.assertEquals(n, conts.size(), 'Deve creare un contenitore per ciascun Account.');

        Map<Id, Id> contToAcc = new Map<Id, Id>();
        for (Contenitore_File__c c : conts) contToAcc.put(c.Id, c.Account__c);

        for (Account a : reloaded) {
            System.assertEquals(a.Id, contToAcc.get(a.NIS2Docs_Punto_di_Contatto__c),
                'Il contenitore deve avere Account__c = Account.Id');
        }
    }
}
