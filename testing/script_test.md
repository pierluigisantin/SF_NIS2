# Script di test manuale (UAT) — App NIS2 su Salesforce

## 0) Prerequisiti

### Utenti
- **U1 – Coordinatore NIS2 (licenza)**: utente operativo che registra la maggior parte dei dati.
- **U2 – CSIRT Lead (licenza)**: supporto incidenti / fallback owner.
- **U3 – DPO/Compliance (licenza)**: gestione aspetti data breach/privacy.
- **U4 – Membro CdA (licenza)**: deve entrare in Salesforce e approvare le “Decision”.

### Dati/Configurazione attesa
- Record Type **Account**: `NIS2_Entity`
- Record Types **NIS2_Register__c**: `Incident`, `Measure`, `Risk`, `Communication`, `DPORequest`, `Decision`
- Campo custom **Activity**: `Task_Category__c` (Picklist: `Training / Action / CallLog / Meeting / EvidenceRequest`)
- Page Layout creati e assegnati (FASE 4bis)
- Flow/automazioni presenti (FASE 7) — almeno creazione Task e aggiornamenti campi base

---

## 1) Test dati base (Account/Contact)

### TC-01 — Creazione Ente NIS2 (Account)
**Obiettivo:** verificare Record Type, campi e layout.

**Passi**
1. Login come **U1**
2. Crea un Account con Record Type **Ente NIS2 (NIS2_Entity)**:
   - `Name`: `Ente Test NIS2 - Alfa`
   - `ACN_Qualification_Status__c` = `InScope`
   - `ACN_Next_Due_Date__c` = (data tra 7 giorni)
   - `Point_of_Contact_User__c` = U1
   - `CSIRT_Lead_User__c` = U2
3. Salva

**Atteso**
- Layout `Account-NIS2 Entity Layout` visibile
- Campi presenti e valorizzati
- Related list `NIS2_Register__c` visibile (se configurata)
- Related list Activities e Files visibili

**Esito**: Pass / Fail  
**Note**:

---

### TC-02 — Creazione membri CdA come Contact
**Obiettivo:** gestire CdA come Contact e verificare layout.

**Passi**
1. Login come **U1**
2. Crea 2 Contact associati all’Account `Ente Test NIS2 - Alfa`:
   - `Mario Rossi` (flag `Is_Board_Member__c = true`)
   - `Luca Bianchi` (flag `Is_Board_Member__c = true`)
3. Salva

**Atteso**
- Layout `Contact-NIS2 Contact Layout` visibile
- Campi CdA/Formazione visibili (se previsti)
- Contact associati correttamente all’Account

**Esito**: Pass / Fail  
**Note**:

---

## 2) Test Registro NIS2 (`NIS2_Register__c`) — Record Types + Layout

### TC-03 — Creazione Incident
**Obiettivo:** verificare layout e campi specifici per Incident.

**Passi**
1. Login come **U1**
2. Crea `NIS2_Register__c` RT = **Incident**:
   - `Related_Account__c` = `Ente Test NIS2 - Alfa`
   - `Severity__c` = `High` (se presente)
   - `Summary__c` / `Incident_Summary__c` = `Test malware su endpoint`
   - `Personal_Data_Involved__c` = `Yes` (se presente)
   - `Aware_At__c` = adesso (se presente)
3. Salva

**Atteso**
- Layout `NIS2 Incident Layout` visibile
- Sezioni (es. Dati incidente / Notifiche / Documentazione) visibili
- Related list Activities e Files visibili

**Esito**: Pass / Fail  
**Note**:

---

### TC-04 — Creazione Measure
**Obiettivo:** verificare layout Measure e campi adozione.

**Passi**
1. Login come **U1**
2. Crea `NIS2_Register__c` RT = **Measure**:
   - `Related_Account__c` = `Ente Test NIS2 - Alfa`
   - `Adoption_Status__c` = `InProgress`
   - `Related_Supplier__c` = (Account fornitore “Supplier Test Srl”, se disponibile)
3. Salva

**Atteso**
- Layout `NIS2 Measure Layout`
- Campi adozione visibili
- Related list Activities e Files visibili

**Esito**: Pass / Fail  
**Note**:

---

### TC-05 — Creazione Decision
**Obiettivo:** verificare layout Decision e campi approvazione.

**Passi**
1. Login come **U1**
2. Crea `NIS2_Register__c` RT = **Decision**:
   - `Related_Account__c` = `Ente Test NIS2 - Alfa`
   - `Approval_Status__c` = `InReview`
   - `Approver_User__c` = **U4**
3. Salva

**Atteso**
- Layout `NIS2 Decision Layout`
- Campi approvazione visibili (Approver, Status, Approved_At)

**Esito**: Pass / Fail  
**Note**:

---

## 3) Test Flow/Automazioni — Incident / Measure / Decision

### TC-06 — Automazione su Incident (Task creati)
**Obiettivo:** alla creazione di un Incident vengono creati Task operativi.

**Prerequisito:** TC-03 completato.

**Passi**
1. Come **U1**, apri l’Incident creato
2. Controlla in **Activities / Open Tasks** (sull’Account e/o sul record):
   - Task: `"[NIS2] Triage incidente - ..."`
   - Task: `"[NIS2] Notifica incidente entro 72h - ..."`
   - Se `Personal_Data_Involved__c = Yes`: Task `"[NIS2] Valutare data breach (DPO) - ..."`
