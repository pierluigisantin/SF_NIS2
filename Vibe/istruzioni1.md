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
5) ricordati di tenetere aggiornato package.xml

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

Crea anche un record Type "Azienda" sempre su account per registrare le aziende che hanno rapporti con l'azienda principale che ha record type `NIS2_Entity`

NON FARE CAMPI CUSTOM REQUIRED SU NIS2_Entity. Il fatto che un campo sia required su un particolare Record Type di NIS2_Entity deve essere gestito come validation rule

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
# FASE 4bis — Page Layout (Lightning) per NIS2 (prompt per Vibe Coding)

> Obiettivo: creare **Page Layout** completi per l’oggetto `NIS2_Register__c` (per ogni Record Type) e aggiornare il Page Layout di `Account` (RT `NIS2_Entity`) e `Contact` (campi CdA), in modo che gli utenti con licenza possano lavorare subito senza configurazioni manuali.

## Regole e vincoli (OBBLIGATORIO)
- NON creare Flexipage / Lightning Record Pages in questa fase: solo **Page Layout** e **Layout Assignment**.
- I layout devono essere creati come metadata in:
  - `force-app/main/default/layouts/`
- Nomi API layout (obbligatori e stabili):
  - `NIS2_Register__c-NIS2 Incident Layout`
  - `NIS2_Register__c-NIS2 Measure Layout`
  - `NIS2_Register__c-NIS2 Risk Layout`
  - `NIS2_Register__c-NIS2 Communication Layout`
  - `NIS2_Register__c-NIS2 DPO Request Layout`
  - `NIS2_Register__c-NIS2 Decision Layout`
  - `Account-NIS2 Entity Layout`
  - `Contact-NIS2 Contact Layout`
- Ogni layout deve includere:
  - sezioni, campi, related lists, pulsanti principali
  - **Description** della sezione (se supportata) o naming chiaro della section
- Non usare riferimenti a package.xml.
- Non usare campi che non esistono: se un campo non esiste, creare un TODO comment nel prompt (non inventare metadata).
- I layout devono essere coerenti con “3 licenze (assetto solido)”:
  - i 3 utenti lavorano principalmente su Account (Ente), NIS2_Register__c e Task
  - gli altri attori sono Contact e NON entrano in Salesforce (tranne 1 membro CdA licenziato, già gestito in fase licenze)

## Definition of Done (DoD) (OBBLIGATORIO)
Un layout è considerato completato solo se:
- contiene almeno 4 sezioni (“Header”, “Dati principali”, “Workflow / Compliance”, “Documentazione & Attività”)
- contiene almeno 1 related list utile (Task, Files, Notes, ecc.)
- espone i campi chiave del record type specifico
- include i pulsanti standard essenziali (Edit, Delete, Clone se utile)
- è assegnato al Record Type corretto (Layout Assignment)

---

# 4bis.1 Layout per `NIS2_Register__c` (6 Record Types)

## Campi comuni (mettere su TUTTI i layout)
Sezione: **Header**
- `Name` (AutoNumber o Name)
- `RecordTypeId` (solo se utile, altrimenti ometti)

Sezione: **Dati principali**
- `Related_Account__c` (lookup ad Account/Ente)
- `Status__c` (picklist)
- `Severity__c` (picklist) se presente su tutti (se no: solo Incident/Risk)
- `Summary__c` (text/textarea)

Sezione: **Workflow / Compliance**
- `Approver_User__c` (solo Decision)
- `Approval_Status__c` (solo Decision)
- `Approved_At__c` (solo Decision)
- `Adoption_Status__c` (solo Measure)
- `Adoption_Date__c` (solo Measure)
- `NotAdopted_Justification__c` (solo Measure)
- `Risk_Description__c` / `Risk_Impact__c` / `Risk_Status__c` (solo Risk)
- Campi notifica/tempi incidente (solo Incident)

