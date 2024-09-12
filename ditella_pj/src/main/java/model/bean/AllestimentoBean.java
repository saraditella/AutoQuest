package model.bean;

import java.math.BigDecimal;

public class AllestimentoBean {
    private int idAllestimento;
    private int idAuto;
    private String nomeAllestimento;
    private String descrizioneAllestimento;
    private BigDecimal prezzoAllestimento;

    public AllestimentoBean() {}

    public int getIdAllestimento() {
        return idAllestimento;
    }
    public void setIdAllestimento(int idAllestimento) {
        this.idAllestimento = idAllestimento;
    }

    public int getIdAuto() {
        return idAuto;
    }

    public void setIdAuto(int idAuto) {
        this.idAuto = idAuto;
    }

    public String getNomeAllestimento() {
        return nomeAllestimento;
    }
    public void setNomeAllestimento(String nomeAllestimento) {
        this.nomeAllestimento = nomeAllestimento;
    }

    public String getDescrizioneAllestimento() {
        return descrizioneAllestimento;
    }

    public void setDescrizioneAllestimento(String descrizioneAllestimento) {
        this.descrizioneAllestimento = descrizioneAllestimento;
    }

    public BigDecimal getPrezzoAllestimento() {
        return prezzoAllestimento;
    }

    public void setPrezzoAllestimento(BigDecimal prezzoAllestimento) {
        this.prezzoAllestimento = prezzoAllestimento;
    }
}
