# AutoQuest

**AutoQuest** è una piattaforma web dinamica per la ricerca, il confronto e la personalizzazione di autovetture. Il progetto è stato sviluppato per l'esame di **Tecnologie Software per il Web** presso l'**Università degli Studi di Salerno (Fisciano)**.

## Descrizione
Il sistema permette agli utenti di navigare in un catalogo auto completo, applicare filtri tecnici avanzati, personalizzare i modelli con allestimenti specifici e gestire un proprio "Garage" virtuale. Include un sistema di amministrazione per il monitoraggio delle statistiche di vendita e la gestione del catalogo.

## Funzionalità Principali

### Area Utente
- **Ricerca Avanzata e Rapida:** Filtri per budget, potenza, cilindrata, marchio, tipo di cambio e alimentazione.
- **Sistema di Confronto:** Confronto tecnico dettagliato tra massimo 4 modelli simultaneamente (gestito via AJAX).
- **Dettaglio e Personalizzazione:** Selezione di allestimenti con aggiornamento dinamico del prezzo totale.
- **Garage Virtuale:** Salvataggio delle configurazioni preferite per gli utenti registrati.
- **Gestione Profilo:** Registrazione, login, modifica dati personali e cambio password.
- **Ordini:** Storico degli acquisti effettuati sul portale.

### Area Amministratore
- **Dashboard Statistica:** Visualizzazione in tempo reale di incassi totali, numero di utenti, ordini e auto nel catalogo.
- **Gestione Catalogo:** Interfaccia per l'aggiunta di nuove auto con specifiche tecniche e link di acquisto.
- **Controllo Accessi:** Badge identificativi e restrizioni sulle funzionalità di acquisto.

## Tecnologie Utilizzate

### Backend
- **Java (Servlet):** Gestione della logica di business e del flusso di controllo.
- **JSP (JavaServer Pages):** Generazione dinamica delle pagine HTML.
- **JSTL & Expression Language (EL):** Gestione della logica di visualizzazione, iterazioni e formattazione dati.
- **Architettura MVC:** Separazione netta tra dati (Model), interfaccia (View) e logica (Controller).

### Frontend
- **HTML5 & CSS3:** Design moderno e responsivo, con uso di componenti card e layout a griglia.
- **JavaScript (Vanilla & AJAX):**
    - Aggiornamento dei contatori in tempo reale senza ricaricamento della pagina.
    - Validazione dei form (lato client).
    - Gestione dinamica dei filtri di ricerca.
- **Interattività:** Sistemi di notifica personalizzati e animazioni per le card del Garage.

## Installazione e Test
1. Clonare la repository.
2. Configurare un database MySQL con le tabelle per utenti, auto, allestimenti, ordini e confronti salvati.
3. Configurare il server **Apache Tomcat** (versione 9 o superiore).
4. Eseguire il deploy della Web Application.

### Account Demo
- **Admin:** `admin@autoquest.com` / `admin123`

---
**Progetto di:** Sara Di Tella  
**Corso:** Tecnologie Software per il Web