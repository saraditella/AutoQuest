package model.bean;

import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class UtenteBean {
    private int idUtente;
    private String nome;
    private String cognome;
    private String email;
    private String passwordhash;  // Cambiato da password a passwordhash
    private String ruolo;

    public UtenteBean() {
    }

    public int getIdUtente() {
        return idUtente;
    }

    public void setIdUtente(int idUtente) {
        this.idUtente = idUtente;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCognome() {
        return cognome;
    }

    public void setCognome(String cognome) {
        this.cognome = cognome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    // Getter per l'hash della password
    public String getPasswordhash() {
        return passwordhash;
    }

    // Setter per l'hash della password (usato quando leggi dal DB)
    public void setPasswordhash(String passwordhash) {
        this.passwordhash = passwordhash;
    }

    //Settaggio di una password in chiarp e trasformazione in hash SHA-256
    public void setPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256"); //oggetto che usa algoritmo SHA-256
            digest.reset(); //resetta affinche non contenga dati precedenti
            digest.update(password.getBytes(StandardCharsets.UTF_8)); //converte password in byte
            this.passwordhash = String.format("%064x", new BigInteger(1, digest.digest())); //calcolo dell'hash
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }


    public String getRuolo() {
        return this.ruolo;
    }

    public void setRuolo(String ruolo) {
        this.ruolo = ruolo;
    }

    // helper per EL: la property "admin" sarà visibile come utente.admin
    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(this.ruolo);
    }
}