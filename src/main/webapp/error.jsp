<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>System Error</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="login-page">
    <div class="login-container">
        <div class="login-card" style="grid-column: span 2; text-align: center;">
            <h2 style="color: #c0392b;"><i class="fas fa-exclamation-triangle"></i> System Error</h2>
            <div class="alert alert-danger" style="display: block;">
                
                <% 
                    // Retrieve the custom error message attribute
                    String errorMessage = (String) request.getAttribute("errorMessage");
                    Exception rootException = (Exception) request.getAttribute("rootException");
                %>
                
                <% if (errorMessage != null) { %>
                    <p>Details: <%= errorMessage %></p>
                <% } else if (rootException != null) { %>
                    <p>Details: <%= rootException.getMessage() %></p>
                <% } else { %>
                    <p>An unknown error occurred. Please try again or contact the administrator.</p>
                <% } %>
            </div>
            <a href="<%= request.getContextPath() %>/login" class="btn-login" style="background: #3498db; width: 50%; margin: 20px auto;">
                <i class="fas fa-undo-alt"></i> Back to Login
            </a>
        </div>
    </div>
</body>
</html>