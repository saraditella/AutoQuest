package model.DAO;

import model.bean.Alimentazione;
import model.bean.Cambio;
import model.ConnessioneDatabase;
import model.bean.AutoBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AutoDAO {


    public List<AutoBean> doRetrieveAllAuto() {
        List<AutoBean> listaAuto = new ArrayList<>();

        try (Connection connection = ConnessioneDatabase.getConnection()) {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM autoquest.auto");

            while (resultSet.next()) {
                AutoBean auto = new AutoBean();
                auto.setIdAuto(resultSet.getInt("ID_Auto"));
                auto.setMarchio(resultSet.getString("Marchio"));
                auto.setModello(resultSet.getString("Modello"));
                auto.setAlimentazione(Alimentazione.fromString(resultSet.getString("Alimentazione")));
                auto.setCambio(Cambio.fromString(resultSet.getString("Cambio")));
                auto.setCilindrata(resultSet.getInt("Cilindrata"));
                auto.setPotenza(resultSet.getInt("Potenza"));
                auto.setPrezzoBase(resultSet.getInt("Prezzo_base"));
                auto.setLinkAcquisto(resultSet.getString("Link_acquisto"));
                auto.setImmagineUrl(resultSet.getString("Immagine_url"));

                listaAuto.add(auto);

            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore nel recupero delle auto dal database", e);
        }

        return listaAuto;
    }


    public List<String> doRetrieveAllMarchi() {
        List<String> marchi = new ArrayList<String>();
        String sql = "SELECT DISTINCT Marchio FROM autoquest.auto ORDER BY Marchio";

        try (Connection connection = ConnessioneDatabase.getConnection()) {
            PreparedStatement preparedStatement = connection.prepareStatement(sql);
            ResultSet resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                marchi.add(resultSet.getString("Marchio").trim());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return marchi;
    }


    public List<AutoBean> ricercaRapida(String marchio, String budget, String potenza, String cilindrata) {
        List<AutoBean> listaAutoRicerca = new ArrayList<>();
        List<Object> parametri = new ArrayList<>();
        String sql = "SELECT * FROM autoquest.auto WHERE 1=1 ";

        if (marchio != null && !marchio.isEmpty()) {
            sql += "AND Marchio = ? ";
            parametri.add(marchio);
        }

        // budget = prezzo massimo
        if (budget != null && !budget.isEmpty()) {
            try {
                int b = Integer.parseInt(budget.trim());
                sql += "AND Prezzo_base <= ? ";
                parametri.add(b);
            } catch (NumberFormatException ignored) {
            }
        }

        // potenza = potenza massima (Fino a X CV) -> usare <=
        if (potenza != null && !potenza.isEmpty()) {
            try {
                int p = Integer.parseInt(potenza.trim());
                sql += "AND Potenza <= ? ";
                parametri.add(p);
            } catch (NumberFormatException ignored) {
            }
        }

        // cilindrata = cilindrata massima (Fino a X cc) -> usare <=
        if (cilindrata != null && !cilindrata.isEmpty()) {
            try {
                int c = Integer.parseInt(cilindrata.trim());
                sql += "AND Cilindrata <= ? ";
                parametri.add(c);
            } catch (NumberFormatException ignored) {
            }
        }

        try (Connection connection = ConnessioneDatabase.getConnection()) {
            PreparedStatement preparedStatement = connection.prepareStatement(sql);

            for (int i = 0; i < parametri.size(); i++) {
                preparedStatement.setObject(i + 1, parametri.get(i));
            }

            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                AutoBean auto = new AutoBean();
                auto.setIdAuto(resultSet.getInt("ID_Auto"));
                auto.setMarchio(resultSet.getString("Marchio"));
                auto.setModello(resultSet.getString("Modello"));
                auto.setAlimentazione(Alimentazione.fromString(resultSet.getString("Alimentazione")));
                auto.setCambio(Cambio.fromString(resultSet.getString("Cambio")));
                auto.setCilindrata(resultSet.getInt("Cilindrata"));
                auto.setPotenza(resultSet.getInt("Potenza"));
                auto.setPrezzoBase(resultSet.getInt("Prezzo_base"));
                auto.setLinkAcquisto(resultSet.getString("Link_acquisto"));
                auto.setImmagineUrl(resultSet.getString("Immagine_url"));
                listaAutoRicerca.add(auto);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaAutoRicerca;
    }


    public List<AutoBean> doRetrieveByMarchio(String marchio) {
        List<AutoBean> listaAutoPerMarchio = new ArrayList<>();
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM autoquest.auto WHERE Marchio = ?");
            preparedStatement.setString(1, marchio);
            ResultSet resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                AutoBean auto = new AutoBean();
                auto.setIdAuto(resultSet.getInt("ID_Auto"));
                auto.setMarchio(resultSet.getString("Marchio"));
                auto.setModello(resultSet.getString("Modello"));
                auto.setAlimentazione(Alimentazione.fromString(resultSet.getString("Alimentazione")));
                auto.setCambio(Cambio.fromString(resultSet.getString("Cambio")));
                auto.setCilindrata(resultSet.getInt("Cilindrata"));
                auto.setPotenza(resultSet.getInt("Potenza"));
                auto.setPrezzoBase(resultSet.getInt("Prezzo_base"));
                auto.setLinkAcquisto(resultSet.getString("Link_acquisto"));
                auto.setImmagineUrl(resultSet.getString("Immagine_url"));
                listaAutoPerMarchio.add(auto);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return listaAutoPerMarchio;
    }


    public int contaAutoFiltrate(String marchio, String alimentazione, String cambio, String minPrezzo, String maxPrezzo, String minPotenza, String maxPotenza, String minCilindrata, String maxCilindrata) {
        int totale = 0;
        List<Object> parametri = new ArrayList<>();
        String sql = "SELECT COUNT(*) as totale FROM autoquest.auto WHERE 1=1";

        if (marchio != null && !marchio.isEmpty()) {
            sql += " AND Marchio = ?";
            parametri.add(marchio);
        }

        if (alimentazione != null && !alimentazione.isEmpty()) {
            sql += " AND Alimentazione = ?";
            parametri.add(alimentazione);
        }

        if (cambio != null && !cambio.isEmpty()) {
            sql += " AND Cambio = ?";
            parametri.add(cambio);
        }

        if (minPrezzo != null && !minPrezzo.isEmpty()) {
            sql += " AND Prezzo_base >= ?";
            parametri.add(minPrezzo);
        }

        if (maxPrezzo != null && !maxPrezzo.isEmpty()) {
            sql += " AND Prezzo_base <= ?";
            parametri.add(maxPrezzo);
        }

        if (minPotenza != null && !minPotenza.isEmpty()) {
            sql += " AND Potenza >= ?";
            parametri.add(minPotenza);
        }

        if (maxPotenza != null && !maxPotenza.isEmpty()) {
            sql += " AND Potenza <= ?";
            parametri.add(maxPotenza);
        }


        if (minCilindrata != null && !minCilindrata.isEmpty()) {
            sql += " AND Cilindrata >= ?";
            parametri.add(minCilindrata);
        }

        if (maxCilindrata != null && !maxCilindrata.isEmpty()) {
            sql += " AND Cilindrata <= ?";
            parametri.add(maxCilindrata);
        }

        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            for (int j = 0; j < parametri.size(); j++) {
                preparedStatement.setObject(j + 1, parametri.get(j));
            }

            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                totale = resultSet.getInt("totale");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return totale;
    }

    public List<AutoBean> filtraAutoRicercaAvanzata(String marchio, String alimentazione, String cambio, String minPrezzo, String maxPrezzo, String minPotenza, String maxPotenza, String minCilindrata, String maxCilindrata, int offset, int risultatiPerPagina, String ordinamento) {
        List<AutoBean> listaAutoRicercaAvanzata = new ArrayList<>();
        List<Object> parametri = new ArrayList<>();
        String sql = "SELECT * FROM autoquest.auto WHERE 1=1";

        if (marchio != null && !marchio.isEmpty()) {
            sql += " AND Marchio = ?";
            parametri.add(marchio);
        }

        if (alimentazione != null && !alimentazione.isEmpty()) {
            sql += " AND Alimentazione = ?";
            parametri.add(alimentazione);
        }

        if (cambio != null && !cambio.isEmpty()) {
            sql += " AND Cambio = ?";
            parametri.add(cambio);
        }

        if (minPrezzo != null && !minPrezzo.isEmpty()) {
            sql += " AND Prezzo_base >= ?";
            parametri.add(Integer.parseInt(minPrezzo));
        }

        if (maxPrezzo != null && !maxPrezzo.isEmpty()) {
            sql += " AND Prezzo_base <= ?";
            parametri.add(Integer.parseInt(maxPrezzo));
        }

        if (minPotenza != null && !minPotenza.isEmpty()) {
            sql += " AND Potenza >= ?";
            parametri.add(Integer.parseInt(minPotenza));
        }

        if (maxPotenza != null && !maxPotenza.isEmpty()) {
            sql += " AND Potenza <= ?";
            parametri.add(Integer.parseInt(maxPotenza));
        }


        if (minCilindrata != null && !minCilindrata.isEmpty()) {
            sql += " AND Cilindrata >= ?";
            parametri.add(Integer.parseInt(minCilindrata));
        }

        if (maxCilindrata != null && !maxCilindrata.isEmpty()) {
            sql += " AND Cilindrata <= ?";
            parametri.add(Integer.parseInt(maxCilindrata));
        }
        if (ordinamento != null) {
            switch (ordinamento) {
                case "prezzoCrescente" -> {
                    sql += " ORDER BY Prezzo_base ASC";
                    break;
                }
                case "prezzoDecrescente" -> {
                    sql += " ORDER BY Prezzo_base DESC";
                    break;
                }
                case "potenzaCrescente" -> {
                    sql += " ORDER BY Potenza ASC";
                    break;
                }
                case "potenzaDecrescente" -> {
                    sql += " ORDER BY Potenza DESC";
                    break;
                }
                case "cilindrataCrescente" -> {
                    sql += " ORDER BY Cilindrata ASC";
                    break;
                }
                case "cilindrataDecrescente" -> {
                    sql += " ORDER BY Cilindrata DESC";
                    break;
                }
                default -> {
                    break;
                }
            }
        }
        sql += " LIMIT ? OFFSET ?";


        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            int i = 1;
            for (Object parametro : parametri) {
                preparedStatement.setObject(i++, parametro);
            }
            preparedStatement.setInt(i++, risultatiPerPagina);
            preparedStatement.setInt(i, offset);

            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                AutoBean auto = new AutoBean();
                auto.setIdAuto(resultSet.getInt("ID_Auto"));
                auto.setMarchio(resultSet.getString("Marchio"));
                auto.setModello(resultSet.getString("Modello"));
                auto.setAlimentazione(Alimentazione.fromString(resultSet.getString("Alimentazione")));
                auto.setCambio(Cambio.fromString(resultSet.getString("Cambio")));
                auto.setCilindrata(resultSet.getInt("Cilindrata"));
                auto.setPotenza(resultSet.getInt("Potenza"));
                auto.setPrezzoBase(resultSet.getInt("Prezzo_base"));
                auto.setLinkAcquisto(resultSet.getString("Link_acquisto"));
                auto.setImmagineUrl(resultSet.getString("Immagine_url"));
                listaAutoRicercaAvanzata.add(auto);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return listaAutoRicercaAvanzata;
    }

    public AutoBean doRetrieveById(int idAuto) {

        try (Connection connection = ConnessioneDatabase.getConnection()) {
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM autoquest.auto WHERE ID_auto = ? ");
            preparedStatement.setInt(1, idAuto);
            ResultSet resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                AutoBean auto = new AutoBean();
                auto.setIdAuto(resultSet.getInt("ID_Auto"));
                auto.setMarchio(resultSet.getString("Marchio"));
                auto.setModello(resultSet.getString("Modello"));
                auto.setAlimentazione(Alimentazione.fromString(resultSet.getString("Alimentazione")));
                auto.setCambio(Cambio.fromString(resultSet.getString("Cambio")));
                auto.setCilindrata(resultSet.getInt("Cilindrata"));
                auto.setPotenza(resultSet.getInt("Potenza"));
                auto.setPrezzoBase(resultSet.getInt("Prezzo_base"));
                auto.setLinkAcquisto(resultSet.getString("Link_acquisto"));
                auto.setImmagineUrl(resultSet.getString("Immagine_url"));
                return auto;
            } else {
                return null;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

    }

    // ===== AGGIUNGI QUESTI METODI AL TUO AutoDAO.java ESISTENTE =====

    /**
     * Conta il numero totale di auto nel catalogo
     */
    public int countTotalAuto() {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            String sql = "SELECT COUNT(*) FROM autoquest.auto";
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }


    /**
     * Recupera tutte le auto per la gestione admin
     * (usa la tua struttura esistente)
     */
    public List<AutoBean> getAllAuto() {
        // Riusa il metodo esistente
        return doRetrieveAllAuto();
    }

    /**
     * Aggiunge una nuova auto al database
     */
    public boolean aggiungiAuto(AutoBean auto) {
        // Query SQL con nomi colonne esatti
        String sql = "INSERT INTO autoquest.auto (Marchio, Modello, Alimentazione, Cambio, Cilindrata, Potenza, Prezzo_base, Link_acquisto, Immagine_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        System.out.println("=== INIZIO INSERIMENTO AUTO ===");
        System.out.println("SQL: " + sql);

        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            // Debug dettagliato dei valori
            System.out.println("=== VALORI DA INSERIRE ===");
            System.out.println("1. Marchio: '" + auto.getMarchio() + "'");
            System.out.println("2. Modello: '" + auto.getModello() + "'");
            System.out.println("3. Alimentazione: '" + auto.getAlimentazione() + "' (toString: '" + auto.getAlimentazione().toString() + "')");
            System.out.println("4. Cambio: '" + auto.getCambio() + "' (toString: '" + auto.getCambio().toString() + "')");
            System.out.println("5. Cilindrata: " + auto.getCilindrata());
            System.out.println("6. Potenza: " + auto.getPotenza());
            System.out.println("7. Prezzo: " + auto.getPrezzoBase());
            System.out.println("8. Link: '" + auto.getLinkAcquisto() + "'");
            System.out.println("9. Immagine: '" + auto.getImmagineUrl() + "'");

            // Imposta i parametri
            ps.setString(1, auto.getMarchio());
            ps.setString(2, auto.getModello());
            ps.setString(3, auto.getAlimentazione().toString());
            ps.setString(4, auto.getCambio().toString());
            ps.setInt(5, auto.getCilindrata());
            ps.setInt(6, auto.getPotenza());
            ps.setInt(7, auto.getPrezzoBase());

            // Gestione parametri nullable
            if (auto.getLinkAcquisto() != null && !auto.getLinkAcquisto().trim().isEmpty()) {
                ps.setString(8, auto.getLinkAcquisto());
            } else {
                ps.setNull(8, java.sql.Types.VARCHAR);
            }

            if (auto.getImmagineUrl() != null && !auto.getImmagineUrl().trim().isEmpty()) {
                ps.setString(9, auto.getImmagineUrl());
            } else {
                ps.setNull(9, java.sql.Types.VARCHAR);
            }

            System.out.println("Parametri impostati, esecuzione query...");

            // Esegui l'inserimento
            int righeInserite = ps.executeUpdate();

            System.out.println("Righe inserite: " + righeInserite);
            System.out.println("=== INSERIMENTO COMPLETATO ===");

            return righeInserite > 0;

        } catch (SQLException e) {
            System.err.println("=== ERRORE SQL DETTAGLIATO ===");
            System.err.println("Messaggio: " + e.getMessage());
            System.err.println("Codice errore: " + e.getErrorCode());
            System.err.println("SQLState: " + e.getSQLState());
            System.err.println("Causa: " + e.getCause());

            // Stampa lo stack trace completo per debug
            e.printStackTrace();

            // Gestione di errori specifici comuni
            if (e.getErrorCode() == 1062) { // Duplicate entry
                System.err.println("ERRORE: Chiave duplicata - auto già esistente");
            } else if (e.getErrorCode() == 1452) { // Foreign key constraint
                System.err.println("ERRORE: Vincolo chiave esterna violato");
            } else if (e.getErrorCode() == 1406) { // Data too long
                System.err.println("ERRORE: Dati troppo lunghi per il campo");
            } else if (e.getErrorCode() == 1265) { // Data truncated
                System.err.println("ERRORE: Dati troncati - possibile problema enum");
            }

            return false;
        } catch (Exception e) {
            System.err.println("=== ERRORE GENERICO ===");
            System.err.println("Tipo: " + e.getClass().getSimpleName());
            System.err.println("Messaggio: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}