package controller.confronto;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.bean.AutoBean;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ConfrontoServlet", value = "/confronto-servlet")
// Definisce la servlet e la associa all'URL "/confronto-servlet"
public class ConfrontoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera la sessione dell’utente corrente
        HttpSession session = request.getSession();

        // Preleva dalla sessione la lista di auto da confrontare
        @SuppressWarnings("unchecked")
        List<AutoBean> confronto = (List<AutoBean>) session.getAttribute("confronto");

        // Se la lista non esiste ancora, inizializza una nuova lista vuota
        if(confronto == null) {
            confronto = new ArrayList<>();
        }

        // Aggiunge la lista come attributo della richiesta, così sarà accessibile dalla JSP
        request.setAttribute("confronto", confronto);

        // Inoltra la richiesta alla JSP "/WEB-INF/view/confronto.jsp"
        // (la JSP sarà responsabile di mostrare il contenuto al client)
        request.getRequestDispatcher("/WEB-INF/view/confronto.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Se viene inviata una richiesta POST, la gestisce come una GET
        // Quindi mostrerà sempre la pagina del confronto
        doGet(request, response);
    }
}
