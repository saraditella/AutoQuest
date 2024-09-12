-- CREAZIONE DATABASE
CREATE DATABASE IF NOT EXISTS autoquest;
USE autoquest;

-- ======================
-- TABELLA AUTO
-- ======================
CREATE TABLE auto
(
    ID_auto       INT AUTO_INCREMENT PRIMARY KEY,
    Marchio       VARCHAR(20) NOT NULL,
    Modello       VARCHAR(50) NOT NULL,
    Alimentazione ENUM ('Benzina','Diesel','Elettrica','Ibrida','Ibrida Plug-in','GPL','Metano','Idrogeno') NOT NULL,
    Potenza       INT NOT NULL COMMENT 'Potenza in CV',
    Cambio        ENUM ('Manuale','Automatico','Sequenziale','CVT','Doppia Frizione') NOT NULL,
    Cilindrata    INT NOT NULL COMMENT 'Cilindrata in cc',
    Prezzo_base   DECIMAL(10,2) NOT NULL,
    Link_acquisto VARCHAR(255) NOT NULL,
    Immagine_url  VARCHAR(100) NOT NULL
);

CREATE INDEX idx_alimentazione ON auto (Alimentazione);
CREATE INDEX idx_cambio        ON auto (Cambio);
CREATE INDEX idx_cilindrata    ON auto (Cilindrata);
CREATE INDEX idx_marca         ON auto (Marchio);
CREATE INDEX idx_modello       ON auto (Modello);
CREATE INDEX idx_potenza       ON auto (Potenza);
CREATE INDEX idx_prezzo        ON auto (Prezzo_base);

-- ======================
-- TABELLA ALLESTIMENTO
-- ======================
CREATE TABLE allestimento
(
    ID_allestimento          INT AUTO_INCREMENT PRIMARY KEY,
    ID_auto                  INT NOT NULL,
    Nome_allestimento        VARCHAR(50) NOT NULL,
    Descrizione_allestimento TEXT NOT NULL,
    Prezzo_allestimento      DECIMAL(10,2) NOT NULL,
    CONSTRAINT allestimento_ibfk_1 FOREIGN KEY (ID_auto) REFERENCES auto(ID_auto) ON DELETE CASCADE
);

CREATE INDEX idx_id_auto ON allestimento (ID_auto);

-- ======================
-- TABELLA ACCESSORIO_ALLESTIMENTO
-- ======================
CREATE TABLE accessorio_allestimento
(
    ID_accessorio_allestimento INT AUTO_INCREMENT PRIMARY KEY,
    ID_allestimento            INT NOT NULL,
    Tipo                       VARCHAR(50) NOT NULL,
    CONSTRAINT accessorio_allestimento_ibfk_1 FOREIGN KEY (ID_allestimento) REFERENCES allestimento(ID_allestimento) ON DELETE CASCADE
);

CREATE INDEX idx_id_allestimento_accessorio ON accessorio_allestimento (ID_allestimento);

-- ======================
-- TABELLA UTENTE
-- ======================
CREATE TABLE utente
(
    ID_utente    INT AUTO_INCREMENT PRIMARY KEY,
    Nome         VARCHAR(30) NOT NULL,
    Cognome      VARCHAR(30) NOT NULL,
    Email        VARCHAR(50) NOT NULL UNIQUE,
    Ruolo        ENUM('ADMIN','UTENTE') NOT NULL DEFAULT 'UTENTE',
    Password     VARCHAR(128) NOT NULL COMMENT 'Password hash (compatibilità)',
    PasswordHash VARCHAR(40) NULL COMMENT 'SHA-1 o SHA-256 in formato esadecimale'
);

-- ======================
-- TABELLA AUTO SALVATE
-- ======================
CREATE TABLE auto_salvate
(
    ID_lista_auto    INT AUTO_INCREMENT PRIMARY KEY,
    ID_auto          INT NOT NULL,
    ID_allestimento  INT NOT NULL,
    ID_utente        INT NOT NULL,
    Prezzo_attuale   DECIMAL(10,2) NOT NULL,
    Data_salvataggio DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT auto_salvate_ibfk_1 FOREIGN KEY (ID_auto) REFERENCES auto(ID_auto) ON DELETE CASCADE,
    CONSTRAINT auto_salvate_ibfk_2 FOREIGN KEY (ID_allestimento) REFERENCES allestimento(ID_allestimento) ON DELETE CASCADE,
    CONSTRAINT auto_salvate_ibfk_3 FOREIGN KEY (ID_utente) REFERENCES utente(ID_utente) ON DELETE CASCADE
);

