<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.Patient, java.util.*" %>
<%
    Patient patient = (Patient) session.getAttribute("patientUser");
    if (patient == null) {
        response.sendRedirect(request.getContextPath() + "/patient_login.jsp?error=unauthorized");
        return;
    }

    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("myAppointments");
    
    // Redirect to controller if data is missing
    if (appointments == null) {
        response.sendRedirect(request.getContextPath() + "/patient/booking-controller?action=viewAppointments");
        return;
    }

    String errorMsg = (String) request.getAttribute("errorMessage");
    String msg = request.getParameter("msg");
    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Appointments | Putra DentalCare</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .report-card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: bold; text-transform: uppercase; }
        .status-scheduled { background: #e3f2fd; color: #1976d2; border: 1px solid #bbdefb; }
        .status-completed { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }
        .status-cancelled { background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; }
        .appt-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .appt-table th, .appt-table td { text-align: left; padding: 12px; border-bottom: 1px solid #eee; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 30px; border-radius: 12px; width: 400px; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            
            <% if (msg != null) { %>
                <div style="background: #d1fae5; color: #065f46; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #a7f3d0;">
                    <i class="fas fa-check-circle"></i> Appointment successfully <%= msg %>!
                </div>
            <% } %>
            <% if (errorMsg != null) { %>
                <div style="background: #fee2e2; color: #b91c1c; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                    <i class="fas fa-exclamation-triangle"></i> <%= errorMsg %>
                </div>
            <% } %>

            <div class="header-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2><i class="fas fa-calendar-alt"></i> My Appointment History</h2>
                <a href="<%= request.getContextPath() %>/patient/booking-controller?action=showBookingPage" class="btn-book" style="background: #2c3e50; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none;">Book New</a>
            </div>

            <div class="report-card">
                <table class="appt-table">
                    <thead>
                        <tr>
                            <th>Date & Time</th>
                            <th>Doctor & Location</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> appt : appointments) { 
                            String status = (String) appt.get("status");
                            int id = (Integer) appt.get("appointmentId");
                        %>
                            <tr>
                                <td><strong><%= appt.get("date") %></strong><br><small><%= appt.get("startTime") %></small></td>
                                <td>Dr. <%= appt.get("dentistName") %><br><small><%= appt.get("branchName") %></small></td>
                                <td><span class="status-badge status-<%= status.toLowerCase() %>"><%= status %></span></td>
                                <td>
                                    <% if ("scheduled".equalsIgnoreCase(status)) { %>
                                        <button class="btn-reschedule" style="background:#f39c12; color:white; border:none; padding:5px 10px; border-radius:4px; cursor:pointer;"
                                                onclick="openRescheduleModal('<%= id %>', '<%= appt.get("date") %>', '<%= appt.get("startTime") %>')">
                                            Reschedule
                                        </button>
                                        <a href="<%= request.getContextPath() %>/patient/booking-controller?action=cancel&appointmentId=<%= id %>" 
                                           style="color:#e74c3c; margin-left:10px; font-weight:bold; text-decoration:none;"
                                           onclick="return confirm('Cancel this appointment? (48h notice required)')">Cancel</a>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <div id="rescheduleModal" class="modal-overlay">
        <div class="modal-content">
            <h3>Reschedule Appointment</h3>
            <form action="<%= request.getContextPath() %>/patient/booking-controller" method="POST">
                <input type="hidden" name="action" value="reschedule">
                <input type="hidden" name="appointmentId" id="modalApptId">
                <div style="margin-top:15px;">
                    <label>New Date</label>
                    <input type="date" name="newDate" id="modalDate" required min="<%= today %>" style="width:100%; padding:8px;">
                </div>
                <div style="margin-top:15px; margin-bottom:20px;">
                    <label>New Time</label>
                    <input type="time" name="newTime" id="modalTime" required style="width:100%; padding:8px;">
                </div>
                <button type="submit" style="width:100%; background:#27ae60; color:white; border:none; padding:10px; border-radius:4px;">Update Appointment</button>
                <button type="button" onclick="closeModal()" style="width:100%; background:#eee; margin-top:10px; border:none; padding:10px;">Close</button>
            </form>
        </div>
    </div>

    <script>
        function openRescheduleModal(id, date, time) {
            document.getElementById('modalApptId').value = id;
            document.getElementById('modalDate').value = date;
            document.getElementById('modalTime').value = time;
            document.getElementById('rescheduleModal').style.display = 'flex';
        }
        function closeModal() {
            document.getElementById('rescheduleModal').style.display = 'none';
        }
        
        document.getElementById('modalDate').addEventListener('change', function() {
            const selectedDate = this.value;
            const today = new Date().toISOString().split('T')[0];
            const timeInput = document.getElementById('modalTime');
            
            if (selectedDate === today) {
                const now = new Date();
                const currentTime = now.getHours().toString().padStart(2, '0') + ":" + 
                                    now.getMinutes().toString().padStart(2, '0');
                timeInput.min = currentTime;
            } else {
                timeInput.removeAttribute('min');
            }
        });
    </script>
</body>
</html>