package model.DAO;

import model.ConnessioneDatabase;
import model.bean.AutoBean;
import model.bean.Alimentazione;
import model.bean.Cambio;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class AutoSalvateDAO {

    /**
     * Restituisce le auto salvate dall'utente con dati aggiuntivi (nome allestimento, prezzo attuale, data salvataggio).
     * Metodo usato dalla servlet /garage e dalle altre viste.
     */
    public List<AutoBean> getAutoSalvateConAllestimento(int idUtente) {
        List<AutoBean> lista = new ArrayList<>();
        String sql =
                "SELECT asv.ID_lista_auto, a.ID_auto, a.Marchio, a.Modello, a.Alimentazione, a.Potenza, a.Cambio, " +
                        " a.Cilindrata, a.Prezzo_base, a.Link_acquisto, a.Immagine_url, asv.ID_allestimento, asv.Prezzo_attuale, asv.Data_salvataggio, " +
                        " al.Nome_allestimento " +
                        "FROM autoquest.auto_salvate asv " +
                        "JOIN autoquest.auto a ON asv.ID_auto = a.ID_auto " +
                        "LEFT JOIN autoquest.allestimento al ON asv.ID_allestimento = al.ID_allestimento " +
                        "WHERE asv.ID_utente = ? " +
                        "ORDER BY asv.Data_salvataggio DESC";

        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, idUtente);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AutoBean a = new AutoBean();
                    a.setIdAuto(rs.getInt("ID_auto"));
                    a.setMarchio(rs.getString("Marchio"));
                    a.setModello(rs.getString("Modello"));

                    String aliment = rs.getString("Alimentazione");
                    if (aliment != null) a.setAlimentazione(Alimentazione.fromString(aliment));
                    String cambio = rs.getString("Cambio");
                    if (cambio != null) a.setCambio(Cambio.fromString(cambio));

                    a.setPotenza(rs.getInt("Potenza"));
                    a.setCilindrata(rs.getInt("Cilindrata"));

                    // Prezzo_base in DB è DECIMAL — nel bean hai int: arrotondo come prima
                    double prezzoBaseDb = rs.getDouble("Prezzo_base");
                    a.setPrezzoBase((int) Math.round(prezzoBaseDb));

                    a.setLinkAcquisto(rs.getString("Link_acquisto"));
                    a.setImmagineUrl(rs.getString("Immagine_url"));

                    // ID_allestimento salvato (può essere null)
                    int idAll = rs.getInt("ID_allestimento");
                    if (!rs.wasNull()) a.setSelectedAllestimentoId(idAll);

                    // Prezzo_attuale (BigDecimal)
                    BigDecimal prezzoAttuale = rs.getBigDecimal("Prezzo_attuale");
                    if (prezzoAttuale != null) {
                        a.setSelectedAllestimentoPrezzo(prezzoAttuale);
                        // aggiungo anche un alias "prezzoAttuale" se il bean lo definisce
                        try {
                            a.setPrezzoAttuale(prezzoAttuale);
                        } catch (NoSuchMethodError ignore) {
                            // nel caso il tuo bean non abbia prezzoAttuale, non è un problema
                        }
                    }

                    // Data_salvataggio -> LocalDateTime
                    Timestamp ts = rs.getTimestamp("Data_salvataggio");
                    if (ts != null) a.setDataSalvataggio(ts.toLocalDateTime());

                    // Nome allestimento (LEFT JOIN)
                    String nomeAll = rs.getString("Nome_allestimento");
                    if (nomeAll != null) a.setSelectedAllestimentoNome(nomeAll);

                    lista.add(a);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore nel recupero delle auto salvate con allestimento", e);
        }
        return lista;
    }

    /**
     * Salva un'auto nel garage (auto_salvate). idAllestimento può essere null -> cerchiamo fallback.
     */
    public void salvaAutoInGarage(int idUtente, int idAuto, Integer idAllestimento, java.math.BigDecimal prezzoAttuale) throws SQLException {
        // se non viene fornito un allestimento valido, prova a trovare un default
        if (idAllestimento == null || idAllestimento <= 0) {
            idAllestimento = findDefaultAllestimentoIdForAuto(idAuto);
        }

        String sql = "INSERT INTO autoquest.auto_salvate (ID_auto, ID_allestimento, ID_utente, Prezzo_attuale) VALUES (?, ?, ?, ?)";
        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, idAuto);
            if (idAllestimento == null) ps.setNull(2, Types.INTEGER);
            else ps.setInt(2, idAllestimento);

            ps.setInt(3, idUtente);

            if (prezzoAttuale != null) ps.setBigDecimal(4, prezzoAttuale);
            else ps.setNull(4, Types.DECIMAL);

            ps.executeUpdate();
        }
    }

    /**
     * Rimuove un'auto dal garage per utente/idAuto.
     */
    public void rimuoviAutoDaGarage(int idUtente, int idAuto) throws SQLException {
        String sql = "DELETE FROM autoquest.auto_salvate WHERE ID_utente = ? AND ID_auto = ?";
        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, idUtente);
            ps.setInt(2, idAuto);
            ps.executeUpdate();
        }
    }

    /**
     * Cerca il primo allestimento (di default) per una data auto — ad es. il più economico.
     * Restituisce null se non ci sono allestimenti.
     */
    private Integer findDefaultAllestimentoIdForAuto(int idAuto) {
        String sql = "SELECT ID_allestimento FROM autoquest.allestimento WHERE ID_auto = ? ORDER BY Prezzo_allestimento ASC LIMIT 1";
        try (Connection connection = ConnessioneDatabase.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, idAuto);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("ID_allestimento");
            }
        } catch (SQLException e) {
            // loggare su console per debug ma non stoppiamo l'esecuzione
            e.printStackTrace();
        }
        return null;
    }
}
