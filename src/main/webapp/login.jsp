<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.database.BranchDAO, com.dentalclinic.models.Branch, java.util.List" %>
<%
    BranchDAO branchDAO = new BranchDAO();
    List<Branch> branches = branchDAO.getAllBranches();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Login - Putra DentalCare</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .back-to-selection {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.4);
            color: white;
            padding: 10px 20px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            backdrop-filter: blur(5px);
            border: 1px solid rgba(0, 0, 0, 0.3);
        }
        .back-to-selection:hover {
            background: rgba(90, 90, 90, 0.4);
            transform: translateX(-5px);
        }
    </style>
</head>
<body class="login-page">
    <a href="index.jsp" class="back-to-selection">
        <i class="fas fa-arrow-left"></i> Back to Selection
    </a>

    <div class="login-container">
        <div class="login-header">
            <div class="clinic-logo">
                <i class="fas fa-tooth"></i>
                <h1>Putra DentalCare </h1>
            </div>
            <p class="tagline">Multi-Branch Management System</p>
        </div>
        
        <div class="login-card">
            <h2><i class="fas fa-sign-in-alt"></i> Staff Login</h2>
            
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger" style="background: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                    <i class="fas fa-exclamation-circle"></i> Invalid username or password!
                </div>
            <% } %>
            
            <form action="login" method="POST" class="login-form">
                <div class="form-group">
                    <label for="username"><i class="fas fa-user"></i> Username</label>
                    <input type="text" id="username" name="username" placeholder="Enter your username" value="admin1" required> 
                </div>
                
                <div class="form-group">
                    <label for="password"><i class="fas fa-lock"></i> Password</label>
                    <div class="password-container">
                        <input type="password" id="password" name="password" placeholder="Enter your password" value="password123" required> 
                        <button type="button" class="show-password" onclick="togglePassword()">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="branch"><i class="fas fa-clinic-medical"></i> Branch</label>
                    <select id="branch" name="branch" required>
                        <option value="">Select Branch</option>
                        <% if(branches != null) { for(Branch b : branches) { %>
                            <option value="<%= b.getBranchId() %>" <%= b.getBranchId() == 1 ? "selected" : "" %>>
                                <%= b.getBranchName() %>
                            </option>
                        <% } } %>
                    </select>
                </div>
                
                <button type="submit" class="btn-login">
                    <i class="fas fa-sign-in-alt"></i> Login to Dashboard
                </button>
                
                <div class="login-footer">
                    <div class="role-hint">
                        <h4><i class="fas fa-users"></i> Login Roles:</h4>
                        <div class="role-tags">
                            <span class="role-tag admin">Admin</span>
                            <span class="role-tag receptionist">Receptionist</span>
                            <span class="role-tag dentist">Dentist</span>
                            <span class="role-tag hr">HR</span>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const eyeIcon = document.querySelector('.show-password i');
            passwordInput.type = passwordInput.type === 'password' ? 'text' : 'password';
            eyeIcon.className = passwordInput.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
        }
    </script>
</body>
</html>