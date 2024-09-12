-- DB corrente e tabelle
USE autoquest;
SHOW TABLES;

-- Struttura di una tabella
DESCRIBE auto;
SHOW COLUMNS FROM allestimento;




-- Tutte le auto di "Tesla"
SELECT * FROM auto WHERE Marchio = 'Tesla';

-- Auto elettriche con prezzo <= 50k
SELECT * FROM auto WHERE Alimentazione = 'Elettrica' AND Prezzo_base <= 50000 ORDER BY Prezzo_base;

-- Auto con potenza >= 200 CV e cambio automatico
SELECT * FROM auto WHERE Potenza >= 200 AND Cambio = 'Automatico';




-- Prezzo totale per un allestimento (Prezzo_base + Prezzo_allestimento)
SELECT a.ID_auto, a.Marchio, a.Modello, al.ID_allestimento, al.Nome_allestimento,
       a.Prezzo_base, al.Prezzo_allestimento,
       (a.Prezzo_base + al.Prezzo_allestimento) AS Prezzo_totale
FROM allestimento al
         JOIN auto a ON a.ID_auto = al.ID_auto
WHERE al.ID_allestimento = 19;

-- Ordini con info utente e auto/allestimento
SELECT o.ID_ordine, o.Data_ordine, o.Stato, u.Nome, u.Cognome,
       a.Marchio, a.Modello, al.Nome_allestimento,
       o.Prezzo_totale
FROM ordine o
         JOIN utente u ON u.ID_utente = o.ID_utente
         JOIN allestimento al ON al.ID_allestimento = o.ID_allestimento
         JOIN auto a ON a.ID_auto = al.ID_auto
ORDER BY o.Data_ordine DESC
LIMIT 50;





-- Auto salvate di un utente (con prezzo calcolato)
SELECT asv.ID_lista_auto, u.Email, a.Marchio, a.Modello, al.Nome_allestimento,
       asv.Prezzo_attuale, asv.Data_salvataggio
FROM auto_salvate asv
         JOIN utente u ON u.ID_utente = asv.ID_utente
         JOIN allestimento al ON al.ID_allestimento = asv.ID_allestimento
         JOIN auto a ON a.ID_auto = asv.ID_auto
WHERE u.Email = 'mario.rossi@example.com';

-- Auto presenti in un confronto (id confronto = 2)
SELECT ca.ID_confronto, ca.ID_allestimento, al.Nome_allestimento, a.Marchio, a.Modello
FROM confronto_auto ca
         JOIN allestimento al ON al.ID_allestimento = ca.ID_allestimento
         JOIN auto a ON a.ID_auto = al.ID_auto
WHERE ca.ID_confronto = 2;



-- Pagina 2, 10 risultati per pagina (OFFSET = (page-1)*limit)
SELECT * FROM auto ORDER BY Prezzo_base ASC LIMIT 10 OFFSET 10;

-- Ricerca testo semplice su marchio/modello
SELECT * FROM auto
WHERE Marchio LIKE '%Volkswagen%' OR Modello LIKE '%Golf%'
ORDER BY Prezzo_base LIMIT 20;





-- Conteggio per alimentazione
SELECT Alimentazione, COUNT(*) AS cnt
FROM auto
GROUP BY Alimentazione
ORDER BY cnt DESC;

-- Prezzo medio per marchio
SELECT Marchio, ROUND(AVG(Prezzo_base),2) AS prezzo_medio, COUNT(*) as n_models
FROM auto
GROUP BY Marchio
HAVING n_models >= 2
ORDER BY prezzo_medio DESC;




-- Inserimento nuovo utente (evita duplicati)
INSERT INTO utente (Nome, Cognome, Email, passwordhash, password_test, Ruolo)
VALUES ('Giovanni','Es.', 'giovanni@example.com','hash_placeholder', 'password_test', 'UTENTE')
ON DUPLICATE KEY UPDATE Nome = VALUES(Nome), Cognome = VALUES(Cognome);

-- Aggiornare stato ordine e prezzo
UPDATE ordine SET Stato = 'confermato', Prezzo_totale = 43500.00 WHERE ID_ordine = 3;

-- Cancellare un confronto (cancella anche le righe in confronto_auto grazie al cascade)
DELETE FROM confronto WHERE ID_confronto = 4;




-- Allestimenti che fanno riferimento ad auto non esistenti (orfani)
SELECT al.* FROM allestimento al
                     LEFT JOIN auto a ON a.ID_auto = al.ID_auto
WHERE a.ID_auto IS NULL;

-- Auto_salvate con utente non esistente
SELECT asv.* FROM auto_salvate asv
                      LEFT JOIN utente u ON u.ID_utente = asv.ID_utente
WHERE u.ID_utente IS NULL;


DROP TABLE IF EXISTS Ricerca_Salvata;
DROP TABLE IF EXISTS Preferenza_Utente;
DROP TABLE IF EXISTS Confronto_Auto;
DROP TABLE IF EXISTS Confronto;
DROP TABLE IF EXISTS Auto_Salvate;
DROP TABLE IF EXISTS Ordine;
DROP TABLE IF EXISTS Utente;
DROP TABLE IF EXISTS Accessorio_Allestimento;
DROP TABLE IF EXISTS Allestimento;
DROP TABLE IF EXISTS Auto;



SELECT * FROM ordine;


SELECT *
/* a.ID_auto,
a.Link_acquisto,
a.Alimentazione,
a.Marchio,
a.Prezzo_base,
a.Modello,
al.ID_allestimento,
al.Nome_allestimento,
al.Descrizione_allestimento,
al.Prezzo_allestimento */
FROM
    auto a;


SELECT DISTINCT *
FROM utente;


SELECT nome, cognome, email, password_test, utente.passwordhash,
       LEFT(passwordhash, 10) as hash_preview
FROM autoquest.utente
ORDER BY nome;