Sezione: **Documentazione & Attività**
- Related List: **Files** (ContentDocumentLink)
- Related List: **Activities** (Task) / Open Activities / Activity History
- Related List: Notes (se disponibile)

> Se un campo non esiste nel progetto, NON inserirlo: aggiungi un TODO nel prompt e lascia il layout con i campi disponibili.

---

## 4bis.1.a `NIS2_Register__c-NIS2 Incident Layout`
Sezioni:
1) Header
2) Dati Incidente
3) Notifiche & Timeline
4) Documentazione & Attività

Campi specifici (se esistono):
- `Detected_Channel__c`
- `Aware_At__c`
- `Incident_Summary__c`
- `Personal_Data_Involved__c`

Related Lists:
- Activities
- Files
- Notes

---

## 4bis.1.b `NIS2_Register__c-NIS2 Measure Layout`
Sezioni:
1) Header
2) Dati Misura
3) Adozione & Verifica
4) Documentazione & Attività

Campi specifici:
- `Adoption_Status__c`
- `Adoption_Date__c`
- `NotAdopted_Justification__c`
- `Related_Supplier__c`

Related Lists:
- Activities
- Files

---

## 4bis.1.c `NIS2_Register__c-NIS2 Risk Layout`
Sezioni:
1) Header
2) Dati Rischio
3) Trattamento & Misure
4) Documentazione & Attività

Campi specifici:
- `Risk_Description__c`
- `Risk_Impact__c`
- `Risk_Status__c`

Related Lists:
- Activities
- Files

---

## 4bis.1.d `NIS2_Register__c-NIS2 Communication Layout`
Sezioni:
1) Header
2) Dati Comunicazione
3) Relazioni & Tracciatura
4) Documentazione & Attività

Campi specifici:
- `Channel__c`
- `Sent_At__c`
- `Related_Incident__c` o campo correlato (se esiste)
- eventuale `Comm_External_Ref__c` (se esiste)

Related Lists:
- Activities
- Files

---

## 4bis.1.e `NIS2_Register__c-NIS2 DPO Request Layout`
Sezioni:
1) Header
2) Richiesta DPO
3) Risposta
4) Documentazione & Attività

Campi specifici:
- `DPO_Request_Text__c`
- `DPO_Answer__c`
- `Answered_At__c`

Related Lists:
- Activities
- Files

---

## 4bis.1.f `NIS2_Register__c-NIS2 Decision Layout`
Sezioni:
1) Header
2) Dati Decisione
3) Approvazione
4) Documentazione & Attività

Campi specifici:
- `Approval_Status__c`
- `Approver_User__c`
- `Approved_At__c`
- `Approval_Comment__c` (se esiste)
- `Evidence_Required__c` (se esiste)

Related Lists:
- Activities
- Files

---

# 4bis.2 Layout per Account (Ente NIS2)

## `Account-NIS2 Entity Layout`
Sezioni:
1) Header
2) Profilo Ente
3) Contatti & Ruoli
4) Scadenze & Compliance
5) Attività & Documenti

Campi (se esistono):
- `ACN_Qualification_Status__c`
- `ACN_Next_Due_Date__c`
- `Point_of_Contact_User__c`
- `CSIRT_Lead_User__c`
- eventuali campi “referente CSIRT” se presenti come Contact lookup o text

Related Lists:
- Contacts
- Related `NIS2_Register__c` (related list dell’oggetto NIS2_Register__c filtrata su Related_Account__c)
- Activities
- Files

---

# 4bis.3 Layout per Contact (CdA e ruoli)

## `Contact-NIS2 Contact Layout`
Sezioni:
1) Header
2) Ruolo NIS2
3) Formazione
4) Note

Campi (se esistono):
- `Is_Board_Member__c`
- `Board_Role__c` (se esiste)
- `Training_Status__c` (se esiste)
- `Training_Last_Completed__c` (se esiste)

Related Lists:
- Activities
- Files (se usato)

---

