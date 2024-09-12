<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- Context path per JavaScript -->
<script>const contextPath = '${pageContext.request.contextPath}';</script>

<!-- Indicatore utente loggato per JavaScript -->
<c:if test="${not empty sessionScope.utenteLoggato}">
    <div data-user-logged="true" class="d-none"></div>
</c:if>

<!-- GRID RISULTATI AUTO -->
<div class="risultati-grid">
    <c:forEach var="auto" items="${listaAuto}">
        <!--per ogni auto si crea una card. carica le immagini delle auto solo quando servono usando loading lazy attributo-->
        <article class="auto-card">

            <!-- Immagine auto -->
            <div class="auto-image">
                <img src="${auto.immagineUrl}"
                     alt="${auto.marchio} ${auto.modello}"
                     loading="lazy" />
            </div>

            <!-- Contenuto card -->
            <div class="auto-content">
                <h3 class="auto-title">${auto.marchio} ${auto.modello}</h3>

                <div class="auto-specs">
                    <div class="spec-item">
                        <span class="spec-label">Alimentazione:</span>
                        <span class="spec-value">${auto.alimentazione}</span>
                    </div>
                    <div class="spec-item">
                        <span class="spec-label">Potenza:</span>
                        <span class="spec-value">${auto.potenza} CV</span>
                    </div>
                    <div class="spec-item">
                        <span class="spec-label">Cambio:</span>
                        <span class="spec-value">${auto.cambio}</span>
                    </div>
                    <div class="spec-item">
                        <span class="spec-label">Cilindrata:</span>
                        <span class="spec-value">${auto.cilindrata} cc</span>
                    </div>
                </div>
                <div class="auto-price">
                        ${auto.prezzoBase}€
                </div>
            </div>

            <!-- Azioni auto -->
            <div class="auto-actions">

                <!-- Azioni in base al login -->
                <c:choose>
                    <c:when test="${not empty sessionScope.utenteLoggato}">
                        <!-- Form confronto -->
                        <form action="${pageContext.request.contextPath}/aggiungi-confronto-servlet"
                              method="post"
                              id="confrontoForm_${auto.idAuto}"
                              class="confronto-form">
                            <input type="hidden" name="idAuto" value="${auto.idAuto}" />
                            <input type="hidden" name="idAllestimento" id="hiddenIdAllestimento_${auto.idAuto}" value="" />
                            <input type="hidden" name="ajax" value="true" />
                            <button type="submit" class="btn btn-confronto btn-aggiungi-confronto">
                                📊 Confronta
                            </button>
                        </form>

                        <!-- Utente loggato: acquista e salva -->
                        <button type="button"
                                onclick="acquistaDelCatalogo(${auto.idAuto}, null, '${fn:escapeXml(auto.linkAcquisto)}', '${fn:escapeXml(auto.marchio)}', '${fn:escapeXml(auto.modello)}')"
                                class="btn btn-success">
                            🛒 Acquista
                        </button>

                        <button type="button"
                                onclick="salvaInGarage(${auto.idAuto}, null)"
                                class="btn btn-info">
                            💾 Salva
                        </button>
                    </c:when>
                    <c:otherwise>
                        <!-- Utente non loggato: acquisto diretto e link login -->
                        <a href="${pageContext.request.contextPath}/login"
                           class="btn btn-info">
                            📊 Accedi per confrontare
                        </a>

                        <button type="button"
                                onclick="acquistaDiretto('${fn:escapeXml(auto.linkAcquisto)}')"
                                class="btn btn-success">
                            🛒 Acquista
                        </button>

                        <a href="${pageContext.request.contextPath}/login"
                           class="btn btn-info">
                            💾 Accedi per salvare
                        </a>
                    </c:otherwise>
                </c:choose>

                <!-- Dettaglio sempre disponibile -->
                <a href="${pageContext.request.contextPath}/dettaglio-auto?idAuto=${auto.idAuto}"
                   class="btn btn-primary btn-dettaglio">
                    📋 Scopri di più
                </a>
            </div>
        </article>
    </c:forEach>
</div>

<!-- Messaggio nessun risultato -->
<c:if test="${empty listaAuto}">
    <div class="no-results">
        <div class="no-results-content">
            <h3>Nessun risultato trovato</h3>
            <p>Nessuna auto corrisponde ai filtri selezionati.</p>
            <a href="${pageContext.request.contextPath}/rimuovi-filtri-servlet"
               class="btn btn-primary">
                Rimuovi filtri
            </a>
        </div>
    </div>
</c:if>

<!-- Paginazione -->
<c:if test="${not empty totalePagine and totalePagine > 1}">
    <nav class="pagination-nav" aria-label="Navigazione pagine">
        <div class="pagination">

            <c:if test="${paginaCorrente > 1}">
                <a href="#"
                   class="pagination-link"
                   data-page="${paginaCorrente - 1}"
                   aria-label="Pagina precedente">
                    ← Precedente
                </a>
            </c:if>

            <c:forEach var="pag" begin="1" end="${totalePagine}">
                <a href="#"
                   class="pagination-link ${pag == paginaCorrente ? 'current' : ''}"
                   data-page="${pag}"
                   aria-label="Pagina ${pag}"
                    ${pag == paginaCorrente ? 'aria-current="page"' : ''}>
                        ${pag}
                </a>
            </c:forEach>

            <c:if test="${paginaCorrente < totalePagine}">
                <a href="#"
                   class="pagination-link"
                   data-page="${paginaCorrente + 1}"
                   aria-label="Pagina successiva">
                    Successiva →
                </a>
            </c:if>
        </div>
    </nav>
</c:if>

<!-- JavaScript -->
<script src="${pageContext.request.contextPath}/js/acquista.js"></script>