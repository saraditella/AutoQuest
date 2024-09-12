<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cambia-password.css">
    <title>Cambia Password</title>
</head>
<body>

<div class="container">
    <div class="form-container">
        <h2>Cambia Password</h2>
        <p>Inserisci la tua password attuale e la nuova password</p>

        <!-- Messaggi di errore -->
        <c:if test="${not empty errore}">
            <div class="message-error" role="alert">
                    ${errore}
            </div>
        </c:if>

        <!-- Messaggi di successo -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="message-success" role="alert">
                    ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <form action="${pageContext.request.contextPath}/cambia-password" method="post" id="passwordForm">

            <div class="form-group">
                <label for="passwordAttuale" class="required">Password Attuale</label>
                <input type="password"
                       id="passwordAttuale"
                       name="passwordAttuale"
                       class="form-control"
                       required
                       autocomplete="current-password">
            </div>

            <div class="form-group">
                <label for="nuovaPassword" class="required">Nuova Password</label>
                <input type="password"
                       id="nuovaPassword"
                       name="nuovaPassword"
                       class="form-control"
                       required
                       minlength="6"
                       autocomplete="new-password">
                <div class="password-requirements">
                    💡 La password deve essere di almeno 6 caratteri
                </div>
            </div>

            <div class="form-group">
                <label for="confermaNuovaPassword" class="required">Conferma Nuova Password</label>
                <input type="password"
                       id="confermaNuovaPassword"
                       name="confermaNuovaPassword"
                       class="form-control"
                       required
                       minlength="6"
                       autocomplete="new-password">
            </div>

            <div class="form-group">
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        🔒 Cambia Password
                    </button>
                    <a href="${pageContext.request.contextPath}/area-utente"
                       class="btn btn-secondary">
                        ↩️ Annulla
                    </a>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.getElementById('passwordForm');
        const nuovaPassword = document.getElementById('nuovaPassword');
        const confermaPassword = document.getElementById('confermaNuovaPassword');

        // Validazione in tempo reale per conferma password
        function validatePasswordMatch() {
            if (confermaPassword.value && nuovaPassword.value !== confermaPassword.value) {
                confermaPassword.setCustomValidity('Le password non corrispondono');
            } else {
                confermaPassword.setCustomValidity('');
            }
        }

        nuovaPassword.addEventListener('input', validatePasswordMatch);
        confermaPassword.addEventListener('input', validatePasswordMatch);

        // Validazione al submit
        form.addEventListener('submit', function(e) {
            const nuovaPasswordValue = nuovaPassword.value;
            const confermaPasswordValue = confermaPassword.value;

            // Controllo corrispondenza password
            if (nuovaPasswordValue !== confermaPasswordValue) {
                e.preventDefault();
                alert('⚠️ Le password non corrispondono!');
                confermaPassword.focus();
                return false;
            }

            // Controllo lunghezza minima
            if (nuovaPasswordValue.length < 6) {
                e.preventDefault();
                alert('⚠️ La password deve essere di almeno 6 caratteri!');
                nuovaPassword.focus();
                return false;
            }

            // Conferma cambio password
            if (!confirm('Sei sicuro di voler cambiare la password?')) {
                e.preventDefault();
                return false;
            }
        });

        // Auto-focus sul primo campo
        document.getElementById('passwordAttuale').focus();
    });
</script>

</body>
</html>