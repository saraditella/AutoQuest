package model.DAO;

import model.ConnessioneDatabase;
import model.bean.AllestimentoBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class AllestimentoDAO {

    public List<AllestimentoBean> getAllestimentiByAuto(int idAuto) {
        List<AllestimentoBean> lista = new ArrayList<>();
        String sql = "SELECT ID_allestimento, ID_auto, Nome_allestimento, Descrizione_allestimento, Prezzo_allestimento " +
                "FROM autoquest.allestimento WHERE ID_auto = ? ORDER BY Prezzo_allestimento ASC";
        try (Connection conn = ConnessioneDatabase.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idAuto);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AllestimentoBean a = new AllestimentoBean();
                    a.setIdAllestimento(rs.getInt("ID_allestimento"));
                    a.setIdAuto(rs.getInt("ID_auto"));
                    a.setNomeAllestimento(rs.getString("Nome_allestimento"));
                    a.setDescrizioneAllestimento(rs.getString("Descrizione_allestimento"));
                    BigDecimal prezzo = rs.getBigDecimal("Prezzo_allestimento");
                    a.setPrezzoAllestimento(prezzo != null ? prezzo : BigDecimal.ZERO);
                    lista.add(a);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return lista;
    }

    public AllestimentoBean getAllestimentoById(int idAllestimento) {
        String sql = "SELECT ID_allestimento, ID_auto, Nome_allestimento, Descrizione_allestimento, Prezzo_allestimento " +
                "FROM autoquest.allestimento WHERE ID_allestimento = ?";
        try (Connection conn = ConnessioneDatabase.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idAllestimento);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    AllestimentoBean a = new AllestimentoBean();
                    a.setIdAllestimento(rs.getInt("ID_allestimento"));
                    a.setIdAuto(rs.getInt("ID_auto"));
                    a.setNomeAllestimento(rs.getString("Nome_allestimento"));
                    a.setDescrizioneAllestimento(rs.getString("Descrizione_allestimento"));
                    BigDecimal prezzo = rs.getBigDecimal("Prezzo_allestimento");
                    a.setPrezzoAllestimento(prezzo != null ? prezzo : BigDecimal.ZERO);
                    return a;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    /**
     * Restituisce il primo ID_allestimento per una data auto (ordine per prezzo asc).
     * Utile come fallback se un elemento in sessione non ha selectedAllestimentoId.
     */
    public Integer getFirstAllestimentoIdForAuto(int idAuto) {
        String sql = "SELECT ID_allestimento FROM autoquest.allestimento WHERE ID_auto = ? ORDER BY Prezzo_allestimento ASC LIMIT 1";
        try (Connection conn = ConnessioneDatabase.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idAuto);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("ID_allestimento");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore getFirstAllestimentoIdForAuto", e);
        }
        return null;
    }


}
