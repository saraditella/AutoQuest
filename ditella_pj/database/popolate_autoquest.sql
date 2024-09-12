-- RICREAZIONE COMPLETA DEL DB AUTOQUEST (da zero)
DROP DATABASE IF EXISTS autoquest;
CREATE DATABASE IF NOT EXISTS autoquest CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE autoquest;

-- ======================
-- TABELLE (schema aggiornato)
-- ======================
CREATE TABLE auto
(
    ID_auto       INT AUTO_INCREMENT PRIMARY KEY,
    Marchio       VARCHAR(50) NOT NULL,
    Modello       VARCHAR(100) NOT NULL,
    Alimentazione ENUM ('Benzina','Diesel','Elettrica','Ibrida','Ibrida Plug-in','GPL','Metano','Idrogeno') NOT NULL,
    Potenza       INT NOT NULL COMMENT 'Potenza in CV',
    Cambio        ENUM ('Manuale','Automatico','Sequenziale','CVT','Doppia Frizione') NOT NULL,
    Cilindrata    INT NOT NULL COMMENT 'Cilindrata in cc',
    Prezzo_base   DECIMAL(10,2) NOT NULL,
    Link_acquisto VARCHAR(255) NOT NULL,
    Immagine_url  VARCHAR(255) NOT NULL
);

CREATE INDEX idx_alimentazione ON auto (Alimentazione);
CREATE INDEX idx_cambio        ON auto (Cambio);
CREATE INDEX idx_cilindrata    ON auto (Cilindrata);
CREATE INDEX idx_marca         ON auto (Marchio);
CREATE INDEX idx_modello       ON auto (Modello);
CREATE INDEX idx_potenza       ON auto (Potenza);
CREATE INDEX idx_prezzo        ON auto (Prezzo_base);

CREATE TABLE allestimento
(
    ID_allestimento          INT AUTO_INCREMENT PRIMARY KEY,
    ID_auto                  INT NOT NULL,
    Nome_allestimento        VARCHAR(100) NOT NULL,
    Descrizione_allestimento TEXT NOT NULL,
    Prezzo_allestimento      DECIMAL(10,2) NOT NULL,
    CONSTRAINT allestimento_ibfk_1 FOREIGN KEY (ID_auto) REFERENCES auto(ID_auto) ON DELETE CASCADE
);

CREATE INDEX idx_id_auto ON allestimento (ID_auto);

CREATE TABLE accessorio_allestimento
(
    ID_accessorio_allestimento INT AUTO_INCREMENT PRIMARY KEY,
    ID_allestimento            INT NOT NULL,
    Tipo                       VARCHAR(100) NOT NULL,
    CONSTRAINT accessorio_allestimento_ibfk_1 FOREIGN KEY (ID_allestimento) REFERENCES allestimento(ID_allestimento) ON DELETE CASCADE
);

CREATE INDEX idx_id_allestimento_accessorio ON accessorio_allestimento (ID_allestimento);

CREATE TABLE utente
(
    ID_utente    INT AUTO_INCREMENT PRIMARY KEY,
    Nome         VARCHAR(50) NOT NULL,
    Cognome      VARCHAR(50) NOT NULL,
    Email        VARCHAR(100) NOT NULL UNIQUE,
    Ruolo        ENUM('ADMIN','UTENTE') NOT NULL DEFAULT 'UTENTE',
    Password     VARCHAR(128) NOT NULL COMMENT 'Password hash (compatibilità)',
    passwordhash VARCHAR(64) NULL COMMENT 'SHA-256 esadecimale',
    password_test VARCHAR(255) NULL
);

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

CREATE TABLE confronto
(
    ID_confronto   INT AUTO_INCREMENT PRIMARY KEY,
    ID_utente      INT NOT NULL,
    Nome_confronto VARCHAR(100) NOT NULL,
    Data_creazione DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT confronto_ibfk_1 FOREIGN KEY (ID_utente) REFERENCES utente(ID_utente) ON DELETE CASCADE
);

CREATE INDEX idx_id_utente_confronto ON confronto (ID_utente);

CREATE TABLE confronto_auto
(
    ID_confronto    INT NOT NULL,
    ID_allestimento INT NOT NULL,
    PRIMARY KEY (ID_confronto, ID_allestimento),
    CONSTRAINT confronto_auto_ibfk_1 FOREIGN KEY (ID_confronto) REFERENCES confronto(ID_confronto) ON DELETE CASCADE,
    CONSTRAINT confronto_auto_ibfk_2 FOREIGN KEY (ID_allestimento) REFERENCES allestimento(ID_allestimento) ON DELETE CASCADE
);

CREATE INDEX idx_allestimento_confronto ON confronto_auto (ID_allestimento);

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

CREATE INDEX idx_data_ordine         ON ordine (Data_ordine);
CREATE INDEX idx_id_allestimento_ord ON ordine (ID_allestimento);
CREATE INDEX idx_id_utente_ordine   ON ordine (ID_utente);

