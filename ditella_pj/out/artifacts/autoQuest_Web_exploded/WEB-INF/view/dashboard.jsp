<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard Amministratore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">

</head>


<body>

<div class="container">
  <main class="admin-main">

    <!-- Header Dashboard -->
    <div class="admin-header">
      <div class="admin-welcome">
        <h1>Dashboard Amministratore</h1>
        <p class="admin-greeting">
          Benvenuto, <strong>${sessionScope.utenteLoggato.nome} ${sessionScope.utenteLoggato.cognome}</strong>
        </p>
      </div>
      <div class="admin-badge">
        <span class="role-badge">ADMIN</span>
      </div>
    </div>

    <!-- Statistiche -->
    <section class="stats-section">
      <h2 class="section-title">Statistiche Generali</h2>
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon">🚗</div>
          <div class="stat-content">
            <div class="stat-number">${totalAuto != null ? totalAuto : 'N/A'}</div>
            <div class="stat-label">Auto nel catalogo</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon">👥</div>
          <div class="stat-content">
            <div class="stat-number">${totalUtenti != null ? totalUtenti : 'N/A'}</div>
            <div class="stat-label">Utenti registrati</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon">📦</div>
          <div class="stat-content">
            <div class="stat-number">${totalOrdini != null ? totalOrdini : 'N/A'}</div>
            <div class="stat-label">Ordini totali</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon">⚖️</div>
          <div class="stat-content">
            <div class="stat-number">${totalConfronti != null ? totalConfronti : 'N/A'}</div>
            <div class="stat-label">Confronti salvati</div>
          </div>
        </div>

        <div class="stat-card stat-card-highlight">
          <div class="stat-icon">💰</div>
          <div class="stat-content">
            <div class="stat-number">
              €<fmt:formatNumber value="${incassoTotale}" pattern="#,##0.00"/>
            </div>
            <div class="stat-label">Incasso Totale</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Gestione Auto -->
    <section class="auto-management">
      <div class="section-header">
        <h2 class="section-title">Gestione Auto</h2>
        <button type="button" id="toggleAutoForm" class="btn btn-primary">
          <span class="btn-icon">+</span>
          Aggiungi Auto
        </button>
      </div>

      <!-- Form Aggiungi Auto -->
      <div id="autoForm" class="auto-form">
        <div class="form-card">
          <div class="form-header">
            <h3>Nuova Auto</h3>
            <button type="button" id="closeForm" class="close-btn">×</button>
          </div>

          <!-- SOSTITUISCI COMPLETAMENTE il form nella tua dashboard con questo -->
          <form action="${pageContext.request.contextPath}/admin/aggiungi-auto" method="post">
            <div class="form-grid">
              <div class="form-group">
                <label for="marchio">Marchio *</label>
                <input type="text" id="marchio" name="marchio" class="form-control" required>
              </div>

              <div class="form-group">
                <label for="modello">Modello *</label>
                <input type="text" id="modello" name="modello" class="form-control" required>
              </div>

              <div class="form-group">
                <label for="alimentazione">Alimentazione *</label>
                <select id="alimentazione" name="alimentazione" class="form-control" required>
                  <option value="">Seleziona...</option>
                  <option value="benzina">Benzina</option>
                  <option value="diesel">Diesel</option>
                  <option value="elettrica">Elettrica</option>
                  <option value="ibrida">Ibrida</option>
                  <option value="ibrida plug-in">Ibrida Plug-in</option>
                  <option value="gpl">GPL</option>
                  <option value="metano">Metano</option>
                  <option value="idrogeno">Idrogeno</option>
                </select>
              </div>

              <div class="form-group">
                <label for="cambio">Cambio *</label>
                <select id="cambio" name="cambio" class="form-control" required>
                  <option value="">Seleziona...</option>
                  <option value="manuale">Manuale</option>
                  <option value="automatico">Automatico</option>
                  <option value="sequenziale">Sequenziale</option>
                  <option value="cvt">CVT</option>
                  <option value="doppia frizione">Doppia Frizione</option>
                </select>
              </div>

              <div class="form-group">
                <label for="potenza">Potenza (CV) *</label>
                <input type="number" id="potenza" name="potenza" class="form-control"
                       min="50" max="1000" required>
              </div>

              <div class="form-group">
                <label for="cilindrata">Cilindrata (cc) *</label>
                <input type="number" id="cilindrata" name="cilindrata" class="form-control"
                       min="500" max="8000" required>
              </div>

              <div class="form-group">
                <label for="prezzoBase">Prezzo Base (€) *</label>
                <input type="number" id="prezzoBase" name="prezzoBase" class="form-control"
                       min="5000" max="500000" step="100" required>
              </div>

              <div class="form-group">
                <label for="linkAcquisto">Link Acquisto</label>
                <input type="url" id="linkAcquisto" name="linkAcquisto" class="form-control"
                       placeholder="https://...">
              </div>
            </div>

            <div class="form-group full-width">
              <label for="immagineUrl">URL Immagine</label>
              <input type="url" id="immagineUrl" name="immagineUrl" class="form-control"
                     placeholder="https://...">
            </div>

            <div class="form-actions">
              <button type="submit" class="btn btn-success">
                <span class="btn-icon">✓</span>
                Aggiungi Auto
              </button>
              <button type="button" id="cancelForm" class="btn btn-secondary">
                Annulla
              </button>
            </div>
          </form>
        </div>
      </div>
    </section>

    <!-- Navigation Footer -->
    <div class="admin-footer">
      <a href="${pageContext.request.contextPath}/area-utente" class="btn btn-outline">
        <span class="btn-icon">🏠</span>
        Pannello Amministratore
      </a>
      <a href="${pageContext.request.contextPath}/home-servlet" class="btn btn-outline">
        <span class="btn-icon">🌐</span>
        Vai al Sito
      </a>
    </div>

  </main>
