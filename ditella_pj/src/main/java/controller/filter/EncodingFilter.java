// ==================================================
// 1. ENCODING FILTER - Gestisce la codifica UTF-8
// ==================================================
package controller.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebFilter(urlPatterns = {"/*"})
public class EncodingFilter implements Filter {

    private String encoding = "UTF-8"; // Codifica di default

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Legge parametro opzionale 'encoding' da web.xml
        String encodingParam = filterConfig.getInitParameter("encoding");
        if (encodingParam != null && !encodingParam.trim().isEmpty()) {
            this.encoding = encodingParam.trim();
        }

        System.out.println("EncodingFilter inizializzato con encoding: " + encoding);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        // Cast a HTTP per funzionalità avanzate
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Imposta encoding solo se non è già stato impostato
        // (evita di sovrascrivere impostazioni specifiche)
        if (httpRequest.getCharacterEncoding() == null) {
            httpRequest.setCharacterEncoding(encoding);
        }

        // Imposta sempre l'encoding della risposta
        httpResponse.setCharacterEncoding(encoding);
        // Imposta Content-Type con charset (importante per il browser)
        httpResponse.setContentType("text/html; charset=" + encoding);

        // Continua la catena di filtri/servlet
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        System.out.println("EncodingFilter distrutto");
        // Nessuna risorsa da liberare in questo caso
    }
}