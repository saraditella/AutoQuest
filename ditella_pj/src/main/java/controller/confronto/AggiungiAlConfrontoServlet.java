package controller.confronto;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AllestimentoDAO;
import model.DAO.AutoDAO;
import model.bean.AutoBean;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
@WebServlet(name = "AggiungiAlConfrontoServlet", value = "/aggiungi-confronto-servlet")
public class AggiungiAlConfrontoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // parametri attesi
        String idAutoParam = request.getParameter("idAuto");
        String ajax = request.getParameter("ajax");

        System.out.println("DEBUG: Ricevuto idAuto: " + idAutoParam + ", ajax: " + ajax);


        if (idAutoParam == null || idAutoParam.isEmpty()) {
            String errorMsg = "ID auto mancante";
            System.out.println("ERROR: " + errorMsg);

            // Se richiesta AJAX, rispondo JSON con errore
            if ("true".equals(ajax)) {
                sendJsonResponse(response, false, errorMsg, 0);
                return;
            }
            // altrimenti redirect alla pagina auto
            response.sendRedirect("auto-servlet");
            return;
        }

        try {
            HttpSession session = request.getSession();
            int idAuto = Integer.parseInt(idAutoParam);

            System.out.println("DEBUG: Parsing idAuto riuscito: " + idAuto);

            // Recupera o inizializza la lista confronto dalla sessione
            List<AutoBean> confronto = (List<AutoBean>) session.getAttribute("confronto");
            if (confronto == null) {
                confronto = new ArrayList<>();
                System.out.println("DEBUG: Creata nuova lista confronto");
            } else {
                System.out.println("DEBUG: Lista confronto esistente con " + confronto.size() + " elementi");
            }

            // Recupera l'auto dal database tramite DAO
            AutoDAO dao = new AutoDAO();
            AutoBean auto = null;

            try {
                auto = dao.doRetrieveById(idAuto);
                System.out.println("DEBUG: Recupero auto dal DB - " + (auto != null ? "successo" : "fallito"));
            } catch (Exception e) {
                // >>> ADDED: gestione errore DB; in produzione loggare con logger e restituire messaggio generico al client
                System.out.println("ERROR: Errore nel recupero auto dal DB: " + e.getMessage());
                e.printStackTrace();

                if ("true".equals(ajax)) {
                    sendJsonResponse(response, false, "Errore nel recupero dell'auto dal database", confronto.size());
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/auto-servlet");
                return;
            }

            // Controlla se l'auto esiste
            if (auto == null) {
                String errorMsg = "Auto non trovata nel database";
                System.out.println("ERROR: " + errorMsg);

                if ("true".equals(ajax)) {
                    sendJsonResponse(response, false, errorMsg, confronto.size());
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/auto-servlet");
                return;
            }

            AllestimentoDAO allDao = new AllestimentoDAO();
            String idAllestimentoParam = request.getParameter("idAllestimento");
            Integer chosenAllestimentoId = null;
            if (idAllestimentoParam != null && !idAllestimentoParam.isEmpty()) {
                try {
                    chosenAllestimentoId = Integer.parseInt(idAllestimentoParam);
                } catch (NumberFormatException ignored) {
                    System.out.println("WARN: idAllestimento non valido: " + idAllestimentoParam);
                }
            }

            // fallback: primo allestimento per auto (ordine prezzo ASC) se non fornito
            if (chosenAllestimentoId == null) {
                chosenAllestimentoId = allDao.getFirstAllestimentoIdForAuto(idAuto);
            }

            if (chosenAllestimentoId != null) {
                try {
                    model.bean.AllestimentoBean sel = allDao.getAllestimentoById(chosenAllestimentoId);
                    if (sel != null) {
                        // >>> ADDED: popolo i campi "selected" nell'AutoBean per indicare quale allestimento visualizzare
                        auto.setSelectedAllestimentoId(sel.getIdAllestimento());
                        auto.setSelectedAllestimentoNome(sel.getNomeAllestimento());
                        auto.setSelectedAllestimentoPrezzo(sel.getPrezzoAllestimento());
                        System.out.println("DEBUG: Impostato allestimento selezionato id=" + sel.getIdAllestimento()
                                + " nome=" + sel.getNomeAllestimento());
                    }
                } catch (Exception e) {
                    System.out.println("WARN: Impossibile caricare allestimento id=" + chosenAllestimentoId + " - " + e.getMessage());
                }
            }

            // Controlla se l'auto è già presente nel confronto (evita duplicati)
            boolean giaPresente = confronto.stream()
                    .anyMatch(a -> a.getIdAuto() == idAuto);

            String message;
            boolean success = false;

            if (giaPresente) {
                message = "Auto già presente nel confronto";
                System.out.println("INFO: " + message);
            } else if (confronto.size() >= 4) {
                // Limite massimo di 4 auto per confronto (business rule)
                message = "Puoi confrontare massimo 4 auto";
                System.out.println("INFO: " + message);
            } else {
                // Aggiungi l'auto al confronto e aggiorna la sessione
                confronto.add(auto);
                session.setAttribute("confronto", confronto);
                success = true;
                message = "Auto aggiunta al confronto con successo";
                System.out.println("SUCCESS: " + message + ". Totale auto nel confronto: " + confronto.size());
            }

            // Se è una richiesta AJAX, restituisci JSON
            if ("true".equals(ajax)) {
                sendJsonResponse(response, success, message, confronto.size());
                return;
            }

            // Altrimenti redirect normale con parametro di successo/errore
            String refererHeader = request.getHeader("Referer");
            String redirectUrl = "auto-servlet";

            if (refererHeader != null) {
                if (refererHeader.contains("ricerca-avanzata")) {
                    // Se provieni dalla ricerca avanzata, voglio preservare i filtri e reindirizzare con gli stessi parametri
                    preserveAdvancedSearchAndRedirect(request, response);
                    return;
                } else if (refererHeader.contains("catalogo") || refererHeader.contains("auto-servlet")) {
                    redirectUrl = "auto-servlet";
                }
            }

            response.sendRedirect(redirectUrl + (success ? "?success=true" : "?error=true"));

        } catch (NumberFormatException e) {
            // ID auto non numerico
            String errorMsg = "ID auto non valido: " + idAutoParam;
            System.out.println("ERROR: " + errorMsg);

            if ("true".equals(ajax)) {
                sendJsonResponse(response, false, errorMsg, 0);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/auto-servlet");

        } catch (Exception e) {
            // Errore generico: loggare e rispondere con errore generico al client
            String errorMsg = "Errore interno del server: " + e.getMessage();
            System.out.println("ERROR: " + errorMsg);
            e.printStackTrace();

            if ("true".equals(ajax)) {
                sendJsonResponse(response, false, "Errore interno del server", 0);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/auto-servlet");
        }
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, int count)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        String jsonResponse = String.format(
                "{\"success\": %s, \"message\": \"%s\", \"count\": %d}",
                success, message.replace("\"", "\\\""), count
        );

        System.out.println("DEBUG: Sending JSON response: " + jsonResponse);
        out.print(jsonResponse);
        out.flush();
    }

    private void preserveAdvancedSearchAndRedirect(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        @SuppressWarnings("unchecked")
        java.util.Map<String, String> filtriAvanzati =
                (java.util.Map<String, String>) session.getAttribute("filtriAvanzati");

        if (filtriAvanzati != null) {
            StringBuilder url = new StringBuilder("ricerca-avanzata-servlet?");
            boolean first = true;

            for (java.util.Map.Entry<String, String> entry : filtriAvanzati.entrySet()) {
                if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                    if (!first) url.append("&");
                    try {
                        url.append(entry.getKey()).append("=")
                                .append(java.net.URLEncoder.encode(entry.getValue(), "UTF-8"));
                    } catch (java.io.UnsupportedEncodingException e) {
                        url.append(entry.getKey()).append("=").append(entry.getValue());
                    }
                    first = false;
                }
            }

            response.sendRedirect(url.toString());
        } else {
            response.sendRedirect("ricerca-avanzata-servlet");
        }
    }
}
