<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Putra DentalCare</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="login-page">
    <div class="login-container" style="max-width: 600px; display: block; min-height: auto; margin: 40px auto;">
        <div class="login-header" style="text-align: center;">
            <div class="clinic-logo" style="justify-content: center;">
                <i class="fas fa-tooth"></i>
                <h1>Patient Registration</h1>
            </div>
            <p class="tagline">Join us for a brighter, healthier smile</p>
        </div>
        
        <div class="login-card">
            <form action="patientRegister" method="POST" class="login-form">
                <div class="form-group">
                    <label for="fullName"><i class="fas fa-user"></i> Full Name (as per IC)</label>
                    <input type="text" id="fullName" name="fullName" placeholder="John Doe" required>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                    <div class="form-group">
                        <label for="email"><i class="fas fa-envelope"></i> Email Address</label>
                        <input type="email" id="email" name="email" placeholder="john@example.com" required>
                    </div>
                    <div class="form-group">
                        <label for="phone"><i class="fas fa-phone"></i> Phone Number</label>
                        <input type="text" id="phone" name="phone" placeholder="0123456789" required>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                    <div class="form-group">
                        <label for="dob"><i class="fas fa-calendar-alt"></i> Date of Birth</label>
                        <input type="date" id="dob" name="dob" required>
                    </div>
                    <div class="form-group">
                        <label for="gender"><i class="fas fa-venus-mars"></i> Gender</label>
                        <select id="gender" name="gender" required>
                            <option value="">Select</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password"><i class="fas fa-key"></i> Create Password</label>
                    <input type="password" id="password" name="password" placeholder="Min 6 characters" required>
                </div>

                <button type="submit" class="btn-login" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <i class="fas fa-check-circle"></i> Complete Registration
                </button>

                <div style="text-align: center; margin-top: 20px;">
                    <a href="patient_login.jsp" style="color: #4a6fa5; text-decoration: none; font-size: 0.9rem;">
                        Already have an account? <span style="font-weight: bold;">Login here</span>
                    </a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>