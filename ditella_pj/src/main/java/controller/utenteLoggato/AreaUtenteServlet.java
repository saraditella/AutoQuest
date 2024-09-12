package controller.utenteLoggato;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.DAO.AutoDAO;
import model.DAO.AutoSalvateDAO;
import model.DAO.ConfrontoDAO;
import model.DAO.OrdineDAO;
import model.DAO.UtenteDAO;
import model.bean.AutoBean;
import model.bean.ConfrontoBean;
import model.bean.UtenteBean;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AreaUtenteServlet", value = "/area-utente")
public class AreaUtenteServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AreaUtenteServlet.class.getName());

    private final ConfrontoDAO confrontoDAO = new ConfrontoDAO();
    private final AutoSalvateDAO autoSalvateDAO = new AutoSalvateDAO();
    private final OrdineDAO ordineDAO = new OrdineDAO();
    private final AutoDAO autoDAO = new AutoDAO();
    private final UtenteDAO utenteDAO = new UtenteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("=== AreaUtenteServlet GET chiamato ===");

        HttpSession session = request.getSession(false);
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;

        if (utente == null) {
            System.out.println("Utente non loggato, redirect al login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        System.out.println("Utente loggato: " + utente.getEmail());
        System.out.println("Ruolo utente: " + utente.getRuolo());
        System.out.println("È admin: " + utente.isAdmin());

        // CORREZIONE: Se l'utente è admin, carica solo le statistiche
        if (isAdmin(utente)) {
            System.out.println("Utente è admin, carico statistiche per pannello admin");
            loadAdminStatistics(request);
            // Per admin non carichiamo confronti/garage/ordini personali
            request.setAttribute("confronti", Collections.emptyList());
            request.setAttribute("garage", Collections.emptyList());
            request.setAttribute("preferiti", Collections.emptyList());
            request.setAttribute("ordini", Collections.emptyList());
        } else {
            System.out.println("Utente normale, carico i suoi dati");
            // Per utenti normali carichiamo i loro dati
            loadUserData(request, utente.getIdUtente());
        }

        request.getRequestDispatcher("/WEB-INF/view/areaUtente.jsp").forward(request, response);
    }

    private void loadAdminStatistics(HttpServletRequest request) {
        System.out.println("=== Caricamento statistiche admin per area utente ===");

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
    }

    private void loadUserData(HttpServletRequest request, int idUtente) {
        List<ConfrontoBean> confronti = Collections.emptyList();
        List<AutoBean> preferiti = Collections.emptyList();
        List<?> ordini = Collections.emptyList();

        try {
            confronti = confrontoDAO.getConfrontiByUtente(idUtente);
            System.out.println("Confronti caricati: " + confronti.size());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore caricamento confronti per utente " + idUtente, e);
            request.setAttribute("confrontiError", "Errore nel caricamento dei confronti.");
        }

        try {
            preferiti = autoSalvateDAO.getAutoSalvateConAllestimento(idUtente);
            System.out.println("Auto garage caricate: " + preferiti.size());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore caricamento garage per utente " + idUtente, e);
            request.setAttribute("garageError", "Errore nel caricamento del garage.");
        }

        try {
            ordini = ordineDAO.getOrdiniByUtente(idUtente);
            System.out.println("Ordini caricati: " + (ordini != null ? ordini.size() : 0));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore caricamento ordini per utente " + idUtente, e);
            request.setAttribute("ordiniError", "Errore nel caricamento degli ordini.");
        }

        // Imposto entrambi gli attributi per compatibilità JSP
        request.setAttribute("confronti", confronti);
        request.setAttribute("garage", preferiti);     // usato in alcune versioni della JSP
        request.setAttribute("preferiti", preferiti);  // usato da /garage JSP
        request.setAttribute("ordini", ordini);
    }

    private boolean isAdmin(UtenteBean utente) {
        if (utente == null) return false;

        try {
            String ruolo = utente.getRuolo();
            boolean isAdminByRole = "ADMIN".equalsIgnoreCase(ruolo);
            boolean isAdminByMethod = utente.isAdmin();

            return isAdminByRole || isAdminByMethod;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Errore nella verifica ruolo admin", e);
            return false;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}