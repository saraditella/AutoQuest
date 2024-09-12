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

@WebServlet(name = "RicercaAvanzataServlet", value = "/ricerca-avanzata-servlet")
public class RicercaAvanzataServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String marchio = request.getParameter("marchio");
        String alimentazione = request.getParameter("alimentazione");
        String cambio = request.getParameter("cambio");
        String minPrezzo = request.getParameter("minPrezzo");
        String maxPrezzo = request.getParameter("maxPrezzo");
        String minPotenza = request.getParameter("minPotenza");
        String maxPotenza = request.getParameter("maxPotenza");
        String minCilindrata = request.getParameter("minCilindrata");
        String maxCilindrata = request.getParameter("maxCilindrata");
        String ordinamento = request.getParameter("ordinamento");

        // Salvataggio dei filtri nella sessione
        Map<String, String> filtriAvanzati = new HashMap<>();
        filtriAvanzati.put("marchio", marchio);
        filtriAvanzati.put("alimentazione", alimentazione);
        filtriAvanzati.put("cambio", cambio);
        filtriAvanzati.put("minPrezzo", minPrezzo);
        filtriAvanzati.put("maxPrezzo", maxPrezzo);
        filtriAvanzati.put("minPotenza", minPotenza);
        filtriAvanzati.put("maxPotenza", maxPotenza);
        filtriAvanzati.put("minCilindrata", minCilindrata);
        filtriAvanzati.put("maxCilindrata", maxCilindrata);

        HttpSession session = request.getSession();
        session.setAttribute("filtriAvanzati", filtriAvanzati);

        // Pulisce altri tipi di filtri
        session.removeAttribute("filtriRapidi");
        session.removeAttribute("filtriMarchio");

        AutoDAO dao = new AutoDAO();
        List<String> tuttiMarchi = dao.doRetrieveAllMarchi();

        // Gestione paginazione
        int risultatiPerPagina = 6;
        int pagina = 1;

        String parametroPagina = request.getParameter("pagina");
        if(parametroPagina != null && !parametroPagina.isEmpty()) {
            try {
                pagina = Integer.parseInt(parametroPagina);
            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }
        int offset = (pagina - 1) * risultatiPerPagina;

        // Conta risultati e calcola pagine
        int totaleAutoFiltrate = dao.contaAutoFiltrate(marchio, alimentazione, cambio, minPrezzo, maxPrezzo, minPotenza, maxPotenza, minCilindrata, maxCilindrata);
        int totalePagine = (int) Math.ceil((double) totaleAutoFiltrate / risultatiPerPagina);
        if (totalePagine == 0) totalePagine = 1;

        // Recupera auto filtrate con paginazione
        List<AutoBean> listaAuto = dao.filtraAutoRicercaAvanzata(marchio, alimentazione, cambio, minPrezzo, maxPrezzo, minPotenza, maxPotenza, minCilindrata, maxCilindrata, offset, risultatiPerPagina, ordinamento);

        // Attributi di paginazione
        request.setAttribute("paginaCorrente", pagina);
        request.setAttribute("totalePagine", totalePagine);

        // Attributi per mantenere i valori nei form
        request.setAttribute("marchio", marchio);
        request.setAttribute("alimentazione", alimentazione);
        request.setAttribute("cambio", cambio);
        request.setAttribute("minPrezzo", minPrezzo);
        request.setAttribute("maxPrezzo", maxPrezzo);
        request.setAttribute("minPotenza", minPotenza);
        request.setAttribute("maxPotenza", maxPotenza);
        request.setAttribute("minCilindrata", minCilindrata);
        request.setAttribute("maxCilindrata", maxCilindrata);
        request.setAttribute("ordinamento", ordinamento);

        request.setAttribute("marchi", tuttiMarchi);
        request.setAttribute("listaAuto", listaAuto);

        request.getRequestDispatcher("/WEB-INF/view/catalogo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}