package controller.generale;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout", "/logout-servlet"})
// Questa servlet gestisce il logout dell'utente.
// È accessibile sia tramite "/logout" che "/logout-servlet".
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Se la richiesta arriva in GET, chiama il metodo logout()
        logout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Se la richiesta arriva in POST, chiama lo stesso metodo logout()
        logout(request, response);
    }

    // Metodo privato che implementa la logica del logout
    private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Recupera la sessione corrente (senza crearne una nuova se non esiste)
        HttpSession session = request.getSession(false);

        // Se esiste una sessione → viene invalidata (rimozione di tutti gli attributi salvati)
        if (session != null) {
            session.invalidate();
        }

        // Crea una nuova sessione (vuota) per mostrare un messaggio di conferma
        HttpSession newSession = request.getSession();
        newSession.setAttribute("successMessage", "Logout effettuato con successo!");

        // Dopo il logout → reindirizza l’utente alla home page del sito
        response.sendRedirect(request.getContextPath() + "/");
    }
}
