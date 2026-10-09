<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("receptionist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "receptionist");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Register Patient | Receptionist</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-user-plus"></i> New Patient Registration</h2>
                <a href="../dashboard.jsp" style="text-decoration:none; color:#7f8c8d;"><i class="fas fa-times"></i> Cancel</a>
            </div>

            <div style="background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); max-width: 800px; margin: 0 auto;">
                <form action="${pageContext.request.contextPath}/receptionist/patient-controller" method="POST">
    			<input type="hidden" name="action" value="register">
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div class="form-group">
                            <label>Full Name</label>
                            <input type="text" name="fullName" required style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                        </div>
                        <div class="form-group">
                            <label>Phone Number</label>
                            <input type="text" name="phone" required placeholder="0123456789" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                        </div>
                        <div class="form-group">
                            <label>Email Address</label>
                            <input type="email" name="email" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                        </div>
                        <div class="form-group">
                            <label>Date of Birth</label>
                            <input type="date" name="dob" required style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                        </div>
                        <div class="form-group">
                            <label>Gender</label>
                            <select name="gender" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>

                    <div style="margin-top: 20px;">
                        <label>Home Address</label>
                        <textarea name="address" rows="2" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;"></textarea>
                    </div>

                    <div style="margin-top: 20px;">
                        <label>Medical Notes (Allergies, chronic illness, etc.)</label>
                        <textarea name="medicalNotes" rows="3" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;"></textarea>
                    </div>

                    <button type="submit" style="margin-top:25px; width:100%; background:#3498db; color:white; border:none; padding:15px; border-radius:5px; font-weight:bold; cursor:pointer;">
                        <i class="fas fa-save"></i> Register Patient
                    </button>
                </form>
            </div>
        </main>
    </div>
</body>
</html>