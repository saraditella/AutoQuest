package controller.generale;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AllestimentoDAO;
import model.DAO.AutoDAO;
import model.bean.AllestimentoBean;
import model.bean.AutoBean;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "DettaglioAutoServlet", value = "/dettaglio-auto")
// Questa servlet gestisce la visualizzazione della pagina di dettaglio di una singola auto.
// Recupera dal database l'auto specificata e i suoi allestimenti, poi inoltra i dati alla JSP di dettaglio.
public class DettaglioAutoServlet extends HttpServlet {

    // DAO per interagire con il DB delle auto
    private final AutoDAO autoDAO = new AutoDAO();
    // DAO per interagire con il DB degli allestimenti
    private final AllestimentoDAO allestimentoDAO = new AllestimentoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera il parametro "idAuto" dalla richiesta
        String idParam = request.getParameter("idAuto");

        // Se il parametro è mancante o vuoto redirect al catalogo generale
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auto-servlet");
            return;
        }

        int idAuto;
        try {
            // Converte l'id passato in numero intero
            idAuto = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            // Se non è un numero valido → redirect al catalogo
            response.sendRedirect(request.getContextPath() + "/auto-servlet");
            return;
        }

        // Recupera i dati dell'auto dal database
        AutoBean auto = autoDAO.doRetrieveById(idAuto);

        // Se l'auto non esiste nel DB → redirect al catalogo
        if (auto == null) {
            response.sendRedirect(request.getContextPath() + "/auto-servlet");
            return;
        }

        // Recupera la lista di allestimenti disponibili per quell'auto
        List<AllestimentoBean> allestimenti = allestimentoDAO.getAllestimentiByAuto(idAuto);

        // Passa i dati alla JSP
        request.setAttribute("auto", auto);                   // l'oggetto AutoBean
        request.setAttribute("allestimenti", allestimenti);   // lista degli allestimenti

        // Inoltra la richiesta alla JSP di dettaglio
        request.getRequestDispatcher("/WEB-INF/view/dettaglioAuto.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Gestisce le richieste POST come GET → comportamento identico
        doGet(request, response);
    }
}