# 4bis.4 Layout Assignment (OBBLIGATORIO)
- Assegna ciascun layout `NIS2_Register__c-*` al Record Type corrispondente:
  - Incident -> NIS2 Incident Layout
  - Measure -> NIS2 Measure Layout
  - Risk -> NIS2 Risk Layout
  - Communication -> NIS2 Communication Layout
  - DPORequest -> NIS2 DPO Request Layout
  - Decision -> NIS2 Decision Layout
- Assegna `Account-NIS2 Entity Layout` al Record Type `NIS2_Entity`
- Assegna `Contact-NIS2 Contact Layout` come layout di default (o a record type specifico se esiste)

---

# Output richiesto (OBBLIGATORIO)
1) Lista file creati in `force-app/main/default/layouts/` (con nomi esatti)
2) Per ogni file: elenco sezioni + campi + related lists
3) Conferma Layout Assignment completato
4) Note TODO solo se mancano campi nel progetto


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

# FASE 7 — Flow automazioni (SENZA controllo “file obbligatorio”) + STANDARD DI COMMENTI E MANUTENZIONE
Obiettivo: implementare automazioni dichiarative (Flow) per:
- reminder scadenze ACN
- gestione apertura incidente con task e follow-up
- gestione “misure in progress”
- generazione task formazione CdA
- workflow decision (richiesta approvazione + timestamp)

NON creare flow vuoti.
Regola di accettazione: il flow è valido solo se contiene:
- Start configurato correttamente (tipo flow, oggetto, evento, entry criteria)
- almeno 6 elementi tra Get/Decision/Assignment/Create/Update/TextTemplate
- connessioni complete: ogni elemento (tranne End) deve avere almeno un connettore in uscita
- tutte le risorse (variabili/formule/text template) richieste devono esistere e essere referenziate da almeno un elemento

Output obbligatorio:
1) elenco elementi creati (nome + tipo)
2) elenco risorse create
3) descrizione grafo: Start -> ... -> End


Se non riesci a generare un flow deployabile dopo 4-5 tentativi, fai un flow minimale ma deployabile, mi avverti e poi io lo implemento manualmente in flow builder

---

# FASE 7 — Flow automazioni (istruzioni “anti-generico” per Vibe Coding)
> Scopo di questa versione: evitare Flow vuoti o “scheletri”.
> Per **ogni Flow** ci sono:
> 1) **Spiegazione umana** (cosa deve fare, perché, cosa deve produrre)
> 2) **Blueprint tecnico** (elementi, risorse, e soprattutto **come collegarli**)

---

## 7.0 Standard di qualità (OBBLIGATORIO) — Naming, commenti, manutenzione

### 7.0.1 Naming Flow (API)
- Prefisso fisso: `NIS2_`
- Suffix descrittivo: es. `_OnCreate`, `_Scheduled`, `_SetApprovedAt`

### 7.0.2 Naming elementi nel Flow (OBBLIGATORIO)
Usa un prefisso per tipo elemento:
- `GET_` Get Records
- `DEC_` Decision
- `ASG_` Assignment
- `LOOP_` Loop
- `CRE_` Create Records
- `UPD_` Update Records
- `SUB_` Subflow
- `TXT_` Text Template
- `VAR_` Variable
- `FORM_` Formula
- `ERR_` Error/fallback branch

Esempi:
- `GET_Account_ById`
- `DEC_Is_NIS2_Entity`
- `ASG_Set_Owner_PoC_Or_CSIRT`
- `CRE_Task_Triage_Incident`
- `TXT_TaskDesc_IncidentTriage`

### 7.0.3 Commenti (OBBLIGATORI) dentro il Flow
Per **ogni elemento**, compilare Description con:
- **Purpose:** 1 riga
- **Inputs:** variabili/campi letti
- **Outputs:** record/campi creati/aggiornati
- **Assumptions:** fallback/default
- **Change log:** data + nota