3. Verifica i campi dei Task:
   - OwnerId = U1 (PoC) oppure U2 (fallback)
   - `Task_Category__c` valorizzato (`Action` / `EvidenceRequest`)
   - Subject e Description valorizzati

**Atteso**
- Task creati correttamente
- Owner fallback coerente
- Nessun errore UI

**Esito**: Pass / Fail  
**Note**:

---

### TC-07 — Dedup Task Incident (no duplicati)
**Obiettivo:** verificare deduplica (se prevista).

**Passi**
1. Modifica l’Incident (senza cambiare record type) e salva
2. Conta i Task “Triage incidente…” ancora aperti

**Atteso**
- Non si crea un secondo Task identico aperto (se dedup implementata)
- Se si creano duplicati: registrare bug

**Esito**: Pass / Fail  
**Note**:

---

### TC-08 — Automazione su Measure “InProgress”
**Obiettivo:** quando una misura passa a InProgress, viene creato un Task.

**Prerequisito:** TC-04 creato.

**Passi**
1. Come **U1**, apri la Measure
2. Se già `InProgress`, cambia:
   - `Adoption_Status__c = Planned` (salva)
   - poi `Adoption_Status__c = InProgress` (salva)
3. Controlla in Activities:
   - Task “Implementare misura …”
   - (Opzionale) Task “Coinvolgere fornitore …” se `Related_Supplier__c` valorizzato

**Atteso**
- Task creati correttamente
- `Task_Category__c = Action`

**Esito**: Pass / Fail  
**Note**:

---

### TC-09 — Decision: task richiesta approvazione a CdA
**Obiettivo:** quando una Decision è `InReview`, viene creato un Task per l’approvatore.

**Passi**
1. Come **U1**, assicurati che la Decision sia `Approval_Status__c = InReview` e `Approver_User__c = U4`
2. Login come **U4**
3. Vai su **Tasks** e cerca:
   - Subject: `"[NIS2] Approvazione richiesta - ..."`
4. Apri il task e verifica:
   - Owner = U4
   - Descrizione contiene istruzioni

**Atteso**
- Task assegnato correttamente a U4

**Esito**: Pass / Fail  
**Note**:

---

### TC-10 — Decision: Approved -> valorizza `Approved_At__c`
**Obiettivo:** quando il CdA approva, il timestamp viene valorizzato.

**Passi**
1. Login come **U4**
2. Apri la Decision
3. Imposta `Approval_Status__c = Approved`
4. Salva

**Atteso**
- `Approved_At__c` valorizzato con data/ora (NOW)
- (Opzionale) se `Evidence_Required__c = true`: Task “Caricare evidenza …” assegnato al PoC/CSIRT

**Esito**: Pass / Fail  
**Note**:

---

## 4) Test campo Activity `Task_Category__c` (su Task)

### TC-11 — `Task_Category__c` presente su Task e valorizzabile
**Obiettivo:** verificare che il campo Activity sia disponibile su Task.

**Passi**
1. Login come **U1**
2. Crea un Task manuale sull’Account `Ente Test NIS2 - Alfa`
3. Verifica campo `Task_Category__c` presente
4. Imposta `Meeting` e salva

**Atteso**
- Campo presente
- Salvataggio ok
- Valori picklist coerenti

**Esito**: Pass / Fail  
**Note**:

---

## 5) Test reminder ACN (Scheduled Flow)

> Nota: un scheduled flow non è “forzabile” da un tester standard senza permessi admin.
> Eseguire in uno di questi modi:
> - (A) attendendo l’orario schedulato
> - (B) usando “Debug” del Flow (se permessi admin)

### TC-12 — Reminder ACN (esecuzione schedulata)
**Obiettivo:** creare Task reminder nei giorni milestone.

**Passi**
1. Su Account `Ente Test NIS2 - Alfa` imposta:
   - `ACN_Next_Due_Date__c = OGGI + 7`
   - `ACN_Qualification_Status__c = InScope`
2. Attendere esecuzione schedulata (oppure Debug)
3. Verificare creazione Task:
   - Subject: `"[NIS2] Scadenza ACN tra X giorni - Ente Test NIS2 - Alfa"`

**Atteso**
- Task creato una sola volta (dedup)
- Owner = PoC o CSIRT fallback
- `Task_Category__c = Action`

**Esito**: Pass / Fail  
**Note**:

---

## 6) Verifica Page Layout (FASE 4bis)

### TC-13 — Layout per record type
**Obiettivo:** layout corretto per ciascun Record Type.

**Passi**
Per ciascun Record Type (`Incident`, `Measure`, `Risk`, `Communication`, `DPORequest`, `Decision`):
1. Apri un record di quel tipo (o crealo velocemente)
2. Verifica che il layout corretto sia applicato
3. Verifica presenza di:
   - sezioni principali
   - related list Activities
   - related list Files

**Atteso**
- Layout giusto assegnato
- Campi chiave visibili
- Nessuna sezione critica mancante

**Esito**: Pass / Fail  
**Note**:

---

## 7) Bug reporting — Template
Quando trovi un problema, registrare:
- **TC-ID**:
- **Pass/Fail**:
- **Cosa mi aspettavo**:
- **Cosa è successo**:
- **Screenshot / URL record**:
- **User usato** (U1/U2/U3/U4):
- **Severità** (Blocker / High / Medium / Low):
