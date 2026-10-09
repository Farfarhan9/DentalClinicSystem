<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    // Set variables for sidebar
    pageContext.setAttribute("user", currentUser);
    pageContext.setAttribute("userRole", "admin");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Staff Account</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
</head>
<body class="dashboard-layout">
    <div class="app-container"> <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper"> <div class="header-bar">
                <h2><i class="fas fa-user-plus"></i> Staff Management</h2>
                <div class="user-info">Admin: <%= currentUser.getFullName() %></div>
            </div>

            <div class="card" style="background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto;">
                <h3>Create New Staff Account</h3>
                <hr style="margin-bottom: 20px; opacity: 0.2;">
                <form action="${pageContext.request.contextPath}/admin/staff" method="POST">
                    <input type="hidden" name="action" value="create">
                    
                    <div style="margin-bottom: 15px;">
                        <label style="display:block; margin-bottom:5px;">Full Name</label>
                        <input type="text" name="fullName" required style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                    </div>
                    
                    <div style="margin-bottom: 15px;">
					    <label style="display:block; margin-bottom:5px;">Username</label>
					    <input type="text" name="username" required style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
					</div>
					
					<div style="margin-bottom: 15px;">
					    <label style="display:block; margin-bottom:5px;">Initial Password</label>
					    <input type="text" name="password" value="password123" required style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
					    <small style="color: #666;">Default set to password123 for development.</small>
					</div>

                    <div style="margin-bottom: 15px;">
                        <label style="display:block; margin-bottom:5px;">Role</label>
                        <select name="role" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                            <option value="receptionist">Receptionist</option>
                            <option value="dentist">Dentist</option>
                            <option value="hr">HR Personnel</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <label style="display:block; margin-bottom:5px;">Branch Assignment</label>
                        <select name="branchId" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;">
                            <option value="1">Branch 1 (Main)</option>
                            <option value="2">Branch 2 (Sub)</option>
                        </select>
                    </div>

                    <button type="submit" style="width:100%; background:#3498db; color:white; border:none; padding:12px; border-radius:4px; cursor:pointer; font-weight:bold;">
                        Save Staff Account
                    </button>
                </form>
            </div>
        </main>
    </div>
</body>
</html>