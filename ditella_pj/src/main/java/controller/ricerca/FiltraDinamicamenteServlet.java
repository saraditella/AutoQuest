package controller.ricerca;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoDAO;
import model.bean.AutoBean;

import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "FiltraDinamicamenteServlet", value = "/filtra-dinamicamente-servlet")
public class FiltraDinamicamenteServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Parametri dal form del catalogo (filtri laterali)
        String[] marchiSelezionati = request.getParameterValues("marchi");
        String ordinamento = request.getParameter("ordinamento");
        String paginaParam = request.getParameter("pagina");
        String cilindrataFiltro = request.getParameter("cilindrata");
        String potenzaFiltro = request.getParameter("potenza");

        AutoDAO dao = new AutoDAO();
        List<AutoBean> listaAuto;

        HttpSession session = request.getSession();
        Map<String, String> filtriAvanzati = (Map<String, String>) session.getAttribute("filtriAvanzati");
        Map<String, String> filtriRapidi = (Map<String, String>) session.getAttribute("filtriRapidi");
        Map<String, String> filtriMarchio = (Map<String, String>) session.getAttribute("filtriMarchio");

        // Determina se ci sono filtri dal catalogo (sidebar)
        boolean hasFiltriCatalogo = (marchiSelezionati != null && marchiSelezionati.length > 0) ||
                (cilindrataFiltro != null && !cilindrataFiltro.isEmpty()) ||
                (potenzaFiltro != null && !potenzaFiltro.isEmpty()) ||
                (ordinamento != null && !ordinamento.isEmpty());

        if (hasFiltriCatalogo) {
            // Se ci sono filtri dal catalogo, parti da tutte le auto e applica solo quelli
            listaAuto = dao.doRetrieveAllAuto();

            // Applica filtri marchi
            if(marchiSelezionati != null && marchiSelezionati.length > 0) {
                listaAuto = listaAuto.stream()
                        .filter(a -> Arrays.asList(marchiSelezionati).contains(a.getMarchio()))
                        .collect(Collectors.toList());
            }

            // Applica filtro cilindrata
            if (cilindrataFiltro != null && !cilindrataFiltro.isEmpty()) {
                try {
                    int maxCilindrata = Integer.parseInt(cilindrataFiltro);
                    listaAuto = listaAuto.stream()
                            .filter(a -> a.getCilindrata() <= maxCilindrata)
                            .collect(Collectors.toList());
                } catch (NumberFormatException e) {
                    // Ignora errore parsing
                }
            }

            // Applica filtro potenza
            if (potenzaFiltro != null && !potenzaFiltro.isEmpty()) {
                try {
                    int maxPotenza = Integer.parseInt(potenzaFiltro);
                    listaAuto = listaAuto.stream()
                            .filter(a -> a.getPotenza() <= maxPotenza)
                            .collect(Collectors.toList());
                } catch (NumberFormatException e) {
                    // Ignora errore parsing
                }
            }

        } else {
            // Nessun filtro dal catalogo, usa i filtri dalla sessione

            if (filtriAvanzati != null) {
                // Usa ricerca avanzata dal DAO
                String marchio = filtriAvanzati.get("marchio");
                String alimentazione = filtriAvanzati.get("alimentazione");
                String cambio = filtriAvanzati.get("cambio");
                String minPrezzo = filtriAvanzati.get("minPrezzo");
                String maxPrezzo = filtriAvanzati.get("maxPrezzo");
                String minPotenza = filtriAvanzati.get("minPotenza");
                String maxPotenza = filtriAvanzati.get("maxPotenza");
                String minCilindrata = filtriAvanzati.get("minCilindrata");
                String maxCilindrata = filtriAvanzati.get("maxCilindrata");

                // Usa il DAO per la ricerca avanzata (senza paginazione qui)
                listaAuto = dao.filtraAutoRicercaAvanzata(marchio, alimentazione, cambio, minPrezzo, maxPrezzo, minPotenza, maxPotenza, minCilindrata, maxCilindrata, 0, Integer.MAX_VALUE, null);

            } else if (filtriRapidi != null) {
                // Usa ricerca rapida dal DAO
                String budget = filtriRapidi.get("budget");
                String potenza = filtriRapidi.get("potenza");
                String cilindrata = filtriRapidi.get("cilindrata");

                listaAuto = dao.ricercaRapida(null, budget, potenza, cilindrata);

            } else if (filtriMarchio != null) {
                // Usa filtro per marchio dal DAO
                String marchio = filtriMarchio.get("marchio");
                if (marchio != null && !marchio.isEmpty()) {
                    listaAuto = dao.doRetrieveByMarchio(marchio);
                } else {
                    listaAuto = dao.doRetrieveAllAuto();
                }

            } else {
                // Nessun filtro, tutte le auto
                listaAuto = dao.doRetrieveAllAuto();
            }
        }

        // Applica ordinamento se specificato
        if (ordinamento != null && !ordinamento.isEmpty()) {
            switch (ordinamento) {
                case "prezzoCrescente":
                    listaAuto.sort(Comparator.comparingDouble(AutoBean::getPrezzoBase));
                    break;
                case "prezzoDecrescente":
                    listaAuto.sort(Comparator.comparingDouble(AutoBean::getPrezzoBase).reversed());
                    break;
                case "potenzaCrescente":
                    listaAuto.sort(Comparator.comparingInt(AutoBean::getPotenza));
                    break;
                case "potenzaDecrescente":
                    listaAuto.sort(Comparator.comparingInt(AutoBean::getPotenza).reversed());
                    break;
                case "cilindrataCrescente":
                    listaAuto.sort(Comparator.comparingInt(AutoBean::getCilindrata));
                    break;
                case "cilindrataDecrescente":
                    listaAuto.sort(Comparator.comparingInt(AutoBean::getCilindrata).reversed());
                    break;
            }
        }

        // Gestione paginazione
        int pagina = 1;
        int perPagina = 6;

        if (paginaParam != null && !paginaParam.isEmpty()) {
            try {
                pagina = Integer.parseInt(paginaParam);
            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }

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

        // Attributi per risultati.jsp
        request.setAttribute("paginaCorrente", pagina);
        request.setAttribute("totalePagine", totalePagine);
        request.setAttribute("listaAuto", autoPaginata);

        // Restituisce sempre solo risultati.jsp per le chiamate AJAX
        request.getRequestDispatcher("/WEB-INF/view/risultati.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}