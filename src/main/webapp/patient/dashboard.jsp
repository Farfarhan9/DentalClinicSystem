<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.Patient, java.util.*" %>
<% 
    Patient patient = (Patient) session.getAttribute("patientUser");
    if (patient == null) {
        response.sendRedirect(request.getContextPath() + "/patient_login.jsp?error=unauthorized");
        return;
    }
    
    List<Map<String, Object>> myAppts = (List<Map<String, Object>>) request.getAttribute("myAppointments");
    String msg = request.getParameter("msg");
    String error = (String) request.getAttribute("errorMessage");
    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Patient Dashboard - Putra DentalCare</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 25px; margin-top: 20px; }
        .panel { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 4px solid #2c3e50; }
        .panel h3 { color: #2c3e50; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        .schedule-panel { grid-column: 1 / -1; }
        .appt-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .appt-table th { text-align: left; padding: 12px; color: #7f8c8d; font-size: 0.85rem; border-bottom: 2px solid #f4f7f6; }
        .appt-table td { padding: 15px 12px; border-bottom: 1px solid #f4f7f6; font-size: 0.95rem; }
        .status-badge { padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
        .status-scheduled { background: #e3f2fd; color: #1976d2; }
        .status-completed { background: #e8f5e9; color: #2e7d32; }
        .status-cancelled { background: #fdeaea; color: #c0392b; }
        .status-no-show { background: #fef5e7; color: #d35400; }
        .action-list { display: flex; flex-direction: column; gap: 12px; }
        .btn-action { padding: 15px; border-radius: 8px; text-decoration: none; font-weight: 500; display: flex; align-items: center; gap: 12px; transition: all 0.3s ease; background: #f8fbff; color: #2c3e50; border: 1px solid #e1e8f0; }
        .btn-action:hover { background: #2c3e50; color: white; transform: translateY(-2px); }
        .btn-mini { padding: 5px 10px; border-radius: 4px; font-size: 0.8rem; cursor: pointer; border: none; transition: 0.2s; }
        .btn-resched { background: #f39c12; color: white; }
        .btn-cancel { background: #e74c3c; color: white; text-decoration: none; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 1000; justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 30px; border-radius: 12px; width: 400px; box-shadow: 0 5px 20px rgba(0,0,0,0.2); }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="welcome-header">
                <h1>Welcome, <%= patient.getFullName() %></h1>
                <p>Your oral health journey at Putra DentalCare starts here.</p>
            </div>

            <%-- Success/Error Alerts --%>
            <% if (msg != null) { %>
                <div style="background: #d4edda; color: #155724; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
                    <i class="fas fa-check-circle"></i> Action successful! Your appointment has been <%= msg %>.
                </div>
            <% } %>
            <% if (error != null) { %>
                <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
                    <i class="fas fa-exclamation-triangle"></i> <%= error %>
                </div>
            <% } %>

            <div class="dashboard-grid">
                <%-- MAIN SCHEDULE PANEL --%>
                <div class="panel schedule-panel">
                    <h3><i class="fas fa-calendar-check"></i> Your Upcoming Appointments</h3>
                    <table class="appt-table">
                        <thead>
                            <tr>
                                <th>DATE AND TIME</th>
                                <th>DENTIST / BRANCH</th>
                                <th>TREATMENT/NOTES</th>
                                <th>STATUS</th>
                                <th>ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                if (myAppts != null && !myAppts.isEmpty()) {
                                    for (Map<String, Object> a : myAppts) {
                                        String status = a.get("status").toString().toLowerCase();
                                        int id = (Integer) a.get("appointmentId");
                            %>
                                <tr>
                                    <td style="font-weight: 600;"><%= a.get("date") %> <br> <small style="color:#7f8c8d;"><%= a.get("startTime") %></small></td>
                                    <td>Dr. <%= a.get("dentistName") %><br><small><%= a.get("branchName") %></small></td>
                                    <td style="color: #666; font-size: 0.85rem;"><%= a.get("notes") %></td>
                                    <td><span class="status-badge status-<%= status %>"><%= status %></span></td>
                                    <td>
                                        <% if (status.equals("scheduled")) { %>
                                            <button class="btn-mini btn-resched" onclick="openRescheduleModal('<%= id %>', '<%= a.get("date") %>', '<%= a.get("startTime") %>')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <a href="<%= request.getContextPath() %>/patient/booking-controller?action=cancel&appointmentId=<%= id %>" 
                                               class="btn-mini btn-cancel" onclick="return confirm('Cancel this appointment? (Minimum 48h notice required)')">
                                                <i class="fas fa-times"></i>
                                            </a>
                                        <% } %>
                                    </td>
                                </tr>
                            <% 
                                    }
                                } else { 
                            %>
                                <tr><td colspan="5" style="padding: 40px; text-align: center; color: #bdc3c7;">No scheduled appointments found.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <%-- APPOINTMENT MANAGEMENT --%>
                <div class="panel">
                    <h3><i class="fas fa-calendar-alt"></i> Appointment Management</h3>
                    <div class="action-list">
                        <a href="<%= request.getContextPath() %>/patient/booking-controller?action=showBookingPage" class="btn-action">
                            <i class="fas fa-calendar-plus"></i> Book New Appointment
                        </a>
                        <a href="<%= request.getContextPath() %>/patient/booking-controller?action=viewAppointments" class="btn-action">
                            <i class="fas fa-history"></i> View Appointment History
                        </a>
                    </div>
                </div>

                <div class="panel">
                    <h3><i class="fas fa-user-circle"></i> Profile Management</h3>
                    <div class="action-list">
                        <a href="<%= request.getContextPath() %>/patient/profile/view.jsp" class="btn-action">
                            <i class="fas fa-id-card"></i> View Profile
                        </a>
                    </div>
                </div>

                <div class="panel">
                    <h3><i class="fas fa-tooth"></i> Treatment and Price</h3>
                    <div class="action-list">
                        <a href="<%= request.getContextPath() %>/patient/pricing.jsp" class="btn-action">
                            <i class="fas fa-money-bill-wave"></i> View Pricing
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <%-- RESCHEDULE MODAL --%>
    <div id="rescheduleModal" class="modal-overlay">
        <div class="modal-content">
            <h3 style="margin-top:0;"><i class="fas fa-clock"></i> Reschedule</h3>
            <p style="font-size: 0.9rem; color: #666;">Select a new date and time. (Must be 48h in advance)</p>
            <form action="<%= request.getContextPath() %>/patient/booking-controller" method="POST">
                <input type="hidden" name="action" value="reschedule">
                <input type="hidden" name="appointmentId" id="modalApptId">
                
                <div style="margin-bottom: 15px;">
                    <label style="display:block; font-size: 0.85rem; margin-bottom:5px;">New Date</label>
                    <input type="date" name="newDate" id="modalDate" required min="<%= today %>" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:5px;">
                </div>
                <div style="margin-bottom: 20px;">
                    <label style="display:block; font-size: 0.85rem; margin-bottom:5px;">New Time</label>
                    <input type="time" name="newTime" id="modalTime" required style="width:100%; padding:10px; border:1px solid #ddd; border-radius:5px;">
                </div>
                
                <div style="display:flex; gap:10px;">
                    <button type="submit" style="flex:2; background:#27ae60; color:white; border:none; padding:12px; border-radius:6px; font-weight:bold; cursor:pointer;">Update Slot</button>
                    <button type="button" onclick="closeModal()" style="flex:1; background:#eee; border:none; padding:12px; border-radius:6px; cursor:pointer;">Close</button>
                </div>
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
        window.onclick = function(event) {
            if (event.target == document.getElementById('rescheduleModal')) closeModal();
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