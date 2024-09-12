package controller.generale;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoDAO;
import model.bean.AutoBean;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AutoServlet", value = "/auto-servlet")
public class AutoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        AutoDAO dao = new AutoDAO();
        List<AutoBean> listaAuto = dao.doRetrieveAllAuto();
        List<String> marchi = dao.doRetrieveAllMarchi();

        // Gestione paginazione
        String paginaParam = request.getParameter("pagina");
        int pagina = 1;
        int perPagina = 6;

        if (paginaParam != null) {
            try {
                pagina = Integer.parseInt(paginaParam);
            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }

        // Calcola paginazione
        int inizio = (pagina - 1) * perPagina;
        int fine = Math.min(inizio + perPagina, listaAuto.size());

        // Verifica che gli indici siano validi
        if (inizio >= listaAuto.size()) {
            inizio = 0;
            pagina = 1;
            fine = Math.min(perPagina, listaAuto.size());
        }

        List<AutoBean> autoPaginata = listaAuto.subList(inizio, fine);
        int totalePagine = (int) Math.ceil((double) listaAuto.size() / perPagina);
        if (totalePagine == 0) totalePagine = 1;

        // Attributi per la JSP
        request.setAttribute("listaAuto", autoPaginata);
        request.setAttribute("marchi", marchi);
        request.setAttribute("paginaCorrente", pagina);
        request.setAttribute("totalePagine", totalePagine);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/view/catalogo.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}