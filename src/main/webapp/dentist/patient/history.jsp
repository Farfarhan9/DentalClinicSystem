<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    List<TreatmentRecord> history = (List<TreatmentRecord>) request.getAttribute("history");
    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "dentist");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<%@ include file="/includes/_dashboard_style.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Clinical History | Dentist</title>
    <style>
        .history-card { border-left: 4px solid #8e44ad; padding: 15px; margin-bottom: 20px; background: #fff; border-radius: 0 8px 8px 0; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .history-date { font-weight: bold; color: #8e44ad; font-size: 0.9rem; }
        .dentist-tag { font-size: 0.8rem; color: #7f8c8d; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-history"></i> Clinical History: Patient #<%= request.getAttribute("patientId") %></h2>
                <a href="<%= request.getContextPath() %>/clinical?action=searchPatient&query=" class="btn-primary-alt">Back to Search</a>
            </div>

            <div class="panel">
                <% if (history != null && !history.isEmpty()) { 
                    for (TreatmentRecord tr : history) { %>
                    <div class="history-card">
                        <div class="history-date"><%= tr.getAppointmentDate() %></div>
                        <div class="dentist-tag">Treated by: Dr. <%= tr.getDentistName() %></div>
                        <hr style="margin: 10px 0; border: 0; border-top: 1px solid #eee;">
                        <p><strong>Diagnosis:</strong> <%= tr.getDiagnosis() %></p>
                        <p><strong>Treatment:</strong> <%= tr.getTreatmentNotes() %></p>
                    </div>
                <% } } else { %>
                    <p style="text-align:center; padding:40px; color:#999;">No previous treatment records found for this patient.</p>
                <% } %>
            </div>
        </main>
    </div>
</body>
</html>