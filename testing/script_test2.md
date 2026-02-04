# Scenario di test (end-to-end) — Basato sulla call con l’esperto NIS2 + copertura COMPLETA di tutti i Record Type di `NIS2_Register__c`
> Obiettivo: validare che il sistema Salesforce “NIS2 semplificato” supporti l’ossatura minima descritta dall’esperto:
> - **repository documentale** (deleghe, verbali, nomine)
> - **ruoli e responsabilità** (CdA, PoC, CSIRT, sostituti)
> - **formazione tracciata** (CdA e personale)
> - **registro** come “cartella” per incidenti/comunicazioni/misure/rischi/decisioni/DPO request
>
> Questo scenario include simulazioni che usano **tutti i Record Type** di `NIS2_Register__c`:
> - `Incident`
> - `Measure`
> - `Risk`
> - `Communication`
> - `DPORequest`
> - `Decision`

---

## 1) Ruoli / attori (setup dati)

### Utenti con licenza
- **U1 – Coordinatore NIS2**: fa la maggior parte delle registrazioni e carica documenti.
- **U2 – CSIRT Lead**: supporto incidenti / fallback owner.
- **U3 – DPO/Compliance**: gestione data breach / privacy.
- **U4 – Membro CdA (licenza)**: entra per approvare decisioni.

### Contatti senza licenza (Contact)
- **C1 – Presidente CdA** (Is_Board_Member__c = true)
- **C2 – Consigliere CdA** (Is_Board_Member__c = true)
- **C3 – Referente CSIRT (persona)** (facoltativo come Contact)
- **C4 – Sostituto CSIRT (persona)** (facoltativo come Contact)

> Se PoC/CSIRT sono gestiti come campi User su Account, i Contact C3/C4 servono solo per anagrafica/evidenze.

---

## 2) Dati iniziali richiesti

### Account (Ente NIS2)
- Account: `Ente Test NIS2 - Alfa`
- Record Type: `NIS2_Entity`
- Campi (se presenti):
  - `ACN_Qualification_Status__c = InScope`
  - `ACN_Next_Due_Date__c = oggi + 30`
  - `Point_of_Contact_User__c = U1`
  - `CSIRT_Lead_User__c = U2`

### File di test (documenti/evidenze)
Preparare questi file (PDF/DOCX anche “finti”):
1. `Delega_CDA_PoC.pdf`
2. `Verbale_Formazione_CDA_2026.pdf`
3. `Nomina_Referente_CSIRT.pdf`
4. `Nomina_Sostituto_CSIRT.pdf`
5. `Email_ACN_Qualifica.pdf` (simula scambio con ACN)
6. `Analisi_Rischi_Fornitori.pdf` (simula risk assessment supply chain)
7. `Evidenza_Misura_Antimalware.pdf` (installazione/config)
8. `Log_Analisi_Incidente_Malware.pdf`
9. `Richiesta_DPO_DataBreach.pdf`
10. `Parere_DPO_DataBreach.pdf`
11. `Verbale_Decisione_CDA.pdf`

---

## 3) Scenario end-to-end (passi da eseguire)

## STEP A — Setup Ente e CdA (Account + Contact)
**Esecutore:** U1

**Passi**
1. Crea Account `Ente Test NIS2 - Alfa` (RT `NIS2_Entity`) e valorizza PoC/CSIRT.
2. Crea Contact `C1 Presidente CdA` e `C2 Consigliere CdA` collegati all’Account, con `Is_Board_Member__c = true`.

**Atteso**
- Layout NIS2 Entity e Contact NIS2 corretti.
- Related list Files e Activities visibili.

---

## STEP B — Repository documentale minimo su Account (Files)
**Esecutore:** U1

**Passi**
1. Apri l’Account.
2. Carica nei **Files**:
   - `Delega_CDA_PoC.pdf`
   - `Nomina_Referente_CSIRT.pdf`
   - `Nomina_Sostituto_CSIRT.pdf`

**Atteso**
- File rintracciabili dal record Account.

---

# STEP C — Simulazioni con TUTTI i Record Type di `NIS2_Register__c`
> Regola: per ogni record creato, allegare almeno **1 file** e creare almeno **1 Task** (manuale se i flow non lo creano).

