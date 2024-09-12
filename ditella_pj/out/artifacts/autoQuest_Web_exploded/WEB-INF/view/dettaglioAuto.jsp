<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dettaglio ${auto.marchio} ${auto.modello}</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dettaglio-auto.css">
</head>
<body>

<script>const contextPath = '${pageContext.request.contextPath}';</script>

<!-- Indicatore per login status -->
<div data-user-logged="${not empty sessionScope.utenteLoggato ? 'true' : 'false'}" style="display:none;"></div>

<div class="container">
  <div class="dettaglio-container">
    <!-- Sezione informazioni auto -->
    <div class="auto-info">
      <img src="${auto.immagineUrl}"
           alt="${auto.marchio} ${auto.modello}"
           class="auto-immagine"
      />

      <h1 class="auto-titolo">${auto.marchio} ${auto.modello}</h1>

      <div class="auto-specifiche">
        <div class="specifica-item">
          <span class="specifica-label">Alimentazione:</span>
          <span class="specifica-valore">${auto.alimentazione}</span>
        </div>

        <div class="specifica-item">
          <span class="specifica-label">Cambio:</span>
          <span class="specifica-valore">${auto.cambio}</span>
        </div>

        <div class="specifica-item">
          <span class="specifica-label">Potenza:</span>
          <span class="specifica-valore">${auto.potenza} CV</span>
        </div>

        <div class="specifica-item">
          <span class="specifica-label">Cilindrata:</span>
          <span class="specifica-valore">${auto.cilindrata} cc</span>
        </div>

        <div class="specifica-item">
          <span class="specifica-label">Prezzo base:</span>
          <span class="specifica-valore prezzo-base" id="prezzoBase">€${auto.prezzoBase}</span>
        </div>
      </div>
    </div>

    <!-- Sezione allestimenti -->
    <div class="allestimenti-section">
      <div class="allestimenti-card">
        <h2 class="allestimenti-titolo">Allestimenti disponibili</h2>

        <form id="allestimentoForm">
          <input type="hidden" id="idAutoInput" name="idAuto" value="${auto.idAuto}" />

          <c:choose>
            <c:when test="${not empty allestimenti}">
              <div class="allestimenti-lista">
                <c:forEach var="all" items="${allestimenti}" varStatus="status">
                  <div class="allestimento-option">
                    <input type="radio"
                           name="idAllestimento"
                           id="all_${all.idAllestimento}"
                           value="${all.idAllestimento}"
                           data-prezzo="${all.prezzoAllestimento}"
                           <c:if test="${status.index == 0}">checked</c:if> />

                    <label for="all_${all.idAllestimento}" class="allestimento-label">
                        ${all.nomeAllestimento}
                      <span class="allestimento-prezzo">€${all.prezzoAllestimento}</span>
                    </label>

                    <c:if test="${not empty all.descrizioneAllestimento}">
                      <div class="allestimento-descrizione">
                          ${all.descrizioneAllestimento}
                      </div>
                    </c:if>
                  </div>
                </c:forEach>
              </div>

              <!-- Prezzo totale -->
              <div class="prezzo-totale">
                <div class="prezzo-totale-label">Prezzo totale selezionato:</div>
                <div class="prezzo-totale-valore" id="prezzoTotaleDisplay">€0.00</div>
              </div>
            </c:when>
            <c:otherwise>
              <div class="no-allestimenti">
                <p>Nessun allestimento disponibile per questo modello.</p>
              </div>
            </c:otherwise>
          </c:choose>

          <!-- Pulsanti azioni -->
          <div class="azioni-container">
            <!-- Aggiungi al garage -->
            <c:choose>
              <c:when test="${not empty sessionScope.utenteLoggato}">
                <button type="button" id="btnAddGarage" class="btn btn-azione btn-garage">
                  Aggiungi al garage
                </button>
              </c:when>
              <c:otherwise>
                <button type="button" class="btn btn-azione btn-accedi"
                        onclick="alert('Devi effettuare il login per salvare nel garage'); window.location.href='${pageContext.request.contextPath}/login';">
                  Accedi per salvare
                </button>
              </c:otherwise>
            </c:choose>

            <!-- Acquista -->
            <button type="button" id="btnAcquista" class="btn btn-azione btn-acquista">
              Acquista ora
            </button>

            <!-- Aggiungi al confronto - VERSIONE CORRETTA -->
            <div style="flex: 1; min-width: 140px;">
              <input type="hidden" id="idAutoConfronto" value="${auto.idAuto}" />
              <button type="button"
                      id="btnAggiungiConfronto"
                      class="btn btn-azione btn-confronto"
                      style="width: 100%;">
                Aggiungi al confronto
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Include JavaScript -->
<script src="${pageContext.request.contextPath}/js/prezzo-dettaglio.js"></script>
<script src="${pageContext.request.contextPath}/js/confronto-dinamico.js"></script>
<script src="${pageContext.request.contextPath}/js/acquista.js"></script>