</div>

<!-- Notification Container -->
<div id="notification-container" class="notification-container"></div>

// SOSTITUISCI TUTTO lo script nella dashboard con questo
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const toggleBtn = document.getElementById('toggleAutoForm');
    const closeBtn = document.getElementById('closeForm');
    const cancelBtn = document.getElementById('cancelForm');
    const autoForm = document.getElementById('autoForm');

    function showForm() {
      if (autoForm) {
        autoForm.classList.add('active');
        document.body.classList.add('form-active');
      }
    }

    function hideForm() {
      if (autoForm) {
        autoForm.classList.remove('active');
        document.body.classList.remove('form-active');
        // Reset form
        const form = autoForm.querySelector('form');
        if (form) form.reset();
      }
    }

    // Event listeners
    if (toggleBtn) toggleBtn.addEventListener('click', showForm);
    if (closeBtn) closeBtn.addEventListener('click', hideForm);
    if (cancelBtn) cancelBtn.addEventListener('click', hideForm);

    // Close form on overlay click
    if (autoForm) {
      autoForm.addEventListener('click', function(e) {
        if (e.target === autoForm) {
          hideForm();
        }
      });
    }

    // Close form on Escape key
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && autoForm && autoForm.classList.contains('active')) {
        hideForm();
      }
    });
  });

  // Notification system
  function showNotification(message, type = 'info') {
    const container = document.getElementById('notification-container');
    if (!container) return;

    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
      <span class="notification-message">${message}</span>
      <button class="notification-close">&times;</button>
    `;

    container.appendChild(notification);

    // Auto remove after 5 seconds
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 5000);

    // Manual close
    const closeButton = notification.querySelector('.notification-close');
    if (closeButton) {
      closeButton.addEventListener('click', () => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      });
    }
  }

  // Mostra messaggi dalla sessione
  <c:if test="${not empty sessionScope.successMessage}">
  document.addEventListener('DOMContentLoaded', function() {
    showNotification('${sessionScope.successMessage}', 'success');
    // Nascondi il form se successo
    const autoForm = document.getElementById('autoForm');
    if (autoForm && autoForm.classList.contains('active')) {
      setTimeout(() => {
        autoForm.classList.remove('active');
        document.body.classList.remove('form-active');
        const form = autoForm.querySelector('form');
        if (form) form.reset();
      }, 1000);
    }
  });
  </c:if>

  <c:if test="${not empty sessionScope.errorMessage}">
  document.addEventListener('DOMContentLoaded', function() {
    showNotification('${sessionScope.errorMessage}', 'error');
  });
  </c:if>
</script>

<!-- Aggiungi alla fine della dashboard per pulire i messaggi dalla sessione -->
<c:if test="${not empty sessionScope.successMessage}">
  <c:remove var="successMessage" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
  <c:remove var="errorMessage" scope="session"/>
</c:if>

</body>
</html>