package controller.generale;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoDAO;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "VaiRicercaAvanzataServlet", value = "/vai-ricerca-avanzata")
// Servlet che gestisce il passaggio alla pagina di ricerca avanzata delle auto
public class VaiRicercaAvanzataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Crea un DAO per interagire con il database delle auto
        AutoDAO dao = new AutoDAO();

        // Recupera tutti i marchi di auto presenti nel DB (per i filtri della ricerca avanzata)
        List<String> marchi = dao.doRetrieveAllMarchi();

        // Imposta i marchi come attributo della request per passarli alla JSP
        request.setAttribute("marchi", marchi);

        // Inoltra la richiesta alla JSP di ricerca avanzata
        request.getRequestDispatcher("/WEB-INF/view/ricercaAvanzata.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // In caso di POST, utilizza la stessa logica del GET
        doGet(request, response);
    }
}
