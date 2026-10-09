<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Appointment, java.util.List" %>
<% 
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("dentist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "dentist");
    pageContext.setAttribute("contextPath", request.getContextPath());

    List<Appointment> queue = (List<Appointment>) request.getAttribute("todayQueue");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Today's Queue | Dentist</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .panel { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-top: 20px; }
        .status-ready { background: #e7f3ed; color: #28a745; padding: 5px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .btn-treat { background: #8e44ad; color: white; padding: 8px 15px; border-radius: 5px; text-decoration: none; font-size: 14px; }
        .btn-treat:hover { background: #732d91; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-user-clock"></i> Clinical Queue Management</h2>
                <span>Date: <%= new java.text.SimpleDateFormat("EEEE, MMM dd, yyyy").format(new java.util.Date()) %></span>
            </div>

            <div class="panel">
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom: 2px solid #eee; text-align: left;">
                            <th style="padding: 15px;">Time</th>
                            <th style="padding: 15px;">Patient Details</th>
                            <th style="padding: 15px;">Status</th>
                            <th style="padding: 15px; text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
					    <% if (queue != null && !queue.isEmpty()) { 
					        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
					        String todayStr = sdf.format(new java.util.Date());
					
					        for (Appointment a : queue) { 
					            String apptDateStr = sdf.format(a.getAppointmentDate());
					            boolean canTreat = todayStr.equals(apptDateStr);
					    %>
					        <tr style="border-bottom: 1px solid #f9f9f9; <%= !canTreat ? "opacity: 0.7;" : "" %>">
					            <td style="padding: 15px;">
					                <span style="font-weight: bold;"><%= apptDateStr %></span><br>
					                <small><%= a.getStartTime() %></small>
					            </td>
					            <td style="padding: 15px;">
								    <%-- Displays the name, falls back to ID if name is missing --%>
								    <strong><%= (a.getPatientName() != null) ? a.getPatientName() : "Patient #" + a.getPatientId() %></strong><br>
								    <small style="color: #7f8c8d;">ID: <%= a.getPatientId() %></small>
								</td>
					            <td style="padding: 15px;">
					                <% if (canTreat) { %>
					                    <span class="status-ready">READY</span>
					                <% } else { %>
					                    <span style="color: #856404; font-size: 12px; font-weight: bold;">PENDING</span>
					                <% } %>
					            </td>
					            <td style="padding: 15px; text-align: right;">
					                <% if (canTreat) { %>
					                    <a href="<%= request.getContextPath() %>/clinical?action=start&id=<%= a.getAppointmentId() %>" class="btn-treat">
					                       <i class="fas fa-tooth"></i> Start Treatment
					                    </a>
					                <% } else { %>
					                    <button disabled style="background: #ccc; color: #666; padding: 8px 15px; border-radius: 5px; border: none; cursor: not-allowed;">
					                        Locked
					                    </button>
					                <% } %>
					            </td>
					        </tr>
					    <% } } else { %>
					        <%-- (Keep empty state code) --%>
					    <% } %>
					</tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>