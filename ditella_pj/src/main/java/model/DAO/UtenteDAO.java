package model.DAO;

import model.ConnessioneDatabase;
import model.bean.UtenteBean;

import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UtenteDAO {

    /**
     * Metodo helper per hashare una password con SHA-256
     */
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.reset();
            digest.update(password.getBytes(StandardCharsets.UTF_8));
            return String.format("%064x", new BigInteger(1, digest.digest()));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    public UtenteBean doLogin(String email, String password) {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            // IMPORTANTE: Ora confrontiamo con passwordhash, non password
            String sql = "SELECT * FROM autoquest.utente WHERE email = ? AND passwordhash = ?";
            PreparedStatement preparedStatement = connection.prepareStatement(sql);

            preparedStatement.setString(1, email);
            preparedStatement.setString(2, hashPassword(password)); // Hash SHA-256 della password inserita

            ResultSet resultSet = preparedStatement.executeQuery();
            if(resultSet.next()) {
                UtenteBean utente = new UtenteBean();
                utente.setIdUtente(resultSet.getInt("ID_utente"));
                utente.setNome(resultSet.getString("Nome"));
                utente.setCognome(resultSet.getString("Cognome"));
                utente.setEmail(resultSet.getString("Email"));
                utente.setPasswordhash(resultSet.getString("passwordhash")); // Leggiamo l'hash
                utente.setRuolo(resultSet.getString("Ruolo"));
                return utente;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean doRegistrazione(UtenteBean utente) {
        try(Connection connection = ConnessioneDatabase.getConnection()) {
            // IMPORTANTE: Salviamo nel campo passwordhash, non password
            String sql = "INSERT INTO autoquest.utente (nome, cognome, email, passwordhash, ruolo) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, utente.getNome());
            preparedStatement.setString(2, utente.getCognome());
            preparedStatement.setString(3, utente.getEmail());
            preparedStatement.setString(4, utente.getPasswordhash()); // Già hashata dal bean con SHA-256
            preparedStatement.setString(5, utente.getRuolo() != null ? utente.getRuolo() : "UTENTE");
            preparedStatement.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Recupera un utente per ID
     */
    public UtenteBean doRetrieveById(int idUtente) {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            String sql = "SELECT * FROM autoquest.utente WHERE ID_utente = ?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idUtente);

            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                UtenteBean utente = new UtenteBean();
                utente.setIdUtente(rs.getInt("ID_utente"));
                utente.setNome(rs.getString("Nome"));
                utente.setCognome(rs.getString("Cognome"));
                utente.setEmail(rs.getString("Email"));
                utente.setPasswordhash(rs.getString("passwordhash")); // Leggiamo l'hash
                utente.setRuolo(rs.getString("Ruolo"));
                return utente;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Aggiorna il profilo utente (nome, cognome, email)
     */
    public boolean updateProfilo(UtenteBean utente) {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            String sql = "UPDATE autoquest.utente SET nome = ?, cognome = ?, email = ? WHERE ID_utente = ?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, utente.getNome());
            ps.setString(2, utente.getCognome());
            ps.setString(3, utente.getEmail());
            ps.setInt(4, utente.getIdUtente());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cambia la password dell'utente
     */
    public boolean updatePassword(int idUtente, String nuovaPassword) {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            // IMPORTANTE: Aggiorniamo passwordhash, non password
            String sql = "UPDATE autoquest.utente SET passwordhash = ? WHERE ID_utente = ?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, hashPassword(nuovaPassword)); // Hash SHA-256 della nuova password
            ps.setInt(2, idUtente);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Verifica la password attuale dell'utente
     */
    public boolean verificaPassword(int idUtente, String passwordAttuale) {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            // IMPORTANTE: Confrontiamo con passwordhash, non password
            String sql = "SELECT ID_utente FROM autoquest.utente WHERE ID_utente = ? AND passwordhash = ?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idUtente);
            ps.setString(2, hashPassword(passwordAttuale)); // Hash SHA-256 della password inserita

            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Conta il numero totale di utenti
     */
    public int countTotalUtenti() {
        try (Connection connection = ConnessioneDatabase.getConnection()) {
            String sql = "SELECT COUNT(*) FROM autoquest.utente";
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