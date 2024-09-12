package controller.ricerca;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoDAO;
import model.bean.AutoBean;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "FiltraPerMarchioServlet", value = "/filtra-per-marchio")
public class FiltraPerMarchioServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String marchio = request.getParameter("marchio");

        if (marchio == null || marchio.trim().isEmpty()) {
            // Se non c'è marchio, reindirizza al catalogo completo
            response.sendRedirect(request.getContextPath() + "/auto-servlet");
            return;
        }

        HttpSession session = request.getSession();

        // Salva filtro marchio in sessione
        Map<String, String> filtriMarchio = new HashMap<>();
        filtriMarchio.put("marchio", marchio);
        session.setAttribute("filtriMarchio", filtriMarchio);

        // Pulisce altri tipi di filtri per evitare conflitti
        session.removeAttribute("filtriAvanzati");
        session.removeAttribute("filtriRapidi");

        AutoDAO dao = new AutoDAO();
        List<AutoBean> autoFiltrate = dao.doRetrieveByMarchio(marchio);
        List<String> tuttiMarchi = dao.doRetrieveAllMarchi();

        // Gestione paginazione
        String paginaParam = request.getParameter("pagina");
        int pagina = 1;
        int perPagina = 6;

        if (paginaParam != null && !paginaParam.isEmpty()) {
            try {
                pagina = Integer.parseInt(paginaParam);
            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }

        // Calcola paginazione
        int inizio = (pagina - 1) * perPagina;
        int fine = Math.min(inizio + perPagina, autoFiltrate.size());

        if (inizio >= autoFiltrate.size()) {
            inizio = 0;
            pagina = 1;
            fine = Math.min(perPagina, autoFiltrate.size());
        }

        List<AutoBean> autoPaginata = autoFiltrate.subList(inizio, fine);
        int totalePagine = (int) Math.ceil((double) autoFiltrate.size() / perPagina);
        if (totalePagine == 0) totalePagine = 1;

        // Attributi per la JSP
        request.setAttribute("listaAuto", autoPaginata);
        request.setAttribute("marchi", tuttiMarchi);
        request.setAttribute("marchioSelezionato", marchio);
        request.setAttribute("paginaCorrente", pagina);
        request.setAttribute("totalePagine", totalePagine);

        request.getRequestDispatcher("/WEB-INF/view/catalogo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}