<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.Patient, com.dentalclinic.models.User, com.dentalclinic.models.Branch, java.util.List" %>
<%
    Patient patient = (Patient) session.getAttribute("patientUser");
    if (patient == null) {
        response.sendRedirect(request.getContextPath() + "/patient_login.jsp?error=unauthorized");
        return;
    }

    // Get lists and selections from request attributes (Populated by PatientBookingServlet)
    List<Branch> branches = (List<Branch>) request.getAttribute("branches");
    List<User> dentists = (List<User>) request.getAttribute("availableDentists");
    
    Integer selBranchId = (Integer) request.getAttribute("selectedBranch");
    String selDate = (String) request.getAttribute("selectedDate");
    String selTime = (String) request.getAttribute("selectedTime");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Formatting today's date for the 'min' attribute to prevent past dates
    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Book Appointment | Putra DentalCare</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .booking-card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); max-width: 800px; margin: 20px auto; }
        .form-header { border-bottom: 1px solid #eee; margin-bottom: 25px; padding-bottom: 10px; color: #2c3e50; }
        .booking-form { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .full-width { grid-column: span 2; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #34495e; font-size: 0.9rem; }
        .form-group input, .form-group select, .form-group textarea { 
            width: 100%; padding: 12px; border: 1px solid #dce4ec; border-radius: 8px; font-size: 1rem;
        }
        .btn-check { background: #3498db; color: white; border: none; padding: 10px; border-radius: 8px; cursor: pointer; width: 100%; font-weight: bold; }
        .btn-confirm { 
            grid-column: span 2; background: #27ae60; color: white; border: none; padding: 15px; 
            border-radius: 8px; font-size: 1.1rem; font-weight: bold; cursor: pointer; margin-top: 10px;
        }
        .btn-confirm:disabled { background: #bdc3c7; cursor: not-allowed; }
        .error-alert { background: #fff5f5; border-left: 5px solid #e53e3e; color: #c53030; padding: 15px; border-radius: 6px; margin-bottom: 20px; display: flex; align-items: center; gap: 12px; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="booking-card">
                <div class="form-header">
                    <h2><i class="fas fa-calendar-check"></i> Schedule Your Visit</h2>
                    <p>Step 1: Select Location and Time. Step 2: Choose your Doctor.</p>
                </div>

                <% if (errorMessage != null) { %>
                    <div class="error-alert">
                        <i class="fas fa-exclamation-circle fa-lg"></i>
                        <div><strong>Error:</strong> <%= errorMessage %></div>
                    </div>
                <% } %>

                <%-- STEP 1: CHECK AVAILABILITY --%>
                <form action="${pageContext.request.contextPath}/patient/booking-controller" method="GET" class="booking-form">
                    <input type="hidden" name="action" value="getAvailable">
                    
                    <div class="form-group full-width">
                        <label>Select Clinic Branch</label>
                        <select name="branchId" required>
                            <option value="">-- Choose a Branch --</option>
                            <% if (branches != null) { 
                                for (Branch b : branches) { %>
                                    <option value="<%= b.getBranchId() %>" <%= (selBranchId != null && selBranchId == b.getBranchId()) ? "selected" : "" %>>
                                        <%= b.getBranchName() %> - <%= b.getAddress() %>
                                    </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Appointment Date</label>
                        <%-- Block past dates using the 'min' attribute --%>
                        <input type="date" name="date" required value="<%= selDate != null ? selDate : "" %>" 
                               min="<%= today %>">
                    </div>

                    <div class="form-group">
                        <label>Preferred Time</label>
                        <input type="time" name="time" required value="<%= selTime != null ? selTime : "" %>">
                    </div>

                    <div class="full-width">
                        <button type="submit" class="btn-check"><i class="fas fa-search"></i> Check Available Doctors</button>
                    </div>
                </form>

                <hr style="margin: 30px 0; border: 0; border-top: 1px solid #eee;">

                <%-- STEP 2: ACTUAL BOOKING --%>
                <form action="${pageContext.request.contextPath}/patient/booking-controller" method="POST" class="booking-form">
                    <input type="hidden" name="branchId" value="<%= selBranchId %>">
                    <input type="hidden" name="appointmentDate" value="<%= selDate %>">
                    <input type="hidden" name="startTime" value="<%= selTime %>">

                    <div class="form-group full-width">
                        <label>Available Dentists</label>
                        <select name="dentistId" required <%= (dentists == null) ? "disabled" : "" %>>
                            <% if (dentists == null) { %>
                                <option value="">Please check availability above first...</option>
                            <% } else if (dentists.isEmpty()) { %>
                                <option value="">No doctors available for this selection.</option>
                            <% } else { %>
                                <option value="">-- Select a Doctor --</option>
                                <% for(User d : dentists) { %>
                                    <option value="<%= d.getUserId() %>">Dr. <%= d.getFullName() %></option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Reason for Visit</label>
                        <select name="notes_prefix" required>
                            <option value="General Checkup">General Checkup</option>
                            <option value="Toothache/Emergency">Toothache/Emergency</option>
                            <option value="Scaling & Polishing">Scaling and Polishing</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Additional Notes</label>
                        <textarea name="notes" rows="1" placeholder="Optional..."></textarea>
                    </div>

                    <button type="submit" class="btn-confirm" <%= (dentists == null || dentists.isEmpty()) ? "disabled" : "" %>>
                        <i class="fas fa-check-circle"></i> Confirm Booking
                    </button>
                </form>
            </div>
        </main>
    </div>
</body>
</html>