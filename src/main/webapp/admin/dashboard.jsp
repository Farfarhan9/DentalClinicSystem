<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.database.AdminDAO, java.util.Map" %>
<% 
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "admin");
    pageContext.setAttribute("contextPath", request.getContextPath());

    AdminDAO adminDAO = new AdminDAO();
    Map<String, Object> stats = adminDAO.getClinicStats();
%>
<%@ include file="/includes/_dashboard_style.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Command Center</title>
    <style>
        .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { padding: 20px; color: white; border-radius: 10px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .bg-blue { background: #3498db; }
        .bg-green { background: #2ecc71; }
        .bg-purple { background: #9b59b6; }
        .stat-value { font-size: 2.2rem; font-weight: bold; display: block; }
        .dashboard-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; }
        .panel { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .action-list { display: flex; flex-direction: column; gap: 12px; margin-top: 15px; }
        .btn-action { 
            padding: 12px; border: none; border-radius: 5px; cursor: pointer; 
            text-align: left; font-weight: 500; transition: 0.2s; text-decoration: none;
            display: flex; align-items: center; gap: 10px;
        }
        .btn-primary-alt { background: #ebf5ff; color: #007bff; border: 1px solid #cce5ff; }
        .btn-primary-alt:hover { background: #007bff; color: white; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container"> <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper"> <div class="header-bar">
                <h2><i class="fas fa-shield-alt"></i> System Administrator: <%= user.getFullName() %></h2>
            </div>

            <div class="stats-container">
                <div class="stat-card bg-blue">
                    <span class="stat-value"><%= stats.getOrDefault("totalPatients", 0) %></span>
                    <span>Total Patients</span>
                </div>
				<div class="stat-card bg-green">
				    <span class="stat-value">
				        RM <%= String.format("%.2f", stats.get("totalRevenue") != null ? (Double)stats.get("totalRevenue") : 0.0) %>
				    </span>
				    <span>Total Revenue</span>
				</div>
                <div class="stat-card bg-purple">
                    <span class="stat-value"><%= stats.getOrDefault("todayAppointments", 0) %></span>
                    <span>Today's Appointments</span>
                </div>
            </div>

            <div class="dashboard-grid">
                <div class="panel">
                    <h3><i class="fas fa-users-cog"></i> User and Access Control</h3>
                    <div class="action-list">
                        <a href="${pageContext.request.contextPath}/admin/user/create.jsp" class="btn-action btn-primary-alt">
                            <i class="fas fa-user-plus"></i> Create New Staff Account
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/user/list.jsp" class="btn-action btn-primary-alt">
                            <i class="fas fa-users"></i> View and Manage All Staff
                        </a>
                    </div>
                </div>

                <div class="panel">
                    <h3><i class="fas fa-cogs"></i> System Configuration</h3>
                    <div class="action-list">
                        <a href="${pageContext.request.contextPath}/admin/config/branch.jsp" class="btn-action btn-primary-alt">
                            <i class="fas fa-code-branch"></i> Manage Clinic Branches
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/config/services.jsp" class="btn-action btn-primary-alt">
                            <i class="fas fa-tooth"></i> Update Treatment Items
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>