<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/confronto.css">
    <title>Confronto Auto</title>
</head>


<body>

<script>const contextPath = '${pageContext.request.contextPath}';</script>

<!-- Indicatore per login status -->
<div data-user-logged="${not empty sessionScope.utenteLoggato ? 'true' : 'false'}" style="display:none;"></div>

<div class="container">
    <main class="confronto-main">

        <!-- Header sezione -->
        <div class="confronto-header">
            <h1>Confronto tra Auto</h1>
            <div class="confronto-info">
                <span class="confronto-count">
                        Auto nel confronto: <strong class="confronto-numero">
                            <c:choose>
                                <c:when test="${not empty sessionScope.confronto}">
                                    ${fn:length(sessionScope.confronto)}
                                </c:when>
                                <c:otherwise>
                                    0
                                </c:otherwise>
                            </c:choose>
                        </strong> / 4
                    </span>
                <small>Puoi confrontare fino a 4 auto contemporaneamente</small>
            </div>
        </div>

        <%-- Normalizzazione variabile confronto: la prende o dalla sessione o dalla richiesta a seconda del caso --%>
        <c:choose>
            <c:when test="${not empty sessionScope.confronto}">
                <c:set var="confronto" value="${sessionScope.confronto}" />
            </c:when>
            <c:when test="${not empty requestScope.confronto}">
                <c:set var="confronto" value="${requestScope.confronto}" />
            </c:when>
            <c:otherwise>
                <c:set var="confronto" value="${null}" />
            </c:otherwise>
        </c:choose>

        <c:choose>
            <c:when test="${empty confronto}">
                <!-- Stato vuoto -->
                <div class="confronto-empty">
                    <div class="empty-icon">🚗</div>
                    <h2>Nessuna auto nel confronto</h2>
                    <p>Inizia aggiungendo alcune auto dal catalogo per confrontarle</p>
                    <div class="empty-actions">
                        <a href="${pageContext.request.contextPath}/auto-servlet" class="btn btn-primary">
                            Vai al Catalogo
                        </a>
                        <a href="${pageContext.request.contextPath}/ricerca-avanzata-servlet" class="btn btn-secondary">
                            Ricerca Avanzata
                        </a>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <!-- Tabella di auto selezionate per il confronto -->
                <div class="confronto-wrapper">
                    <div class="confronto-table-container">
                        <table class="confronto-table">
                            <!-- Row: Immagini -->
                            <tr class="table-row-images">
                                <th class="table-header">Immagine</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell-image">
                                        <div class="auto-image">
                                            <img src="${auto.immagineUrl}"
                                                 alt="${auto.marchio} ${auto.modello}"
                                                 class="car-image" />
                                        </div>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Modello -->
                            <tr class="table-row-highlight">
                                <th class="table-header">Modello</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <div class="car-title">
                                            <strong>${auto.marchio}</strong><br>
                                            <span class="car-model">${auto.modello}</span>
                                        </div>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Alimentazione -->
                            <tr>
                                <th class="table-header">Alimentazione</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <span class="spec-value">${auto.alimentazione}</span>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Cambio -->
                            <tr>
                                <th class="table-header">Cambio</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <span class="spec-value">${auto.cambio}</span>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Potenza -->
                            <tr class="table-row-highlight">
                                <th class="table-header">Potenza</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <span class="spec-highlight">${auto.potenza} CV</span>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Cilindrata -->
                            <tr>
                                <th class="table-header">Cilindrata</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <span class="spec-value">${auto.cilindrata} cc</span>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Prezzo -->
                            <tr class="table-row-price">
                                <th class="table-header">Prezzo Base</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <span class="price">${auto.prezzoBase} €</span>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Allestimento -->
                            <tr>
                                <th class="table-header">Allestimento</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <div class="allestimento-info">
                                            <c:choose>
                                                <c:when test="${not empty auto.selectedAllestimentoNome}">
                                                    <span class="allestimento-name">${auto.selectedAllestimentoNome}</span>
                                                    <small class="allestimento-price">+<c:out value="${auto.selectedAllestimentoPrezzo}" /> €</small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="allestimento-base">Base</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </c:forEach>
                            </tr>

                            <!-- Row: Azioni -->
                            <tr class="table-row-actions">
                                <th class="table-header">Azioni</th>
                                <c:forEach var="auto" items="${confronto}">
                                    <td class="table-cell">
                                        <div class="auto-actions">
                                            <!-- Dettaglio -->
                                            <a href="${pageContext.request.contextPath}/dettaglio-auto?idAuto=${auto.idAuto}<c:if test='${not empty auto.selectedAllestimentoId}'>&idAllestimento=${auto.selectedAllestimentoId}</c:if>"
                                               class="btn btn-sm btn-outline">
                                                Dettagli
                                            </a>

                                            <!-- Acquista -->
                                            <button type="button" class="btn btn-sm btn-success"
                                                    onclick="acquistaERegistra('${auto.idAuto}', '${auto.selectedAllestimentoId}', '${fn:escapeXml(auto.linkAcquisto)}')">
                                                Acquista
                                            </button>

                                            <!-- Salva nel garage (solo se loggato) -->
                                            <c:if test="${not empty sessionScope.utenteLoggato}">
                                                <button type="button" class="btn btn-sm btn-secondary"
                                                        onclick="salvaInGarage('${auto.idAuto}', '${auto.selectedAllestimentoId}')">
                                                    Garage
                                                </button>
                                            </c:if>

                                            <!-- Rimuovi dal confronto l'auto con un certo id passato alla servlet -->
                                            <form action="${pageContext.request.contextPath}/rimuovi-confronto-servlet"
                                                  method="post" class="remove-form">
                                                <input type="hidden" name="idAuto" value="${auto.idAuto}" />
                                                <button type="submit" class="btn btn-sm btn-danger"
                                                        onclick="return confirm('Rimuovere ${fn:escapeXml(auto.marchio)} ${fn:escapeXml(auto.modello)} dal confronto?')">
                                                    ✕
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </c:forEach>
                            </tr>
                        </table>
                    </div>
                </div>

                <!-- Azioni globali -->
                <div class="confronto-actions">
                    <a href="${pageContext.request.contextPath}/auto-servlet" class="btn btn-primary">
                        Aggiungi altre auto
                    </a>
                </div>

                <!-- Salva confronto (solo per utenti loggati) -->
                <c:if test="${not empty sessionScope.utenteLoggato}">
                    <div class="save-comparison">
                        <h3>Salva questo confronto</h3>
                        <div class="save-form">
                            <input type="text"
                                   id="nomeConfronto"
                                   placeholder="Nome del confronto"
                                   maxlength="50"
                                   class="form-control" />
                            <button id="btnSalvaConfronto" class="btn btn-primary">
                                Salva
                            </button>
                        </div>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>

    </main>
</div>
<%-- Gestione conteggio per confronti salvati --%>
<c:if test="${not empty requestScope.confrontoSalvato and requestScope.confrontoSalvato}">
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Aspetta un momento per far caricare il JS principale
            setTimeout(function() {
                const autoCount = ${numeroAutoSalvate};
                console.log('Aggiornando contatore confronto salvato:', autoCount);

                // Aggiorna i contatori
                document.querySelectorAll(".confronto-numero").forEach(el => {
                    el.textContent = autoCount;
                });

                // Aggiorna il badge nell'header
                const badgeHeader = document.querySelector('.numero-confrontati-nav');
                if (badgeHeader) {
                    badgeHeader.textContent = autoCount;
                } else {
                    const link = document.querySelector('.confronto-link');
                    if (link && autoCount > 0) {
                        const newBadge = document.createElement('span');
                        newBadge.classList.add('numero-confrontati-nav');
                        newBadge.textContent = autoCount;
                        link.appendChild(newBadge);
                    }
                }
            }, 100);
        });
    </script>
</c:if>

<!-- Scripts -->
<script src="${pageContext.request.contextPath}/js/acquista.js"></script>
<script src="${pageContext.request.contextPath}/js/salva-confronto.js"></script>

</body>
</html>