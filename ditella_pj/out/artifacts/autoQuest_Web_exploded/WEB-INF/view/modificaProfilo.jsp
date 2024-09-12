<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifica Profilo</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modifica-profilo.css">
</head>
<body>

<div class="form-container">
    <h2>Modifica Profilo</h2>

    <c:if test="${not empty errore}">
        <div class="error">${errore}</div>
    </c:if>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <!-- Imposta i valori di default in modo più pulito -->
    <c:set var="nomeValue" value="${not empty utente ? utente.nome : sessionScope.utenteLoggato.nome}" />
    <c:set var="cognomeValue" value="${not empty utente ? utente.cognome : sessionScope.utenteLoggato.cognome}" />
    <c:set var="emailValue" value="${not empty utente ? utente.email : sessionScope.utenteLoggato.email}" />

    <form action="${pageContext.request.contextPath}/modifica-profilo" method="post" id="profiloForm">
        <div class="form-group">
            <label for="nome">Nome:</label>
            <input type="text" id="nome" name="nome" value="${nomeValue}" required maxlength="50">
            <div class="validation-info">Massimo 50 caratteri</div>
        </div>

        <div class="form-group">
            <label for="cognome">Cognome:</label>
            <input type="text" id="cognome" name="cognome" value="${cognomeValue}" required maxlength="50">
            <div class="validation-info">Massimo 50 caratteri</div>
        </div>

        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" value="${emailValue}" required maxlength="100">
            <div class="validation-info">Deve essere un indirizzo email valido</div>
        </div>

        <div class="form-group">
            <button type="submit" class="btn">Aggiorna Profilo</button>
            <a href="${pageContext.request.contextPath}/area-utente" class="btn-secondary">Annulla</a>
        </div>
    </form>
</div>


<!--Validazione dei campi lato client-->
<script>
    document.getElementById('profiloForm').addEventListener('submit', function(e) {
        const nome = document.getElementById('nome').value.trim();
        const cognome = document.getElementById('cognome').value.trim();
        const email = document.getElementById('email').value.trim();

        // Validazione nome
        if (nome.length < 2) {
            e.preventDefault();
            alert('Il nome deve essere di almeno 2 caratteri!');
            return false;
        }

        // Validazione cognome
        if (cognome.length < 2) {
            e.preventDefault();
            alert('Il cognome deve essere di almeno 2 caratteri!');
            return false;
        }

        // Validazione email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            e.preventDefault();
            alert('Inserisci un indirizzo email valido!');
            return false;
        }

        // Controllo se almeno un campo è stato modificato
        const originalNome = '${nomeValue}';
        const originalCognome = '${cognomeValue}';
        const originalEmail = '${emailValue}';

        if (nome === originalNome && cognome === originalCognome && email === originalEmail) {
            e.preventDefault();
            alert('Nessuna modifica rilevata. Modifica almeno un campo per continuare.');
            return false;
        }
    });

    // Migliora l'esperienza utente con feedback visivo
    document.querySelectorAll('input').forEach(input => {
        input.addEventListener('input', function() {
            // Rimuovi classi precedenti
            this.classList.remove('valid', 'invalid');

            // Aggiungi classe basata sulla validità
            if (this.checkValidity() && this.value.trim().length > 0) {
                this.classList.add('valid');
            } else if (!this.checkValidity() && this.value.trim().length > 0) {
                this.classList.add('invalid');
            }

            // Aggiungi classe di validazione temporanea
            this.classList.add('validating');
            setTimeout(() => this.classList.remove('validating'), 300);
        });
    });
</script>

</body>
</html>