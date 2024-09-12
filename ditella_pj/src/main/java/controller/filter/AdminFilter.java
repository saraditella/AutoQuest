
// ==================================================
// 3. ADMIN FILTER - Controlla privilegi amministratore
// ==================================================
package controller.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.bean.UtenteBean;

import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    // Costanti per gli attributi e valori
    private static final String ATTR_UTENTE_LOGGATO = "utenteLoggato";
    private static final String ATTR_REDIRECT_AFTER_LOGIN = "redirectAfterLogin";
    private static final String ATTR_ERROR_MESSAGE = "errorMessage";
    private static final String RUOLO_ADMIN = "ADMIN";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AdminFilter inizializzato per proteggere area amministrativa");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Calcola path relativo per logging (rimuove context path)
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String relativePath = requestURI.substring(contextPath.length());

        System.out.println("AdminFilter: Controllo accesso admin a: " + relativePath);

        // === VERIFICA AUTENTICAZIONE ===
        HttpSession session = httpRequest.getSession(false);
        UtenteBean utente = (session != null) ?
                (UtenteBean) session.getAttribute(ATTR_UTENTE_LOGGATO) : null;

        // Utente non loggato
        if (utente == null) {
            System.out.println("AdminFilter: Utente non loggato, redirect al login");
            handleUnauthenticatedUser(httpRequest, httpResponse);
            return;
        }

        // === VERIFICA AUTORIZZAZIONE ADMIN ===
        if (!isAdmin(utente)) {
            System.out.println("AdminFilter: Accesso negato per utente " + utente.getEmail() +
                    " (ruolo: " + utente.getRuolo() + ")");
            handleUnauthorizedUser(httpRequest, httpResponse, utente);
            return;
        }

        // === ACCESSO CONSENTITO ===
        System.out.println("AdminFilter: Accesso admin consentito per: " + utente.getEmail());
        chain.doFilter(request, response);
    }

    private void handleUnauthenticatedUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Salva URL per redirect post-login
        HttpSession session = request.getSession(); // Crea sessione se necessario
        session.setAttribute(ATTR_REDIRECT_AFTER_LOGIN, request.getRequestURI());

        // Redirect al login
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void handleUnauthorizedUser(HttpServletRequest request, HttpServletResponse response,
                                        UtenteBean utente) throws IOException {

        // Imposta messaggio di errore specifico
        request.getSession().setAttribute(ATTR_ERROR_MESSAGE,
                "Accesso negato. È richiesto il ruolo di amministratore per accedere a questa sezione.");

        // Redirect all'area utente normale
        response.sendRedirect(request.getContextPath() + "/area-utente");
    }

    private boolean isAdmin(UtenteBean utente) {
        if (utente == null) {
            return false;
        }

        try {
            // Controllo 1: Campo ruolo
            String ruolo = utente.getRuolo();
            boolean isAdminByRole = RUOLO_ADMIN.equalsIgnoreCase(ruolo);

            // Controllo 2: Metodo isAdmin()
            boolean isAdminByMethod = utente.isAdmin();

            // Log per debugging
            System.out.println("AdminFilter: Verifica privilegi per " + utente.getEmail() +
                    " - Ruolo='" + ruolo + "', isAdmin()=" + isAdminByMethod);

            // OR logico: basta una condizione vera
            return isAdminByRole || isAdminByMethod;

        } catch (Exception e) {
            // Gestione errori durante la verifica
            System.err.println("AdminFilter: Errore nella verifica privilegi admin per utente " +
                    (utente.getEmail() != null ? utente.getEmail() : "sconosciuto") +
                    ": " + e.getMessage());
            e.printStackTrace();

            // In caso di errore, NEGA l'accesso (sicurezza)
            return false;
        }
    }

    @Override
    public void destroy() {
        System.out.println("AdminFilter distrutto");
    }
}
