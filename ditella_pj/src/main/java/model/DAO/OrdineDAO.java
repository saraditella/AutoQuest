package model.DAO;

import model.ConnessioneDatabase;
import model.bean.OrdineBean;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrdineDAO {
    public List<OrdineBean> getOrdiniByUtente(int idUtente) {
        List<OrdineBean> lista = new ArrayList<>();
        String sql =
                "SELECT o.ID_ordine, a.Marchio, a.Modello, al.Nome_allestimento, o.Data_ordine, o.Prezzo_totale " +
                        "FROM autoquest.ordine o " +
                        "JOIN autoquest.allestimento al ON o.ID_allestimento = al.ID_allestimento " +
                        "JOIN autoquest.auto a ON al.ID_auto = a.ID_auto " +
                        "WHERE o.ID_utente = ? ORDER BY o.Data_ordine DESC";

        try (Connection conn = ConnessioneDatabase.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUtente);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrdineBean ob = new OrdineBean();
                    ob.setIdOrdine(rs.getInt("ID_ordine"));
                    ob.setMarchio(rs.getString("Marchio"));
                    ob.setModello(rs.getString("Modello"));
                    ob.setNomeAllestimento(rs.getString("Nome_allestimento"));
                    ob.setDataOrdine(rs.getTimestamp("Data_ordine").toLocalDateTime());
                    ob.setPrezzoTotale(rs.getBigDecimal("Prezzo_totale"));
                    lista.add(ob);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return lista;
    }

    public int creaOrdine(int idUtente, int idAllestimento, java.math.BigDecimal prezzoTotale) throws SQLException {
        String sql = "INSERT INTO autoquest.ordine (ID_utente, ID_allestimento, Prezzo_totale, Data_ordine, Stato) VALUES (?, ?, ?, NOW(), 'creato')";
        try (Connection conn = ConnessioneDatabase.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, idUtente);
            ps.setInt(2, idAllestimento);
            ps.setBigDecimal(3, prezzoTotale);
            int affected = ps.executeUpdate();
            if (affected == 0) throw new SQLException("Creazione ordine fallita");
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
                else throw new SQLException("Nessuna chiave generata per ordine");
            }
        }
    }

    /**
     * Conta il numero totale di ordini
     */
    public int countTotalOrdini() {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            String sql = "SELECT COUNT(*) FROM autoquest.ordine";
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
     * Calcola l'incasso totale di tutti gli ordini
     * @return BigDecimal rappresentante la somma di tutti i prezzi degli ordini
     */
    public BigDecimal getIncassoTotale() {
        String sql = "SELECT COALESCE(SUM(prezzo_totale), 0) AS incasso_totale FROM autoquest.ordine";

        try (Connection conn = ConnessioneDatabase.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getBigDecimal("incasso_totale");
            }

        } catch (SQLException e) {
            System.err.println("Errore nel calcolo dell'incasso totale: " + e.getMessage());
            e.printStackTrace();
        }

        return BigDecimal.ZERO; // Ritorna 0 in caso di errore
    }
}