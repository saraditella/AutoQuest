// File: model/bean/ConfrontoBean.java
package model.bean;

import java.time.LocalDateTime;

public class ConfrontoBean {
    private int idConfronto;
    private String nomeConfronto;
    private LocalDateTime dataCreazione;

    public ConfrontoBean() {}

    public int getIdConfronto() {
        return idConfronto;
    }
    public void setIdConfronto(int idConfronto) {
        this.idConfronto = idConfronto;
    }

    public String getNomeConfronto() {
        return nomeConfronto;
    }
    public void setNomeConfronto(String nomeConfronto) {
        this.nomeConfronto = nomeConfronto;
    }

    public LocalDateTime getDataCreazione() {
        return dataCreazione;
    }
    public void setDataCreazione(LocalDateTime dataCreazione) {
        this.dataCreazione = dataCreazione;
    }
}