<script>
  document.addEventListener('DOMContentLoaded', function() {
    //seleziona i pulsanti della pagina
    const btnAddGarage = document.getElementById('btnAddGarage');
    const btnAcquista = document.getElementById('btnAcquista');

    // Aggiungi al garage
    if (btnAddGarage) {
      btnAddGarage.addEventListener('click', function() {
        //recupera auto e allestimento selezionato e chiama lla funzione globale salvaInGarage per gestire l'auto in garage via AJAX
        const selectedRadio = document.querySelector('input[name="idAllestimento"]:checked');
        const idAllestimento = selectedRadio ? selectedRadio.value : null;
        const idAuto = document.getElementById('idAutoInput').value;

        if (!idAuto) {
          alert('Errore: ID auto mancante');
          return;
        }

        // Usa la funzione globale
        salvaInGarage(idAuto, idAllestimento);
      });
    }

    // Acquista
    if (btnAcquista) {
      btnAcquista.addEventListener('click', function() {
        //controlla se ha selezionato un allestimento e chiama funzione globale per procedere all'acquisto
        const selectedRadio = document.querySelector('input[name="idAllestimento"]:checked');
        const idAllestimento = selectedRadio ? selectedRadio.value : null;
        const idAuto = document.getElementById('idAutoInput').value;
        const linkAcquisto = '${fn:escapeXml(auto.linkAcquisto)}';

        // Se ci sono allestimenti disponibili ma nessuno è selezionato, mostra errore
        const hasAllestimenti = document.querySelectorAll('input[name="idAllestimento"]').length > 0;
        if (hasAllestimenti && !idAllestimento) {
          alert('Seleziona un allestimento prima di procedere all\'acquisto');
          return;
        }

        // Usa la funzione globale per acquisto
        acquistaERegistra(idAuto, idAllestimento, linkAcquisto);
      });
    }

    // NUOVO: Gestione del confronto
    const btnConfronto = document.getElementById('btnAggiungiConfronto');
    if (btnConfronto) {
      btnConfronto.addEventListener('click', function(e) {
        e.preventDefault();

        console.log('Click sul confronto rilevato');

        // Trova l'allestimento selezionato
        const selectedRadio = document.querySelector('input[name="idAllestimento"]:checked');
        const idAuto = document.getElementById('idAutoConfronto').value;
        const idAllestimento = selectedRadio ? selectedRadio.value : '';

        console.log('Dati:', { idAuto, idAllestimento });

        if (!idAuto) {
          alert('Errore: ID auto mancante');
          return;
        }

        // Prepara parametri per la richiesta
        const params = new URLSearchParams();
        params.append('idAuto', idAuto);
        params.append('ajax', 'true');
        if (idAllestimento) {
          params.append('idAllestimento', idAllestimento);
        }

        console.log('Parametri da inviare:', params.toString());

        // Invia richiesta AJAX per inviare i dati dell'auto e dell'allestimento al servlet
        fetch('${pageContext.request.contextPath}/aggiungi-confronto-servlet', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
          },
          body: params.toString(),
          credentials: 'same-origin'
        })
                .then(response => {
                  console.log('Response:', response.status);
                  if (!response.ok) {
                    throw new Error(`HTTP ${response.status} - ${response.statusText}`);
                  }
                  return response.json();
                })
                .then(data => {
                  console.log('Success:', data);

                  // Mostra messaggio
                  if (typeof window.mostraMessaggio === 'function') {
                    window.mostraMessaggio(data.message, data.success ? "success" : "error");
                  } else {
                    alert(data.message); // Fallback se la funzione non esiste
                  }

                  // Aggiorna contatore
                  if (typeof window.aggiornaContatoreConfronto === 'function' && data.count !== undefined) {
                    window.aggiornaContatoreConfronto(data.count);
                  }
                })
                .catch(error => {
                  console.error('Error:', error);
                  if (typeof window.mostraMessaggio === 'function') {
                    window.mostraMessaggio('Errore durante l\'aggiunta al confronto: ' + error.message, 'error');
                  } else {
                    alert('Errore: ' + error.message);
                  }
                });
      });
    }

    // Migliora accessibilità: click su label attiva anche il radio
    const labels = document.querySelectorAll('.allestimento-label');
    labels.forEach(function(label) {
      label.addEventListener('click', function(e) {
        if (e.target.tagName !== 'INPUT') {
          const radio = document.getElementById(label.getAttribute('for'));
          if (radio) {
            radio.checked = true;
            radio.dispatchEvent(new Event('change'));
          }
        }
      });
    });
  });
</script>

</body>
</html>