package controller.generale;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.UtenteDAO;
import model.bean.UtenteBean;

import java.io.IOException;

@WebServlet(name = "RegistrazioneServlet", urlPatterns = {"/registrazione", "/registrazione-servlet"})
// Servlet che gestisce la registrazione di nuovi utenti.
// È accessibile sia tramite "/registrazione" che "/registrazione-servlet".
public class RegistrazioneServlet extends HttpServlet {
    // DAO per gestire le operazioni sul database relative agli utenti
    private final UtenteDAO utenteDAO = new UtenteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera la sessione corrente (senza crearne una nuova se non esiste)
        HttpSession session = request.getSession(false);

        // Se l'utente è già loggato → reindirizza all'area utente
        if (session != null && session.getAttribute("utenteLoggato") != null) {
            response.sendRedirect(request.getContextPath() + "/area-utente");
            return;
        }

        // Mostra la pagina di registrazione
        request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera i parametri inviati dal form di registrazione
        String nome = request.getParameter("nome");
        String cognome = request.getParameter("cognome");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confermaPassword = request.getParameter("confermaPassword");

        // Validazione input: tutti i campi obbligatori
        if (nome == null || nome.trim().isEmpty() ||
                cognome == null || cognome.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

            // Se manca un campo → mostra messaggio di errore e preserva i dati inseriti
            request.setAttribute("errorMessage", "Tutti i campi sono obbligatori");
            preserveFormData(request, nome, cognome, email);
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
            return;
        }

        // Verifica che le password corrispondano
        if (!password.equals(confermaPassword)) {
            request.setAttribute("errorMessage", "Le password non corrispondono");
            preserveFormData(request, nome, cognome, email);
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
            return;
        }

        // Verifica lunghezza minima della password
        if (password.length() < 6) {
            request.setAttribute("errorMessage", "La password deve essere di almeno 6 caratteri");
            preserveFormData(request, nome, cognome, email);
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
            return;
        }

        try {
            // Crea un nuovo oggetto UtenteBean con i dati forniti
            UtenteBean nuovoUtente = new UtenteBean();
            nuovoUtente.setNome(nome.trim());
            nuovoUtente.setCognome(cognome.trim());
            nuovoUtente.setEmail(email.trim().toLowerCase());
            nuovoUtente.setPassword(password);
            nuovoUtente.setRuolo("UTENTE"); // Ruolo di default

            // Tentativo di registrazione tramite DAO
            if (utenteDAO.doRegistrazione(nuovoUtente)) {
                // Registrazione riuscita → salva messaggio di successo in sessione
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "Registrazione completata con successo! Effettua il login.");

                // Redirect alla pagina di login
                response.sendRedirect(request.getContextPath() + "/login");
            } else {
                // Registrazione fallita (es. email già in uso)
                request.setAttribute("errorMessage", "Errore durante la registrazione. L'email potrebbe essere già in uso.");
                preserveFormData(request, nome, cognome, email);
                request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
            }
        } catch (Exception e) {
            // Gestione eccezioni (es. errore DB) → messaggio generico
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore del sistema. Riprova più tardi.");
            preserveFormData(request, nome, cognome, email);
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
        }
    }

    // Metodo helper per preservare i dati inseriti dall'utente nel form in caso di errore
    private void preserveFormData(HttpServletRequest request, String nome, String cognome, String email) {
        request.setAttribute("nome", nome);
        request.setAttribute("cognome", cognome);
        request.setAttribute("email", email);
    }
}