### 7.0.4 Commenti a livello Flow (OBBLIGATORI)
Nel Description del Flow indicare:
- Scope (fa / non fa)
- Trigger conditions
- Dipendenze (campi/RT)
- Owner logic
- Dedup logic

### 7.0.5 Text Template manutenzione (OBBLIGATORIO)
Creare sempre `TXT_MAINTENANCE_NOTES` (non mostrato a utenti) con:
- campi usati
- record types usati
- dove cambiare milestone/valori
- dedup rules
- TODO futuri

---

## Regole generali (valgono per tutti i Flow)
- Condizioni su RT: usare `RecordType.DeveloperName` (NO RecordTypeId hardcoded)
- Notifiche: creare **Task** (email opzionali in future fasi)
- Owner Task: PoC -> CSIRT -> `$User.Id`
- Dedup: prima di creare Task, fare sempre un `GET_Existing_Open_Task_*` + `DEC_Task_Exists`

---

# 7.1 Flow — `NIS2_ACN_Reminder_Scheduled` (Scheduled-Triggered Flow su Account)

## Spiegazione “umana” (cosa deve fare)
Ogni mattina il sistema controlla tutti gli **Account NIS2 (record type NIS2_Entity)** che:
- hanno una prossima scadenza ACN (`ACN_Next_Due_Date__c`) valorizzata
- sono ancora “in perimetro” o in revisione (`InScope` o `InReview`)

Per ognuno calcola quanti giorni mancano alla scadenza (**DaysToDue**).  
Solo in alcuni giorni “milestone” (30,14,7,1,0,-1,-7) deve:
1) determinare l’owner della task (PoC, altrimenti CSIRT, altrimenti utente corrente)
2) verificare che **non esista già** una task aperta di reminder simile (dedup)
3) creare una Task di promemoria con subject e description standard
4) uscire senza creare duplicati negli altri giorni

> Nota: la dedup serve per evitare che lo schedule giornaliero crei task identiche.

## Blueprint tecnico (risorse + elementi + collegamenti)

### Start (Scheduled)
- Object: `Account`
- Entry criteria:
  - `RecordType.DeveloperName = "NIS2_Entity"`
  - `ACN_Next_Due_Date__c != null`
  - `(ACN_Qualification_Status__c = "InScope") OR (ACN_Qualification_Status__c = "InReview")`

### Risorse (OBBLIGATORIE)
- `FORM_DaysToDue` (Formula Number): `ACN_Next_Due_Date__c - TODAY()`
- `VAR_OwnerId` (Text)
- `TXT_TaskSubject_ACNReminder`: `[NIS2] Scadenza ACN tra {!FORM_DaysToDue} giorni - {!$Record.Name}`
- `TXT_TaskDesc_ACNReminder`: include NextDue + QualificationStatus
- `TXT_MAINTENANCE_NOTES`

### Elementi (OBBLIGATORI, con nomi ESATTI)
1) `ASG_Set_Owner_PoC_Or_CSIRT`
   - logic:
     - if `$Record.Point_of_Contact_User__c` not null => `VAR_OwnerId = $Record.Point_of_Contact_User__c`
     - else if `$Record.CSIRT_Lead_User__c` not null => `VAR_OwnerId = $Record.CSIRT_Lead_User__c`
     - else `VAR_OwnerId = $User.Id`
2) `DEC_Is_Milestone_Day`
   - rami: `30/14/7/1/0/-1/-7`
   - default: termina (nessuna task)
3) `GET_Existing_Open_Task_ACNReminder`
   - object: Task
   - filtri:
     - `WhatId = $Record.Id`
     - `Subject CONTAINS "[NIS2] Scadenza ACN"`
     - `Status != "Completed"` (o `!= "Closed"` se la tua org usa Closed)
     - `Task_Category__c = "Action"`
   - first record only
4) `DEC_Task_Exists`
   - se task trovata => End (skip)
   - se task non trovata => crea task
