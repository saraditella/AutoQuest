<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/garage.css">
    <title>Garage - Auto salvate</title>
</head>
<body>

<script>const contextPath = '${pageContext.request.contextPath}';</script>

<!-- Indicatore per login status -->
<div data-user-logged="${not empty sessionScope.utenteLoggato ? 'true' : 'false'}" style="display:none;"></div>

<div class="container">
    <!-- Header della pagina -->
    <div class="garage-header">
        <h1 class="garage-titolo">Il tuo Garage</h1>
        <p class="garage-sottotitolo">Le auto che hai salvato per confrontarle e acquistarle</p>
    </div>

    <!-- Messaggio di errore -->
    <c:if test="${not empty error}">
        <div class="error-message">
                ${error}
        </div>
    </c:if>

    <!-- Contenuto principale -->
    <c:choose>
        <c:when test="${empty preferiti}">
            <!-- Garage vuoto -->
            <div class="garage-vuoto">
                <div class="garage-vuoto-icona">🚗</div>
                <h2 class="garage-vuoto-titolo">Il tuo garage è vuoto</h2>
                <p class="garage-vuoto-descrizione">
                    Non hai ancora salvato auto nel tuo garage.<br>
                    Inizia a esplorare il nostro catalogo per trovare l'auto dei tuoi sogni!
                </p>
                <div class="garage-vuoto-azioni">
                    <a href="${pageContext.request.contextPath}/auto-servlet" class="btn-catalogo">
                        Vai al Catalogo
                    </a>
                    <a href="${pageContext.request.contextPath}/ricerca-avanzata-servlet" class="btn-ricerca">
                        Ricerca Avanzata
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Lista auto salvate -->
            <div class="garage-lista">
                <c:forEach var="a" items="${preferiti}">
                    <article class="auto-card">
                        <!-- Immagine auto -->
                        <div class="auto-immagine-container">
                            <img src="${a.immagineUrl}"
                                 alt="${a.marchio} ${a.modello}"
                                 class="auto-immagine" />
                        </div>

                        <!-- Informazioni auto -->
                        <div class="auto-info">
                            <h2 class="auto-titolo">${a.marchio} ${a.modello}</h2>

                            <div class="auto-dettagli">
                                <div class="dettaglio-item">
                                    <span class="dettaglio-label">Alimentazione:</span>
                                    <span class="dettaglio-valore">${a.alimentazione}</span>
                                </div>

                                <div class="dettaglio-item">
                                    <span class="dettaglio-label">Potenza:</span>
                                    <span class="dettaglio-valore">${a.potenza} CV</span>
                                </div>

                                <div class="dettaglio-item">
                                    <span class="dettaglio-label">Allestimento:</span>
                                    <span class="dettaglio-valore">
                                        <c:choose>
                                            <c:when test="${not empty a.selectedAllestimentoNome}">
                                                <span class="allestimento-nome">${a.selectedAllestimentoNome}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="allestimento-nome">Base</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="dettaglio-item">
                                    <span class="dettaglio-label">Prezzo:</span>
                                    <span class="dettaglio-valore prezzo-salvato">
                                        €<fmt:formatNumber value="${a.prezzoAttuale != null ? a.prezzoAttuale : a.selectedAllestimentoPrezzo}" pattern="#,##0.00"/>
                                    </span>
                                </div>
                            </div>

                            <div class="data-salvataggio">
                                Salvata il:
                                <c:choose>
                                    <c:when test="${not empty a.dataSalvataggioFormatted}">
                                        ${a.dataSalvataggioFormatted}
                                    </c:when>
                                    <c:when test="${not empty a.dataSalvataggio}">
                                        <fmt:formatDate value="${a.dataSalvataggio}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:when>
                                    <c:otherwise>
                                        Non disponibile
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Azioni -->
                        <div class="auto-azioni">
                            <!-- Rimuovi dal garage -->
                            <form action="${pageContext.request.contextPath}/rimuovi-garage"
                                  method="post"
                                  style="margin: 0;">
                                <input type="hidden" name="idAuto" value="${a.idAuto}" />
                                <button type="submit"
                                        class="btn btn-azione btn-rimuovi"
                                        onclick="return confirm('Sei sicuro di voler rimuovere ${fn:escapeXml(a.marchio)} ${fn:escapeXml(a.modello)} dal garage?')"
                                        aria-label="Rimuovi ${a.marchio} ${a.modello} dal garage">
                                    Rimuovi
                                </button>
                            </form>

                            <!-- Acquista -->
                            <button type="button"
                                    class="btn btn-azione btn-acquista"
                                    onclick="acquistaERegistra('${a.idAuto}', '${a.selectedAllestimentoId}', '${fn:escapeXml(a.linkAcquisto)}')"
                                    aria-label="Acquista ${a.marchio} ${a.modello}">
                                Procedi all'acquisto
                            </button>

                            <!-- Vedi dettaglio -->
                            <a href="${pageContext.request.contextPath}/dettaglio-auto?idAuto=${a.idAuto}<c:if test='${not empty a.selectedAllestimentoId}'>&idAllestimento=${a.selectedAllestimentoId}</c:if>"
                               class="btn btn-azione btn-dettaglio"
                               aria-label="Vedi dettagli di ${a.marchio} ${a.modello}">
                                Vedi Dettaglio
                            </a>
                        </div>
                    </article>
                </c:forEach>
            </div>

            <!-- Statistiche garage (opzionale) -->
            <div class="garage-stats" style="margin-top: 2rem; text-align: center; color: var(--secondary-color);">
                <p>Hai salvato <strong>${fn:length(preferiti)}</strong>
                    auto${fn:length(preferiti) != 1 ? '' : ''} nel tuo garage</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Include JavaScript -->
<script src="${pageContext.request.contextPath}/js/acquista.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Miglioramenti accessibilità e UX

        // Conferma rimozione più user-friendly
        const removeButtons = document.querySelectorAll('.btn-rimuovi');
        removeButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                const form = this.closest('form');
                const autoName = this.getAttribute('aria-label').replace('Rimuovi ', '').replace(' dal garage', '');

                // Personalizza il messaggio di conferma
                const confirmed = confirm(
                    `Sei sicuro di voler rimuovere "${autoName}" dal garage?\n\n` +
                    'Questa azione non può essere annullata.'
                );

                if (!confirmed) {
                    e.preventDefault();
                    return false;
                }
            });
        });

        // Loading state per i pulsanti di acquisto
        const buyButtons = document.querySelectorAll('.btn-acquista');
        buyButtons.forEach(button => {
            button.addEventListener('click', function() {
                this.disabled = true;
                this.textContent = 'Elaborando...';

                // Riabilita dopo 3 secondi in caso di errore
                setTimeout(() => {
                    this.disabled = false;
                    this.textContent = 'Procedi all\'acquisto';
                }, 3000);
            });
        });

        // Animazione di entrata per le card
        const cards = document.querySelectorAll('.auto-card');
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const cardObserver = new IntersectionObserver((entries) => {
            entries.forEach((entry, index) => {
                if (entry.isIntersecting) {
                    setTimeout(() => {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }, index * 100);
                    cardObserver.unobserve(entry.target);
                }
            });
        }, observerOptions);

        // Applica animazione solo se il browser supporta Intersection Observer
        if ('IntersectionObserver' in window) {
            cards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                cardObserver.observe(card);
            });
        }
    });
</script>

</body>
</html>