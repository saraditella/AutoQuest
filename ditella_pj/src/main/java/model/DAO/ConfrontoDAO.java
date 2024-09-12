package model.DAO;

import model.ConnessioneDatabase;
import model.bean.Alimentazione;
import model.bean.AutoBean;
import model.bean.Cambio;
import model.bean.ConfrontoBean;

import javax.imageio.plugins.jpeg.JPEGImageWriteParam;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ConfrontoDAO {
    //Crea un nuovo record in confronto e restituisce l'd generato
    public int creaConfronto(int idUtente, String nomeConfronto) throws SQLException {
        String sql = "INSERT INTO autoquest.confronto (ID_utente, Nome_confronto) VALUES (?, ?)";
        try(Connection connection = ConnessioneDatabase.getConnection();
            PreparedStatement preparedStatement = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            preparedStatement.setInt(1, idUtente);
            preparedStatement.setString(2, nomeConfronto);
            int affected = preparedStatement.executeUpdate();
            if(affected == 0) {
                throw new SQLException("Creazione del controllo fallita, nessuna riga è stata inserita");
            }
            try (ResultSet keys = preparedStatement.getGeneratedKeys()) {
                if(keys.next()) {
                    return keys.getInt(1);
                } else {
                    throw new SQLException("Creazione del controllo fallita, nessuna chiave generata");
                }
            }
        }
    }

    /**
     * Salva le auto collegate ad un confronto esistente.
     * Input: autoIDs = lista di ID_auto (cioè gli id che tieni in sessione)
     * Questo metodo mappa ogni ID_auto -> ID_allestimento (scegliendo il primo / piu economico)
     * e inserisce in confronto_auto (ID_confronto, ID_allestimento).
     */
    // OVERLOAD: mantiene comportamento precedente (per compatibilità)
    public void salvaConfrontoAuto(int confrontoId, List<Integer> autoIDs) throws SQLException {
        // reindirizza alla nuova versione senza allestimenti (null list)
        salvaConfrontoAuto(confrontoId, autoIDs, null);
    }

    /**
     * Nuova versione: salva per ogni auto anche l'ID_allestimento passato nella lista allestimentiIDs.
     * Se per una certa auto l'id allestimento è null, si usa getDefaultAllestimentoIdPerAuto(connection, idAuto).
     * La tabella target rimane: autoquest.confronto_auto (ID_confronto, ID_allestimento)
     */
    public void salvaConfrontoAuto(int confrontoId, List<Integer> autoIDs, List<Integer> allestimentiIDs) throws SQLException {
        if (autoIDs == null || autoIDs.isEmpty()) return;

        String sql = "INSERT INTO autoquest.confronto_auto (ID_confronto, ID_allestimento) VALUES (?, ?)";
        Connection connection = null;
        PreparedStatement insertPs = null;
        boolean originalAutoCommit = true;

        try {
            connection = ConnessioneDatabase.getConnection();
            originalAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false); // transaction

            insertPs = connection.prepareStatement(sql);

            for (int i = 0; i < autoIDs.size(); i++) {
                Integer idAuto = autoIDs.get(i);
                if (idAuto == null) continue;

                Integer idAllestimento = null;
                if (allestimentiIDs != null && i < allestimentiIDs.size()) {
                    idAllestimento = allestimentiIDs.get(i);
                }

                // se non fornito, fallback al default (primo allestimento per auto)
                if (idAllestimento == null) {
                    idAllestimento = getDefaultAllestimentoIdPerAuto(connection, idAuto);
                }

                if (idAllestimento == null) {
                    // nessun allestimento trovato per questa auto: salta e logga
                    System.out.println("DEBUG: Nessun allestimento trovato per ID_auto=" + idAuto + " — salto inserimento.");
                    continue;
                }

                insertPs.setInt(1, confrontoId);
                insertPs.setInt(2, idAllestimento);
                insertPs.addBatch();
            }

            insertPs.executeBatch();
            connection.commit();
        } catch (SQLException e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (insertPs != null) {
                try {
                    insertPs.close();
                } catch (SQLException ignored) {
                }
            }
            if (connection != null) {
                try {
                    connection.setAutoCommit(originalAutoCommit);
                    connection.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Restituisce un ID_allestimento "di default" per una data auto (es. il più economico).
     * Usa la stessa connection per evitare overhead.
     * Ritorna null se non esiste alcun allestimento per quell'auto.
     */
    private Integer getDefaultAllestimentoIdPerAuto(Connection connection, int idAuto) throws SQLException {
        String sql = "SELECT ID_allestimento FROM autoquest.allestimento WHERE ID_auto = ? ORDER BY Prezzo_allestimento ASC LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, idAuto);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("ID_allestimento");
                } else {
                    return null;
                }
            }
        }
    }

    /**
     * Recupera i confronti meta (id, nome, data) per un utente.
     */
    public List<ConfrontoBean> getConfrontiByUtente(int utenteId) {
        List<ConfrontoBean> listaConfronti = new ArrayList<>();
        String sql = "SELECT ID_confronto, Nome_confronto, Data_creazione " +
                "FROM autoquest.confronto WHERE ID_utente = ? ORDER BY Data_creazione DESC";
        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, utenteId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    ConfrontoBean confrontoBean = new ConfrontoBean();
                    confrontoBean.setIdConfronto(resultSet.getInt("ID_confronto"));
                    confrontoBean.setNomeConfronto(resultSet.getString("Nome_confronto"));
                    Timestamp ts = resultSet.getTimestamp("Data_creazione");
                    if (ts != null) confrontoBean.setDataCreazione(ts.toLocalDateTime());
                    listaConfronti.add(confrontoBean);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore nel recupero dei confronti", e);
        }
        return listaConfronti;
    }

    /**
     * Recupera le AutoBean associate a un confronto (tramite allestimenti).
     * Query: confronto_auto -> allestimento -> auto
     */
    public List<AutoBean> getAutoByConfronto(int confrontoId) {
        List<AutoBean> listaAuto = new ArrayList<>();
        String sql =
                "SELECT a.ID_auto, a.Marchio, a.Modello, a.Alimentazione, a.Potenza, a.Cambio, " +
                        "a.Cilindrata, a.Prezzo_base, a.Link_acquisto, a.Immagine_url, " +
                        "al.ID_allestimento AS ID_allestimento, al.Nome_allestimento AS Nome_allestimento, al.Prezzo_allestimento AS Prezzo_allestimento " +
                        "FROM autoquest.confronto_auto ca " +
                        "JOIN autoquest.allestimento al ON ca.ID_allestimento = al.ID_allestimento " +
                        "JOIN autoquest.auto a ON al.ID_auto = a.ID_auto " +
                        "WHERE ca.ID_confronto = ?";

        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setInt(1, confrontoId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    AutoBean auto = new AutoBean();
                    auto.setIdAuto(resultSet.getInt("ID_auto"));
                    auto.setMarchio(resultSet.getString("Marchio"));
                    auto.setModello(resultSet.getString("Modello"));
                    auto.setAlimentazione(Alimentazione.fromString(resultSet.getString("Alimentazione")));
                    auto.setPotenza(resultSet.getInt("Potenza"));
                    auto.setCambio(Cambio.fromString(resultSet.getString("Cambio")));
                    auto.setCilindrata(resultSet.getInt("Cilindrata"));
                    double prezzo = resultSet.getDouble("Prezzo_base");
                    auto.setPrezzoBase((int) Math.round(prezzo));
                    auto.setLinkAcquisto(resultSet.getString("Link_acquisto"));
                    auto.setImmagineUrl(resultSet.getString("Immagine_url"));

                    // Ora queste colonne esistono nella SELECT
                    int idAll = resultSet.getInt("ID_allestimento");
                    if (!resultSet.wasNull()) {
                        auto.setSelectedAllestimentoId(idAll);
                        auto.setSelectedAllestimentoNome(resultSet.getString("Nome_allestimento"));
                        java.math.BigDecimal prezzoAll = resultSet.getBigDecimal("Prezzo_allestimento");
                        auto.setSelectedAllestimentoPrezzo(prezzoAll != null ? prezzoAll : java.math.BigDecimal.ZERO);
                    }

                    listaAuto.add(auto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaAuto;
    }

    public int countTotalConfronti() {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            String sql = "SELECT COUNT(*) FROM autoquest.confronto";
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
}
