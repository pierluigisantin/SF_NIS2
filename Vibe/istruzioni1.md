# PROMPT OPERATIVO A FASI — Implementa NIS2 “Accountability & Documentale” (Salesforce metadata)
Agisci come **Salesforce metadata coding agent**. Devi GENERARE file metadata deployabili in un progetto SFDX.
Lavoreremo **a fasi**: esegui **solo la fase che ti chiedo** e fermati, producendo l’output di quella fase (file creati + checklist deploy/test).

---

## Contesto di esecuzione (assumi vero)
- Progetto SFDX con default package dir: `force-app/main/default`
- Org di sviluppo già autenticata con alias: `nis2dev`
- Obiettivo: **solo metadata** (NO Apex, NO package esterni)
- UI: Lightning
- Etichette in ITA; API name in inglese

---

## Regole di output (IMPORTANTISSIME)
1) Crea/modifica i file metadata dentro `force-app/main/default` con path corretti.
2) Usa i nomi **esatti** indicati nelle fasi (API name, DeveloperName, flow names).
3) Alla fine di ogni fase includi:
   - elenco file creati/modificati
   - comando deploy suggerito
   - mini-check UAT della sola fase
4) Se una parte non è implementabile 100% in metadata, segnala il punto e applica il **fallback dichiarativo** previsto (quando la fase lo include).

---

# FASE -1 — Convenzioni di naming e label (standardizza tutto)
## Obiettivo
Definire convenzioni per evitare incoerenze. NON creare metadata, solo applicare queste regole in tutte le fasi successive.

## Convenzioni API Name
- Oggetti custom: `NIS2_<Nome>__c`
- Campi custom: `Snake_Case__c` (es. `ACN_Next_Due_Date__c`)
- Record Types: PascalCase (es. `DPORequest`)
- Flow API Name: prefisso `NIS2_` + descrizione
- Permission Set: suffisso `_PS`

## Convenzioni label ITA (indicative)
- Account RT: **"Ente NIS2"** (label utente), DeveloperName `NIS2_Entity`
- Esempi label: "Categoria NIS2", "Stato qualifica ACN", "Prossima scadenza ACN", "Evidenza obbligatoria"

## Stop condition
Fermati qui.

---

# FASE 0 — Preparazione (solo note, nessun file)
## Deliverable
- Conferma struttura cartelle: `force-app/main/default/{objects,flows,permissionsets,sharingRules,groups,layouts}`
- Se mancano cartelle, creale.

## Stop condition
Alla fine della fase 0, fermati.

---

# FASE 1 — Data model: Account (Profilo Ente)
## Deliverable (file da creare)
### 1.1 Record Type su Account
- Oggetto: Account
- Label: `Ente NIS2`
- DeveloperName: `NIS2_Entity`
Path:
- `objects/Account/recordTypes/NIS2_Entity.recordType-meta.xml`

### 1.2 Campi custom su Account (minimi)
Crea questi fields (label ITA, API name ESATTI):
imposta required solo su RecordType NIS2_Entity
Picklist inline nei campi + etichette come da righe seguenti
1) `NIS_Category__c` (Picklist) REQUIRED  
   Values: `Essential`, `Important`, `ToAssess`

2) `ACN_Qualification_Status__c` (Picklist) REQUIRED  
   Values: `Draft`, `InReview`, `InScope`, `OutOfScope`

3) `Point_of_Contact_User__c` (Lookup(User)) REQUIRED
4) `Deputy_PoC_Contact__c` (Lookup(Contact)) optional
5) `CSIRT_Lead_User__c` (Lookup(User)) REQUIRED
6) `Deputy_CSIRT_Contact__c` (Lookup(Contact)) optional
7) `ACN_Last_Confirmation_Date__c` (Date) optional
8) `ACN_Next_Due_Date__c` (Date) REQUIRED
9) `NIS2_Notes__c` (Long Text Area) optional

Paths:
- `objects/Account/fields/<FieldName>.field-meta.xml`



al termine fai "sf project deploy start --target-org nis2dev" e correggi eventuali errori prima di dire che la fase 1 è finita. adotta questo principio anche per le fasi successive

  Non deployare Account.object-meta.xml. cancellalo se questo file "force-app/main/default/objects/Account/Account.object-meta.xml" è stato generato

attenzione ai metadati per il recordtype
<?xml version="1.0" encoding="UTF-8"?>
<RecordType xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>NIS2_Entity</fullName>
    <label>Ente NIS2</label>
    <description>Record Type per profilo Ente NIS2</description>
    <active>true</active>
