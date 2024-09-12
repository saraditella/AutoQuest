<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrazione</title>
    <!-- CSS specifico per la registrazione -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/registrazione.css">
</head>
<body>

<main class="container">
    <div class="register-container">
        <h2>Registrazione</h2>

        <c:if test="${not empty errorMessage}">
            <div class="error" role="alert">${errorMessage}</div>
        </c:if>

        <!--Prima mostra il messaggio poi lo rimuove per evitare che venga mostrato di nuovo al refresh-->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="success" role="alert">${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <!--novalidate: validazione gestita con js e precompila con il campo nome se gia presente ad es. dopo un errore-->
        <form action="${pageContext.request.contextPath}/registrazione" method="post" novalidate>
            <div class="form-group">
                <label for="nome">Nome:</label>
                <input type="text"
                       id="nome"
                       name="nome"
                       class="form-control"
                       value="${nome}"
                       required
                       aria-describedby="nome-help">
            </div>

            <div class="form-group">
                <label for="cognome">Cognome:</label>
                <input type="text"
                       id="cognome"
                       name="cognome"
                       class="form-control"
                       value="${cognome}"
                       required
                       aria-describedby="cognome-help">
            </div>

            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email"
                       id="email"
                       name="email"
                       class="form-control"
                       value="${email}"
                       required
                       aria-describedby="email-help"
                       autocomplete="email">
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password"
                       id="password"
                       name="password"
                       class="form-control"
                       required
                       aria-describedby="password-help"
                       autocomplete="new-password"
                       minlength="6">
                <div class="password-requirements" id="password-help">
                    La password deve essere di almeno 6 caratteri
                </div>
            </div>

            <div class="form-group">
                <label for="confermaPassword">Conferma Password:</label>
                <input type="password"
                       id="confermaPassword"
                       name="confermaPassword"
                       class="form-control"
                       required
                       aria-describedby="confirm-password-help"
                       autocomplete="new-password"
                       minlength="6">
            </div>

            <div class="form-group">
                <button type="submit" class="btn">Registrati</button>
            </div>
        </form>

        <div class="login-link">
            Hai già un account? <a href="${pageContext.request.contextPath}/login">Accedi qui!</a>
        </div>
    </div>
</main>

<script>
    document.querySelector('form').addEventListener('submit', function(e) {
        const password = document.getElementById('password').value;
        const confermaPassword = document.getElementById('confermaPassword').value;

        if (password !== confermaPassword) {
            e.preventDefault();
            alert('Le password non corrispondono!');
            return false;
        }

        if (password.length < 6) {
            e.preventDefault();
            alert('La password deve essere di almeno 6 caratteri!');
            return false;
        }
    });
</script>

</body>
</html>