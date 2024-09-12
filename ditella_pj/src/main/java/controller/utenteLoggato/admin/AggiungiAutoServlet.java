package controller.utenteLoggato.admin;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.DAO.AutoDAO;
import model.bean.AutoBean;
import model.bean.Alimentazione;
import model.bean.Cambio;
import model.bean.UtenteBean;

import java.io.IOException;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AggiungiAutoServlet", value = "/admin/aggiungi-auto")
public class AggiungiAutoServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AggiungiAutoServlet.class.getName());
    private final AutoDAO autoDAO = new AutoDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== AggiungiAutoServlet POST chiamato ===");

        // Verifica che l'utente sia admin
        if (!isAdmin(request)) {
            System.out.println("Utente non è admin, redirect al login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Debug completo dei parametri ricevuti
        System.out.println("=== PARAMETRI RAW ===");
        request.getParameterMap().forEach((key, values) -> {
            System.out.println(key + " = " + Arrays.toString(values));
        });

        try {
            // Recupera i dati dal form
            String marchio = getParameterTrimmed(request, "marchio");
            String modello = getParameterTrimmed(request, "modello");
            String alimentazioneStr = getParameterTrimmed(request, "alimentazione");
            String cambioStr = getParameterTrimmed(request, "cambio");
            String cilindrataStr = getParameterTrimmed(request, "cilindrata");
            String potenzaStr = getParameterTrimmed(request, "potenza");
            String prezzoBaseStr = getParameterTrimmed(request, "prezzoBase");
            String linkAcquisto = getParameterTrimmed(request, "linkAcquisto");
            String immagineUrl = getParameterTrimmed(request, "immagineUrl");

            // Debug dei valori estratti
            System.out.println("=== VALORI ESTRATTI ===");
            System.out.println("Marchio: '" + marchio + "'");
            System.out.println("Modello: '" + modello + "'");
            System.out.println("Alimentazione: '" + alimentazioneStr + "'");
            System.out.println("Cambio: '" + cambioStr + "'");
            System.out.println("Cilindrata: '" + cilindrataStr + "'");
            System.out.println("Potenza: '" + potenzaStr + "'");
            System.out.println("Prezzo: '" + prezzoBaseStr + "'");

            // Validazione base
            if (isNullOrEmpty(marchio) || isNullOrEmpty(modello) ||
                    isNullOrEmpty(alimentazioneStr) || isNullOrEmpty(cambioStr) ||
                    isNullOrEmpty(cilindrataStr) || isNullOrEmpty(potenzaStr) ||
                    isNullOrEmpty(prezzoBaseStr)) {

                setErrorMessage(request, "Tutti i campi obbligatori devono essere compilati");
                redirectToDashboard(response, request);
                return;
            }

            // Parsing e validazione numeri
            int cilindrata, potenza, prezzoBase;
            try {
                cilindrata = Integer.parseInt(cilindrataStr);
                potenza = Integer.parseInt(potenzaStr);
                prezzoBase = Integer.parseInt(prezzoBaseStr);

                // Validazione range
                if (cilindrata < 500 || cilindrata > 8000) {
                    throw new IllegalArgumentException("Cilindrata deve essere tra 500 e 8000 cc");
                }
                if (potenza < 50 || potenza > 1000) {
                    throw new IllegalArgumentException("Potenza deve essere tra 50 e 1000 CV");
                }
                if (prezzoBase < 5000 || prezzoBase > 500000) {
                    throw new IllegalArgumentException("Prezzo deve essere tra 5.000 e 500.000 €");
                }

                System.out.println("Validazione numerica completata con successo");

            } catch (NumberFormatException e) {
                System.err.println("Errore parsing numeri: " + e.getMessage());
                setErrorMessage(request, "Errore nei dati numerici inseriti: verifica cilindrata, potenza e prezzo");
                redirectToDashboard(response, request);
                return;
            } catch (IllegalArgumentException e) {
                System.err.println("Errore validazione range: " + e.getMessage());
                setErrorMessage(request, e.getMessage());
                redirectToDashboard(response, request);
                return;
            }

            // Conversione enum con gestione degli errori migliorata
            Alimentazione alimentazione;
            Cambio cambio;

            try {
                alimentazione = mappaAlimentazione(alimentazioneStr);
                System.out.println("Alimentazione mappata: " + alimentazione);
            } catch (Exception e) {
                System.err.println("Errore mappatura alimentazione: " + e.getMessage());
                setErrorMessage(request, "Alimentazione '" + alimentazioneStr + "' non valida");
                redirectToDashboard(response, request);
                return;
            }

            try {
                cambio = mapCambio(cambioStr);
                System.out.println("Cambio mappato: " + cambio);
            } catch (Exception e) {
                System.err.println("Errore mappatura cambio: " + e.getMessage());
                setErrorMessage(request, "Cambio '" + cambioStr + "' non valido");
                redirectToDashboard(response, request);
                return;
            }

            // Crea il bean Auto
            AutoBean auto = new AutoBean();
            auto.setMarchio(marchio);
            auto.setModello(modello);
            auto.setAlimentazione(alimentazione);
            auto.setCambio(cambio);
            auto.setCilindrata(cilindrata);
            auto.setPotenza(potenza);
            auto.setPrezzoBase(prezzoBase);

            // Gestione campi opzionali
            auto.setLinkAcquisto(isNullOrEmpty(linkAcquisto) ? null : linkAcquisto);
            auto.setImmagineUrl(isNullOrEmpty(immagineUrl) ? null : immagineUrl);

            System.out.println("Bean auto creato: " + auto.toString());

            // Salva nel database
            boolean success = autoDAO.aggiungiAuto(auto);

            if (success) {
                System.out.println("Auto aggiunta con successo");
                setSuccessMessage(request, "Auto '" + marchio + " " + modello + "' aggiunta con successo!");
            } else {
                System.out.println("Errore nell'aggiunta dell'auto - metodo ha restituito false");
                setErrorMessage(request, "Errore nell'aggiunta dell'auto al database");
            }

            redirectToDashboard(response, request);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore imprevisto in AggiungiAutoServlet", e);
            e.printStackTrace();
            setErrorMessage(request, "Errore del sistema: " + e.getMessage());
            redirectToDashboard(response, request);
        }
    }

    /**
     * Estrae e pulisce un parametro dalla request
     */
    private String getParameterTrimmed(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        return (value != null) ? value.trim() : null;
    }

    /**
     * Verifica se una stringa è null o vuota
     */
    private boolean isNullOrEmpty(String str) {
        return str == null || str.isEmpty();
    }

    /**
     * Imposta un messaggio di errore nella sessione
     */
    private void setErrorMessage(HttpServletRequest request, String message) {
        request.getSession().setAttribute("errorMessage", message);
    }

    /**
     * Imposta un messaggio di successo nella sessione
     */
    private void setSuccessMessage(HttpServletRequest request, String message) {
        request.getSession().setAttribute("successMessage", message);
    }

    /**
     * Redirect alla dashboard
     */
    private void redirectToDashboard(HttpServletResponse response, HttpServletRequest request)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }

    /**
     * Mappa i valori del form agli enum Alimentazione
     * Mantiene la tua enumerazione esistente
     */
    private Alimentazione mappaAlimentazione(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Alimentazione non può essere vuota");
        }

        String cleanValue = value.trim().toLowerCase();
        System.out.println("Mappatura alimentazione da: '" + value + "' a '" + cleanValue + "'");

        return switch (cleanValue) {
            case "benzina" -> Alimentazione.Benzina;
            case "diesel" -> Alimentazione.Diesel;
            case "elettrica" -> Alimentazione.Elettrica;
            case "ibrida" -> Alimentazione.Ibrida;
            case "ibrida plug-in" -> Alimentazione.Ibrida_Plug_in;
            case "gpl" -> Alimentazione.GPL;
            case "metano" -> Alimentazione.Metano;
            case "idrogeno" -> Alimentazione.Idrogeno;
            default -> {
                System.err.println("Valore alimentazione non riconosciuto: '" + value + "'");
                throw new IllegalArgumentException("Alimentazione non riconosciuta: " + value);
            }
        };
    }

    /**
     * Mappa i valori del form agli enum Cambio
     * Mantiene la tua enumerazione esistente
     */
    private Cambio mapCambio(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Cambio non può essere vuoto");
        }

        String cleanValue = value.trim().toLowerCase();
        System.out.println("Mappatura cambio da: '" + value + "' a '" + cleanValue + "'");

        return switch (cleanValue) {
            case "manuale" -> Cambio.Manuale;
            case "automatico" -> Cambio.Automatico;
            case "sequenziale" -> Cambio.Sequenziale;
            case "cvt" -> Cambio.CVT;
            case "doppia frizione" -> Cambio.Doppia_Frizione;
            default -> {
                System.err.println("Valore cambio non riconosciuto: '" + value + "'");
                throw new IllegalArgumentException("Cambio non riconosciuto: " + value);
            }
        };
    }

    /**
     * Verifica se l'utente è admin
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("Sessione non trovata");
            return false;
        }

        UtenteBean utente = (UtenteBean) session.getAttribute("utenteLoggato");
        if (utente == null) {
            System.out.println("Utente non trovato in sessione");
            return false;
        }

        try {
            String ruolo = utente.getRuolo();
            boolean isAdminByRole = "ADMIN".equalsIgnoreCase(ruolo);
            boolean isAdminByMethod = utente.isAdmin();

            System.out.println("Ruolo utente: " + ruolo);
            System.out.println("Is admin by role: " + isAdminByRole);
            System.out.println("Is admin by method: " + isAdminByMethod);

            return isAdminByRole || isAdminByMethod;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Errore nella verifica ruolo admin", e);
            return false;
        }
    }
}