</RecordType>


## Stop condition
Alla fine della fase 1, fermati.

---

# FASE 2 — Data model: Custom Object `NIS2_Register__c` (base + record types)
## Deliverable
### 2.1 Oggetto
- Label: `NIS2 Register`
- API: `NIS2_Register__c`
- Record Name: Auto Number `NIS2-{000000}`
Path:
- `objects/NIS2_Register__c/NIS2_Register__c.object-meta.xml`

### 2.2 Record Types (DeveloperName ESATTI)
- `Incident`
- `Measure`
- `Risk`
- `Communication`
- `DPORequest`
- `Decision`
Paths:
- `objects/NIS2_Register__c/recordTypes/<RT>.recordType-meta.xml`

### 2.3 Campo comune
- `Related_Account__c` (Lookup(Account)) REQUIRED
Path:
- `objects/NIS2_Register__c/fields/Related_Account__c.field-meta.xml`


al termine fai "sf project deploy start --target-org nis2dev" e correggi eventuali errori prima di dire che la fase 1 è finita. adotta questo principio anche per le fasi successive
## Stop condition
Alla fine della fase 2, fermati.

---

# FASE 3 — Data model: Campi per record type su `NIS2_Register__c`
## Deliverable
Crea i campi sotto `objects/NIS2_Register__c/fields/` con questi API name ESATTI.

## 3.1 RT = Incident
- `Detected_Channel__c` (Picklist) REQUIRED: Email/Phone/Portal/Manual/Other
- `Aware_At__c` (DateTime) REQUIRED
- `Severity__c` (Picklist) REQUIRED: Low/Med/High/Critical
- `Status__c` (Picklist) REQUIRED: New/Triage/InProgress/Notifying/Resolved/Closed
- `Personal_Data_Involved__c` (Picklist) REQUIRED: Yes/No/ToAssess
- `Regime_NIS2__c` (Checkbox) default true
- `Regime_Parallel__c` (Checkbox) optional
- `Incident_Summary__c` (Long Text Area) REQUIRED
- `Related_Supplier__c` (Lookup(Account)) optional

## 3.2 RT = Measure
- `Measure_Code__c` (Text) optional
- `Measure_Class__c` (Picklist) REQUIRED: Essential/Important/Both
- `Adoption_Status__c` (Picklist) REQUIRED: NotStarted/InProgress/Adopted/NotApplicable
- `Adoption_Date__c` (Date)
- `NotAdopted_Justification__c` (Long Text)
- `Related_Supplier__c` (Lookup(Account)) optional

## 3.3 RT = Risk
- `Risk_Category__c` (Picklist) REQUIRED: Malware/SupplyChain/Access/Other
- `Risk_Impact__c` (Picklist) REQUIRED: Low/Med/High/Critical
- `Risk_Status__c` (Picklist) REQUIRED: Open/Mitigating/Accepted/Closed
- `Risk_Description__c` (Long Text) REQUIRED
- `Related_Measure__c` (Lookup(NIS2_Register__c)) optional

## 3.4 RT = Communication
- `Direction__c` (Picklist) REQUIRED: Inbound/Outbound
- `Channel__c` (Picklist) REQUIRED: Email/PEC/Phone/Portal/Meeting/Other
- `Recipient_Type__c` (Picklist) REQUIRED: ACN/CSIRT/DPO/Supplier/Other
- `Occurred_At__c` (DateTime) REQUIRED
- `Protocol_Number__c` (Text) optional
- `Summary__c` (Long Text) REQUIRED
- `Related_Incident__c` (Lookup(NIS2_Register__c)) optional
- `Related_Measure__c` (Lookup(NIS2_Register__c)) optional
- `Related_Supplier__c` (Lookup(Account)) optional

## 3.5 RT = DPORequest
- `Related_Incident__c` (Lookup(NIS2_Register__c)) REQUIRED
- `DPO_Status__c` (Picklist) REQUIRED: Requested/InReview/Answered/Closed
- `Question__c` (Long Text) REQUIRED
- `Answer__c` (Long Text)
- `DPO_User__c` (Lookup(User)) REQUIRED
- `Answered_At__c` (DateTime)

