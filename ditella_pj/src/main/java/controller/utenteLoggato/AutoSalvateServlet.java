package controller.utenteLoggato;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoSalvateDAO;
import model.bean.AutoBean;
import model.bean.UtenteBean;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AutoSalvateServlet", value = "/garage")
public class AutoSalvateServlet extends HttpServlet {
    private final AutoSalvateDAO autoSalvateDAO = new AutoSalvateDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;


        if (utente == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<AutoBean> preferiti = autoSalvateDAO.getAutoSalvateConAllestimento(utente.getIdUtente());
            request.setAttribute("preferiti", preferiti);
            double prezzo = 0.0 ;
            for(AutoBean auto : preferiti) {
                prezzo += auto.getPrezzoBase();
            }
            request.setAttribute("prezzo", prezzo);
            request.getRequestDispatcher("/WEB-INF/view/garage.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Errore nel caricamento del garage");
            request.getRequestDispatcher("/WEB-INF/view/garage.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
