package model.bean;
// import in cima al file (aggiungilo se non è già presente)
import java.time.format.DateTimeFormatter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

public class AutoBean {
    private int idAuto;
    private String marchio;
    private String modello;
    private Alimentazione alimentazione;
    private int potenza;
    private Cambio cambio;
    private int cilindrata;
    private int prezzoBase;
    private String linkAcquisto;
    private String immagineUrl;

    // Campi per allestimenti selezionati
    private Integer selectedAllestimentoId;         // nullable: id dell'allestimento selezionato
    private String selectedAllestimentoNome;
    private BigDecimal selectedAllestimentoPrezzo;

    // Campi aggiuntivi per auto salvate (garage)
    private BigDecimal prezzoAttuale;               // prezzo totale salvato (auto + allestimento)
    private LocalDateTime dataSalvataggio;          // quando è stata salvata nel garage
    private String nomeAllestimento;                // alias per selectedAllestimentoNome (per compatibilità)

    public AutoBean() {
    }

    // Getters e Setters base
    public int getIdAuto() {
        return idAuto;
    }

    public void setIdAuto(int idAuto) {
        this.idAuto = idAuto;
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

    public Alimentazione getAlimentazione() {
        return alimentazione;
    }

    public void setAlimentazione(Alimentazione alimentazione) {
        this.alimentazione = alimentazione;
    }

    public int getPotenza() {
        return potenza;
    }

    public void setPotenza(int potenza) {
        this.potenza = potenza;
    }

    public Cambio getCambio() {
        return cambio;
    }

    public void setCambio(Cambio cambio) {
        this.cambio = cambio;
    }

    public int getCilindrata() {
        return cilindrata;
    }

    public void setCilindrata(int cilindrata) {
        this.cilindrata = cilindrata;
    }

    public int getPrezzoBase() {
        return prezzoBase;
    }

    public void setPrezzoBase(int prezzoBase) {
        this.prezzoBase = prezzoBase;
    }

    public String getLinkAcquisto() {
        return linkAcquisto;
    }

    public void setLinkAcquisto(String linkAcquisto) {
        this.linkAcquisto = linkAcquisto;
    }

    public String getImmagineUrl() {
        return immagineUrl;
    }

    public void setImmagineUrl(String immagineUrl) {
        this.immagineUrl = immagineUrl;
    }

    // Getters e Setters per allestimenti
    public Integer getSelectedAllestimentoId() {
        return selectedAllestimentoId;
    }

    public void setSelectedAllestimentoId(Integer selectedAllestimentoId) {
        this.selectedAllestimentoId = selectedAllestimentoId;
    }

    public String getSelectedAllestimentoNome() {
        return selectedAllestimentoNome;
    }

    public void setSelectedAllestimentoNome(String selectedAllestimentoNome) {
        this.selectedAllestimentoNome = selectedAllestimentoNome;
        // Mantieni sincronizzato anche nomeAllestimento per compatibilità
        this.nomeAllestimento = selectedAllestimentoNome;
    }

    public BigDecimal getSelectedAllestimentoPrezzo() {
        return selectedAllestimentoPrezzo;
    }

    public void setSelectedAllestimentoPrezzo(BigDecimal selectedAllestimentoPrezzo) {
        this.selectedAllestimentoPrezzo = selectedAllestimentoPrezzo;
    }

    // Getters e Setters per auto salvate
    public BigDecimal getPrezzoAttuale() {
        return prezzoAttuale;
    }

    public void setPrezzoAttuale(BigDecimal prezzoAttuale) {
        this.prezzoAttuale = prezzoAttuale;
    }

    public LocalDateTime getDataSalvataggio() {
        return dataSalvataggio;
    }

    public void setDataSalvataggio(LocalDateTime dataSalvataggio) {
        this.dataSalvataggio = dataSalvataggio;
    }

    // Metodi di compatibilità
    public String getNomeAllestimento() {
        // Restituisce selectedAllestimentoNome se disponibile, altrimenti nomeAllestimento
        return selectedAllestimentoNome != null ? selectedAllestimentoNome : nomeAllestimento;
    }

    public void setNomeAllestimento(String nomeAllestimento) {
        this.nomeAllestimento = nomeAllestimento;
        // Se selectedAllestimentoNome non è già impostato, usa questo valore
        if (this.selectedAllestimentoNome == null) {
            this.selectedAllestimentoNome = nomeAllestimento;
        }
    }

    // Metodi di utilità
    /**
     * Calcola il prezzo totale (base + allestimento) se l'allestimento è selezionato
     */
    public BigDecimal getPrezzoTotaleCalcolato() {
        BigDecimal base = BigDecimal.valueOf(prezzoBase);
        if (selectedAllestimentoPrezzo != null) {
            return base.add(selectedAllestimentoPrezzo);
        }
        return base;
    }

    /**
     * Restituisce il prezzo da mostrare: prezzoAttuale se presente,
     * altrimenti calcola base + allestimento
     */
    public BigDecimal getPrezzoDisplay() {
        return prezzoAttuale != null ? prezzoAttuale : getPrezzoTotaleCalcolato();
    }



    public String getDataSalvataggioFormatted() {
        if (this.dataSalvataggio == null) {
            return "—";
        }
        // Pattern: giorno/mese/anno ore:minuti (minuti con zero se necessario)
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/M/yyyy H:mm");
        return this.dataSalvataggio.format(formatter);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        AutoBean autoBean = (AutoBean) o;
        return idAuto == autoBean.idAuto &&
                potenza == autoBean.potenza &&
                cilindrata == autoBean.cilindrata &&
                prezzoBase == autoBean.prezzoBase &&
                Objects.equals(marchio, autoBean.marchio) &&
                Objects.equals(modello, autoBean.modello) &&
                alimentazione == autoBean.alimentazione &&
                cambio == autoBean.cambio &&
                Objects.equals(linkAcquisto, autoBean.linkAcquisto) &&
                Objects.equals(immagineUrl, autoBean.immagineUrl);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idAuto, marchio, modello, alimentazione, potenza, cambio, cilindrata, prezzoBase, linkAcquisto, immagineUrl);
    }

    @Override
    public String toString() {
        return "AutoBean{" +
                "idAuto=" + idAuto +
                ", marchio='" + marchio + '\'' +
                ", modello='" + modello + '\'' +
                ", alimentazione=" + alimentazione +
                ", potenza=" + potenza +
                ", cambio=" + cambio +
                ", cilindrata=" + cilindrata +
                ", prezzoBase=" + prezzoBase +
                ", selectedAllestimentoId=" + selectedAllestimentoId +
                ", selectedAllestimentoNome='" + selectedAllestimentoNome + '\'' +
                ", prezzoAttuale=" + prezzoAttuale +
                ", dataSalvataggio=" + dataSalvataggio +
                '}';
    }
}