CREATE TABLE preferenza_utente
(
    ID_preferenza      INT AUTO_INCREMENT PRIMARY KEY,
    ID_utente          INT NOT NULL,
    Marchio_pref       VARCHAR(50) NULL,
    Modello_pref       VARCHAR(100) NULL,
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

CREATE TABLE ricerca_salvata
(
    ID_ricerca        INT AUTO_INCREMENT PRIMARY KEY,
    ID_utente         INT NOT NULL,
    Nome_ricerca      VARCHAR(100) NOT NULL,
    Parametri_ricerca JSON NOT NULL COMMENT 'JSON con parametri di ricerca',
    Data_ricerca      DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ricerca_salvata_ibfk_1 FOREIGN KEY (ID_utente) REFERENCES utente(ID_utente) ON DELETE CASCADE
);

CREATE INDEX idx_id_utente_ricerca ON ricerca_salvata (ID_utente);

-- ======================
-- DATI: INSERT INTO auto
-- ======================
USE autoquest;

INSERT INTO auto (Marchio, Modello, Alimentazione, Potenza, Cambio, Cilindrata, Prezzo_base, Link_acquisto, Immagine_url) VALUES
                                                                                                                              ('Audi', 'A3 Sportback', 'Benzina', 150, 'Automatico', 1498, 32850.00, 'https://www.audi.it/it/web/it/modelli/a3/a3-sportback.html', 'images/auto/audi_a3.jpg'),
                                                                                                                              ('Audi', 'Q5', 'Diesel', 204, 'Automatico', 1968, 67350.00, 'https://www.audi.it/it/web/it/modelli/q5/q5.html', 'images/auto/audi_q5.jpg'),
                                                                                                                              ('Audi', 'e-tron GT', 'Elettrica', 476, 'Automatico', 0, 126000.00, 'https://www.audi.it/it/modelli/e-tron-gt/', 'images/auto/audi_etron_gt.jpg'),
                                                                                                                              ('BMW', 'Serie 3', 'Diesel', 190, 'Automatico', 1995, 48500.00, 'https://www.bmw.it/it/configuratore.html', 'images/auto/bmw_serie3.jpg'),
                                                                                                                              ('BMW', 'iX', 'Elettrica', 326, 'Automatico', 0, 86000.00, 'https://www.bmw.it/it/configuratore.html', 'images/auto/bmw_ix.jpg'),
                                                                                                                              ('BMW', 'X5', 'Ibrida Plug-in', 394, 'Automatico', 2998, 95500.00, 'https://www.bmw.it/it/configuratore.html', 'images/auto/bmw_x5.jpg'),
                                                                                                                              ('Fiat', '500e', 'Elettrica', 118, 'Automatico', 0, 29950.00, 'https://www.fiat.it/500-elettrica', 'images/auto/fiat_500e.jpg'),
                                                                                                                              ('Fiat', 'Panda', 'GPL', 69, 'Manuale', 1242, 15950.00, 'https://www.fiat.it/panda', 'images/auto/fiat_panda.jpg'),
                                                                                                                              ('Fiat', 'Tipo', 'Diesel', 130, 'Manuale', 1598, 25200.00, 'https://www.fiat.it/tipo', 'images/auto/fiat_tipo.jpg'),
                                                                                                                              ('Ford', 'Kuga', 'Ibrida', 190, 'Automatico', 2488, 38250.00, 'https://www.ford.it/auto/nuova-kuga', 'images/auto/ford_kuga.jpg'),
                                                                                                                              ('Ford', 'Mustang Mach-E', 'Elettrica', 294, 'Automatico', 0, 49900.00, 'https://www.ford.it/acquista/acquista-online/inventario/pv/bev', 'images/auto/ford_mustang_mache.jpg'),
                                                                                                                              ('Ford', 'Explorer', 'Ibrida Plug-in', 457, 'Automatico', 2956, 49000.00, 'https://www.ford.it/auto/explorer-elettrico', 'images/auto/ford_explorer.jpg'),
                                                                                                                              ('Toyota', 'Yaris Cross', 'Ibrida', 116, 'CVT', 1490, 28750.00, 'https://www.toyota.it/gamma/yaris-cross/configura', 'images/auto/toyota_yaris_cross.jpg'),
                                                                                                                              ('Toyota', 'RAV4', 'Ibrida', 222, 'CVT', 2487, 42200.00, 'https://www.toyota.it/gamma/rav4/configura', 'images/auto/toyota_rav4.jpg'),
                                                                                                                              ('Toyota', 'bZ4X', 'Elettrica', 204, 'Automatico', 0, 38500.00, 'https://www.toyota.it/gamma/bz4x/configura', 'images/auto/toyota_bz4x.jpg'),
                                                                                                                              ('Volkswagen', 'Golf', 'Benzina', 130, 'Manuale', 1498, 31600.00, 'https://www.volkswagen.it/it/configuratore.html/__app/nuova-golf.app', 'images/auto/vw_golf.jpg'),
                                                                                                                              ('Volkswagen', 'ID.4', 'Elettrica', 204, 'Automatico', 0, 34900.00, 'https://www.volkswagen.it/it/configuratore.html/__app/id-4.app', 'images/auto/vw_id4.jpg'),
                                                                                                                              ('Volkswagen', 'Tiguan', 'Diesel', 150, 'Doppia Frizione', 1968, 36900.00, 'https://www.volkswagen.it/it/configuratore.html/__app/nuova-tiguan.app', 'images/auto/vw_tiguan.jpg'),
                                                                                                                              ('Tesla', 'Model 3', 'Elettrica', 325, 'Automatico', 0, 40490.00, 'https://www.tesla.com/it_IT/model3/design', 'images/auto/tesla_model3.jpg'),
                                                                                                                              ('Tesla', 'Model Y', 'Elettrica', 347, 'Automatico', 0, 44990.00, 'https://www.tesla.com/it_IT/modely/design', 'images/auto/tesla_modely.jpg'),
                                                                                                                              ('Tesla', 'Model S', 'Elettrica', 670, 'Automatico', 0, 79990.00, 'https://www.tesla.com/it_IT/models/design', 'images/auto/tesla_models.jpg'),
                                                                                                                              ('Mercedes', 'Classe A', 'Benzina', 163, 'Automatico', 1332, 37194.00, 'https://www.mercedes-benz.it/', 'images/auto/mercedes_classe_a.jpg'),
                                                                                                                              ('Mercedes', 'EQE', 'Elettrica', 292, 'Automatico', 0, 68000.00, 'https://www.mercedes-benz.it/', 'images/auto/mercedes_eqe.jpg'),
                                                                                                                              ('Mercedes', 'GLC', 'Diesel', 220, 'Automatico', 1993, 74987.00, 'https://www.mercedes-benz.it/', 'images/auto/mercedes_glc.jpg'),
                                                                                                                              ('Dacia', 'Duster', 'GPL', 100, 'Manuale', 999, 17750.00, 'https://www.dacia.it/gamma/duster.html', 'images/auto/dacia_duster.jpg'),
                                                                                                                              ('Dacia', 'Sandero', 'GPL', 100, 'Manuale', 999, 13950.00, 'https://www.dacia.it/gamma/sandero.html', 'images/auto/dacia_sandero.jpg'),
                                                                                                                              ('Dacia', 'Spring', 'Elettrica', 65, 'Automatico', 0, 17900.00, 'https://www.dacia.it/gamma/spring.html', 'images/auto/dacia_spring.jpg'),
                                                                                                                              ('Jeep', 'Renegade', 'Ibrida', 190, 'Automatico', 1332, 34000.00, 'https://www.jeep-official.it/configuratore/', 'images/auto/jeep_renegade.jpg'),
                                                                                                                              ('Jeep', 'Compass', 'Ibrida Plug-in', 240, 'Automatico', 1332, 47900.00, 'https://www.jeep-official.it/configuratore/', 'images/auto/jeep_compass.jpg'),
                                                                                                                              ('Jeep', 'Avenger', 'Elettrica', 156, 'Automatico', 0, 41900.00, 'https://www.jeep-official.it/configuratore/', 'images/auto/jeep_avenger.jpg'),
                                                                                                                              ('Alfa Romeo', 'Giulia', 'Benzina', 280, 'Automatico', 1995, 52900.00, 'https://www.alfaromeo.it/giulia', 'images/auto/alfa_giulia.jpg'),
                                                                                                                              ('Alfa Romeo', 'Stelvio', 'Diesel', 210, 'Automatico', 2143, 58900.00, 'https://www.alfaromeo.it/stelvio', 'images/auto/alfa_stelvio.jpg'),
                                                                                                                              ('Alfa Romeo', 'Junior', 'Elettrica', 156, 'Automatico', 0, 39500.00, 'https://www.alfaromeo.it/junior', 'images/auto/alfa_junior.jpg'),
                                                                                                                              ('Cupra', 'Formentor', 'Benzina', 150, 'Doppia Frizione', 1498, 35900.00, 'https://www.cupraofficial.it/auto/formentor', 'images/auto/cupra_formentor.jpg'),
                                                                                                                              ('Cupra', 'Born', 'Elettrica', 204, 'Automatico', 0, 39500.00, 'https://www.cupraofficial.it/auto/born', 'images/auto/cupra_born.jpg'),
                                                                                                                              ('Cupra', 'Ateca', 'Benzina', 300, 'Doppia Frizione', 1984, 48900.00, 'https://www.cupraofficial.it/auto/ateca', 'images/auto/cupra_ateca.jpg'),
                                                                                                                              ('Hyundai', 'Tucson', 'Ibrida', 230, 'Automatico', 1598, 36500.00, 'https://www.hyundai.com/it/it/promozioni-offerte/guida-all-acquisto/configuratore.html', 'images/auto/hyundai_tucson.jpg'),
                                                                                                                              ('Hyundai', 'Kona Electric', 'Elettrica', 204, 'Automatico', 0, 36900.00, 'https://www.hyundai.com/it/it/promozioni-offerte/guida-all-acquisto/configuratore.html', 'images/auto/hyundai_kona_electric.jpg'),
                                                                                                                              ('Hyundai', 'IONIQ 5', 'Elettrica', 228, 'Automatico', 0, 45500.00, 'https://www.hyundai.com/it/it/promozioni-offerte/guida-all-acquisto/configuratore.html', 'images/auto/hyundai_ioniq5.jpg'),
                                                                                                                              ('Kia', 'Sportage', 'Ibrida', 230, 'Automatico', 1598, 36500.00, 'https://www.kia.com/it/modelli/sportage/', 'images/auto/kia_sportage.jpg'),
                                                                                                                              ('Kia', 'EV6', 'Elettrica', 229, 'Automatico', 0, 47500.00, 'https://www.kia.com/it/modelli/ev6/', 'images/auto/kia_ev6.jpg'),
                                                                                                                              ('Kia', 'Niro', 'Ibrida Plug-in', 183, 'Doppia Frizione', 1580, 39950.00, 'https://www.kia.com/it/guida-all-acquisto/configuratore/', 'images/auto/kia_niro.jpg'),
                                                                                                                              ('Mazda', 'CX-5', 'Diesel', 184, 'Automatico', 2191, 40500.00, 'https://www.mazda.it/configura-la-tua-mazda/MAZDA%20CX-5/5WGN', 'images/auto/mazda_cx5.jpg'),
                                                                                                                              ('Mazda', 'MX-30', 'Elettrica', 145, 'Automatico', 0, 36900.00, 'https://www.mazda.it/configura-la-tua-mazda/MAZDA%20MX-30/5WGN', 'images/auto/mazda_mx30.jpg'),
                                                                                                                              ('Mazda', 'MX-5', 'Benzina', 184, 'Manuale', 1998, 34500.00, 'https://www.mazda.it/configura-la-tua-mazda/MAZDA%20MX-5/2DR.OPEN', 'images/auto/mazda_mx5.jpg'),
                                                                                                                              ('Nissan', 'Qashqai', 'Ibrida', 158, 'Automatico', 1332, 33500.00, 'https://www.nissan.it/veicoli/veicoli-nuovi/qashqai.html', 'images/auto/nissan_qashqai.jpg'),
                                                                                                                              ('Nissan', 'Leaf', 'Elettrica', 150, 'Automatico', 0, 32900.00, 'https://www.nissan.it/veicoli/veicoli-nuovi/leaf.html', 'images/auto/nissan_leaf.jpg'),
                                                                                                                              ('Nissan', 'Ariya', 'Elettrica', 218, 'Automatico', 0, 47500.00, 'https://www.nissan.it/veicoli/veicoli-nuovi/ariya.html', 'images/auto/nissan_ariya.jpg'),
                                                                                                                              ('Opel', 'Corsa', 'Elettrica', 136, 'Automatico', 0, 35900.00, 'https://www.opel.it/veicoli/gamma-corsa/nuova-corsa/panoramica.html', 'images/auto/opel_corsa.jpg'),
                                                                                                                              ('Opel', 'Mokka', 'Elettrica', 136, 'Automatico', 0, 37900.00, 'https://www.opel.it/veicoli/gamma-mokka/nuovo-mokka/panoramica.html', 'images/auto/opel_mokka.jpg'),
                                                                                                                              ('Opel', 'Grandland', 'Ibrida Plug-in', 300, 'Automatico', 1598, 48900.00, 'https://www.opel.it/veicoli/nuova-gamma-grandland/nuovo-grandland/panoramica.html', 'images/auto/opel_grandland.jpg'),
                                                                                                                              ('Peugeot', '208', 'Elettrica', 136, 'Automatico', 0, 33900.00, 'https://store.peugeot.it/configurable', 'images/auto/peugeot_208.jpg'),
                                                                                                                              ('Peugeot', '2008', 'Elettrica', 136, 'Automatico', 0, 36900.00, 'https://store.peugeot.it/configurable', 'images/auto/peugeot_2008.jpg'),
                                                                                                                              ('Peugeot', '3008', 'Ibrida Plug-in', 300, 'Automatico', 1598, 53900.00, 'https://store.peugeot.it/configurable', 'images/auto/peugeot_3008.jpg'),
                                                                                                                              ('Renault', 'Clio', 'Ibrida', 145, 'Automatico', 1598, 23950.00, 'https://www.renault.it/configuratore-gamma.html', 'images/auto/renault_clio.jpg'),
                                                                                                                              ('Renault', 'Captur', 'Ibrida Plug-in', 160, 'Automatico', 1598, 31950.00, 'https://www.renault.it/configuratore-gamma.html', 'images/auto/renault_captur.jpg'),
                                                                                                                              ('Renault', 'Megane E-Tech', 'Elettrica', 218, 'Automatico', 0, 39950.00, 'https://www.renault.it/configuratore-gamma.html', 'images/auto/renault_megane_etech.jpg'),
                                                                                                                              ('Skoda', 'Octavia', 'Diesel', 150, 'Doppia Frizione', 1968, 29900.00, 'https://cc.skoda-auto.com/ita/it-it?pagegroup=Website&salesprogram=ITA&type=Car%20configurator', 'images/auto/skoda_octavia.jpg'),
                                                                                                                              ('Skoda', 'Enyaq', 'Elettrica', 204, 'Automatico', 0, 46500.00, 'https://cc.skoda-auto.com/ita/it-it?pagegroup=Website&salesprogram=ITA&type=Car%20configurator', 'images/auto/skoda_enyaq.jpg'),
                                                                                                                              ('Skoda', 'Kamiq', 'Benzina', 110, 'Manuale', 999, 23950.00, 'https://cc.skoda-auto.com/ita/it-it?pagegroup=Website&salesprogram=ITA&type=Car%20configurator', 'images/auto/skoda_kamiq.jpg'),
                                                                                                                              ('Seat', 'Leon', 'Benzina', 130, 'Manuale', 1498, 25900.00, 'https://www.seat-italia.it/modelli/leon.html', 'images/auto/seat_leon.jpg'),
                                                                                                                              ('Seat', 'Ibiza', 'Benzina', 95, 'Manuale', 999, 19900.00, 'https://www.seat-italia.it/modelli/ibiza.html', 'images/auto/seat_ibiza.jpg'),
                                                                                                                              ('Seat', 'Ateca', 'Diesel', 150, 'Doppia Frizione', 1968, 33900.00, 'https://www.seat-italia.it/configuratore', 'images/auto/seat_ateca.jpg'),
                                                                                                                              ('Volvo', 'XC40', 'Ibrida Plug-in', 211, 'Automatico', 1477, 47950.00, 'https://www.volvocars.com/it/cars/xc40/', 'images/auto/volvo_xc40.jpg'),
                                                                                                                              ('Volvo', 'XC60', 'Ibrida Plug-in', 350, 'Automatico', 1969, 70850.00, 'https://www.volvocars.com/it/cars/xc60/', 'images/auto/volvo_xc60.jpg'),
                                                                                                                              ('Volvo', 'C40 Recharge', 'Elettrica', 231, 'Automatico', 0, 51950.00, 'https://www.volvocars.com/it/build', 'images/auto/volvo_c40.jpg'),
                                                                                                                              ('Porsche', 'Taycan', 'Elettrica', 408, 'Automatico', 0, 93471.00, 'https://configurator.porsche.com/it-IT/model-start/', 'images/auto/porsche_taycan.jpg'),
                                                                                                                              ('Porsche', '911', 'Benzina', 385, 'Doppia Frizione', 2981, 133602.00, 'https://www.porsche.com/italy/models/911/911-models/', 'images/auto/porsche_911.jpg'),
                                                                                                                              ('Porsche', 'Cayenne', 'Ibrida Plug-in', 462, 'Automatico', 2995, 103166.00, 'https://configurator.porsche.com/it-IT/model-start/', 'images/auto/porsche_cayenne.jpg'),
                                                                                                                              ('Jaguar', 'F-PACE', 'Diesel', 204, 'Automatico', 1997, 66880.00, 'https://www.jaguar.it/jaguar-range/f-pace/index.html', 'images/auto/jaguar_fpace.jpg'),
                                                                                                                              ('Jaguar', 'I-PACE', 'Elettrica', 400, 'Automatico', 0, 85050.00, 'https://www.jaguar.it/jaguar-range/i-pace/index.html', 'images/auto/jaguar_ipace.jpg'),
                                                                                                                              ('Jaguar', 'F-TYPE', 'Benzina', 450, 'Automatico', 5000, 94460.00, 'https://www.jaguar.it/jaguar-range/f-type/index.html', 'images/auto/jaguar_ftype.jpg');

-- ======================
-- INSERT INTO allestimento (seguono molte righe)
-- ======================
INSERT INTO allestimento (ID_auto, Nome_allestimento, Descrizione_allestimento, Prezzo_allestimento) VALUES
                                                                                                         (1, 'Business', 'Versione che offre un equilibrio perfetto tra comfort e tecnologia, con dotazioni pensate per il pendolare esigente. Include elementi di praticità quotidiana senza rinunciare all''eleganza tipica del marchio.', 2500.00),
                                                                                                         (1, 'S line', 'Versione dal carattere decisamente sportivo che esalta il dinamismo della A3, con finiture esterne ed interne più grintose e tecnologia avanzata per un''esperienza di guida superiore.', 5200.00),
                                                                                                         (2, 'Business Advanced', 'Versione che eleva lo standard di comfort per il professionista in movimento, con tecnologie intuitive e sistemi di assistenza che semplificano ogni viaggio.', 3800.00),
                                                                                                         (2, 'S line plus', 'Versione premium che combina prestazioni sportive e lusso, con tecnologie all''avanguardia e finiture di alta qualità per chi non accetta compromessi.', 7500.00),
                                                                                                         (3, 'Executive', 'Versione che interpreta l''eleganza elettrica in chiave business, con un''attenzione particolare al comfort e alla tecnologia per lunghi spostamenti.', 6200.00),
                                                                                                         (3, 'Performance', 'Versione che esalta il DNA sportivo della e-tron GT, con componenti derivati dal motorsport e tecnologie esclusive per prestazioni elettrizzanti.', 14500.00),
                                                                                                         (4, 'Business Advantage', 'Versione studiata per il professionista moderno, che offre il meglio della tecnologia bavarese in un pacchetto equilibrato ed efficiente per l''uso quotidiano.', 3200.00),
                                                                                                         (4, 'MSport', 'Versione che porta il DNA sportivo di BMW sulle strade di tutti i giorni, con un carattere più dinamico e un''estetica che richiama le auto da competizione del marchio.', 6800.00),
                                                                                                         (5, 'xLine', 'Versione che interpreta il lusso sostenibile in chiave tecnologica, con un''esperienza digitale avanzata e comfort di alto livello per tutti gli occupanti.', 4500.00),
                                                                                                         (5, 'Sport', 'Versione che dimostra come la mobilità elettrica possa essere emozionante, con un carattere più dinamico e soluzioni estetiche e funzionali che esaltano le prestazioni.', 9800.00),
                                                                                                         (6, 'xLine', 'Versione che esalta l''eleganza robusta del SUV bavarese, con elementi di design distintivi e tecnologie intuitive per ogni tipo di viaggio.', 4200.00),
                                                                                                         (6, 'MSport Pro', 'Versione che trasforma il grande SUV in un''auto dalle sorprendenti doti dinamiche, con assetto e componenti derivati dal motorsport per prestazioni entusiasmanti.', 8500.00),
                                                                                                         (7, 'Red', 'Versione che unisce stile italiano ed ecosostenibilità, con un carattere vivace e tecnologie intuitive per la mobilità urbana moderna.', 1800.00),
                                                                                                         (7, 'La Prima', 'Versione flagship che rappresenta il massimo dell''eleganza cittadina a zero emissioni, con finiture pregiate e tecnologie avanzate per un''esperienza premium.', 4500.00),
                                                                                                         (8, 'City Life', 'Versione che modernizza il concetto di city car con un tocco di stile e tecnologie pratiche per semplificare la vita quotidiana in città.', 1200.00),
                                                                                                         (8, 'Cross', 'Versione con spirito avventuroso che non teme le strade più difficili, grazie a protezioni specifiche e sistemi di trazione avanzati.', 2500.00),
                                                                                                         (9, 'City Life', 'Versione che offre un ottimo rapporto qualità-prezzo con dotazioni tecnologiche moderne e comfort per tutta la famiglia.', 1500.00),
                                                                                                         (9, 'Cross', 'Versione dal carattere più avventuroso con assetto rialzato e protezioni che permettono di affrontare con sicurezza anche percorsi più impegnativi.', 3200.00),
                                                                                                         (10, 'Titanium', 'Versione che rappresenta il perfetto equilibrio tra eleganza e praticità, con dotazioni tecnologiche che semplificano la vita a bordo.', 2800.00),
                                                                                                         (10, 'ST-Line X', 'Versione che combina l''anima sportiva con il lusso, offrendo un''esperienza di guida dinamica senza rinunciare al comfort premium.', 5500.00),
                                                                                                         (11, 'Premium', 'Versione che reinterpreta il mito Mustang in chiave elettrica e lussuosa, con tecnologie all''avanguardia e finiture di alto livello.', 4500.00),
                                                                                                         (11, 'GT', 'Versione ad alte prestazioni che mantiene vivo lo spirito della muscle car anche in formato elettrico, con accelerazioni brucianti e handling sportivo.', 8900.00),
                                                                                                         (12, 'ST-Line', 'Versione che dona un carattere più dinamico al grande SUV americano, con elementi sportivi che ne esaltano la presenza su strada.', 5200.00),
                                                                                                         (12, 'Platinum', 'Versione che rappresenta il massimo del lusso alla maniera americana, con materiali pregiati e tecnologie avanzate per un comfort superiore.', 9800.00),
                                                                                                         (13, 'Active Tech', 'Versione che offre un eccellente equilibrio tra tecnologia e praticità quotidiana, ideale per la mobilità urbana e le gite fuoriporta.', 1800.00),
                                                                                                         (13, 'Premiere', 'Versione top di gamma che eleva il concetto di crossover compatto con finiture premium e tecnologie avanzate normalmente riservate a segmenti superiori.', 4200.00),
                                                                                                         (14, 'Style', 'Versione che combina eleganza e funzionalità, con dotazioni tecnologiche complete per affrontare con stile ogni tipo di viaggio.', 2900.00),
                                                                                                         (14, 'Lounge', 'Versione che trasforma il SUV ibrido in un''esperienza premium, con materiali raffinati e tecnologie avanzate per il massimo comfort.', 5800.00),
                                                                                                         (15, 'Pure', 'Versione che introduce al mondo della mobilità elettrica Toyota con un approccio razionale e funzionale, senza rinunciare alle tecnologie essenziali.', 2500.00),
                                                                                                         (15, 'First Edition', 'Versione speciale che celebra l''ingresso di Toyota nel mondo dell''elettrico puro con dotazioni esclusive e tecnologie all''avanguardia.', 6500.00),
                                                                                                         (16, 'Life', 'Versione che rappresenta l''equilibrio perfetto della compatta tedesca, con tutte le tecnologie essenziali per un''esperienza di guida moderna.', 1800.00),
                                                                                                         (16, 'R-Line', 'Versione che dona un carattere più sportivo all''iconica compatta, con elementi estetici e dinamici ispirati alle versioni più performanti.', 4200.00),
                                                                                                         (17, 'Pro', 'Versione che introduce al mondo elettrico Volkswagen con un approccio razionale ma completo, con tecnologie intuitive per una transizione senza stress.', 3200.00),
                                                                                                         (17, 'GTX', 'Versione sportiva che porta la filosofia GTI nel mondo elettrico, con doppio motore per prestazioni entusiasmanti e un carattere decisamente dinamico.', 7500.00),
                                                                                                         (18, 'Business', 'Versione pensata per il professionista moderno, con tecnologie intuitive che facilitano sia gli spostamenti lavorativi che il tempo libero.', 2500.00),
                                                                                                         (18, 'R-Line', 'Versione che conferisce un carattere sportivo al SUV tedesco, con elementi estetici e dinamici che esaltano le sue doti stradali.', 5800.00),
                                                                                                         (19, 'Autonomy Upgrade', 'Versione che potenzia l''esperienza di guida semi-autonoma con tecnologie avanzate e interni premium per viaggi più rilassanti e confortevoli.', 4500.00),
                                                                                                         (19, 'Full Self-Driving', 'Versione all''avanguardia della tecnologia di guida autonoma, che trasforma l''esperienza al volante con funzionalità avanzate e prestazioni superiori.', 9500.00),
                                                                                                         (20, 'Enhanced Autopilot', 'Versione che eleva l''esperienza di guida del crossover elettrico con funzionalità avanzate di assistenza che semplificano ogni viaggio.', 3800.00),
                                                                                                         (20, 'Performance', 'Versione ad alte prestazioni che dimostra come un SUV elettrico possa offrire accelerazioni e handling degni di una sportiva.', 8200.00),
                                                                                                         (21, 'Premium Connectivity', 'Versione che esalta l''esperienza digitale e di comfort della berlina elettrica di riferimento, con connettività avanzata e materiali pregiati.', 5000.00),
                                                                                                         (21, 'Plaid', 'Versione estrema che ridefinisce il concetto di berlina sportiva elettrica, con prestazioni da supercar e tecnologie all''avanguardia.', 20000.00),
                                                                                                         (22, 'Executive', 'Versione che porta il lusso Mercedes in formato compatto, con tecnologie intuitive e comfort superiore per gli spostamenti quotidiani.', 2800.00),
                                                                                                         (22, 'AMG Line', 'Versione che infonde il DNA sportivo AMG nella compatta della stella, con elementi estetici e dinamici che ne esaltano il carattere.', 6200.00),
                                                                                                         (23, 'Electric Art', 'Versione che interpreta la mobilità elettrica premium in chiave artistica, con design ricercato e tecnologie all''avanguardia per un''esperienza unica.', 5800.00),
                                                                                                         (23, 'AMG Line', 'Versione che dimostra come l''elettrico possa essere emozionante, con un carattere sportivo e prestazioni dinamiche superiori.', 11500.00),
                                                                                                         (24, 'Advanced Plus', 'Versione che offre un''esperienza Mercedes completa nel formato SUV di medie dimensioni, con tecnologie avanzate per comfort e sicurezza.', 4200.00),
                                                                                                         (24, 'Premium Pro', 'Versione che eleva il concetto di SUV premium con finiture esclusive e tecnologie all''avanguardia per un''esperienza di lusso totale.', 9800.00),
                                                                                                         (25, 'Comfort', 'Versione che dimostra come praticità e comfort possano essere accessibili, con dotazioni complete per affrontare ogni tipo di strada.', 1200.00),
                                                                                                         (25, 'Prestige', 'Versione top di gamma che arricchisce il SUV economico con tecnologie avanzate e finiture di qualità superiore senza compromettere il valore.', 2500.00),
                                                                                                         (26, 'Essential', 'Versione che offre tutto il necessario per la mobilità moderna a un prezzo accessibile, con un approccio razionale e funzionale.', 800.00),
                                                                                                         (26, 'Comfort', 'Versione che eleva l''esperienza a bordo con dotazioni aggiuntive che aumentano il comfort quotidiano senza appesantire il budget.', 1800.00),
                                                                                                         (27, 'Comfort', 'Versione che rende l''elettrico accessibile a tutti con un approccio pratico e razionale, mantenendo le tecnologie essenziali per la mobilità moderna.', 900.00),
                                                                                                         (27, 'Extreme', 'Versione che aggiunge un tocco di carattere alla city car elettrica economica, con elementi distintivi e tecnologie aggiuntive per un''esperienza superiore.', 1800.00),
                                                                                                         (28, 'Limited', 'Versione che combina il DNA avventuroso Jeep con dotazioni tecnologiche moderne e finiture di qualità per un uso versatile.', 2800.00),
                                                                                                         (28, 'Trailhawk', 'Versione hardcore che esalta le capacità fuoristradistiche del piccolo SUV, pronta ad affrontare i percorsi più impegnativi con tecnologie specifiche.', 5500.00),
                                                                                                         (29, 'Limited', 'Versione che offre un''esperienza Jeep completa con dotazioni tecnologiche avanzate e comfort superiore per viaggi rilassanti.', 3500.00),
                                                                                                         (29, 'S', 'Versione premium che eleva il concetto di SUV medio con finiture eleganti e tecnologie all''avanguardia, senza rinunciare al DNA Jeep.', 6800.00),
                                                                                                         (30, 'Longitude', 'Versione che introduce al mondo Jeep con un formato compatto ma dotazioni complete, ideale per l''avventura urbana e oltre.', 2200.00),
                                                                                                         (30, 'Summit', 'Versione top di gamma che trasforma il SUV compatto in un''esperienza premium, con tecnologie avanzate e finiture di alta qualità.', 4800.00),
                                                                                                         (31, 'Sprint', 'Versione che esalta il DNA sportivo italiano con un carattere dinamico ma accessibile, ideale per chi cerca emozioni nella guida quotidiana.', 3200.00),
                                                                                                         (31, 'Veloce', 'Versione ad alte prestazioni che offre un''esperienza di guida esaltante, con componenti derivati dal motorsport e finiture sportive di alta qualità.', 7500.00),
                                                                                                         (32, 'Sprint', 'Versione che porta il carattere sportivo Alfa Romeo nel mondo dei SUV, con un''attenzione particolare alla dinamica di guida e al piacere di viaggiare.', 3500.00),
                                                                                                         (32, 'Veloce', 'Versione che eleva le prestazioni del SUV italiano a livelli sorprendenti, con un carattere decisamente sportivo e tecnologie avanzate.', 8200.00),
                                                                                                         (33, 'Super', 'Versione che introduce al mondo Alfa con un approccio fresco e moderno, mantenendo il DNA sportivo del marchio in formato compatto.', 2500.00),
                                                                                                         (33, 'Veloce', 'Versione che esalta il carattere sportivo della compatta italiana con elementi distintivi e prestazioni superiori per una guida coinvolgente.', 5200.00),
                                                                                                         (34, 'V1', 'Versione che introduce al mondo Cupra con un carattere distintivo e sportivo, offrendo tecnologie avanzate e un design anticonvenzionale.', 2800.00),
                                                                                                         (34, 'VZ', 'Versione ad alte prestazioni che trasforma il crossover in una vera sportiva, con componenti specifici per un''esperienza di guida entusiasmante.', 6500.00),
                                                                                                         (35, 'V', 'Versione che interpreta la mobilità elettrica in chiave sportiva, con un carattere dinamico che sfida le convenzioni delle auto a batteria.', 3200.00),
                                                                                                         (35, 'VZ', 'Versione che porta l''elettrico a un nuovo livello di sportività, con componenti specifici per il massimo delle prestazioni e dell''emozione.', 6800.00),
                                                                                                         (36, 'V1', 'Versione che trasforma il SUV compatto in un''auto dal carattere sportivo e distintivo, con tecnologie avanzate e un''estetica grintosa.', 3500.00),
                                                                                                         (36, 'VZ', 'Versione estrema che sfida il concetto di SUV, con componenti derivati dal motorsport e prestazioni sorprendenti per la categoria.', 7800.00),
                                                                                                         (37, 'XLine', 'Versione che offre un''esperienza completa e moderna nel formato SUV medio, con tecnologie intuitive e design all''avanguardia.', 2500.00),
                                                                                                         (37, 'Excellence', 'Versione che eleva il concetto di SUV coreano a livelli premium, con finiture ricercate e tecnologie normalmente riservate a segmenti superiori.', 5800.00),
                                                                                                         (38, 'XPrime', 'Versione che rende l''elettrico accessibile e pratico, con tecnologie avanzate e un''autonomia ideale per l''uso quotidiano.', 2800.00),
                                                                                                         (38, 'Excellence', 'Versione che trasforma l''elettrico in un''esperienza premium, con finiture di alta qualità e tecnologie all''avanguardia per un comfort superiore.', 5200.00),
                                                                                                         (39, 'Progress', 'Versione che introduce alla mobilità elettrica di nuova generazione con un design rivoluzionario e tecnologie avanzate.', 3200.00),
                                                                                                         (39, 'Evolution', 'Versione che rappresenta il massimo dell''esperienza elettrica moderna, con dotazioni premium e tecnologie all''avanguardia.', 6800.00),
                                                                                                         (40, 'Business', 'Versione che offre un ottimo equilibrio tra tecnologia e praticità, ideale per chi cerca un SUV completo senza eccessi.', 2200.00),
                                                                                                         (40, 'GT-Line', 'Versione dal carattere più dinamico che combina l''aspetto sportivo con tecnologie avanzate e comfort per tutti gli occupanti.', 5500.00),
                                                                                                         (41, 'Earth', 'Versione che interpreta la mobilità elettrica con un approccio futuristico ma accessibile, con tecnologie intuitive per un''esperienza senza stress.', 3500.00),
                                                                                                         (41, 'GT-Line', 'Versione che aggiunge un carattere sportivo all''elettrico di nuova generazione, con elementi estetici distintivi e tecnologie avanzate.', 7200.00),
                                                                                                         (42, 'Style', 'Versione che offre un approccio moderno alla mobilità sostenibile, con tecnologie intuitive e dotazioni complete per l''uso quotidiano.', 2500.00),
                                                                                                         (42, 'Evolution', 'Versione che eleva l''esperienza ibrida a livelli premium, con finiture di alta qualità e tecnologie avanzate per il massimo comfort.', 5200.00),
                                                                                                         (43, 'Exclusive', 'Versione che interpreta il SUV medio con un''eleganza tipicamente giapponese, con materiali di qualità superiore e tecnologie intuitive.', 2800.00),
                                                                                                         (43, 'Homura', 'Versione dal carattere più sportivo e deciso, con elementi estetici distintivi e dotazioni tecnologiche avanzate per un''esperienza superiore.', 5500.00),
                                                                                                         (44, 'Executive', 'Versione che introduce all''elettrico con un approccio originale e ricercato, con materiali sostenibili e tecnologie intuitive.', 2500.00),
                                                                                                         (44, 'Makoto', 'Versione che rappresenta la filosofia Mazda al suo meglio, con materiali premium sostenibili e un''attenzione ai dettagli tipicamente giapponese.', 5200.00),
                                                                                                         (45, 'Exceed', 'Versione che offre l''essenza della roadster più venduta al mondo, con un equilibrio perfetto tra dotazioni e leggerezza.', 2200.00),
                                                                                                         (45, 'Sport', 'Versione che esalta il carattere puramente sportivo dell''iconica roadster, con componenti specifici per prestazioni ancora più entusiasmanti.', 5800.00),
                                                                                                         (46, 'Acenta', 'Versione che offre un''esperienza completa nel crossover che ha inventato la categoria, con tecnologie intuitive per la famiglia moderna.', 2200.00),
                                                                                                         (46, 'Tekna+', 'Versione che eleva il concetto di crossover a livelli premium, con finiture ricercate e tecnologie all''avanguardia normalmente riservate a segmenti superiori.', 6800.00),
                                                                                                         (47, 'Acenta', 'Versione che offre un''esperienza elettrica accessibile e completa, con tecnologie intuitive che semplificano la transizione verso la mobilità a zero emissioni.', 2000.00),
                                                                                                         (47, 'Tekna', 'Versione che arricchisce l''esperienza elettrica con tecnologie avanzate e finiture di qualità superiore per un comfort ottimale.', 5200.00),
                                                                                                         (48, 'Advance', 'Versione che introduce al nuovo corso elettrico Nissan con un carattere moderno e tecnologie avanzate per un''esperienza completa.', 3200.00),
                                                                                                         (48, 'Evolve', 'Versione che rappresenta il massimo dell''esperienza elettrica Nissan, con finiture premium e tecnologie all''avanguardia per reinventare la mobilità.', 7500.00),
                                                                                                         (49, 'GS', 'Versione che dona un carattere più sportivo alla compatta tedesca, con elementi distintivi e tecnologie moderne per un''esperienza di guida coinvolgente.', 1800.00),
                                                                                                         (49, 'Ultimate', 'Versione top di gamma che trasforma la compatta in un''auto premium, con tecnologie avanzate normalmente riservate a segmenti superiori.', 4200.00),
                                                                                                         (50, 'GS', 'Versione che interpreta il crossover compatto con personalità decisa e tecnologie intuitive per un''esperienza moderna e distintiva.', 2200.00),
                                                                                                         (50, 'Ultimate', 'Versione che eleva il concetto di crossover urbano con dotazioni di livello superiore e tecnologie all''avanguardia per un''esperienza premium.', 4800.00),
                                                                                                         (51, 'GS', 'Versione che offre un''esperienza completa nel SUV tedesco, con tecnologie intuitive e un design distintivo per famiglie moderne.', 2800.00),
                                                                                                         (51, 'Ultimate', 'Versione che rappresenta il massimo dell''esperienza Opel, con tecnologie esclusive e finiture di alta qualità per un comfort superiore.', 6500.00),
                                                                                                         (52, 'GT', 'Versione che interpreta la compatta francese in chiave sportiva, con elementi distintivi e tecnologie avanzate per un''esperienza coinvolgente.', 2200.00),
                                                                                                         (52, 'GT Premium', 'Versione che eleva il concetto di compatta a livelli premium, con finiture raffinate e tecnologie all''avanguardia per un''esperienza superiore.', 4500.00),
                                                                                                         (53, 'GT', 'Versione che dona un carattere sportivo al crossover compatto, con elementi distintivi e tecnologie avanzate per un''esperienza moderna.', 2500.00),
                                                                                                         (53, 'GT Premium', 'Versione che rappresenta il massimo dell''esperienza Peugeot, con finiture esclusive e tecnologie all''avanguardia per un comfort superiore.', 5200.00),
                                                                                                         (54, 'GT', 'Versione che interpreta il SUV in chiave sportiva, con un carattere distintivo e tecnologie avanzate per un''esperienza di guida coinvolgente.', 3500.00),
                                                                                                         (54, 'GT Premium', 'Versione che eleva il concetto di SUV a livelli premium, con dotazioni esclusive e tecnologie all''avanguardia per un''esperienza di lusso.', 7200.00),
                                                                                                         (55, 'Techno', 'Versione che porta la tecnologia al centro dell''esperienza della compatta francese, con dotazioni avanzate e un design moderno.', 1500.00),
                                                                                                         (55, 'R.S. Line', 'Versione ispirata al mondo delle competizioni che dona un carattere sportivo alla Clio, con elementi distintivi e un''esperienza di guida più coinvolgente.', 3200.00),
                                                                                                         (56, 'Techno', 'Versione che offre un''esperienza tecnologica completa nel crossover compatto, con soluzioni intuitive per la mobilità moderna.', 1800.00),
                                                                                                         (56, 'R.S. Line', 'Versione dal carattere sportivo che trasforma il crossover in un''auto più dinamica, con elementi estetici distintivi e tecnologie avanzate.', 3800.00),
                                                                                                         (57, 'Techno', 'Versione che introduce alla nuova era elettrica Renault con un approccio tecnologico avanzato e soluzioni pratiche per la mobilità quotidiana.', 2500.00),
                                                                                                         (57, 'Iconic', 'Versione che rappresenta il massimo dell''esperienza elettrica Renault, con finiture premium e tecnologie all''avanguardia per reinventare la mobilità.', 5800.00),
                                                                                                         (58, 'Executive', 'Versione che offre un ottimo equilibrio tra tecnologia e praticità, ideale per chi cerca una vettura completa senza eccessi.', 1800.00),
                                                                                                         (58, 'RS', 'Versione ad alte prestazioni che trasforma la pratica Octavia in un''auto sportiva per famiglie, con prestazioni entusiasmanti e carattere deciso.', 5200.00),
                                                                                                         (59, 'Loft', 'Versione che introduce all''elettrico Skoda con un approccio razionale ma completo, con interni spaziosi e tecnologie intuitive.', 2800.00),
                                                                                                         (59, 'Suite', 'Versione che eleva l''esperienza elettrica a livelli premium, con materiali raffinati e tecnologie avanzate per un comfort superiore.', 6500.00),
                                                                                                         (60, 'Executive', 'Versione che offre tutte le tecnologie essenziali nel formato crossover compatto, con un approccio razionale e funzionale.', 1500.00),
                                                                                                         (60, 'Monte Carlo', 'Versione dal carattere sportivo ispirata al mondo del rally, con elementi estetici distintivi e dotazioni tecnologiche avanzate.', 3800.00),
                                                                                                         (61, 'Style', 'Versione che offre un''esperienza completa e moderna nella compatta spagnola, con tecnologie intuitive e un design accattivante.', 1800.00),
                                                                                                         (61, 'FR', 'Versione sportiva che esalta il carattere dinamico della Leon, con elementi distintivi e tecnologie avanzate per un''esperienza di guida coinvolgente.', 4200.00),
                                                                                                         (62, 'Style', 'Versione che rappresenta il perfetto equilibrio nella compatta spagnola, con dotazioni moderne e un design giovane e fresco.', 1500.00),
                                                                                                         (62, 'FR', 'Versione dal carattere più sportivo che trasforma la piccola Ibiza in un''auto dinamica e grintosa, con elementi distintivi e tecnologie moderne.', 3500.00),
                                                                                                         (63, 'Style', 'Versione che offre un''esperienza completa nel SUV compatto spagnolo, con tecnologie intuitive e un design moderno per la famiglia.', 2200.00),
                                                                                                         (63, 'FR', 'Versione sportiva che dona un carattere più dinamico al SUV, con elementi distintivi e tecnologie avanzate per un''esperienza di guida coinvolgente.', 5200.00),
                                                                                                         (64, 'Plus', 'Versione che introduce al mondo premium svedese nel formato SUV compatto, con tecnologie intuitive e sicurezza ai massimi livelli.', 2800.00),
                                                                                                         (64, 'Ultimate', 'Versione che rappresenta il massimo dell''esperienza Volvo, con finiture raffinate e tecnologie all''avanguardia per un comfort superiore in totale sicurezza.', 7500.00),
                                                                                                         (65, 'Plus', 'Versione che offre l''essenza del premium svedese, con tecnologie intuitive e soluzioni pratiche per un lusso accessibile e razionale.', 3500.00),
                                                                                                         (65, 'Ultimate', 'Versione che eleva il concetto di SUV di lusso secondo l''interpretazione svedese, con materiali sostenibili di alta qualità e tecnologie all''avanguardia.', 9800.00),
                                                                                                         (66, 'Plus', 'Versione che interpreta la mobilità elettrica in chiave premium scandinava, con design distintivo e tecnologie intuitive.', 3200.00),
                                                                                                         (66, 'Ultimate', 'Versione che rappresenta il massimo dell''esperienza elettrica Volvo, con finiture esclusive e tecnologie all''avanguardia per reinventare il lusso sostenibile.', 7800.00),
                                                                                                         (67, 'Performance', 'Versione che offre l''essenza dell''esperienza Porsche in formato elettrico, con prestazioni esaltanti e tecnologie avanzate.', 6800.00),
                                                                                                         (67, 'Premium Plus', 'Versione che eleva l''elettrico a livelli di eccellenza assoluta, con dotazioni esclusive e tecnologie all''avanguardia per prestazioni da supercar a zero emissioni.', 18500.00),
                                                                                                         (68, 'Heritage Design', 'Versione che richiama l’eleganza senza tempo delle classiche 911, con interni raffinati e dettagli ispirati alla tradizione Porsche.', 14500.00),
                                                                                                         (68, 'Sport Design', 'Versione che esalta le prestazioni e l’aerodinamica, pensata per chi cerca il massimo in pista e su strada con uno stile grintoso.', 22800.00),
                                                                                                         (69, 'Premium', 'Versione che unisce lusso e comfort per ogni viaggio, con dotazioni pensate per il benessere di guidatore e passeggeri.', 8500.00),
                                                                                                         (69, 'Sport Design', 'Versione che abbina estetica aggressiva e dinamica di guida sportiva, ideale per chi non vuole compromessi tra stile e prestazioni.', 16800.00),
                                                                                                         (70, 'R-Dynamic', 'Versione che coniuga eleganza e sportività con dettagli stilistici distintivi e tecnologie moderne per un’esperienza di guida esaltante.', 5200.00),
                                                                                                         (70, 'SVR', 'Versione che porta al massimo la vocazione sportiva del SUV Jaguar, con prestazioni elevate e un design esclusivo.', 12500.00),
                                                                                                         (71, 'SE', 'Versione che offre un perfetto equilibrio tra tecnologia, comfort e stile, pensata per chi desidera un SUV elettrico completo.', 6800.00),
                                                                                                         (71, 'HSE', 'Versione che rappresenta il top della gamma, per chi cerca il massimo in termini di lusso, innovazione e assistenza alla guida.', 9500.00),
                                                                                                         (72, 'R', 'Versione ad alte prestazioni con motore V8 sovralimentato, sospensioni adattive e design sportivo per un''esperienza di guida straordinaria.', 8500.00),
                                                                                                         (72, 'P450', 'Versione con motore V8 da 450 CV che combina prestazioni entusiasmanti e raffinatezza, perfetta per chi cerca un equilibrio tra sportività e comfort quotidiano.', 7200.00);

-- ======================
-- INSERT INTO accessorio_allestimento
-- (ho mantenuto i valori che hai specificato)
-- ======================
INSERT INTO accessorio_allestimento (ID_allestimento, Tipo) VALUES
                                                                (1, 'Sistema di navigazione'), (1, 'Sensori di parcheggio'),
                                                                (2, 'Cerchi in lega sportivi'), (2, 'Sedili sportivi'),
                                                                (3, 'Head-up display'), (3, 'Sistema audio premium'),
                                                                (4, 'Tetto panoramico'), (4, 'Sedili in pelle'),
                                                                (5, 'Ricarica wireless'), (5, 'Climatizzatore a 4 zone'),
                                                                (6, 'Impianto frenante sportivo'), (6, 'Sistema audio Bang & Olufsen'),
                                                                (7, 'BMW ConnectedDrive'), (7, 'Sistema di assistenza alla guida'),
                                                                (8, 'Cerchi in lega M'), (8, 'Volante sportivo'),
                                                                (9, 'Ricarica rapida DC'), (9, 'Sedili riscaldati'),
                                                                (10, 'Head-up display'), (10, 'Sistema audio Harman Kardon'),
                                                                (11, 'Portellone elettrico'), (11, 'Telecamera 360°'),
                                                                (12, 'Sospensioni adattive'), (12, 'Pacchetto aerodinamico M'),
                                                                (13, 'Sistema infotainment da 10,25""'), (13, 'Caricatore wireless'),
                                                                (14, 'Tetto panoramico'), (14, 'Cerchi in lega da 17""'),
                                                                (15, 'Radio DAB'), (15, 'Bluetooth'),
                                                                (16, 'Sedili con rivestimento outdoor'), (16, 'Sistema Hill Holder'),
                                                                (17, 'Sensori di parcheggio'), (17, 'Cruise control'),
                                                                (18, 'Barre sul tetto'), (18, 'Cerchi in lega da 17""'),
                                                                (19, 'Sistema SYNC 3'), (19, 'Portellone elettrico'),
                                                                (20, 'Sedili sportivi'), (20, 'Sistema audio B&O'),
                                                                (21, 'Tetto panoramico'), (21, 'Sistema di guida assistita'),
                                                                (22, 'Freni Brembo'), (22, 'Sistema audio premium'),
                                                                (23, 'Head-up display'), (23, 'Cerchi in lega da 20""'),
                                                                (24, 'Rivestimenti in pelle trapuntata'), (24, 'Sistema audio B&O'),
                                                                (25, 'Sistema multimediale Toyota Touch'), (25, 'Telecamera posteriore'),
                                                                (26, 'Head-up display'), (26, 'Tetto bicolore'),
                                                                (27, 'Sistema Toyota Safety Sense'), (27, 'Apple CarPlay/Android Auto'),
                                                                (28, 'Tetto panoramico'), (28, 'Sistema audio JBL'),
                                                                (29, 'Pompa di calore'), (29, 'Sistema multimediale da 12,3""'),
                                                                (30, 'Sistema di ricarica bidirezionale'), (30, 'Head-up display'),
                                                                (31, 'Digital Cockpit'), (31, 'App-Connect'),
                                                                (32, 'Cerchi in lega da 18""'), (32, 'Fari LED Plus'),
                                                                (33, 'Climatizzatore automatico bizona'), (33, 'Illuminazione ambiente a 30 colori'),
                                                                (34, 'Sistema audio premium'), (34, 'Trazione integrale'),
                                                                (35, 'Navigatore Discover Media'), (35, 'Portellone elettrico'),
                                                                (36, 'Assetto sportivo'), (36, 'Virtual Cockpit Pro'),
                                                                (37, 'Sistema Premium Connectivity'), (37, 'Interni vegani'),
                                                                (38, 'Sistema di guida completamente autonoma'), (38, 'Sedili Premium'),
                                                                (39, 'Autopilot avanzato'), (39, 'Sistema audio premium'),
                                                                (40, 'Cerchi Überturbine da 21""'), (40, 'Impianto frenante Performance'),
                                                                (41, 'Interni Premium'), (41, 'Vetri acustici laminati'),
                                                                (42, 'Modalità Pista'), (42, 'Impianto frenante carboceramico'),
                                                                (43, 'Sistema MBUX'), (43, 'Pacchetto Advantage'),
                                                                (44, 'Cerchi AMG'), (44, 'Assetto sportivo'),
                                                                (45, 'Illuminazione ambient attiva'), (45, 'MBUX Hyperscreen'),
                                                                (46, 'Pacchetto aerodinamico AMG'), (46, 'Sound Experience'),
                                                                (47, 'Navigazione aumentata'), (47, 'Sedili riscaldati'),
                                                                (48, 'Pacchetto Night'), (48, 'Tetto panoramico'),
                                                                (49, 'Media Nav Evolution'), (49, 'Sensori parcheggio'),
                                                                (50, 'Telecamera Multiview'), (50, 'Sistema keyless'),
                                                                (51, 'Radio DAB'), (51, 'Bluetooth'),
                                                                (52, 'Climatizzatore automatico'), (52, 'Sensori di parcheggio posteriori'),
                                                                (53, 'Media Nav'), (53, 'Climatizzatore'),
                                                                (54, 'Cerchi diamantati'), (54, 'Telecamera posteriore'),
                                                                (55, 'Sistema Uconnect 8,4""'), (55, 'Portellone elettrico'),
                                                                (56, 'Sistema Selec-Terrain'), (56, 'Gancio traino'),
                                                                (57, 'Sistema Uconnect 10,1""'), (57, 'Sensori parcheggio 360°'),
                                                                (58, 'Tetto nero a contrasto'), (58, 'Sistema audio Alpine'),
                                                                (59, 'Lane Assist'), (59, 'Cruise control adattivo'),
                                                                (60, 'Tetto apribile'), (60, 'Sistema Selec-Terrain'),
                                                                (61, 'Sistema infotainment da 8,8""'), (61, 'Sensori di parcheggio'),
                                                                (62, 'Cerchi in lega da 19""'), (62, 'Pinze freno rosse'),
                                                                (63, 'Sistema infotainment da 8,8""'), (63, 'Portellone elettrico'),
                                                                (64, 'Assetto sportivo'), (64, 'Sedili sportivi in pelle'),
                                                                (65, 'Sistema infotainment da 10,25""'), (65, 'Sensori di parcheggio'),
                                                                (66, 'Cerchi in lega da 18""'), (66, 'Sistema frenante Brembo'),
                                                                (67, 'Digital Cockpit'), (67, 'Sistema infotainment da 12""'),
                                                                (68, 'Sedili sportivi'), (68, 'Scarichi sportivi'),
                                                                (69, 'Head-up display'), (69, 'Illuminazione ambiente'),
                                                                (70, 'Assetto sportivo DCC'), (70, 'Cerchi in lega da 20""'),
                                                                (71, 'Virtual Cockpit'), (71, 'Portellone elettrico'),
                                                                (72, 'Sistema di scarico sportivo'), (72, 'Cerchi in lega da 19""'),
                                                                (73, 'Navigatore con schermo da 10,25""'), (73, 'Clima automatico bizona'),
                                                                (74, 'Tetto panoramico'), (74, 'Sistema audio Krell'),
                                                                (75, 'Navigatore con schermo da 10,25""'), (75, 'Smart Key'),
                                                                (76, 'Head-up display'), (76, 'Sistema audio Krell'),
                                                                (77, 'Sistema di ricarica bidirezionale'), (77, 'Digital key'),
                                                                (78, 'Sedili relax con poggiapolpacci'), (78, 'Head-up display con realtà aumentata'),
                                                                (79, 'Navigatore con schermo da 12,3""'), (79, 'Telecamera posteriore'),
                                                                (80, 'Cerchi in lega da 19""'), (80, 'Tetto nero a contrasto'),
                                                                (81, 'Sistema di ricarica ultra-rapida'), (81, 'Sedili riscaldati'),
                                                                (82, 'Head-up display'), (82, 'Sistema audio Meridian'),
                                                                (83, 'Smart key'), (83, 'Clima automatico'),
                                                                (84, 'Tetto bicolore'), (84, 'Sistema audio premium'),
                                                                (85, 'Sistema Mazda Connect'), (85, 'Head-up display'),
                                                                (86, 'Cerchi in lega da 19""'), (86, 'Sedili in pelle nera'),
                                                                (87, 'Sistema infotainment da 8,8""'), (87, 'Pompa di calore'),
                                                                (88, 'Interni in sughero'), (88, 'Portiere freestyle'),
                                                                (89, 'Sistema Mazda Connect'), (89, 'Cerchi in lega da 16""'),
                                                                (90, 'Sedili Recaro'), (90, 'Sospensioni Bilstein'),
                                                                (91, 'NissanConnect'), (91, 'Around View Monitor'),
                                                                (92, 'Tetto panoramico'), (92, 'Sistema audio Bose'),
                                                                (93, 'Sistema NissanConnect EV'), (93, 'Pompa di calore'),
                                                                (94, 'ProPILOT'), (94, 'Sistema audio Bose'),
                                                                (95, 'Sistema di navigazione con realtà aumentata'), (95, 'Pompa di calore'),
                                                                (96, 'Head-up display'), (96, 'Sistema ProPILOT 2.0'),
                                                                (97, 'IntelliLink'), (97, 'Sedili sportivi'),
                                                                (98, 'Head-up display'), (98, 'Fari IntelliLux LED'),
                                                                (99, 'Pure Panel'), (99, 'IntelliLink'),
                                                                (100, 'Tetto nero a contrasto'), (100, 'Fari IntelliLux LED'),
                                                                (101, 'Pure Panel'), (101, 'IntelliLink'),
                                                                (102, 'Night Vision'), (102, 'Sistema IntelliGrip'),
                                                                (103, 'i-Cockpit 3D'), (103, 'Navigatore connesso'),
                                                                (104, 'Tetto panoramico'), (104, 'Fari Full LED'),
                                                                (105, 'i-Cockpit 3D'), (105, 'Navigatore connesso'),
                                                                (106, 'Tetto panoramico'), (106, 'Ambient LED Pack'),
                                                                (107, 'i-Cockpit'), (107, 'Grip Control'),
                                                                (108, 'Night Vision'), (108, 'Sistema audio Focal'),
                                                                (109, 'Easy Link 9,3""'), (109, 'Multi-Sense'),
                                                                (110, 'Fari Full LED'), (110, 'Cerchi in lega da 17""'),
                                                                (111, 'Easy Link 9,3""'), (111, 'Multi-Sense'),
                                                                (112, 'Tetto panoramico'), (112, 'Sedili riscaldati'),
                                                                (113, 'OpenR Link con Google'), (113, 'Pompa di calore'),
                                                                (114, 'Sistema audio Harman Kardon'), (114, 'Head-up display'),
                                                                (115, 'Virtual Cockpit'), (115, 'Portellone elettrico'),
                                                                (116, 'Fari Matrix LED'), (116, 'Sedili sportivi'),
                                                                (117, 'Head-up display con realtà aumentata'), (117, 'Pompa di calore'),
                                                                (118, 'Crystal Face'), (118, 'Sistema audio Canton'),
                                                                (119, 'Amundsen 9,2""'), (119, 'Virtual Cockpit'),
                                                                (120, 'Cerchi in lega da 18""'), (120, 'Tetto panoramico'),
                                                                (121, 'Full Link'), (121, 'Kessy'),
                                                                (122, 'Fari Full LED'), (122, 'Cerchi in lega da 18""'),
                                                                (123, 'Full Link'), (123, 'Kessy'),
                                                                (124, 'Fari Full LED'), (124, 'Cerchi in lega da 17""'),
                                                                (125, 'Full Link'), (125, 'Kessy'),
                                                                (126, 'Sedili sportivi'), (126, 'Cerchi in lega da 19""'),
                                                                (127, 'Infotainment Google'), (127, 'Sensus Connect'),
                                                                (128, 'Tetto panoramico'), (128, 'Sistema audio Harman Kardon'),
                                                                (129, 'Pilot Assist'), (129, 'Head-up display'),
                                                                (130, 'Sistema audio Bowers & Wilkins'), (130, 'Sospensioni pneumatiche'),
                                                                (131, 'Google built-in'), (131, 'Pompa di calore'),
                                                                (132, 'Sistema audio Harman Kardon'), (132, 'Tetto panoramico'),
                                                                (133, 'Porsche Electric Sport Sound'), (133, 'Climatizzatore a 4 zone'),
                                                                (134, 'Asse posteriore sterzante'), (134, 'Sistema audio Burmester'),
                                                                (135, 'Pacchetto Heritage Design'), (135, 'Sedili sportivi adattivi'),
                                                                (136, 'Pacchetto Aerodynamic'), (136, 'Impianto di scarico sportivo'),
                                                                (137, 'Head-up display'), (137, 'Sospensioni pneumatiche adattive'),
                                                                (138, 'Pacchetto Sport Chrono'), (138, 'Cerchi da 22""'),
                                                                (139, 'Sistema Pivi Pro'), (139, 'Meridian Sound System'),
                                                                (140, 'Performance seats'), (140, 'Impianto frenante potenziato'),
                                                                (141, 'Tetto panoramico in vetro'), (141, 'Adaptive Cruise Control'),
                                                                (142, 'Head-up Display'), (142, 'Sistema audio Meridian Surround Sound'),
                                                                (143, 'Active Sports Exhaust'), (143, 'Configurable Dynamics'),
                                                                (144, 'Performance Seats in pelle Windsor'), (144, 'Carbon Ceramic Braking System');

-- ======================
-- INSERT INTO utente (solo passwordhash (SHA2) e password_test (in chiaro per test))
-- ======================
INSERT INTO utente (Nome, Cognome, Email, passwordhash, password_test, Ruolo) VALUES
                                                                                  ('Mario', 'Rossi', 'mario.rossi@example.com', SHA2('Password123.', 256), 'Password123.', 'UTENTE'),
                                                                                  ('Giulia', 'Bianchi', 'giulia.bianchi@example.com', SHA2('Secure123.', 256), 'Secure123.', 'UTENTE'),
                                                                                  ('Alessandro', 'Verdi', 'alessandro.verdi@example.com', SHA2('Mypassword1.', 256), 'Mypassword1.', 'UTENTE'),
                                                                                  ('Francesca', 'Neri', 'francesca.neri@example.com', SHA2('leTmein1.', 256), 'leTmein1.', 'UTENTE'),
                                                                                  ('Luca', 'Ferrari', 'luca.ferrari@example.com', SHA2('weLcome.321', 256), 'weLcome.321', 'UTENTE'),
                                                                                  ('Sofia', 'Esposito', 'sofia.esposito@example.com', SHA2('Qwerty.1.2', 256), 'Qwerty.1.2', 'UTENTE'),
                                                                                  ('Marco', 'Romano', 'marco.romano@example.com', SHA2('123456marcO.', 256), '123456marcO.', 'UTENTE'),
                                                                                  ('Valentina', 'Marino', 'valentina.marino@example.com', SHA2('password1valE', 256), 'password1valE', 'UTENTE'),
                                                                                  ('Andrea', 'Greco', 'andrea.greco@example.com', SHA2('aDmin888.', 256), 'aDmin888.', 'UTENTE'),
                                                                                  ('Chiara', 'Colombo', 'chiara.colombo@example.com', SHA2('userChiara.123', 256), 'userChiara.123', 'UTENTE'),
                                                                                  ('Roberto', 'Ricci', 'roberto.ricci@example.com', SHA2('guest.Ricc5', 256), 'guest.Ricc5', 'UTENTE'),
                                                                                  ('Laura', 'Galli', 'laura.galli@example.com', SHA2('testq.Q1', 256), 'testq.Q1', 'UTENTE'),
                                                                                  ('Davide', 'Marini', 'davide.marini@example.com', SHA2('e.xample12A', 256), 'e.xample12A', 'UTENTE'),
                                                                                  ('Elena', 'Vitale', 'elena.vitale@example.com', SHA2('demo11.1Elena', 256), 'demo11.1Elena', 'UTENTE'),
                                                                                  ('Paolo', 'Leone', 'paolo.leone@example.com', SHA2('sam.plE11', 256), 'sam.plE11', 'UTENTE'),
                                                                                  ('Admin', 'Sistema', 'admin@autoquest.com', SHA2('admin123', 256), 'admin123', 'ADMIN'),
                                                                                  ('Sara', 'DiTella', 'sara@example.com', SHA2('1234Sara.', 256), '1234Sara.', 'UTENTE'),
                                                                                  ('Immacolata', 'Volpe', 'imma.volpe@example.com', SHA2('ababab.Ab', 256), 'ababab.Ab', 'UTENTE'),
                                                                                  ('Francesco', 'Rossi', 'francesco@example.com', SHA2('Fra.12345678', 256), 'Fra.12345678', 'UTENTE');

-- ======================
-- INSERT ORDINI (seguono i tuoi esempi)
-- ======================
INSERT INTO ordine (ID_utente, ID_allestimento, Data_ordine) VALUES
                                                                 (1, 2, '2024-09-15'),
                                                                 (2, 4, '2024-10-02'),
                                                                 (3, 6, '2024-08-28'),
                                                                 (4, 8, '2024-11-05'),
                                                                 (5, 10, '2024-07-18'),
                                                                 (6, 14, '2024-10-22'),
                                                                 (7, 22, '2024-12-01'),
                                                                 (8, 34, '2024-09-30'),
                                                                 (9, 42, '2024-11-17'),
                                                                 (10, 44, '2024-08-12'),
                                                                 (11, 58, '2024-10-05'),
                                                                 (12, 66, '2024-12-10'),
                                                                 (13, 68, '2024-11-22'),
                                                                 (14, 90, '2024-07-29');

-- ======================
-- INSERT AUTO_SALVATE (con SELECT per calcolare prezzo)
-- ======================
INSERT INTO auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale, Data_salvataggio)
SELECT 16, 1, 1, (a.Prezzo_base + al.Prezzo_allestimento), '2025-01-01 10:00:32'
FROM auto a JOIN allestimento al ON al.ID_allestimento = 1 AND a.ID_auto = 16;

