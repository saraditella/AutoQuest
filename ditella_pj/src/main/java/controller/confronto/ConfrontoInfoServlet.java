package controller.confronto;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.bean.AutoBean;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "ConfrontoInfoServlet", value = "/confronto-info") // Definisce la servlet e la mappa all'URL "/confronto-info"
public class ConfrontoInfoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Recupera la sessione corrente dell'utente (creandola se non esiste già)
        HttpSession session = request.getSession();

        // Recupera dalla sessione la lista di auto da confrontare (se presente)
        List<AutoBean> confronto = (List<AutoBean>) session.getAttribute("confronto");

        // Calcola il numero di auto presenti nella lista confronto
        // Se la lista è null (cioè non esiste ancora), il numero è 0
        int numeroAuto = (confronto != null) ? confronto.size() : 0;

        // Imposta il tipo di contenuto della risposta come JSON e codifica UTF-8
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Ottiene lo stream di output per scrivere la risposta
        PrintWriter out = response.getWriter();

        // Stampa un oggetto JSON semplice contenente il numero di auto in confronto
        out.print("{\"count\": " + numeroAuto + "}");

        // Forza lo svuotamento del buffer e l'invio della risposta al client
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Se arriva una richiesta POST, viene gestita esattamente come la GET
        // (quindi restituisce il numero di auto in confronto in formato JSON)
        doGet(request, response);
    }
}
