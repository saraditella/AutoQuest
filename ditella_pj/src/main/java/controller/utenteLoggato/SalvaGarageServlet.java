package controller.utenteLoggato;

import model.DAO.AutoSalvateDAO;
import model.DAO.AutoDAO;
import model.bean.UtenteBean;
import model.bean.AutoBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet(name = "SalvaGarageServlet", value = "/salva-garage")
// Servlet per salvare un'auto nel garage dell'utente loggato
public class SalvaGarageServlet extends HttpServlet {

    private final AutoSalvateDAO autoSalvateDAO = new AutoSalvateDAO();
    private final AutoDAO autoDAO = new AutoDAO(); // Per recuperare il prezzo attuale

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Imposta content type JSON anziche HTML e il printwriter serve a scrivere direttamente il JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        try {
            // Verifica se l'utente è loggato
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("utenteLoggato") == null) {
                String jsonResponse = createJsonResponse(false, "Utente non autenticato");
                out.print(jsonResponse);
                return;
            }

            UtenteBean utente = (UtenteBean) session.getAttribute("utenteLoggato");

            // Recupera parametri dalla richiesta
            String idAutoStr = request.getParameter("idAuto");
            String idAllestimentoStr = request.getParameter("idAllestimento");
            String prezzoAttualeStr = request.getParameter("prezzoAttuale");

            // Validazione parametro idAuto; se vuoto o mancante: errore JSON
            if (idAutoStr == null || idAutoStr.trim().isEmpty()) {
                String jsonResponse = createJsonResponse(false, "ID auto mancante");
                out.print(jsonResponse);
                return;
            }

            int idAuto;
            try {
                idAuto = Integer.parseInt(idAutoStr.trim());
            } catch (NumberFormatException e) {
                String jsonResponse = createJsonResponse(false, "ID auto non valido");
                out.print(jsonResponse);
                return;
            }

            // Verifica che l'auto esista
            AutoBean autoEsistente = autoDAO.doRetrieveById(idAuto);
            if (autoEsistente == null) {
                String jsonResponse = createJsonResponse(false, "Auto non trovata");
                out.print(jsonResponse);
                return;
            }

            // Gestione idAllestimento
            Integer idAllestimento = null;
            if (idAllestimentoStr != null && !idAllestimentoStr.trim().isEmpty() &&
                    !idAllestimentoStr.equals("null") && !idAllestimentoStr.equals("0")) {
                try {
                    idAllestimento = Integer.parseInt(idAllestimentoStr.trim());
                } catch (NumberFormatException e) {
                    // Ignora allestimento non valido, sarà null
                }
            }

            // Recupera il prezzo attuale con optional calcolati se presenti, altrimenti usa il prezzoBase dell'auto dal DB
            BigDecimal prezzoAttuale = null;
            if (prezzoAttualeStr != null && !prezzoAttualeStr.trim().isEmpty()) {
                try {
                    prezzoAttuale = new BigDecimal(prezzoAttualeStr.trim());
                } catch (NumberFormatException e) {
                    // Se non riusciamo a parsare il prezzo, recuperiamo quello dell'auto
                    prezzoAttuale = BigDecimal.valueOf(autoEsistente.getPrezzoBase());
                }
            } else {
                // Se non è fornito il prezzo, usa quello base dell'auto
                prezzoAttuale = BigDecimal.valueOf(autoEsistente.getPrezzoBase());
            }

            // Salva l'auto nel garage
            autoSalvateDAO.salvaAutoInGarage(utente.getIdUtente(), idAuto, idAllestimento, prezzoAttuale);

            String jsonResponse = createJsonResponse(true, "Auto salvata nel garage con successo");
            out.print(jsonResponse);

        } catch (SQLException e) {
            // Controlla se è un errore di duplicato (auto già presente)
            if (e.getMessage() != null &&
                    (e.getMessage().contains("Duplicate entry") ||
                            e.getMessage().contains("duplicate key") ||
                            e.getSQLState() != null && e.getSQLState().equals("23000"))) {
                String jsonResponse = createJsonResponse(false, "Auto già presente nel garage");
                out.print(jsonResponse);
            } else {
                e.printStackTrace();
                String jsonResponse = createJsonResponse(false, "Errore durante il salvataggio nel garage");
                out.print(jsonResponse);
            }
        } catch (Exception e) {
            e.printStackTrace();
            String jsonResponse = createJsonResponse(false, "Errore interno del server");
            out.print(jsonResponse);
        }
    }

    private String createJsonResponse(boolean success, String message) {
        String escapedMessage = message.replace("\"", "\\\"")
                .replace("\\", "\\\\")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");

        return String.format("{\"success\": %s, \"message\": \"%s\"}", success, escapedMessage);
    }
}