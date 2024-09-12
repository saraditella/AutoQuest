package controller.utenteLoggato.admin;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoDAO;
import model.DAO.ConfrontoDAO;
import model.DAO.UtenteDAO;
import model.DAO.OrdineDAO;
import model.bean.UtenteBean;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AdminDashboardServlet", value = "/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminDashboardServlet.class.getName());

    private final AutoDAO autoDAO = new AutoDAO();
    private final UtenteDAO utenteDAO = new UtenteDAO();
    private final OrdineDAO ordineDAO = new OrdineDAO();
    private final ConfrontoDAO confrontoDAO = new ConfrontoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== AdminDashboardServlet GET chiamato ===");
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Context Path: " + request.getContextPath());

        try {
            // Carica statistiche reali dal database
            loadDashboardStatistics(request);

            String jspPath = "/WEB-INF/view/dashboard.jsp";
            System.out.println("Forward verso: " + jspPath);

            request.getRequestDispatcher(jspPath).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore nel caricamento della dashboard admin", e);
            e.printStackTrace();
            request.setAttribute("error", "Errore nel caricamento della dashboard amministratore");

            request.getRequestDispatcher("/WEB-INF/view/dashboard.jsp")
                    .forward(request, response);
        }
    }

    /**
     * Carica tutte le statistiche per la dashboard
     */
    private void loadDashboardStatistics(HttpServletRequest request) {
        System.out.println("=== Caricamento statistiche dashboard ===");

        // Statistica Auto
        try {
            int totalAuto = autoDAO.countTotalAuto();
            request.setAttribute("totalAuto", totalAuto);
            System.out.println("Totale auto caricate: " + totalAuto);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Errore nel conteggio auto", e);
            request.setAttribute("totalAuto", "N/A");
        }

        // Statistica Utenti
        try {
            int totalUtenti = utenteDAO.countTotalUtenti();
            request.setAttribute("totalUtenti", totalUtenti);
            System.out.println("Totale utenti caricati: " + totalUtenti);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Errore nel conteggio utenti", e);
            request.setAttribute("totalUtenti", "N/A");
        }

        // Statistica Ordini
        try {
            int totalOrdini = ordineDAO.countTotalOrdini();
            request.setAttribute("totalOrdini", totalOrdini);
            System.out.println("Totale ordini caricati: " + totalOrdini);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Errore nel conteggio ordini", e);
            request.setAttribute("totalOrdini", "N/A");
        }

        // Statistica Confronti
        try {
            int totalConfronti = confrontoDAO.countTotalConfronti();
            request.setAttribute("totalConfronti", totalConfronti);
            System.out.println("Totale confronti caricati: " + totalConfronti);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Errore nel conteggio confronti", e);
            request.setAttribute("totalConfronti", "N/A");
        }

        // NUOVO: Statistica Incasso Totale
        try {
            BigDecimal incassoTotale = ordineDAO.getIncassoTotale();
            request.setAttribute("incassoTotale", incassoTotale);
            System.out.println("Incasso totale caricato: " + incassoTotale);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Errore nel calcolo incasso totale", e);
            request.setAttribute("incassoTotale", BigDecimal.ZERO);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}