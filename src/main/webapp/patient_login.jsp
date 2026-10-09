<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Login - Putra DentalCare</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="login-page">
    <div class="login-container" style="max-width: 500px; display: block; min-height: auto;">
        <div class="login-header" style="text-align: center;">
            <div class="clinic-logo" style="justify-content: center;">
                <i class="fas fa-tooth"></i>
                <h1>Patient Portal</h1>
            </div>
            <p class="tagline">Manage your oral health with ease</p>
        </div>
        
        <div class="login-card">
            <h2><i class="fas fa-lock"></i> Secure Login</h2>
            
            <%-- Registration Success Message --%>
            <% if ("success".equals(request.getParameter("registration"))) { %>
                <div id="successAlert" class="alert alert-success" style="background: #d4edda; color: #155724; padding: 10px; border-radius: 5px; margin-bottom: 15px; border: 1px solid #c3e6cb;">
                    <i class="fas fa-check-circle"></i> Registration successful! Please login.
                </div>
            <% } %>

            <%-- Error Message --%>
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger" style="background: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                    <i class="fas fa-exclamation-circle"></i> Invalid email, phone, or password!
                </div>
            <% } %>

            <%-- Logout Success Message --%>
            <% if ("loggedout".equals(request.getParameter("status"))) { %>
                <div class="alert alert-success" style="background: #d4edda; color: #155724; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                    <i class="fas fa-check-circle"></i> You have been logged out successfully.
                </div>
            <% } %>
            
            <form action="patientLogin" method="POST" class="login-form">
                <div class="form-group">
                    <label for="identifier"><i class="fas fa-user-circle"></i> Email or Phone Number</label>
                    <input type="text" id="identifier" name="identifier" 
                           placeholder="Enter your registered email or phone" required>
                </div>
                
                <div class="form-group">
                    <label for="password"><i class="fas fa-key"></i> Password</label>
                    <div class="password-container" style="position: relative; display: flex; align-items: center;">
                        <input type="password" id="password" name="password" 
                               placeholder="Enter your password" required 
                               style="width: 100%; padding-right: 40px;">
                        <button type="button" class="show-password" onclick="togglePassword()" 
                                style="position: absolute; right: 10px; background: none; border: none; cursor: pointer; color: #7f8c8d;">
                            <i class="fas fa-eye" id="eyeIcon"></i>
                        </button>
                    </div>
					 <div style="text-align: right; margin-top: 5px;">
					    <a href="forgot_password.jsp" style="font-size: 0.8rem; color: #3498db; text-decoration: none;">
					        Forgot Password?
					    </a>
					</div>
                </div>
                
                <button type="submit" class="btn-login" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                    <i class="fas fa-sign-in-alt"></i> Access My Portal
                </button>
                
                <div style="text-align: center; margin-top: 25px; border-top: 1px solid #eee; padding-top: 20px;">
                    <p style="color: #7f8c8d; margin-bottom: 10px; font-size: 0.9rem;">New to our clinic?</p>
                    <a href="patient_register.jsp" class="btn-login" style="background: #f8f9fa; color: #4a6fa5; border: 2px solid #4a6fa5; margin-top: 0; text-decoration: none;">
                        <i class="fas fa-user-plus"></i> Create New Account
                    </a>
                </div>

                <div style="text-align: center; margin-top: 20px;">
                    <a href="index.jsp" style="color: #7f8c8d; text-decoration: none; font-size: 0.9rem;">
                        <i class="fas fa-arrow-left"></i> Back to selection
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const eyeIcon = document.getElementById('eyeIcon');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.className = 'fas fa-eye-slash';
            } else {
                passwordInput.type = 'password';
                eyeIcon.className = 'fas fa-eye';
            }
        }

        // Auto-hide the success message after 5 seconds
        window.onload = function() {
            const alert = document.getElementById('successAlert');
            if(alert) {
                setTimeout(function() {
                    alert.style.display = 'none';
                }, 5000);
            }
        };
    </script>
</body>
</html>