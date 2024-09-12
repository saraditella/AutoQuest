<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/area-utente.css">
    <title>Area Utente</title>
</head>
<body>

<div class="container">
    <!-- User info card -->
    <div class="user-info card">
        <h1>Benvenuto, ${sessionScope.utenteLoggato.nome} ${sessionScope.utenteLoggato.cognome}
            <c:choose>
                <c:when test="${sessionScope.utenteLoggato.admin || sessionScope.utenteLoggato.ruolo == 'ADMIN'}">
                    <span class="role-badge role-admin">👑 Amministratore</span>
                </c:when>
                <c:otherwise>
                    <span class="role-badge role-user">👤 Utente</span>
                </c:otherwise>
            </c:choose>
        </h1>
        <p><strong>Email:</strong> ${sessionScope.utenteLoggato.email}</p>
        <p><strong>ID Utente:</strong> ${sessionScope.utenteLoggato.idUtente}</p>
        <p><strong>Ruolo:</strong> ${sessionScope.utenteLoggato.ruolo}</p>
    </div>

    <!-- Messaggi di errore -->
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="error-message">
                ${sessionScope.errorMessage}
        </div>
        <c:remove var="errorMessage" scope="session" />
    </c:if>

    <script>
        const contextPath = '${pageContext.request.contextPath}';
    </script>

    <!-- Sezione Admin  -->
    <c:if test="${sessionScope.utenteLoggato.admin || sessionScope.utenteLoggato.ruolo == 'ADMIN'}">
        <div class="admin-section">
            <h2>🔧 Pannello Amministratore</h2>
            <p>Panoramica rapida del sistema</p>

            <!-- Statistiche principali -->
            <div class="admin-stats">
                <div class="admin-stat-card">
                    <div class="admin-stat-number">${totalAuto != null ? totalAuto : 'N/A'}</div>
                    <div class="admin-stat-label">Auto nel catalogo</div>
                </div>
                <div class="admin-stat-card">
                    <div class="admin-stat-number">${totalUtenti != null ? totalUtenti : 'N/A'}</div>
                    <div class="admin-stat-label">Utenti registrati</div>
                </div>
                <div class="admin-stat-card">
                    <div class="admin-stat-number">${totalOrdini != null ? totalOrdini : 'N/A'}</div>
                    <div class="admin-stat-label">Ordini totali</div>
                </div>
                <div class="admin-stat-card">
                    <div class="admin-stat-number">${totalConfronti != null ? totalConfronti : 'N/A'}</div>
                    <div class="admin-stat-label">Confronti salvati</div>
                </div>
            </div>

            <!-- Unico bottone per dashboard completa -->
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-dashboard-btn">
                📊 Apri Dashboard Amministratore
            </a>
        </div>
    </c:if>

    <!-- Sezioni utente normale - nascoste per admin -->
    <c:if test="${not (sessionScope.utenteLoggato.admin || sessionScope.utenteLoggato.ruolo == 'ADMIN')}">
        <div class="section card">
            <h2>I tuoi confronti salvati</h2>
            <c:if test="${empty confronti}">
                <p>Non hai ancora salvato alcun confronto.</p>
            </c:if>
            <c:if test="${not empty confronti}">
                <table>
                    <thead>
                    <tr><th>Nome confronto</th><th>Data creazione</th><th>Azioni</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="c" items="${confronti}">
                        <tr>
                            <td>${c.nomeConfronto}</td>
                            <td>${c.dataCreazione.dayOfMonth}/${c.dataCreazione.monthValue}/${c.dataCreazione.year} ${c.dataCreazione.hour}:${c.dataCreazione.minute < 10 ? '0' : ''}${c.dataCreazione.minute}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/confronto-salvato?idConfronto=${c.idConfronto}" class="link-marchio">Visualizza</a>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>

        <div class="section card">
            <h2>Il tuo garage</h2>
            <c:if test="${empty garage}">
                <p> Nessuna auto salvata nel garage.</p>
            </c:if>
            <c:if test="${not empty garage}">
                <table>
                    <thead>
                    <tr><th>Auto</th><th>Allestimento</th><th>Prezzo salvato</th><th>Data</th><th>Azioni</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="g" items="${garage}">
                        <tr>
                            <td>${g.marchio} ${g.modello}</td>
                            <td>${g.selectedAllestimentoNome}</td>
                            <td>€<fmt:formatNumber value="${g.prezzoAttuale}" pattern="#,##0.00"/></td>
                            <td>${g.dataSalvataggio.dayOfMonth}/${g.dataSalvataggio.monthValue}/${g.dataSalvataggio.year} ${g.dataSalvataggio.hour}:${g.dataSalvataggio.minute < 10 ? '0' : ''}${g.dataSalvataggio.minute}</td>
                            <td>
                                <div class="d-flex align-center gap-1">
                                    <form action="${pageContext.request.contextPath}/rimuovi-garage" method="post" class="d-inline">
                                        <input type="hidden" name="idAuto" value="${g.idAuto}" />
                                        <button type="submit" class="btn btn-ghost">Rimuovi</button>
                                    </form>

                                    <button type="button"
                                            onclick="acquistaERegistra(${g.idAuto}, ${g.selectedAllestimentoId}, '${g.linkAcquisto}')"
                                            class="btn btn-primary">
                                        Acquista
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:if>

            <c:if test="${not empty garage}">
                <p><a href="${pageContext.request.contextPath}/garage" class="link-marchio">Visualizza garage completo</a></p>
            </c:if>
        </div>

        <div class="section card">
            <h2>I tuoi ordini</h2>
            <c:if test="${empty ordini}">
                <p>Nessun ordine presente.</p>
            </c:if>
            <c:if test="${not empty ordini}">
                <table>
                    <thead>
                    <tr><th>ID ordine</th><th>Auto</th><th>Allestimento</th><th>Prezzo</th><th>Data ordine</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="o" items="${ordini}">
                        <tr>
                            <td>${o.idOrdine}</td>
                            <td>${o.marchio} ${o.modello}</td>
                            <td>${o.nomeAllestimento}</td>
                            <td>€<fmt:formatNumber value="${o.prezzoTotale}" pattern="#,##0.00"/></td>
                            <td>${o.dataOrdine.dayOfMonth}/${o.dataOrdine.monthValue}/${o.dataOrdine.year} ${o.dataOrdine.hour}:${o.dataOrdine.minute < 10 ? '0' : ''}${o.dataOrdine.minute}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>
    </c:if>

    <div class="section card">
        <h2>Gestione Account</h2>
        <div class="d-flex gap-1" style="margin-top:10px;">
            <a href="${pageContext.request.contextPath}/modifica-profilo" class="link-marchio">Modifica Profilo</a>
            <a href="${pageContext.request.contextPath}/cambia-password" class="link-marchio">Cambia Password</a>
            <a href="${pageContext.request.contextPath}/home-servlet" class="link-marchio">🏠 Torna alla Home</a>
            <a href="${pageContext.request.contextPath}/logout" class="link-marchio">🚪 Logout</a>
        </div>
    </div>

</div>

<!--Gli amministratori non devono accedere a funzioni di acquisto-->
<c:if test="${not (sessionScope.utenteLoggato.admin || sessionScope.utenteLoggato.ruolo == 'ADMIN')}">
    <script src="${pageContext.request.contextPath}/js/acquista.js"></script>
</c:if>

</body>
</html>
