package controller.utenteLoggato;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.ConfrontoDAO;
import model.bean.AutoBean;
import model.bean.UtenteBean;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "SalvaConfrontoServlet", value = "/salva-confronto")
// Servlet per salvare il confronto di auto dell'utente loggato
public class SalvaConfrontoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Delegazione a doPost per gestire la richiesta
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Imposta content type JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Recupera sessione e utente loggato
        HttpSession session = request.getSession(false);
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;

        // Se utente non loggato, ritorna messaggio di errore
        if (utente == null) {
            out.print("{\"success\":false,\"message\":\"Devi essere loggato per salvare un confronto\"}");
            out.flush();
            return;
        }

        // Legge il nome del confronto dalla richiesta
        String nomeConfronto = request.getParameter("nomeConfronto");
        if (nomeConfronto == null || nomeConfronto.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Inserisci un nome per il confronto\"}");
            out.flush();
            return;
        }
        // Escape eventuali virgolette nel nome
        nomeConfronto = nomeConfronto.replace("\"", "\\\"");

        // Recupera la lista delle auto dal confronto in sessione
        @SuppressWarnings("unchecked")
        List<AutoBean> confronto = (List<AutoBean>) session.getAttribute("confronto");
        if (confronto == null || confronto.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Nessuna auto nel confronto da salvare\"}");
            out.flush();
            return;
        }

        // Prepara liste di ID auto e ID allestimenti
        List<Integer> autoIds = confronto.stream()
                .map(AutoBean::getIdAuto)
                .collect(Collectors.toList());

        List<Integer> allestimentiIds = confronto.stream()
                .map(AutoBean::getSelectedAllestimentoId) // può restituire null se non selezionato
                .collect(Collectors.toList());

        // Salvataggio nel database tramite ConfrontoDAO
        ConfrontoDAO dao = new ConfrontoDAO();
        try {
            int idConfronto = dao.creaConfronto(utente.getIdUtente(), nomeConfronto);
            dao.salvaConfrontoAuto(idConfronto, autoIds, allestimentiIds);

            out.print("{\"success\":true,\"message\":\"Confronto salvato con successo!\"}");
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() != null
                    ? e.getMessage().replace("\"", "\\\"")
                    : "Errore interno";
            out.print("{\"success\":false,\"message\":\"Errore durante il salvataggio: " + msg + "\"}");
        } finally {
            out.flush();
        }
    }
}