---

## C1) Record Type: `Communication`
**Esecutore:** U1

**Scopo umano**
Tracciare le comunicazioni ufficiali/di accountability (email, PEC, portale) legate alla qualifica e alle conferme annuali.

**Passi**
1. Crea `NIS2_Register__c` RT = **Communication**
   - `Related_Account__c = Ente Alfa`
   - `Summary__c = "Ricevuta comunicazione ACN: conferma rientro perimetro"`
   - (se esiste) `Channel__c = Email/PEC/Portale`
   - (se esiste) `Sent_At__c = oggi`
2. Allegare file: `Email_ACN_Qualifica.pdf`
3. Creare Task manuale:
   - Subject: `[NIS2] Registrare esito comunicazione ACN`
   - `Task_Category__c = CallLog` (o Action)
   - Owner = U1
   - WhatId = Account

**Atteso**
- Esiste un “registro comunicazioni” con evidenza allegata e attività.

---

## C2) Record Type: `Risk`
**Esecutore:** U1 (creazione), U2 (review facoltativa)

**Scopo umano**
Documentare una valutazione rischio (es. supply chain) e collegarla a evidenze e ad azioni correttive.

**Passi**
1. Crea `NIS2_Register__c` RT = **Risk**
   - `Related_Account__c = Ente Alfa`
   - `Summary__c = "Rischio supply chain: dipendenza da fornitore antimalware"`
   - (se esistono) `Risk_Description__c`, `Risk_Impact__c`, `Risk_Status__c = Open`
2. Allegare file: `Analisi_Rischi_Fornitori.pdf`
3. Creare Task manuale:
   - Subject: `[NIS2] Definire mitigazione rischio supply chain`
   - `Task_Category__c = Action`
   - Owner = U1 (o U2)
   - Due date = oggi + 14

**Atteso**
- Rischio tracciato, con evidenza e task di mitigazione.

---

## C3) Record Type: `Measure`
**Esecutore:** U1 (creazione), U2 (supporto tecnico)

**Scopo umano**
Tracciare l’adozione di una misura richiesta (esempio dell’esperto: antimalware), con data, fornitore e verifiche.

**Passi**
1. Crea `NIS2_Register__c` RT = **Measure**
   - `Related_Account__c = Ente Alfa`
   - `Summary__c = "Adozione misura: soluzione antimalware su endpoint"`
   - (se esiste) `Adoption_Status__c = InProgress`
   - (se esiste) `Related_Supplier__c = Supplier Test Srl`
2. Allegare file: `Evidenza_Misura_Antimalware.pdf`
3. Se flow `NIS2_Measure_OnInProgress` è attivo: verificare creazione Task “Implementare misura…”
   - Se non c’è flow, creare manualmente:
     - Subject: `[NIS2] Implementare misura - antimalware`
     - `Task_Category__c = Action`
     - Owner = U1 (o U2)

**Atteso**
- Misura tracciata, evidenza allegata, attività assegnata.

---

## C4) Record Type: `Incident`
**Esecutore:** U1 (creazione), U2 (gestione)

**Scopo umano**
Simulare un incidente rilevante: aprire l’incidente, tracciare attività, raccogliere evidenze, preparare “notifica 72h”.

**Passi**
1. Crea `NIS2_Register__c` RT = **Incident**
   - `Related_Account__c = Ente Alfa`
   - `Summary__c = "Incidente malware su postazione operatore (test)"`
   - (se esiste) `Severity__c = High`
   - (se esiste) `Aware_At__c = adesso`
   - (se esiste) `Personal_Data_Involved__c = Yes`
2. Allegare file: `Log_Analisi_Incidente_Malware.pdf`
3. Se flow `NIS2_Incident_OnCreate` è attivo: verificare task create:
   - Triage
   - Notifica 72h
   - DPO assessment (se PD=Yes)
4. Se flow non attivo: creare manualmente 2 task:
   - `[NIS2] Triage incidente - ...` (Category Action, Owner U2, Due oggi)
   - `[NIS2] Notifica incidente entro 72h - ...` (Category Action, Due oggi+3)