5) `CRE_Task_ACNReminder`
   - crea Task:
     - `WhatId = $Record.Id`
     - `OwnerId = VAR_OwnerId`
     - `ActivityDate = TODAY()` (oppure `$Record.ACN_Next_Due_Date__c` se vuoi)
     - `Subject = TXT_TaskSubject_ACNReminder`
     - `Description = TXT_TaskDesc_ACNReminder`
     - `Status = "Not Started"`
     - `Task_Category__c = "Action"`
     - `Priority` = `"High"` se `FORM_DaysToDue <= 7` else `"Normal"` (NON usare numero in Priority)

### Collegamenti (OBBLIGATORI)
`Start`
→ `ASG_Set_Owner_PoC_Or_CSIRT`
→ `DEC_Is_Milestone_Day`

- Per ciascun ramo milestone (30/14/7/1/0/-1/-7):
  → `GET_Existing_Open_Task_ACNReminder`
  → `DEC_Task_Exists`
    - Yes (exists) → `End`
    - No (not exists) → `CRE_Task_ACNReminder` → `End`

- Default di `DEC_Is_Milestone_Day` → `End`

---

# 7.2 Flow — `NIS2_Incident_OnCreate` (Record-Triggered After Save, Create, RT Incident)

## Spiegazione “umana”
Quando viene creato un record `NIS2_Register__c` di tipo **Incident**, il sistema deve:
1) capire a quale Ente (Account) si riferisce (`Related_Account__c`)
2) scegliere l’owner operativo per le attività (PoC → CSIRT → utente corrente)
3) creare una task di **triage immediato** per gestire l’incidente
4) creare una task per la **notifica entro 72 ore** (scadenza calcolata)
5) se l’incidente coinvolge dati personali, creare anche una task per avviare la valutazione “DPO / data breach”
6) evitare duplicati per la task di triage (se l’automazione venisse rilanciata per errore)

## Blueprint tecnico

### Start
- Object: `NIS2_Register__c`
- Trigger: After Save
- Run: only when record is created
- Entry criteria: `RecordType.DeveloperName = "Incident"`

### Risorse (OBBLIGATORIE)
- `VAR_AccountId` (Text): `$Record.Related_Account__c`
- `VAR_OwnerId` (Text)
- `TXT_TaskDesc_IncidentTriage` (include canale, aware_at, severity, summary)
- `TXT_TaskDesc_IncidentNotify72h`
- `TXT_MAINTENANCE_NOTES`

### Elementi (nomi ESATTI)
1) `GET_Account_ForIncident` (Get Account by `VAR_AccountId`)
2) `ASG_Set_Owner_PoC_Or_CSIRT` (Owner fallback da Account)
3) `GET_Existing_Open_Task_Triage` (dedup)
4) `DEC_Triage_Task_Exists`
5) `CRE_Task_Triage_Incident` (solo se non esiste)
6) `CRE_Task_Notify_72h` (sempre)
7) `DEC_PersonalData_Involved`
8) `CRE_Task_DPO_Assessment` (solo ramo Yes)

### Collegamenti (OBBLIGATORI)
`Start`
→ `GET_Account_ForIncident`
→ `ASG_Set_Owner_PoC_Or_CSIRT`
→ `GET_Existing_Open_Task_Triage`
→ `DEC_Triage_Task_Exists`

- Branch “exists” → `CRE_Task_Notify_72h` → `DEC_PersonalData_Involved`
- Branch “not exists” → `CRE_Task_Triage_Incident` → `CRE_Task_Notify_72h` → `DEC_PersonalData_Involved`

`DEC_PersonalData_Involved`
- Yes → `CRE_Task_DPO_Assessment` → End
- No → End

---

# 7.3 Flow — `NIS2_Measure_OnInProgress` (Record-Triggered After Save, Update, RT Measure)

