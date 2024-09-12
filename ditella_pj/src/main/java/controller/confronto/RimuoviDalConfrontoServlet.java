package controller.confronto;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.bean.AutoBean;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "RimuoviDalConfrontoServlet", value = "/rimuovi-confronto-servlet")
// Questa servlet gestisce la rimozione di auto dalla lista di confronto.
// Può rimuovere una singola auto (tramite idAuto) o svuotare completamente la lista.
public class RimuoviDalConfrontoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Se arriva una richiesta GET, viene gestita come una POST
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Parametro che identifica l'auto da rimuovere
        String idAutoParam = request.getParameter("idAuto");
        // Parametro che indica se svuotare l'intero confronto
        String svuota = request.getParameter("svuota");

        // Recupera la sessione dell’utente
        HttpSession session = request.getSession();
        // Recupera la lista delle auto in confronto dalla sessione
        @SuppressWarnings("unchecked")
        List<AutoBean> confronto = (List<AutoBean>) session.getAttribute("confronto");


        // --- Caso 1: svuotare completamente il confronto ---
        if("true".equals(svuota)) {
            if(confronto != null) {
                // Svuota la lista
                confronto.clear();
                // Aggiorna la sessione con la lista vuota
                session.setAttribute("confronto", confronto);
            }
            // Dopo aver svuotato, reindirizza alla pagina del confronto
            response.sendRedirect("confronto-servlet");
            return;
        }

        // --- Caso 2: rimuovere una singola auto ---
        // Se non è stato passato nessun idAuto, torna alla pagina del confronto
        if(idAutoParam == null || idAutoParam.isEmpty()) {
            response.sendRedirect("confronto-servlet");
            return;
        }

        try {
            // Converte l'id passato in numero
            int idAuto = Integer.parseInt(idAutoParam);

            if(confronto != null) {
                // Rimuove l'auto dalla lista se l'id corrisponde
                confronto.removeIf(a -> a.getIdAuto() == idAuto);
                // Aggiorna la sessione con la nuova lista
                session.setAttribute("confronto", confronto);
            }

            // Dopo la rimozione, reindirizza alla pagina del confronto
            response.sendRedirect(request.getContextPath() + "/confronto-servlet");

        } catch (NumberFormatException e) {
            // Se l'id non è un numero valido, torna comunque alla pagina del confronto
            response.sendRedirect(request.getContextPath() + "/confronto-servlet");
        }
    }
}
