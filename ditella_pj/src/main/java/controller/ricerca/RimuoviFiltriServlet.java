package controller.ricerca;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet(name = "RimuoviFiltriServlet", value = "/rimuovi-filtri-servlet")
public class RimuoviFiltriServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Rimuove tutti i tipi di filtri dalla sessione
        session.removeAttribute("filtriAvanzati");
        session.removeAttribute("filtriRapidi");
        session.removeAttribute("filtriMarchio");

        // Reindirizza al servlet principale del catalogo per ricaricare tutto
        response.sendRedirect(request.getContextPath() + "/auto-servlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}