## Spiegazione “umana”
Quando una misura (record type **Measure**) passa a stato **InProgress**, il sistema deve:
1) identificare l’Ente collegato
2) assegnare l’owner operativo (PoC/CSIRT)
3) creare una task “Implementare misura” (solo una volta, dedup)
4) se c’è un fornitore collegato, creare una task aggiuntiva “Coinvolgere fornitore” (opzionale con dedup)

## Blueprint tecnico (collegamenti)
`Start`
→ `GET_Account_ForMeasure`
→ `ASG_Set_Owner_PoC_Or_CSIRT`
→ `GET_Existing_Open_Task_ImplementMeasure`
→ `DEC_Task_Exists`
- Yes → `DEC_Has_Supplier` → (se supplier) `CRE_Task_ContactSupplier` → End
- No  → `CRE_Task_ImplementMeasure` → `DEC_Has_Supplier` → (se supplier) `CRE_Task_ContactSupplier` → End

---

# 7.4 Flow — `NIS2_Training_Generate` (Autolaunched Invocable)

## Spiegazione “umana”
Questo flow serve per “generare in blocco” le attività di formazione.  
Dato un Account NIS2:
1) controlla che sia un Ente NIS2
2) recupera i Contact con flag CdA
3) per ciascun CdA crea una task di formazione con scadenza X giorni
4) opzionalmente crea una task di coordinamento a un utente specifico
5) restituisce quante task ha creato

## Blueprint tecnico (collegamenti)
`Start (Autolaunched)`
→ `GET_Account_ById`
→ `DEC_Is_NIS2_Entity`
- No → End
- Yes → `ASG_Set_Owner_Default`
→ `GET_BoardContacts`
→ `LOOP_BoardContacts`
   → `GET_Existing_Open_Task_Training_ForContact`
   → `DEC_Task_Exists`
      - Yes → next loop
      - No  → `CRE_Task_Training_BoardMember` → `ASG_Increment_out_TasksCreated` → next loop
→ `DEC_Has_AssignToUser`
   - Yes → `CRE_Task_Training_Coordination` → End
   - No  → End

---

# 7.5 Flow — `NIS2_Decision_OnInReview` (After Save Update, RT Decision)

## Spiegazione “umana”
Quando una Decision passa a `InReview`, deve partire un “ping” operativo:
1) se manca l’approvatore, crea una task al PoC per completare i dati
2) se c’è l’approvatore, crea una task assegnata all’approvatore (membro CdA licenziato)
3) la task deve spiegare cosa fare: cambiare status Approved/Rejected e inserire commento se reject

## Blueprint tecnico (collegamenti)
`Start`
→ `DEC_Has_Approver`
- No → `CRE_Task_MissingApprover` → End
- Yes → `GET_Account_ForDecision` → `CRE_Task_ApprovalRequest` → End

---

# 7.6 Flow — `NIS2_Decision_SetApprovedAt` (Before Save Update, RT Decision)

## Spiegazione “umana”
Quando l’approvatore imposta Approved o Rejected:
1) se il timestamp `Approved_At__c` è vuoto, viene valorizzato con NOW()
2) se Approved e “Evidence required” (se esiste flag), viene generata una task per caricare evidenze (senza controllare file in questa fase)

## Blueprint tecnico (collegamenti)
`Start`
→ `DEC_ApprovedAt_IsBlank`
- Yes → `ASG_Set_ApprovedAt_Now`
- No  → (prosegue)
→ `DEC_Is_Approved_And_EvidenceRequired`
- Yes → `CRE_Task_RequestEvidence` → End
- No  → End

---

## Deploy & Test (obbligatorio a fine fase)
- Deploy: `sf project deploy start --target-org nis2dev --source-dir force-app/main/default/flows`
- Alla fine della fase 7: **STOP** (non proseguire con fasi successive).

---




---

.

---



---

## Come usare questo prompt
Quando ti chiedo “Esegui FASE X”, esegui SOLO quella fase e fermati.
