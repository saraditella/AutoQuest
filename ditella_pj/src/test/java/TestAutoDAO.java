import model.DAO.AutoDAO;
import model.bean.AutoBean;

import java.util.List;

public class TestAutoDAO {
    public static void main(String[] args) {
        AutoDAO dao = new AutoDAO();
        List<AutoBean> tutte = dao.doRetrieveAllAuto();

        for (AutoBean a : tutte) {
            System.out.println("ID: " + a.getIdAuto());
            System.out.println("Marchio: " + a.getMarchio());
            System.out.println("Modello: " + a.getModello());
            System.out.println("Alimentazione: " + a.getAlimentazione());
            System.out.println("Potenza: " + a.getPotenza() + " CV");
            System.out.println("Cambio: " + a.getCambio());
            System.out.println("Cilindrata: " + a.getCilindrata() + " cc");
            System.out.println("Prezzo base: " + a.getPrezzoBase() + " €");
            System.out.println("Link: " + a.getLinkAcquisto());
            System.out.println("Immagine: " + a.getImmagineUrl());
            System.out.println("------------");
        }
    }
}
