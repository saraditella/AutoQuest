
package controller.acquisto;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AllestimentoDAO;
import model.DAO.AutoDAO;
import model.DAO.OrdineDAO;
import model.bean.AllestimentoBean;
import model.bean.AutoBean;
import model.bean.UtenteBean;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
@WebServlet(name = "AcquistaServlet", value = "/acquista")
public class AcquistaServlet extends HttpServlet {
    private final OrdineDAO ordineDAO = new OrdineDAO();
    private final AllestimentoDAO allestimentoDAO = new AllestimentoDAO();
    private final AutoDAO autoDAO = new AutoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;
        if (utente == null) {
            out.print("{\"success\":false,\"message\":\"Devi essere loggato per acquistare\"}");
            out.flush();
            return;
        }

        String idAutoParam = request.getParameter("idAuto");
        String idAllParam = request.getParameter("idAllestimento");
        String externalUrl = request.getParameter("externalUrl");


        if (idAutoParam == null || idAutoParam.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"ID auto mancante\"}");
            out.flush();
            return;
        }

        try {
            int idAuto = Integer.parseInt(idAutoParam);
            Integer idAll = null;
            if (idAllParam != null && !idAllParam.trim().isEmpty()) {
                try { idAll = Integer.parseInt(idAllParam); } catch (NumberFormatException ignored) {}
            }

            if (idAll == null) idAll = allestimentoDAO.getFirstAllestimentoIdForAuto(idAuto);
            if (idAll == null) {
                out.print("{\"success\":false,\"message\":\"Nessun allestimento disponibile per questa auto\"}");
                out.flush();
                return;
            }

            AutoBean auto = autoDAO.doRetrieveById(idAuto);
            AllestimentoBean all = allestimentoDAO.getAllestimentoById(idAll);

            BigDecimal prezzoAuto = BigDecimal.valueOf(auto.getPrezzoBase());

            BigDecimal prezzoAll = (all != null && all.getPrezzoAllestimento() != null) ? all.getPrezzoAllestimento() : BigDecimal.ZERO;
            BigDecimal prezzoTotale = prezzoAuto.add(prezzoAll);

            int idOrdine = ordineDAO.creaOrdine(utente.getIdUtente(), idAll, prezzoTotale);

            String json = String.format("{\"success\":true,\"message\":\"Ordine creato\",\"idOrdine\":%d,\"externalUrl\":\"%s\"}",
                    idOrdine, (externalUrl != null ? externalUrl.replace("\"", "\\\"") : ""));
            out.print(json);

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"ID non valido\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Errore interno: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            out.flush();
        }
    }
}
