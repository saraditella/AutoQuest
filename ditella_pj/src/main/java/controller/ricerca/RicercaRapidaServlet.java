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

@WebServlet(name = "RicercaRapidaServlet", value = "/ricerca-rapida-servlet")
public class RicercaRapidaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String budget = request.getParameter("budget");
        String potenza = request.getParameter("potenza");
        String cilindrata = request.getParameter("cilindrata");

        // Salva i filtri rapidi in sessione
        HttpSession session = request.getSession();
        Map<String, String> filtriRapidi = new HashMap<>();
        filtriRapidi.put("budget", budget);
        filtriRapidi.put("potenza", potenza);
        filtriRapidi.put("cilindrata", cilindrata);

        session.setAttribute("filtriRapidi", filtriRapidi);

        // Pulisce eventuali altri filtri
        session.removeAttribute("filtriAvanzati");
        session.removeAttribute("filtriMarchio");

        AutoDAO dao = new AutoDAO();

        // Ricerca con parametri della ricerca rapida
        List<AutoBean> autoFiltrate = dao.ricercaRapida(null, budget, potenza, cilindrata);
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

        // Calcola paginazione sui risultati filtrati
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
        request.setAttribute("paginaCorrente", pagina);
        request.setAttribute("totalePagine", totalePagine);

        // Mantiene i parametri per eventuali form
        request.setAttribute("budget", budget);
        request.setAttribute("potenza", potenza);
        request.setAttribute("cilindrata", cilindrata);

        request.getRequestDispatcher("/WEB-INF/view/catalogo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}