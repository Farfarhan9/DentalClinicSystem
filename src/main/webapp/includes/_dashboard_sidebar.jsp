<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Patient" %>
<%
    User sidebarUser = (User) session.getAttribute("user");
    Patient sidebarPatient = (Patient) session.getAttribute("patientUser");
    
    String sidebarRole = "guest";
    String displayName = "Guest";
    String displaySub = "";

    if (sidebarUser != null) {
        sidebarRole = sidebarUser.getRole().toLowerCase();
        displayName = sidebarUser.getFullName();
        displaySub = sidebarUser.getRole();
    } else if (sidebarPatient != null) {
        sidebarRole = "patient";
        displayName = sidebarPatient.getFullName();
        displaySub = "Patient";
    }
    
    String sidebarPath = request.getContextPath();
%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<div class="sidebar">
    <div class="sidebar-header">
        <i class="fas fa-clinic-medical"></i> Clinic Manager
    </div>
    
    <div class="user-profile">
        <i class="fas fa-user-circle"></i>
        <% if (!"guest".equals(sidebarRole)) { %>
            <div style="display: flex; flex-direction: column; margin-left: 10px;">
                <span style="font-weight: bold;"><%= displayName %></span> 
                <small style="font-size: 0.8em; opacity: 0.8;">(<%= displaySub %>)</small>
            </div>
        <% } %>
    </div>
    
    <nav class="navigation">
        <%-- DASHBOARD HOME --%>
        <% if ("patient".equals(sidebarRole)) { %>
	        <a href="<%= sidebarPath %>/patient/booking-controller?action=viewDashboard" class="nav-item">
	            <i class="fas fa-home"></i> Dashboard Home
	        </a>
	    <% } else if ("receptionist".equals(sidebarRole)) { %>
	        <%-- For Receptionist, we point to the controller to load the branch appointments --%>
	        <a href="<%= sidebarPath %>/receptionist/appointment-controller?action=viewDashboard" class="nav-item">
	            <i class="fas fa-home"></i> Dashboard Home
	        </a>
	    <% } else { %>
	        <%-- Admin, HR, and Dentist go straight to their JSPs (or update these later if needed) --%>
	        <a href="<%= sidebarPath %>/<%= sidebarRole %>/dashboard.jsp" class="nav-item">
	            <i class="fas fa-home"></i> Dashboard Home
	        </a>
	    <% } %>

        <%-- PATIENT SECTION --%>
        <% if ("patient".equals(sidebarRole)) { %>
            <div class="nav-section-title">MY CARE</div>
            <a href="<%= sidebarPath %>/patient/booking-controller?action=viewAppointments" class="nav-item">
                <i class="fas fa-calendar-alt"></i> Manage Appointments
            </a>
            <a href="<%= sidebarPath %>/patient/booking-controller?action=showBookingPage" class="nav-item">
                <i class="fas fa-calendar-plus"></i> Book Appointments
            </a>
            <div class="nav-section-title">ACCOUNT</div>
            <a href="<%= sidebarPath %>/patient/profile/view.jsp" class="nav-item">
                <i class="fas fa-user-circle"></i> View Profile
            </a>
            <a href="<%= sidebarPath %>/patient/pricing.jsp" class="nav-item">
                <i class="fas fa-tags"></i> Treatments and Prices
            </a>
        <% } %>
        
        <%-- ADMIN SECTION --%>
        <% if ("admin".equals(sidebarRole)) { %>
            <div class="nav-section-title">SYSTEM MANAGEMENT</div>
            <a href="<%= sidebarPath %>/admin/user/list.jsp" class="nav-item">
                <i class="fas fa-users-cog"></i> User Management
            </a>
            <a href="<%= sidebarPath %>/admin/config/branch.jsp" class="nav-item">
                <i class="fas fa-code-branch"></i> Branch Management
            </a>
            <a href="<%= sidebarPath %>/admin/reporting/revenue.jsp" class="nav-item">
                <i class="fas fa-chart-line"></i> Reporting
            </a>
        <% } %>

        <%-- RECEPTIONIST SECTION --%>
        <% if ("receptionist".equals(sidebarRole)) { %>
        <div class="nav-section-title">PATIENT CARE</div>
	        <%-- Redundant Dashboard link REMOVED from here --%>
	        <a href="<%= sidebarPath %>/receptionist/patient/register.jsp" class="nav-item">
	            <i class="fas fa-user-plus"></i> Register Patient
	        </a>
	        <a href="<%= sidebarPath %>/receptionist/patient-controller?action=search&query=" class="nav-item">
	            <i class="fas fa-users"></i> Patient List
	        </a>
	        <a href="<%= sidebarPath %>/receptionist/appointment-controller?action=searchPatient&query=" class="nav-item">
	            <i class="fas fa-calendar-check"></i> Schedule Appt
	        </a>
	        
	        <div class="nav-section-title">FINANCIALS</div>
	        <a href="<%= sidebarPath %>/billing?action=searchPatient&query=" class="nav-item">
	            <i class="fas fa-file-invoice-dollar"></i> Bills and Payments
	        </a>
	        <a href="<%= sidebarPath %>/billing?action=viewDebts" class="nav-item">
	            <i class="fas fa-exclamation-triangle"></i> Debt List
	        </a>
	    <% } %>
        
        <%-- DENTIST SECTION --%>
        <% if ("dentist".equals(sidebarRole)) { %>
            <div class="nav-section-title">CLINICAL OPERATIONS</div>
            <a href="<%= sidebarPath %>/clinical?action=viewQueue" class="nav-item">
                <i class="fas fa-user-clock"></i> My Patient Queue
            </a>
            <div class="nav-section-title">CLINICAL TOOLS</div>
            <a href="<%= sidebarPath %>/clinical?action=searchPatient&query=" class="nav-item">
                <i class="fas fa-search"></i> Patient Record Lookup
            </a>
            <a href="<%= sidebarPath %>/dentist/patient/pricing.jsp" class="nav-item">
                <i class="fas fa-list-ol"></i> Item and Pricing List
            </a>
        <% } %>

        <%-- HR SECTION --%>
        <% if ("hr".equals(sidebarRole)) { %>
            <div class="nav-section-title">STAFF MANAGEMENT</div>
            <a href="<%= sidebarPath %>/hr/employee/records.jsp" class="nav-item">
                <i class="fas fa-user-tie"></i> Employee List
            </a>
 <%--  Not functioning so let it be omment here
           <a href="<%= sidebarPath %>/leave/approve.jsp" class="nav-item">
                <i class="fas fa-envelope-open-text"></i> Leave Requests
            </a>
            <div class="nav-section-title">PAYROLL AND REPORTS</div>
            <a href="<%= sidebarPath %>/hr/dashboard.jsp" class="nav-item">
                <i class="fas fa-money-check-alt"></i> Payroll Summary
            </a>
            <a href="<%= sidebarPath %>/reports/turnover.jsp" class="nav-item">
                <i class="fas fa-file-alt"></i> Turnover Report
            </a> 	--%>
        <% } %>

        <a href="<%= sidebarPath %>/logout" class="nav-item nav-logout" style="margin-top: auto;">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </nav>
</div>