## 3.6 RT = Decision
- `Decision_Type__c` (Picklist) REQUIRED: Policy/RiskAcceptance/IncidentOversight/Other
- `Approval_Status__c` (Picklist) REQUIRED: Draft/InReview/Approved/Rejected
- `Approver_User__c` (Lookup(User)) REQUIRED
- `Approved_At__c` (DateTime)
- `Approval_Comment__c` (Long Text)
- `Evidence_Required__c` (Checkbox) default true
- `Related_Incident__c` (Lookup(NIS2_Register__c)) optional
- `Related_Measure__c` (Lookup(NIS2_Register__c)) optional


al termine fai "sf project deploy start --target-org nis2dev" e correggi eventuali errori prima di dire che la fase 1 è finita. adotta questo principio anche per le fasi successive

## Stop condition
Alla fine della fase 3, fermati.

---

# FASE 4 — Task e Contact: campi di supporto
## 4.1 Activity: campo categoria (valido per Task + Event)
> Nota: i **custom field** “di attività” non si creano su `Task` ma su **`Activity`** (oggetto base).  
> Il campo sarà visibile su **Task** (e anche su **Event**); se serve solo su Task, nascondilo dai layout di Event.
CREA IL CAMPO SU ACTIVITY!
- `Task_Category__c` (Picklist): `Training` / `Action` / `CallLog` / `Meeting` / `EvidenceRequest`

Path (CORRETTO):
- `objects/Activity/fields/Task_Category__c.field-meta.xml`

## 4.2 Contact: flag membro CdA
- `Is_Board_Member__c` (Checkbox) label ITA: `Membro CdA`
Path:
- `objects/Contact/fields/Is_Board_Member__c.field-meta.xml`

## Stop condition
Alla fine della fase 4, fermati.

---

# FASE 5 — Sicurezza: Group + Permission Sets (+ sharing se separata)
## Deliverable
- Group `NIS2_Core_Team`
- 4 Permission Set (Coordinator/IncidentManager/DPO/BoardApprover)
- (opzionale) sharingRules per `NIS2_Register__c`

## Stop condition
Alla fine della fase 5, fermati.

---

# FASE 6 — Regole: validazioni e vincoli (senza file check)
## Deliverable minimo
1) Measure Adopted => Adoption_Date required  
2) Measure NotApplicable => NotAdopted_Justification required  
3) DPORequest Answered/Closed => Answer + Answered_At required  
4) Decision Rejected => Approval_Comment required  
5) Communication: almeno uno tra Related_Incident/Related_Measure/Related_Supplier required  

## Stop condition
Alla fine della fase 6, fermati.

---

# FASE 7 — Flow automazioni (senza “file obbligatorio”)
## Deliverable
1) `NIS2_ACN_Reminder_Scheduled`
2) `NIS2_Incident_OnCreate`
3) `NIS2_Measure_OnInProgress`
4) `NIS2_Training_Generate`
5) `NIS2_Decision_OnInReview`
6) `NIS2_Decision_SetApprovedAt`

## Stop condition
Alla fine della fase 7, fermati.

---

# FASE 8 — Evidenze “file obbligatorio” (A e fallback B)
## Deliverable
8A: Flow before-save con AddError che verifica ContentDocumentLink  
8B: fallback Quick Action + Screen Flow

## Stop condition
Alla fine della fase 8, fermati.

---

# FASE 9 — Page Layouts (NUOVA)
## Obiettivo
Creare Page Layout specifici per:
- Account RT `NIS2_Entity`
- `NIS2_Register__c` per ogni Record Type (Incident, Measure, Risk, Communication, DPORequest, Decision)
- (opz.) Task layout “Training” (se fattibile via layout) e Contact layout CdA

## Deliverable (metadata in `layouts/`)
### 9.1 Account Layout per Ente NIS2
Crea layout:
- **Label:** `Account Layout - Ente NIS2`
- **API/Layout name:** `Account-Account Layout - Ente NIS2`
Includi sezioni:
1) **Governance e ruoli**
   - NIS_Category__c
   - ACN_Qualification_Status__c
   - Point_of_Contact_User__c / Deputy_PoC_Contact__c
   - CSIRT_Lead_User__c / Deputy_CSIRT_Contact__c
2) **Scadenze**
   - ACN_Last_Confirmation_Date__c
   - ACN_Next_Due_Date__c
3) **Note**
   - NIS2_Notes__c
4) Related Lists (mostra almeno):
   - `NIS2 Registers` (tutte le related list su NIS2_Register__c)
   - `Activities`
   - `Files`

