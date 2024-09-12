<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Ricerca Avanzata Auto</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ricerca-avanzata.css">
</head>
<body>

<!-- 1) Espongo contextPath al JS -->
<script>
    const contextPath = '${pageContext.request.contextPath}';
</script>

<div class="container">
    <h2 class="text-center">Ricerca Avanzata tra le auto</h2>

    <!-- 2) Pulsante Vedi confronto -->
    <div class="confronto-button-container">
        <form action="${pageContext.request.contextPath}/confronto-servlet" method="get">
            <button type="submit" class="btn-confronto">
                <span>👥</span>
                Vedi confronto (<span class="confronto-counter">${fn:length(sessionScope.confronto)}</span>)
            </button>
        </form>
    </div>

    <div class="ricerca-container">

        <!-- FORM RICERCA AVANZATA -->
        <div class="filtri-sidebar">
            <h3 class="filtri-title">🔍 Filtri di Ricerca</h3>

            <form id="ricercaAvanzataForm" action="${pageContext.request.contextPath}/ricerca-avanzata-servlet" method="get">

                <div class="filtro-gruppo">
                    <!--dalla lista di marchi, prendere ognuno per ottenere opzioni da pigiare nei filtri e se il marchio è gia selezionato lo evidenzia-->
                    <label for="marchio">Marchio:</label>
                    <select name="marchio" id="marchio">
                        <option value="">Tutti i marchi</option>
                        <c:forEach var="marchioItem" items="${marchi}">
                            <option value="${marchioItem}" ${marchio == marchioItem ? 'selected' : ''}>
                                    ${marchioItem}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="alimentazione">Alimentazione:</label>
                    <select name="alimentazione" id="alimentazione">
                        <option value="">Tutte le alimentazioni</option>
                        <option value="Benzina"  ${alimentazione == 'Benzina' ? 'selected' : ''}>🚗 Benzina</option>
                        <option value="Diesel"   ${alimentazione == 'Diesel' ? 'selected' : ''}>⛽ Diesel</option>
                        <option value="Elettrica"${alimentazione == 'Elettrica' ? 'selected' : ''}>🔋 Elettrica</option>
                        <option value="Ibrida"   ${alimentazione == 'Ibrida' ? 'selected' : ''}>🔄 Ibrida</option>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="cambio">Cambio:</label>
                    <select name="cambio" id="cambio">
                        <option value="">Tutti i cambi</option>
                        <option value="Manuale"   ${cambio == 'Manuale' ? 'selected' : ''}>🖐️ Manuale</option>
                        <option value="Automatico"${cambio == 'Automatico' ? 'selected' : ''}>🤖 Automatico</option>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="minPrezzo">Prezzo minimo:</label>
                    <select name="minPrezzo" id="minPrezzo">
                        <option value="">Qualsiasi</option>
                        <option value="5000"  ${minPrezzo == '5000' ? 'selected' : ''}>5.000 €</option>
                        <option value="10000" ${minPrezzo == '10000' ? 'selected' : ''}>10.000 €</option>
                        <option value="15000" ${minPrezzo == '15000' ? 'selected' : ''}>15.000 €</option>
                        <option value="20000" ${minPrezzo == '20000' ? 'selected' : ''}>20.000 €</option>
                        <option value="30000" ${minPrezzo == '30000' ? 'selected' : ''}>30.000 €</option>
                        <option value="50000" ${minPrezzo == '50000' ? 'selected' : ''}>50.000 €</option>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="maxPrezzo">Prezzo massimo:</label>
                    <select name="maxPrezzo" id="maxPrezzo">
                        <option value="">Qualsiasi</option>
                        <option value="15000"  ${maxPrezzo == '15000' ? 'selected' : ''}>15.000 €</option>
                        <option value="20000"  ${maxPrezzo == '20000' ? 'selected' : ''}>20.000 €</option>
                        <option value="30000"  ${maxPrezzo == '30000' ? 'selected' : ''}>30.000 €</option>
                        <option value="50000"  ${maxPrezzo == '50000' ? 'selected' : ''}>50.000 €</option>
                        <option value="150000" ${maxPrezzo == '150000' ? 'selected' : ''}>150.000 €</option>
                        <option value="200000" ${maxPrezzo == '200000' ? 'selected' : ''}>200.000 €</option>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="minPotenza">Potenza minima (CV):</label>
                    <select name="minPotenza" id="minPotenza">
                        <option value="">Qualsiasi</option>
                        <option value="100" ${minPotenza == '100' ? 'selected' : ''}>100 CV</option>
                        <option value="150" ${minPotenza == '150' ? 'selected' : ''}>150 CV</option>
                        <option value="200" ${minPotenza == '200' ? 'selected' : ''}>200 CV</option>
                        <option value="300" ${minPotenza == '300' ? 'selected' : ''}>300 CV</option>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="maxPotenza">Potenza massima (CV):</label>
                    <select name="maxPotenza" id="maxPotenza">
                        <option value="">Qualsiasi</option>
                        <option value="100" ${maxPotenza == '100' ? 'selected' : ''}>100 CV</option>
                        <option value="150" ${maxPotenza == '150' ? 'selected' : ''}>150 CV</option>
                        <option value="200" ${maxPotenza == '200' ? 'selected' : ''}>200 CV</option>
                        <option value="400" ${maxPotenza == '400' ? 'selected' : ''}>400 CV</option>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="minCilindrata">Cilindrata minima (cc):</label>
                    <select name="minCilindrata" id="minCilindrata">
                        <option value="">Qualsiasi</option>
                        <option value="1000" ${minCilindrata == '1000' ? 'selected' : ''}>1000 cc</option>
                        <option value="1500" ${minCilindrata == '1500' ? 'selected' : ''}>1500 cc</option>
                        <option value="2000" ${minCilindrata == '2000' ? 'selected' : ''}>2000 cc</option>
                    </select>
                </div>

                <div class="filtro-gruppo">
                    <label for="maxCilindrata">Cilindrata massima (cc):</label>
                    <select name="maxCilindrata" id="maxCilindrata">
                        <option value="">Qualsiasi</option>
                        <option value="1500" ${maxCilindrata == '1500' ? 'selected' : ''}>1500 cc</option>
                        <option value="2000" ${maxCilindrata == '2000' ? 'selected' : ''}>2000 cc</option>
                        <option value="2500" ${maxCilindrata == '2500' ? 'selected' : ''}>2500 cc</option>
                    </select>
                </div>

                <div class="ordinamento-section">
                    <h3>📊 Ordina per</h3>
                    <div class="filtro-gruppo">
                        <select name="ordinamento" id="ordinamento">
                            <option value="">-- Nessun ordinamento --</option>
                            <option value="prezzoCrescente" ${ordinamento == 'prezzoCrescente' ? 'selected' : ''}>
                                💰 Prezzo crescente
                            </option>
                            <option value="prezzoDecrescente" ${ordinamento == 'prezzoDecrescente' ? 'selected' : ''}>
                                💎 Prezzo decrescente
                            </option>
                            <option value="potenzaCrescente" ${ordinamento == 'potenzaCrescente' ? 'selected' : ''}>
                                ⚡ Potenza crescente
                            </option>
                            <option value="potenzaDecrescente" ${ordinamento == 'potenzaDecrescente' ? 'selected' : ''}>
                                🚀 Potenza decrescente
                            </option>
                            <option value="cilindrataCrescente" ${ordinamento == 'cilindrataCrescente' ? 'selected' : ''}>
                                🔧 Cilindrata crescente
                            </option>
                            <option value="cilindrataDecrescente" ${ordinamento == 'cilindrataDecrescente' ? 'selected' : ''}>
                                🏎️ Cilindrata decrescente
                            </option>
                        </select>
                    </div>
                </div>

                <input type="submit" value="🔍 Cerca Auto" class="btn-cerca">
            </form>
        </div>

        <!-- 3) Contenitore risultati, gestito da ricerca-avanzata.js -->
        <div class="risultati-container">
            <h3 class="risultati-header">🚗 Risultati della ricerca</h3>
            <div id="risultatiRicercaAvanzata">
                <jsp:include page="/WEB-INF/view/risultati.jsp" />
            </div>
        </div>
    </div>
</div>

<!-- 4) Includo JavaScript: PRIMA il filtro, POI il confronto-dinamico -->
<script src="${pageContext.request.contextPath}/js/ricerca-avanzata.js"></script>
<script src="${pageContext.request.contextPath}/js/confronto-dinamico.js"></script>
<script src="${pageContext.request.contextPath}/js/acquista.js"></script>

<!-- JavaScript aggiuntivo per mobile -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Gestione espansione filtri su mobile
        const filtriSidebar = document.querySelector('.filtri-sidebar');

        if (window.innerWidth <= 768) {
            filtriSidebar.addEventListener('click', function(e) {
                // Solo se si clicca nell'area del titolo/header
                if (e.target === this || e.target.classList.contains('filtri-title')) {
                    this.classList.toggle('expanded');
                }
            });
        }

        // Rimuovi comportamento su resize per desktop
        window.addEventListener('resize', function() {
            if (window.innerWidth > 768) {
                filtriSidebar.classList.remove('expanded');
            }
        });
    });
</script>

<!-- Indicatore utente loggato -->
<c:if test="${not empty sessionScope.utenteLoggato}">
    <div data-user-logged="true" style="display:none;"></div>
</c:if>

</body>
</html>