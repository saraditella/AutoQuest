package controller.utenteLoggato;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.UtenteDAO;
import model.bean.UtenteBean;

import java.io.IOException;

@WebServlet(name = "CambiaPasswordServlet", value = "/cambia-password")
// Servlet che gestisce la visualizzazione e l'aggiornamento della password dell'utente loggato
public class CambiaPasswordServlet extends HttpServlet {
    // DAO per interagire con il database degli utenti
    private final UtenteDAO utenteDAO = new UtenteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera la sessione esistente senza crearne una nuova
        HttpSession session = request.getSession(false);
        // Recupera l'utente loggato dalla sessione
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;

        // Se l'utente non è loggato, reindirizza al login
        if (utente == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Inoltra alla JSP per cambiare password
        request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera sessione e utente loggato
        HttpSession session = request.getSession(false);
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;

        // Se l'utente non è loggato, reindirizza al login
        if (utente == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Recupera i parametri della form
        String passwordAttuale = request.getParameter("passwordAttuale");
        String nuovaPassword = request.getParameter("nuovaPassword");
        String confermaNuovaPassword = request.getParameter("confermaNuovaPassword");

        // Validazione dei campi: password attuale obbligatoria
        if (passwordAttuale == null || passwordAttuale.trim().isEmpty()) {
            request.setAttribute("errore", "La password attuale è obbligatoria");
            request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
            return;
        }

        // Validazione: nuova password obbligatoria
        if (nuovaPassword == null || nuovaPassword.trim().isEmpty()) {
            request.setAttribute("errore", "La nuova password è obbligatoria");
            request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
            return;
        }

        // Validazione: conferma nuova password
        if (!nuovaPassword.equals(confermaNuovaPassword)) {
            request.setAttribute("errore", "La conferma della nuova password non corrisponde");
            request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
            return;
        }

        // Validazione: lunghezza minima nuova password
        if (nuovaPassword.length() < 6) {
            request.setAttribute("errore", "La nuova password deve essere di almeno 6 caratteri");
            request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
            return;
        }

        // Validazione: nuova password diversa dalla attuale
        if (passwordAttuale.equals(nuovaPassword)) {
            request.setAttribute("errore", "La nuova password deve essere diversa da quella attuale");
            request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
            return;
        }

        try {
            // Verifica che la password attuale corrisponda a quella nel DB
            if (!utenteDAO.verificaPassword(utente.getIdUtente(), passwordAttuale)) {
                request.setAttribute("errore", "La password attuale non è corretta");
                request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
                return;
            }

            // Aggiorna la password nel DB
            if (utenteDAO.updatePassword(utente.getIdUtente(), nuovaPassword)) {
                // Successo: imposta messaggio e reindirizza all'area utente
                session.setAttribute("successMessage", "Password cambiata con successo!");
                response.sendRedirect(request.getContextPath() + "/area-utente");
            } else {
                // Fallimento aggiornamento password
                request.setAttribute("errore", "Errore durante il cambio password. Riprova.");
                request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
            }
        } catch (Exception e) {
            // Errore generico del sistema
            e.printStackTrace();
            request.setAttribute("errore", "Errore del sistema. Riprova più tardi.");
            request.getRequestDispatcher("/WEB-INF/view/cambiaPassword.jsp").forward(request, response);
        }
    }
}
