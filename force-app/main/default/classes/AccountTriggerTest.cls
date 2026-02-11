@IsTest
public class AccountTriggerTest {

    private static Id getNis2RecordTypeId() {
        Schema.RecordTypeInfo rti =
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NIS2_Entity');
        System.assertNotEquals(
            null, rti,
            'RecordType Account.NIS2_Entity non trovato o non attivo. Crealo/attivalo prima di eseguire i test.'
        );
        return rti.getRecordTypeId();
    }

    private static List<Contenitore_File__c> createContenitori(Id accountId, Integer count) {
        List<Contenitore_File__c> res = new List<Contenitore_File__c>();
        for (Integer i = 0; i < count; i++) {
            res.add(new Contenitore_File__c(Account__c = accountId));
        }
        insert res;
        return res;
    }

    @IsTest
    static void testInsert_creaContenitore_e_valorizzaPrimoCampoNullo() {
        Id nis2RtId = getNis2RecordTypeId();

        Account a = new Account(
            Name = 'Test Insert NIS2',
            RecordTypeId = nis2RtId
            // i 3 campi lasciati null
        );

        Test.startTest();
        insert a;
        Test.stopTest();

        Account reloaded = [
            SELECT Id,
                   NIS2Docs_Punto_di_Contatto__c,
                   NIS2Docs_Referente_CSIRT__c,
                   NIS2Docs_Storyboard_Organization__c
            FROM Account
            WHERE Id = :a.Id
        ];

        System.assertNotEquals(
            null, reloaded.NIS2Docs_Punto_di_Contatto__c,
            'Su insert deve valorizzare almeno il primo campo nullo (Punto di Contatto).'
        );

        List<Contenitore_File__c> conts = [
            SELECT Id, Account__c
            FROM Contenitore_File__c
            WHERE Account__c = :a.Id
        ];
        System.assertEquals(1, conts.size(), 'Su insert deve creare 1 solo Contenitore_File__c per l’Account.');
        System.assertEquals(reloaded.NIS2Docs_Punto_di_Contatto__c, conts[0].Id, 'Il lookup deve puntare al contenitore creato.');
    }

    @IsTest
    static void testUpdate_nonCreaContenitoriSeTuttiICampiSonoValorizzati() {
        Id nis2RtId = getNis2RecordTypeId();

        // Insert (trigger potrebbe creare 1 contenitore e valorizzare il primo campo)
        Account a = new Account(Name = 'Test No Create', RecordTypeId = nis2RtId);
        insert a;

        // Completo gli altri due campi con contenitori creati ad hoc
        List<Contenitore_File__c> extra = createContenitori(a.Id, 2);

        // Ricarico Account per prendere il valore del primo campo assegnato dal trigger
        Account reloaded = [
            SELECT Id,
                   NIS2Docs_Punto_di_Contatto__c,
                   NIS2Docs_Referente_CSIRT__c,
                   NIS2Docs_Storyboard_Organization__c
            FROM Account
            WHERE Id = :a.Id
        ];

        // Valorizzo tutti i campi
        reloaded.NIS2Docs_Referente_CSIRT__c = extra[0].Id;
        reloaded.NIS2Docs_Storyboard_Organization__c = extra[1].Id;
        update reloaded;

        Integer countBefore = [
            SELECT COUNT()
            FROM Contenitore_File__c
            WHERE Account__c = :a.Id
        ];

        // Update "innocuo" (scatena after update) ma non deve creare nuovi contenitori
        Account upd = new Account(Id = a.Id, Name = 'Test No Create - Updated');
        Test.startTest();
        update upd;
        Test.stopTest();

        Integer countAfter = [
            SELECT COUNT()
            FROM Contenitore_File__c
            WHERE Account__c = :a.Id
        ];
        System.assertEquals(countBefore, countAfter, 'Non deve creare nuovi contenitori se i 3 campi sono già valorizzati.');

        Account finalAcc = [
            SELECT Id,
                   NIS2Docs_Punto_di_Contatto__c,
                   NIS2Docs_Referente_CSIRT__c,
                   NIS2Docs_Storyboard_Organization__c
            FROM Account
            WHERE Id = :a.Id
        ];
        System.assertNotEquals(null, finalAcc.NIS2Docs_Punto_di_Contatto__c);
        System.assertNotEquals(null, finalAcc.NIS2Docs_Referente_CSIRT__c);
        System.assertNotEquals(null, finalAcc.NIS2Docs_Storyboard_Organization__c);
    }

    @IsTest
    static void testUpdate_quandoUnCampoDiventaNull_creaNuovoContenitore_e_loAssegna() {
        Id nis2RtId = getNis2RecordTypeId();

        // Insert (trigger potrebbe creare 1 contenitore)
        Account a = new Account(Name = 'Test Create On Update', RecordTypeId = nis2RtId);
        insert a;

        // Creo altri 2 contenitori e valorizzo i campi mancanti
        List<Contenitore_File__c> extra = createContenitori(a.Id, 2);

        Account baseAcc = [
            SELECT Id,
                   NIS2Docs_Punto_di_Contatto__c,
                   NIS2Docs_Referente_CSIRT__c,
                   NIS2Docs_Storyboard_Organization__c
            FROM Account
            WHERE Id = :a.Id
        ];
        baseAcc.NIS2Docs_Referente_CSIRT__c = extra[0].Id;
        baseAcc.NIS2Docs_Storyboard_Organization__c = extra[1].Id;
        update baseAcc;

        // Baseline contenitori
        List<Contenitore_File__c> beforeConts = [
            SELECT Id
            FROM Contenitore_File__c
            WHERE Account__c = :a.Id
        ];
        Integer countBefore = beforeConts.size();
        Set<Id> oldIds = new Set<Id>();
        for (Contenitore_File__c c : beforeConts) oldIds.add(c.Id);

        // Rendo NULL un campo e faccio update: deve creare un nuovo contenitore e assegnarlo
        Account makeNull = new Account(Id = a.Id, NIS2Docs_Referente_CSIRT__c = null);

        Test.startTest();
        update makeNull;
        Test.stopTest();

        Account afterAcc = [
            SELECT Id, NIS2Docs_Referente_CSIRT__c
            FROM Account
            WHERE Id = :a.Id
        ];
        System.assertNotEquals(null, afterAcc.NIS2Docs_Referente_CSIRT__c, 'Il campo nullo deve essere riassegnato.');

        Integer countAfter = [
            SELECT COUNT()
            FROM Contenitore_File__c
            WHERE Account__c = :a.Id
        ];
        System.assertEquals(countBefore + 1, countAfter, 'Su update deve creare 1 nuovo contenitore.');

        System.assertEquals(false, oldIds.contains(afterAcc.NIS2Docs_Referente_CSIRT__c),
            'Il valore assegnato deve essere l’Id di un nuovo contenitore.');
    }
}
