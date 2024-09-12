package controller.utenteLoggato;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.ConfrontoDAO;
import model.bean.AutoBean;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ConfrontoSalvatoServlet", value = "/confronto-salvato")
public class ConfrontoSalvatoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Verifica che l'utente sia loggato
        HttpSession session = request.getSession();
        if (session.getAttribute("utenteLoggato") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("idConfronto");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/area-utente");
            return;
        }

        int idConfronto;
        try {
            idConfronto = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/area-utente");
            return;
        }

        ConfrontoDAO dao = new ConfrontoDAO();
        List<AutoBean> auto = dao.getAutoByConfronto(idConfronto);

        if (auto == null || auto.isEmpty()) {
            session.setAttribute("errorMessage", "Confronto non trovato o vuoto");
            response.sendRedirect(request.getContextPath() + "/area-utente");
            return;
        }

        // Salva il confronto corrente dalla sessione
        Object confrontoCorrente = session.getAttribute("confronto");
        session.removeAttribute("confronto");

        // Passa i dati alla JSP
        request.setAttribute("confronto", auto);
        request.setAttribute("confrontoSalvato", true);
        request.setAttribute("numeroAutoSalvate", auto.size());

        try {
            request.getRequestDispatcher("/WEB-INF/view/confronto.jsp").forward(request, response);
        } finally {
            // Rimetti il confronto originale nella sessione
            if (confrontoCorrente != null) {
                session.setAttribute("confronto", confrontoCorrente);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}