package controller.utenteLoggato;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.UtenteDAO;
import model.bean.UtenteBean;

import java.io.IOException;

@WebServlet(name = "ModificaProfiloServlet", value = "/modifica-profilo")
// Servlet per la modifica dei dati dell'utente loggato
public class ModificaProfiloServlet extends HttpServlet {
    private final UtenteDAO utenteDAO = new UtenteDAO(); // DAO per gestire le operazioni sul database utenti

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera la sessione e l'utente loggato
        HttpSession session = request.getSession(false);
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;

        // Se l'utente non è loggato, reindirizza al login
        if (utente == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Recupera i dati completi dell'utente dal database
        UtenteBean utenteCompleto = utenteDAO.doRetrieveById(utente.getIdUtente());
        if (utenteCompleto != null) {
            request.setAttribute("utente", utenteCompleto); // Passa i dati alla JSP
        }

        // Inoltra la richiesta alla JSP per la modifica del profilo
        request.getRequestDispatcher("/WEB-INF/view/modificaProfilo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera sessione e utente loggato
        HttpSession session = request.getSession(false);
        UtenteBean utenteLoggato = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;

        // Se l'utente non è loggato, reindirizza al login
        if (utenteLoggato == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Recupera i parametri inviati dal form
        String nome = request.getParameter("nome");
        String cognome = request.getParameter("cognome");
        String email = request.getParameter("email");

        // Validazione base: tutti i campi obbligatori
        if (nome == null || nome.trim().isEmpty() ||
                cognome == null || cognome.trim().isEmpty() ||
                email == null || email.trim().isEmpty()) {

            request.setAttribute("errore", "Tutti i campi sono obbligatori");
            request.setAttribute("utente", utenteLoggato);
            request.getRequestDispatcher("/WEB-INF/view/modificaProfilo.jsp").forward(request, response);
            return;
        }

        try {
            // Crea un nuovo oggetto UtenteBean con i dati aggiornati
            UtenteBean utenteAggiornato = new UtenteBean();
            utenteAggiornato.setIdUtente(utenteLoggato.getIdUtente());
            utenteAggiornato.setNome(nome.trim());
            utenteAggiornato.setCognome(cognome.trim());
            utenteAggiornato.setEmail(email.trim());
            utenteAggiornato.setRuolo(utenteLoggato.getRuolo()); // Mantiene il ruolo esistente

            // Aggiorna il profilo nel database tramite DAO
            boolean success = utenteDAO.updateProfilo(utenteAggiornato);

            if (success) {
                // Se aggiornamento riuscito, aggiorna la sessione con i nuovi dati
                utenteLoggato.setNome(nome.trim());
                utenteLoggato.setCognome(cognome.trim());
                utenteLoggato.setEmail(email.trim());
                session.setAttribute("utenteLoggato", utenteLoggato);

                session.setAttribute("successMessage", "Profilo aggiornato con successo!");
                response.sendRedirect(request.getContextPath() + "/area-utente");
            } else {
                // Se aggiornamento fallito (email già in uso o altro)
                request.setAttribute("errore", "Errore durante l'aggiornamento. L'email potrebbe essere già in uso.");
                request.setAttribute("utente", utenteAggiornato);
                request.getRequestDispatcher("/WEB-INF/view/modificaProfilo.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errore", "Errore del sistema durante l'aggiornamento");
            request.setAttribute("utente", utenteLoggato);
            request.getRequestDispatcher("/WEB-INF/view/modificaProfilo.jsp").forward(request, response);
        }
    }
}
