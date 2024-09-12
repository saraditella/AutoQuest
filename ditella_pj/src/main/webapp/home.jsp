<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AutoQuest - Trova la tua auto ideale</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
    <meta name="description" content="Trova, confronta e personalizza la tua auto ideale con AutoQuest">
</head>

<body>
<!-- HEADER COMUNE -->


<!-- BANNER PRINCIPALE -->
<section class="banner">
    <div class="container">
        <h1>Trova la tua auto dei sogni!</h1>
        <p>Filtra, confronta e personalizza in pochi istanti.</p>
    </div>
</section>

<!-- CONTENUTO PRINCIPALE -->
<main class="container">
    <!-- RICERCA RAPIDA -->
    <section class="ricerca-rapida">
        <div class="card">
            <h2 class="text-center mb-2">Ricerca Rapida</h2>
            <p class="text-center mb-2">Trova auto in base alle tue esigenze</p>

            <form action="${pageContext.request.contextPath}/ricerca-rapida-servlet" method="get" class="search-form">
                <!-- FILTRO BUDGET -->
                <div class="form-group">
                    <label for="budget">Budget massimo:</label>
                    <select name="budget" id="budget" class="form-control">
                        <option value="">Qualsiasi budget</option>
                        <option value="15000">Fino a 15.000€</option>
                        <option value="20000">Fino a 20.000€</option>
                        <option value="30000">Fino a 30.000€</option>
                        <option value="50000">Fino a 50.000€</option>
                        <option value="75000">Fino a 75.000€</option>
                    </select>
                </div>

                <!-- FILTRO POTENZA -->
                <div class="form-group">
                    <label for="potenza">Potenza massima:</label>
                    <select name="potenza" id="potenza" class="form-control">
                        <option value="">Qualsiasi potenza</option>
                        <option value="80">Fino a 80 CV (Citycar)</option>
                        <option value="100">Fino a 100 CV (Utilitaria)</option>
                        <option value="150">Fino a 150 CV (Berlina)</option>
                        <option value="200">Fino a 200 CV (Sportiva)</option>
                        <option value="300">Fino a 300 CV (Alta prestazione)</option>
                    </select>
                </div>

                <!-- FILTRO CILINDRATA -->
                <div class="form-group">
                    <label for="cilindrata">Cilindrata massima:</label>
                    <select name="cilindrata" id="cilindrata" class="form-control">
                        <option value="">Qualsiasi cilindrata</option>
                        <option value="1000">Fino a 1.0L (1000 cc)</option>
                        <option value="1200">Fino a 1.2L (1200 cc)</option>
                        <option value="1600">Fino a 1.6L (1600 cc)</option>
                        <option value="2000">Fino a 2.0L (2000 cc)</option>
                        <option value="3000">Fino a 3.0L (3000 cc)</option>
                    </select>
                </div>

                <!-- PULSANTE RICERCA -->
                <div class="form-group">
                    <button type="submit" class="btn btn-primary btn-search">
                        🔍 Cerca Auto
                    </button>
                </div>
            </form>
        </div>
    </section>

    <!-- NAVIGAZIONE PER MARCHI -->
    <section class="marchi">
        <h2 class="text-center mb-2">Sfoglia per Marchio</h2>
        <p class="text-center mb-2">Esplora tutte le auto di un marchio specifico</p>

        <c:choose>
            <c:when test="${not empty marchi}">
                <div class="grid-marchi">
                    <c:forEach var="marchio" items="${marchi}">
                        <div class="card-marchio">
                            <div class="marchio-image">
                                <img src="${pageContext.request.contextPath}/images/marchi/${fn:toLowerCase(fn:replace(marchio, ' ', ''))}.png"
                                     alt="Logo ${marchio}">
                            </div>

                            <div class="marchio-content">
                                <h3 class="marchio-name">${marchio}</h3>
                                <a href="${pageContext.request.contextPath}/filtra-per-marchio?marchio=${fn:escapeXml(marchio)}"
                                   class="btn btn-secondary btn-marchio">
                                    Vedi Auto
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="no-data card">
                    <p>Nessun marchio disponibile al momento.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<!-- FOOTER SEMPLICE (opzionale) -->
<footer class="footer">
    <div class="container text-center">
        <p>&copy; 2025 AutoQuest - Progetto Tecnologie Software Per Il Web</p>
    </div>
</footer>
</body>
</html>