INSERT INTO auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale, Data_salvataggio)
SELECT 17, 2, 1, (a.Prezzo_base + al.Prezzo_allestimento), '2025-01-01 10:03:02'
FROM auto a JOIN allestimento al ON al.ID_allestimento = 2 AND a.ID_auto = 17;

INSERT INTO auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale, Data_salvataggio)
SELECT 18, 3, 2, (a.Prezzo_base + al.Prezzo_allestimento), '2025-02-01 09:30:00'
FROM auto a JOIN allestimento al ON al.ID_allestimento = 3 AND a.ID_auto = 18;

INSERT INTO auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale, Data_salvataggio)
SELECT 19, 4, 3, (a.Prezzo_base + al.Prezzo_allestimento), '2025-03-01 14:45:00'
FROM auto a JOIN allestimento al ON al.ID_allestimento = 4 AND a.ID_auto = 19;

INSERT INTO auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale, Data_salvataggio)
SELECT 20, 5, 4, (a.Prezzo_base + al.Prezzo_allestimento), '2025-04-01 16:00:00'
FROM auto a JOIN allestimento al ON al.ID_allestimento = 5 AND a.ID_auto = 20;

INSERT INTO auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale, Data_salvataggio)
SELECT 16, 2, 5, (a.Prezzo_base + al.Prezzo_allestimento), '2025-05-01 08:15:00'
FROM auto a JOIN allestimento al ON al.ID_allestimento = 2 AND a.ID_auto = 16;

