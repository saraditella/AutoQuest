<%--
  Created by IntelliJ IDEA.
  User: frank
  Date: 26/07/2025
  Time: 06:23
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="/WEB-INF/includes/header.jspf" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accedi - AutoQuest</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body>

<div class="login-container">
    <h2>Accedi al tuo account</h2>

    <!-- Messaggi di errore -->
    <c:if test="${not empty erroreLogin}">
        <div class="error-message">${erroreLogin}</div>
    </c:if>

    <!-- Messaggi di successo -->
    <c:if test="${not empty successoRegistrazione}">
        <div class="success-message">${successoRegistrazione}</div>
    </c:if>

    <!-- Form di login -->
    <form action="${pageContext.request.contextPath}/login" method="post" class="login-form">
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" placeholder="Inserisci la tua email" required
                   value="${param.email}">
        </div>

        <div class="form-group">
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" placeholder="Inserisci la tua password" required>
        </div>

        <button type="submit" class="login-btn">Accedi</button>
    </form>

    <!-- Link registrazione -->
    <div class="register-link">
        <p>Non hai un account? <a href="${pageContext.request.contextPath}/registrazione">Crealo qui!</a></p>
        <p><a href="${pageContext.request.contextPath}/home-servlet">← Torna alla Home</a></p>
    </div>

    <!-- Account demo per test (rimuovi in produzione) -->
    <div class="demo-accounts">
        <h4>🔧 Account Demo per Test</h4>
        <p>
            Clicca sull'account per compilare automaticamente i campi:
        </p>

        <div class="demo-account" onclick="fillLogin('admin@autoquest.com', 'admin123')">
            <strong>ADMIN:</strong> admin@autoquest.com / admin123
        </div>

    </div>
</div>

<script>
    function fillLogin(email, password) {
        document.getElementById('email').value = email;
        document.getElementById('password').value = password;
    }

    // Focus automatico sul primo campo
    document.addEventListener('DOMContentLoaded', function() {
        if (!document.getElementById('email').value) {
            document.getElementById('email').focus();
        }
    });
</script>

</body>
</html>