Path:
- `layouts/Account-Account Layout - Ente NIS2.layout-meta.xml`

Assegna layout al Record Type `NIS2_Entity` (via recordType layoutAssignments nell’object metadata se necessario).

### 9.2 Layout `NIS2_Register__c` — Incident
- Label: `NIS2 Register Layout - Incident`
- Layout name: `NIS2_Register__c-NIS2 Register Layout - Incident`
Sezioni:
1) **Dettagli incidente**
   - Related_Account__c
   - Detected_Channel__c
   - Aware_At__c
   - Severity__c
   - Status__c
   - Personal_Data_Involved__c
2) **Regimi**
   - Regime_NIS2__c
   - Regime_Parallel__c
3) **Sintesi**
   - Incident_Summary__c
4) **Relazioni**
   - Related_Supplier__c
5) Related Lists:
   - Activities
   - Files
   - Comunicazioni (filtrabili: per ora almeno related list generale su NIS2_Register__c)

Path:
- `layouts/NIS2_Register__c-NIS2 Register Layout - Incident.layout-meta.xml`

### 9.3 Layout `NIS2_Register__c` — Measure
- Layout name: `NIS2_Register__c-NIS2 Register Layout - Measure`
Sezioni:
- Related_Account__c
- Measure_Code__c
- Measure_Class__c
- Adoption_Status__c
- Adoption_Date__c
- NotAdopted_Justification__c
- Related_Supplier__c
Related Lists: Activities, Files

Path:
- `layouts/NIS2_Register__c-NIS2 Register Layout - Measure.layout-meta.xml`

### 9.4 Layout `NIS2_Register__c` — Risk
- Layout name: `NIS2_Register__c-NIS2 Register Layout - Risk`
Sezioni:
- Related_Account__c
- Risk_Category__c
- Risk_Impact__c
- Risk_Status__c
- Risk_Description__c
- Related_Measure__c
Related Lists: Activities, Files

Path:
- `layouts/NIS2_Register__c-NIS2 Register Layout - Risk.layout-meta.xml`

### 9.5 Layout `NIS2_Register__c` — Communication
- Layout name: `NIS2_Register__c-NIS2 Register Layout - Communication`
Sezioni:
- Related_Account__c
- Direction__c
- Channel__c
- Recipient_Type__c
- Occurred_At__c
- Protocol_Number__c
- Summary__c
- Related_Incident__c / Related_Measure__c / Related_Supplier__c
Related Lists: Files

Path:
- `layouts/NIS2_Register__c-NIS2 Register Layout - Communication.layout-meta.xml`

### 9.6 Layout `NIS2_Register__c` — DPORequest
- Layout name: `NIS2_Register__c-NIS2 Register Layout - DPORequest`
Sezioni:
- Related_Account__c
- Related_Incident__c
- DPO_User__c
- DPO_Status__c
- Question__c
- Answer__c
- Answered_At__c
Related Lists: Files, Activities

Path:
- `layouts/NIS2_Register__c-NIS2 Register Layout - DPORequest.layout-meta.xml`

### 9.7 Layout `NIS2_Register__c` — Decision
- Layout name: `NIS2_Register__c-NIS2 Register Layout - Decision`
Sezioni:
- Related_Account__c
- Decision_Type__c
- Approver_User__c
- Approval_Status__c
- Approved_At__c
- Approval_Comment__c
- Evidence_Required__c
- Related_Incident__c / Related_Measure__c
Related Lists: Files, Activities

Path:
- `layouts/NIS2_Register__c-NIS2 Register Layout - Decision.layout-meta.xml`

### 9.8 Assegnazione layout ai record type
Aggiorna `objects/NIS2_Register__c/NIS2_Register__c.object-meta.xml` (o file dedicati se necessario) per assegnare:
- Incident -> Layout Incident
- Measure -> Layout Measure
- Risk -> Layout Risk
- Communication -> Layout Communication
- DPORequest -> Layout DPORequest
- Decision -> Layout Decision

## Stop condition
Alla fine della fase 9, fermati.

---

# FASE 10 — UI minima (Lightning App / Flexipage) (opzionale)
(come da versione precedente)

---

# FASE 11 — CHECK di deploy e mini-UAT per fase
Dopo ogni fase includi:
- `sf project deploy start --target-org nis2dev`
- elenco file creati
- 3 test rapidi della fase

---

## Come usare questo prompt
Quando ti chiedo “Esegui FASE X”, esegui SOLO quella fase e fermati.
