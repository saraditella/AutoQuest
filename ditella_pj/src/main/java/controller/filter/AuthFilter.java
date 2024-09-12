// ==================================================
// 2. AUTH FILTER - Controlla autenticazione utente
// ==================================================
package controller.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.bean.UtenteBean;

import java.io.IOException;

@WebFilter(urlPatterns = {
        "/area-utente",
        "/garage",
        "/confronto-servlet",
        "/salva-garage",
        "/rimuovi-garage",
        "/acquista-servlet"
})
public class AuthFilter implements Filter {

    // Costanti per gli attributi di sessione
    private static final String ATTR_UTENTE_LOGGATO = "utenteLoggato";
    private static final String ATTR_REDIRECT_AFTER_LOGIN = "redirectAfterLogin";
    private static final String ATTR_ERROR_MESSAGE = "errorMessage";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AuthFilter inizializzato per proteggere pagine autenticate");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        System.out.println("AuthFilter: Controllo autenticazione per: " + requestURI);

        // === VERIFICA SESSIONE E UTENTE ===
        // getSession(false) = NON crea sessione se non esiste (ottimizzazione)
        HttpSession session = httpRequest.getSession(false);

        // Recupera utente dalla sessione (impostato durante il login)
        UtenteBean utente = (session != null) ?
                (UtenteBean) session.getAttribute(ATTR_UTENTE_LOGGATO) : null;

        // === GESTIONE UTENTE NON AUTENTICATO ===
        if (utente == null) {
            System.out.println("AuthFilter: Utente non autenticato, redirect al login");

            // Costruisce URL completa per il redirect post-login
            String requestedUrl = buildFullRequestUrl(httpRequest);

            // Crea sessione per salvare dati di redirect e errore
            HttpSession newSession = httpRequest.getSession(); // Crea se non esiste
            newSession.setAttribute(ATTR_REDIRECT_AFTER_LOGIN, requestedUrl);
            newSession.setAttribute(ATTR_ERROR_MESSAGE,
                    "È necessario effettuare il login per accedere a questa pagina.");

            // Redirect alla pagina di login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return; // Ferma l'esecuzione qui
        }

        // === UTENTE AUTENTICATO ===
        System.out.println("AuthFilter: Accesso consentito per utente: " + utente.getEmail());

        // Continua la catena di filtri/servlet
        chain.doFilter(request, response);
    }

    private String buildFullRequestUrl(HttpServletRequest request) {
        String requestedUrl = request.getRequestURL().toString();
        String queryString = request.getQueryString();

        if (queryString != null && !queryString.trim().isEmpty()) {
            requestedUrl += "?" + queryString;
        }

        return requestedUrl;
    }

    @Override
    public void destroy() {
        System.out.println("AuthFilter distrutto");
    }
}
