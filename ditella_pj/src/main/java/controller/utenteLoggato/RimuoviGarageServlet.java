package controller.utenteLoggato;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoSalvateDAO;
import model.bean.UtenteBean;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "RimuoviGarageServlet", value = "/rimuovi-garage")
// Servlet per rimuovere un'auto salvata dal garage dell'utente loggato
public class RimuoviGarageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Delegazione a doPost per gestire la richiesta
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera la sessione e l'utente loggato
        HttpSession session = request.getSession(false);
        UtenteBean utente = (session != null) ? (UtenteBean) session.getAttribute("utenteLoggato") : null;

        // Se l'utente non è loggato, reindirizza al login
        if (utente == null) {
            response.sendRedirect(request.getContextPath() + "/login"); // mapping LoginServlet = /login
            return;
        }

        // Recupera l'id dell'auto da rimuovere
        String idAutoParam = request.getParameter("idAuto");
        if (idAutoParam == null || idAutoParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/area-utente");
            return;
        }

        try {
            int idAuto = Integer.parseInt(idAutoParam); // converte l'id in intero
            AutoSalvateDAO dao = new AutoSalvateDAO();
            dao.rimuoviAutoDaGarage(utente.getIdUtente(), idAuto); // rimuove l'auto dal garage dell'utente
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            // Opzionale: aggiungere messaggio di errore nella sessione
        }

        // Redirect all'area utente dopo la rimozione
        response.sendRedirect(request.getContextPath() + "/area-utente");
    }
}
