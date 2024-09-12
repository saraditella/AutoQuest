<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catalogo auto</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/catalogo.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/risultati.css">
</head>
<body>

<!-- ESPONGO contextPath PER IL JS -->
<script>
    const contextPath = '${pageContext.request.contextPath}';
</script>

<!-- INDICATORE UTENTE LOGGATO (nascosto) -->
<c:if test="${not empty sessionScope.utenteLoggato}">
    <div data-user-logged="true" class="d-none"></div>
</c:if>

<div class="container">
    <!-- TITOLO PRINCIPALE -->
    <h2 class="page-title">Catalogo delle auto</h2>

    <!-- LAYOUT PRINCIPALE -->
    <div class="catalogo-layout">
        <!-- SIDEBAR FILTRI -->
        <aside class="filtri-sidebar">
            <form id="filtroForm" action="${pageContext.request.contextPath}/filtra-dinamicamente-servlet" method="get">

                <div class="filtro-group">
                    <h3>Cilindrata</h3>
                    <select name="cilindrata" id="cilindrataFiltro" class="filtro-select">
                        <option value="">Tutte</option>
                        <option value="1000">Fino a 1000</option>
                        <option value="1500">Fino a 1500</option>
                        <option value="2000">Fino a 2000</option>
                    </select>
                </div>

                <div class="filtro-group">
                    <h3>Potenza</h3>
                    <select name="potenza" id="potenzaFiltro" class="filtro-select">
                        <option value="">Qualsiasi</option>
                        <option value="100">Fino a 100 CV</option>
                        <option value="150">Fino a 150 CV</option>
                        <option value="200">Fino a 200 CV</option>
                    </select>
                </div>

                <div class="filtro-group">
                    <h3>Marchio</h3>
                    <div class="checkbox-group">
                        <c:forEach var="marchio" items="${marchi}">
                            <div class="checkbox-item">
                                <input type="checkbox"
                                       name="marchi"
                                       value="${marchio}"
                                       id="marchio_${marchio}"
                                    ${marchioSelezionato == marchio ? 'checked' : ''}
                                       class="filtro-checkbox"/>
                                <label for="marchio_${marchio}">${marchio}</label>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="filtro-group">
                    <h3>Ordina per</h3>
                    <select id="ordinamento" name="ordinamento" class="filtro-select">
                        <option value="">-- Nessun ordinamento --</option>
                        <option value="prezzoCrescente">Prezzo crescente</option>
                        <option value="prezzoDecrescente">Prezzo decrescente</option>
                        <option value="potenzaCrescente">Potenza crescente</option>
                        <option value="potenzaDecrescente">Potenza decrescente</option>
                        <option value="cilindrataCrescente">Cilindrata crescente</option>
                        <option value="cilindrataDecrescente">Cilindrata decrescente</option>
                    </select>
                </div>
            </form>
        </aside>

        <!-- CONTENUTO PRINCIPALE -->
        <main class="catalogo-content">

            <!-- FILTRI ATTIVI -->
            <div class="filtri-attivi">
                <h4>Filtri attivi:</h4>
                <div class="filtri-badges">
                    <c:choose>
                        <c:when test="${not empty sessionScope.filtriAvanzati}">
                            <span class="badge">Ricerca Avanzata Attiva</span>
                            <!-- Marchio -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.marchio}">
                                <span class="badge">Marchio: ${sessionScope.filtriAvanzati.marchio}</span>
                            </c:if>

                            <!-- Alimentazione -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.alimentazione}">
                                <span class="badge">Alimentazione: ${sessionScope.filtriAvanzati.alimentazione}</span>
                            </c:if>

                            <!-- Cambio -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.cambio}">
                                <span class="badge">Cambio: ${sessionScope.filtriAvanzati.cambio}</span>
                            </c:if>

                            <!-- Prezzo minimo -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.minPrezzo}">
                                <span class="badge">Prezzo min: ${sessionScope.filtriAvanzati.minPrezzo}€</span>
                            </c:if>

                            <!-- Prezzo massimo -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.maxPrezzo}">
                                <span class="badge">Prezzo max: ${sessionScope.filtriAvanzati.maxPrezzo}€</span>
                            </c:if>

                            <!-- Potenza minima -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.minPotenza}">
                                <span class="badge">Potenza min: ${sessionScope.filtriAvanzati.minPotenza} CV</span>
                            </c:if>

                            <!-- Potenza massima -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.maxPotenza}">
                                <span class="badge">Potenza max: ${sessionScope.filtriAvanzati.maxPotenza} CV</span>
                            </c:if>

                            <!-- Cilindrata minima -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.minCilindrata}">
                                <span class="badge">Cilindrata min: ${sessionScope.filtriAvanzati.minCilindrata} cc</span>
                            </c:if>

                            <!-- Cilindrata massima -->
                            <c:if test="${not empty sessionScope.filtriAvanzati.maxCilindrata}">
                                <span class="badge">Cilindrata max: ${sessionScope.filtriAvanzati.maxCilindrata} cc</span>
                            </c:if>
                        </c:when>
                        <c:when test="${not empty sessionScope.filtriRapidi}">
                            <span class="badge">Ricerca Rapida Attiva</span>
                            <c:if test="${not empty sessionScope.filtriRapidi.budget}">
                                <span class="badge">Budget: max ${sessionScope.filtriRapidi.budget}€</span>
                            </c:if>
                            <c:if test="${not empty sessionScope.filtriRapidi.potenza}">
                                <span class="badge">Potenza: max ${sessionScope.filtriRapidi.potenza} CV</span>
                            </c:if>
                        </c:when>
                        <c:when test="${not empty sessionScope.filtriMarchio}">
                            <span class="badge">Marchio: ${sessionScope.filtriMarchio.marchio}</span>
                        </c:when>
                        <c:otherwise>
                            <span style="color: #6c757d;">Tutti i risultati</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="filtri-actions">
                    <!-- Pulsante confronto -->
                    <a href="${pageContext.request.contextPath}/confronto-servlet"
                       class="confronto-button">
                        📊 Vedi confronto
                        <span class="confronto-counter">${fn:length(sessionScope.confronto)}</span>
                    </a>

                    <!-- Link rimuovi filtri -->
                    <a href="${pageContext.request.contextPath}/rimuovi-filtri-servlet"
                       class="rimuovi-filtri">
                        ✖ Rimuovi tutti i filtri
                    </a>
                </div>
            </div>

            <!-- RISULTATI DEL CATALOGO -->
            <div id="catalogoRisultati">
                <jsp:include page="/WEB-INF/view/risultati.jsp" />
            </div>

        </main>
    </div>
</div>

<!-- INCLUDO I JS -->
<script src="${pageContext.request.contextPath}/js/filtri.js"></script>
<script src="${pageContext.request.contextPath}/js/confronto-dinamico.js"></script>
<script src="${pageContext.request.contextPath}/js/acquista.js"></script>

</body>
</html>