**Atteso**
- Incidente è una “cartella” con evidenze + task operative.

---

## C5) Record Type: `DPORequest`
**Esecutore:** U1 (apertura), U3 (risposta)

**Scopo umano**
Tracciare richiesta a DPO (data breach / privacy) e la risposta/valutazione.

**Passi**
1. Crea `NIS2_Register__c` RT = **DPORequest**
   - `Related_Account__c = Ente Alfa`
   - `Summary__c = "Richiesta a DPO: valutazione data breach su incidente malware"`
   - (se esistono) `DPO_User__c = U3`
2. Allegare file: `Richiesta_DPO_DataBreach.pdf`
3. Creare Task:
   - Subject: `[NIS2] Rispondere a richiesta DPO - data breach`
   - `Task_Category__c = EvidenceRequest`
   - Owner = U3
   - Due date = oggi + 2
4. Simulare risposta:
   - Allegare file: `Parere_DPO_DataBreach.pdf`
   - (se esiste campo) compilare `DPO_Answer__c` e `Answered_At__c = now`

**Atteso**
- Richiesta e risposta tracciate con evidenze e responsabilità.

---

## C6) Record Type: `Decision`
**Esecutore:** U1 (creazione), U4 (approvazione)

**Scopo umano**
Tracciare una decisione CdA (es. cambio fornitore antimalware o approvazione comunicazione/notifica) con approvazione formale.

**Passi**
1. Crea `NIS2_Register__c` RT = **Decision**
   - `Related_Account__c = Ente Alfa`
   - `Summary__c = "Decisione CdA: sostituzione fornitore antimalware"`
   - `Approval_Status__c = InReview` (se esiste)
   - `Approver_User__c = U4` (se esiste)
2. Allegare file: `Verbale_Decisione_CDA.pdf`
3. Verificare che il flow `NIS2_Decision_OnInReview` crei un task di approvazione per U4
4. Login come **U4**:
   - aprire Decision e impostare `Approval_Status__c = Approved`
   - salvare
5. Verificare che il flow `NIS2_Decision_SetApprovedAt` valorizzi `Approved_At__c`
6. (Opzionale) se esiste `Evidence_Required__c = true`, verificare task “richiesta evidenza” al PoC

**Atteso**
- Approvazione tracciata con timestamp + evidenza allegata.
- Task di approvazione assegnato a U4.

---

## STEP D — Verifica finale di “accountability”
**Esecutore:** tester

**Passi**
1. Aprire Account `Ente Test NIS2 - Alfa`
2. Verificare che siano visibili e rintracciabili:
   - Files “ossatura documentale” (deleghe/nomine/verbali)
   - Related list `NIS2_Register__c` con **6 record** (uno per ogni RT)
   - Activities/Task (Training/Action/EvidenceRequest ecc.)
3. Aprire ogni record `NIS2_Register__c` e verificare:
   - file allegato presente
   - almeno 1 task correlato (o su Account, se modello così)

**Atteso**
- Un auditor può ricostruire:
  - chi è responsabile (ruoli)
  - quali documenti esistono
  - quali attività sono state eseguite e quando
  - incidenti e decisioni con evidenze

---

## 4) Criteri di accettazione (pass/fail)
- **A1**: Account NIS2 creato e ruoli minimi valorizzati.
- **A2**: Documenti minimi caricati e rintracciabili.
- **A3**: Esistono record `NIS2_Register__c` per **tutti e 6 i record type**.
- **A4**: Ogni record ha almeno 1 evidenza allegata e 1 attività.
- **A5**: Decision approvata con timestamp (se flow implementato).
- **A6**: Incident contiene evidenze e task di gestione/notifica.

---

## 5) Output del tester (da consegnare)
- Screenshot Account con:
  - ruoli valorizzati
  - Files (deleghe/nomine/verbali)
  - related list NIS2 Register (6 record types)
  - Activities
- Screenshot per ciascun record type (6 screenshot):
  - record + file allegato + task correlato
- Lista bug con:
  - passo, atteso, osservato, user, severità
