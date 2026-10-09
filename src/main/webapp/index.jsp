<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - Putra DentalCare</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .gateway-container { text-align: center; background: white; padding: 50px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); width: 100%; max-width: 600px; }
        .choice-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 30px; }
        .choice-card { 
            padding: 30px; border: 2px solid #e0e0e0; border-radius: 15px; cursor: pointer; 
            transition: all 0.3s ease; text-decoration: none; color: inherit;
        }
        .choice-card:hover { border-color: #667eea; background: #f8fbff; transform: translateY(-5px); }
        .choice-card i { font-size: 3rem; color: #4a6fa5; margin-bottom: 15px; }
        .choice-card h3 { color: #2c3e50; }
    </style>
</head>
<body>
    <div class="gateway-container">
        <div class="clinic-logo" style="justify-content: center; margin-bottom: 20px;">
            <i class="fas fa-tooth" style="font-size: 3rem; color: #4a6fa5;"></i>
            <h1 style="font-size: 2.5rem; color: #2c3e50;">Putra DentalCare</h1>
        </div>
        <p style="color: #7f8c8d;">Welcome to our Multi-Branch Management System. Please identify yourself:</p>
        
        <div class="choice-grid">
            <a href="patient_login.jsp" class="choice-card">
                <i class="fas fa-user-injured"></i>
                <h3>I am a Patient</h3>
                <p style="font-size: 0.8rem; color: #95a5a6; margin-top: 5px;">Book appointments and view history</p>
            </a>
            
            <a href="login.jsp" class="choice-card">
                <i class="fas fa-user-md"></i>
                <h3>I am an Employee</h3>
                <p style="font-size: 0.8rem; color: #95a5a6; margin-top: 5px;">Manage clinic operations</p>
            </a>
        </div>
    </div>
</body>
</html>