CREATE INDEX idx_allestimento_salvate ON auto_salvate (ID_allestimento);
CREATE INDEX idx_auto_salvate         ON auto_salvate (ID_auto);
CREATE INDEX idx_id_utente_salvate    ON auto_salvate (ID_utente);

-- ======================
-- TABELLA CONFRONTO
-- ======================
CREATE TABLE confronto
(
    ID_confronto   INT AUTO_INCREMENT PRIMARY KEY,
    ID_utente      INT NOT NULL,
    Nome_confronto VARCHAR(50) NOT NULL,
    Data_creazione DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT confronto_ibfk_1 FOREIGN KEY (ID_utente) REFERENCES utente(ID_utente) ON DELETE CASCADE
);

CREATE INDEX idx_id_utente_confronto ON confronto (ID_utente);

-- ======================
-- TABELLA CONFRONTO_AUTO
-- ======================
CREATE TABLE confronto_auto
(
    ID_confronto    INT NOT NULL,
    ID_allestimento INT NOT NULL,
    PRIMARY KEY (ID_confronto, ID_allestimento),
    CONSTRAINT confronto_auto_ibfk_1 FOREIGN KEY (ID_confronto) REFERENCES confronto(ID_confronto) ON DELETE CASCADE,
    CONSTRAINT confronto_auto_ibfk_2 FOREIGN KEY (ID_allestimento) REFERENCES allestimento(ID_allestimento) ON DELETE CASCADE
);

CREATE INDEX idx_allestimento_confronto ON confronto_auto (ID_allestimento);

-- ======================
-- TABELLA ORDINE
-- ======================
CREATE TABLE ordine
(
    ID_ordine       INT AUTO_INCREMENT PRIMARY KEY,
    ID_utente       INT NOT NULL,
    ID_allestimento INT NOT NULL,
    Data_ordine     DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Prezzo_totale   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Stato           VARCHAR(30) NOT NULL DEFAULT 'creato',
    CONSTRAINT ordine_ibfk_1 FOREIGN KEY (ID_utente) REFERENCES utente(ID_utente) ON DELETE CASCADE,
    CONSTRAINT ordine_ibfk_2 FOREIGN KEY (ID_allestimento) REFERENCES allestimento(ID_allestimento) ON DELETE CASCADE
);

CREATE INDEX idx_data_ordine        ON ordine (Data_ordine);
CREATE INDEX idx_id_allestimento_ord ON ordine (ID_allestimento);
CREATE INDEX idx_id_utente_ordine   ON ordine (ID_utente);

-- ======================
-- TABELLA PREFERENZA UTENTE
-- ======================
CREATE TABLE preferenza_utente
(
    ID_preferenza      INT AUTO_INCREMENT PRIMARY KEY,
    ID_utente          INT NOT NULL,
    Marchio_pref       VARCHAR(20) NULL,
    Modello_pref       VARCHAR(50) NULL,
    Alimentazione_pref ENUM ('Benzina','Diesel','Elettrica','Ibrida','GPL','Metano','Idrogeno') NULL,
    Potenza_pref       INT NULL,
    Cambio_pref        ENUM ('Manuale','Automatico','Sequenziale','CVT','Doppia Frizione') NULL,
    Cilindrata_pref    INT NULL,
    Budget_min         DECIMAL(10,2) NULL,
    Budget_max         DECIMAL(10,2) NULL,
    Data_creazione     DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT preferenza_utente_ibfk_1 FOREIGN KEY (ID_utente) REFERENCES utente(ID_utente) ON DELETE CASCADE
);

CREATE INDEX idx_id_utente_pref ON preferenza_utente (ID_utente);

-- ======================
-- TABELLA RICERCA SALVATA
-- ======================
CREATE TABLE ricerca_salvata
(
    ID_ricerca        INT AUTO_INCREMENT PRIMARY KEY,
    ID_utente         INT NOT NULL,
    Nome_ricerca      VARCHAR(50) NOT NULL,
    Parametri_ricerca JSON NOT NULL COMMENT 'JSON con parametri di ricerca',
    Data_ricerca      DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ricerca_salvata_ibfk_1 FOREIGN KEY (ID_utente) REFERENCES utente(ID_utente) ON DELETE CASCADE
);

CREATE INDEX idx_id_utente_ricerca ON ricerca_salvata (ID_utente);
