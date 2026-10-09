<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Appointment, com.dentalclinic.database.ClinicalRecordDAO, java.util.List" %>
<% 
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("dentist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "dentist");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<%@ include file="/includes/_dashboard_style.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dentist Dashboard | Putra DentalCare</title>
    <style>
        /* Shared Styles with Admin/Receptionist */
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
        .btn-success-alt { background: #e7f3ed; color: #28a745; border: 1px solid #d4edda; }
        
        /* Queue Specifics */
        .queue-item { 
            padding: 10px; border-bottom: 1px solid #eee; 
            display: flex; justify-content: space-between; align-items: center; 
        }
        .status-pill { font-size: 11px; padding: 3px 8px; border-radius: 10px; font-weight: bold; }
        .text-muted { color: #7f8c8d; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-tooth"></i> Dentist Dashboard: Dr. <%= user.getFullName() %></h2>
            </div>

            <div class="dashboard-grid">
                <div class="panel">
                    <h3><i class="fas fa-user-clock"></i> Clinical Queue (Today and Upcoming)</h3>
                    <div class="action-list">
                        <% 
                            ClinicalRecordDAO dashDAO = new ClinicalRecordDAO();
                            List<Appointment> dashQueue = dashDAO.getTodayQueue(user.getUserId());
                            
                            if (dashQueue != null && !dashQueue.isEmpty()) {
                                java.util.Date today = new java.util.Date();
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                String todayStr = sdf.format(today);

                                for (Appointment a : dashQueue) { 
                                    String apptDateStr = sdf.format(a.getAppointmentDate());
                                    boolean isToday = todayStr.equals(apptDateStr);
                        %>
                            <div class="queue-item" style="<%= !isToday ? "opacity: 0.8; background: #fcfcfc;" : "" %>">
                                <div>
                                    <small class="text-muted"><%= apptDateStr %> | <%= a.getStartTime() %></small><br>
                                    <%-- FIX: Changed Patient #ID to Patient Name --%>
                                    <strong><%= (a.getPatientName() != null) ? a.getPatientName() : "Patient #" + a.getPatientId() %></strong>
                                </div>
                                <div>
                                    <% if (isToday) { %>
                                        <a href="<%= request.getContextPath() %>/clinical?action=start&id=<%= a.getAppointmentId() %>" 
                                           class="btn-action btn-primary-alt" style="padding: 5px 10px; font-size: 13px;">
                                            Treat Patient
                                        </a>
                                    <% } else { %>
                                        <span class="status-pill" style="background:#fff3cd; color:#856404; border: 1px solid #ffeeba;">UPCOMING</span>
                                    <% } %>
                                </div>
                            </div>
                        <% 
                                }
                            } else { 
                        %>
                            <p style="color:#888; text-align:center; padding: 20px;">No appointments found in your queue.</p>
                        <% } %>
                    </div>
                </div>

                <div class="panel">
                    <h3><i class="fas fa-search"></i> Patient Lookup</h3>
                    <%-- FIX: Action changed to /clinical to trigger the Servlet search --%>
                    <form action="<%= request.getContextPath() %>/clinical" method="GET" style="display:flex; gap:10px; margin-top:15px;">
                        <input type="hidden" name="action" value="searchPatient">
                        <input type="text" name="query" placeholder="Name or IC..." style="flex:1; padding:8px; border:1px solid #ddd; border-radius:4px;">
                        <button type="submit" class="btn-primary-alt" style="padding:8px 15px; border-radius:4px; border: 1px solid #cce5ff; cursor:pointer;">Search</button>
                    </form>

                    <h3 style="margin-top: 30px;"><i class="fas fa-hand-holding-medical"></i> Clinical Tools</h3>
                    <div class="action-list">
					    <a href="<%= request.getContextPath() %>/clinical?action=searchPatient&query=" class="btn-action btn-success-alt">
					        <i class="fas fa-file-medical"></i> Patient Record lookup
					    </a>
					    
					    <a href="<%= request.getContextPath() %>/clinical?action=finalizeList" class="btn-action btn-primary-alt">
					        <i class="fas fa-file-invoice-dollar"></i> Finalize Billing (Today)
					    </a>
					
					    <a href="<%= request.getContextPath() %>/dentist/patient/pricing.jsp" class="btn-action btn-success-alt">
					        <i class="fas fa-tags"></i> Treatment and Pricing List
					    </a>
					</div>
                </div>
                
                <div class="panel">
                    <h3><i class="fas fa-cogs"></i> Leave</h3>
                    <div class="action-list">
						                        
						<!-- Add this inside the main dashboard action/card area for each role -->
						<a href="<%= request.getContextPath() %>/leave/apply.jsp" class="btn-action" style="background: #eafaf1; color: #27ae60; padding: 15px; text-decoration: none; border-radius: 5px;">
						    <i class="fas fa-plane-departure"></i> Apply for Leave
						</a>

                    </div>
                </div>
                
            </div>
        </main>
    </div>
</body>
</html>