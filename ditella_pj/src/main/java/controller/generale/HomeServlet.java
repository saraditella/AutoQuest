// ==================================================
// 1. HOME SERVLET - Gestisce la pagina principale
// ==================================================
package controller.generale;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoDAO;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", value = "/home-servlet")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            AutoDAO dao = new AutoDAO();

            // Recupera tutti i marchi disponibili per la navigazione per marchio
            // (utilizzati nella sezione "Sfoglia per marchio")
            List<String> marchi = dao.doRetrieveAllMarchi();

            // Passa i marchi alla JSP tramite request scope
            request.setAttribute("marchi", marchi);

            // Forward per mantenere i dati in request
            RequestDispatcher dispatcher = request.getRequestDispatcher("/home.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            // Gestione errori: log e redirect a pagina errore
            System.err.println("Errore in HomeServlet: " + e.getMessage());
            e.printStackTrace();

            // Redirect a pagina di errore generale
            response.sendRedirect(request.getContextPath() + "/error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Pattern POST-Redirect-GET: delega tutto al doGet
        doGet(request, response);
    }
}