INSERT INTO auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale, Data_salvataggio)
SELECT 17, 4, 5, (a.Prezzo_base + al.Prezzo_allestimento), '2025-05-01 09:45:00'
FROM auto a JOIN allestimento al ON al.ID_allestimento = 4 AND a.ID_auto = 17;

-- ======================
-- INSERT confronto e confronto_auto
-- ======================
INSERT INTO confronto (ID_utente, Nome_confronto, Data_creazione) VALUES
                                                                      (1, 'Berlina vs Crossover', '2025-04-05 09:15:33'),
                                                                      (2, 'Elettriche compatte', '2025-03-25 16:45:10'),
                                                                      (3, 'Auto sportive', '2025-04-18 11:20:55'),
                                                                      (7, 'Citycar', '2025-03-22 16:20:15');

INSERT INTO confronto_auto (ID_confronto, ID_allestimento) VALUES
                                                               (1, 7), (1, 19), (1, 31),
                                                               (2, 14), (2, 37), (2, 81),
                                                               (3, 62), (3, 133),
                                                               (4, 13), (4, 15), (4, 49);

-- ======================
-- INSERT preferenza_utente
-- ======================
INSERT INTO preferenza_utente (ID_utente, Marchio_pref, Modello_pref, Alimentazione_pref, Potenza_pref, Cambio_pref, Cilindrata_pref, Budget_min, Budget_max, Data_creazione) VALUES
                                                                                                                                                                                  (1, 'BMW', NULL, 'Diesel', 180, 'Automatico', 2000, 45000.00, 60000.00, '2025-03-10 08:30:15'),
                                                                                                                                                                                  (2, 'Fiat', NULL, 'GPL', NULL, NULL, NULL, 15000.00, 25000.00, '2025-03-20 14:45:30'),
                                                                                                                                                                                  (3, 'Tesla', 'Model 3', 'Elettrica', 300, 'Automatico', NULL, 40000.00, 55000.00, '2025-04-01 10:20:45'),
                                                                                                                                                                                  (4, NULL, NULL, 'Ibrida', NULL, NULL, NULL, 30000.00, 50000.00, '2025-04-10 16:15:20'),
                                                                                                                                                                                  (5, 'Volkswagen', NULL, NULL, 150, 'Doppia Frizione', NULL, 35000.00, 60000.00, '2025-04-15 09:40:55'),
                                                                                                                                                                                  (6, 'Alfa Romeo', 'Giulia', 'Benzina', 250, NULL, 2000, 50000.00, 65000.00, '2025-03-12 11:30:40'),
                                                                                                                                                                                  (7, 'Kia', NULL, 'Elettrica', NULL, 'Automatico', NULL, 45000.00, 60000.00, '2025-03-18 15:25:10'),
                                                                                                                                                                                  (8, 'Ford', NULL, NULL, NULL, NULL, NULL, 25000.00, 40000.00, '2025-03-25 12:50:35'),
                                                                                                                                                                                  (9, 'Dacia', NULL, 'GPL', NULL, 'Manuale', NULL, 12000.00, 20000.00, '2025-04-05 17:10:25'),
                                                                                                                                                                                  (10, NULL, NULL, NULL, 200, 'Automatico', NULL, 35000.00, 55000.00, '2025-04-12 10:35:50'),
                                                                                                                                                                                  (11, 'Fiat', '500e', 'Elettrica', NULL, NULL, NULL, 25000.00, 35000.00, '2025-03-15 13:40:15'),
                                                                                                                                                                                  (12, 'Volkswagen', 'Golf', NULL, 130, 'Manuale', 1500, 28000.00, 35000.00, '2025-03-22 16:55:30'),
                                                                                                                                                                                  (13, 'Jeep', NULL, NULL, NULL, NULL, NULL, 40000.00, 60000.00, '2025-04-08 09:15:45'),
                                                                                                                                                                                  (14, NULL, NULL, 'Elettrica', NULL, NULL, NULL, 35000.00, 90000.00, '2025-04-18 14:30:20');

-- ======================
-- INSERT ricerca_salvata
-- ======================
INSERT INTO ricerca_salvata (ID_utente, Nome_ricerca, Parametri_ricerca, Data_ricerca) VALUES
                                                                                           (1, 'SUV diesel', '{"marca": "Volkswagen", "modello": "Tiguan", "alimentazione": "Diesel", "potenza_min": 150, "cambio": "Doppia Frizione", "cilindrata_min": 1968, "prezzo_max": 60000}', '2025-03-11 09:25:15'),
                                                                                           (1, 'Business car', '{"marca": "Mercedes", "modello": "GLC", "alimentazione": "Diesel", "potenza_min": 220, "cambio": "Automatico", "cilindrata_min": 1993, "prezzo_max": 75000}', '2025-04-05 11:40:30'),
                                                                                           (2, 'City car', '{"marca": "Dacia", "modello": "Sandero", "alimentazione": "GPL", "potenza_min": 100, "cambio": "Manuale", "cilindrata_min": 999, "prezzo_max": 25000}', '2025-03-22 15:15:45');