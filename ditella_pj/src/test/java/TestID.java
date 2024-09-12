import model.DAO.AutoDAO;
import model.bean.AutoBean;

import java.util.List;

public class TestID {

    public TestID() {
        AutoDAO dao = new AutoDAO();

        // Test 1: Recupera tutte le auto e stampa i primi ID
        List<AutoBean> listaAuto = dao.doRetrieveAllAuto();
        System.out.println("=== TEST DAO ===");
        System.out.println("Totale auto recuperate: " + listaAuto.size());

        for (int i = 0; i < Math.min(5, listaAuto.size()); i++) {
            AutoBean auto = listaAuto.get(i);
            System.out.println("Auto " + i + ":");
            System.out.println("  - ID: " + auto.getIdAuto());
            System.out.println("  - Marchio: " + auto.getMarchio());
            System.out.println("  - Modello: " + auto.getModello());
        }

        // Test 2: Prova a recuperare per ID specifico
        if (!listaAuto.isEmpty()) {
            int testId = listaAuto.get(0).getIdAuto();
            System.out.println("Test recupero per ID: " + testId);
            AutoBean autoById = dao.doRetrieveById(testId);
            System.out.println("Auto recuperata per ID: " + (autoById != null ? autoById.getMarchio() + " " + autoById.getModello() : "NULL"));
        }
    }
    public static void main(String[] args) {
        TestID testID = new TestID();
    }
}
