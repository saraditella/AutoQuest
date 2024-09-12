package model.bean;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class OrdineBean {
    private int idOrdine;
    private String marchio;
    private String modello;
    private String nomeAllestimento;
    private LocalDateTime dataOrdine;
    private BigDecimal prezzoTotale; // nuovo campo

    public OrdineBean(){}

    public int getIdOrdine() {
        return idOrdine;
    }

    public void setIdOrdine(int idOrdine) {
        this.idOrdine = idOrdine;
    }

    public String getMarchio() {
        return marchio;
    }

    public void setMarchio(String marchio) {
        this.marchio = marchio;
    }

    public String getModello() {
        return modello;
    }

    public void setModello(String modello) {
        this.modello = modello;
    }

    public String getNomeAllestimento() {
        return nomeAllestimento;
    }

    public void setNomeAllestimento(String nomeAllestimento) {
        this.nomeAllestimento = nomeAllestimento;
    }

    public LocalDateTime getDataOrdine() {
        return dataOrdine;
    }
    public void setDataOrdine(LocalDateTime dataOrdine) {
        this.dataOrdine = dataOrdine;
    }

    public BigDecimal getPrezzoTotale() {
        return prezzoTotale;
    }

    public void setPrezzoTotale(BigDecimal prezzoTotale) {
        this.prezzoTotale = prezzoTotale;
    }
}
