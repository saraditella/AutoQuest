package controller.generale;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.UtenteDAO;
import model.bean.UtenteBean;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/login-servlet"})
// Questa servlet gestisce il processo di login dell'utente.
// È accessibile sia tramite "/login" che "/login-servlet".
public class LoginServlet extends HttpServlet {
    // DAO che gestisce le operazioni sul database relative agli utenti
    private final UtenteDAO utenteDAO = new UtenteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera la sessione corrente (senza crearne una nuova se non esiste)
        HttpSession session = request.getSession(false);

        // Se l'utente è già loggato → reindirizza alla pagina area utente
        if (session != null && session.getAttribute("utenteLoggato") != null) {
            response.sendRedirect(request.getContextPath() + "/area-utente");
            return;
        }

        // Se non è loggato → mostra la pagina di login
        request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera i parametri inviati dal form di login
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Controlla che i campi non siano nulli o vuoti
        if (email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

            // Se mancano → mostra un messaggio di errore nella pagina di login
            request.setAttribute("errorMessage", "Email e password sono obbligatori");
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            return;
        }

        try {
            // Tentativo di autenticazione con le credenziali inserite
            UtenteBean utente = utenteDAO.doLogin(email.trim(), password);

            if (utente != null) {
                // Login riuscito → salva l'utente in sessione
                HttpSession session = request.getSession();
                session.setAttribute("utenteLoggato", utente);

                // Rimuove eventuali vecchi messaggi di errore
                session.removeAttribute("errorMessage");

                // Controlla se c'è un redirect memorizzato (es. utente voleva accedere a una pagina protetta)
                String redirectUrl = (String) session.getAttribute("redirectAfterLogin");
                if (redirectUrl != null) {
                    // Se esiste → lo usa e poi lo rimuove
                    session.removeAttribute("redirectAfterLogin");
                    response.sendRedirect(redirectUrl);
                } else {
                    // Se non esiste → reindirizza all'area utente
                    response.sendRedirect(request.getContextPath() + "/area-utente");
                }
            } else {
                // Credenziali errate → mostra errore e ripresenta il form
                request.setAttribute("errorMessage", "Email o password non corretti");
                request.setAttribute("email", email); // Mantiene l'email inserita per comodità
                request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            // In caso di eccezione (es. problemi DB) → mostra errore generico
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore del sistema. Riprova più tardi.");
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
        }
    }
}
