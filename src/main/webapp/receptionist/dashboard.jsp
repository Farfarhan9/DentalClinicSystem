<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User,java.util.*,java.time.LocalDate" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("receptionist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    
    String selectedDate = (String) request.getAttribute("selectedDate");
    List<Map<String, Object>> appts = (List<Map<String, Object>>) request.getAttribute("branchAppointments");

    // Get today's date for validation
    String today = LocalDate.now().toString();

    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "receptionist");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Receptionist Dashboard | Putra DentalCare</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .schedule-container { grid-column: span 2; background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .filter-section { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #f0f0f0; }
        .date-picker-form { display: flex; align-items: center; gap: 10px; }
        .date-input { padding: 8px 12px; border: 1px solid #ddd; border-radius: 6px; font-family: inherit; }
        .status-pill { padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
        .status-scheduled { background: #e3f2fd; color: #1976d2; }
        .status-completed { background: #e8f5e9; color: #2e7d32; }
        .status-cancelled { background: #ffebee; color: #c62828; }
        .status-no-show { background: #f4f4f4; color: #666; } /* Added for DAO support */
        .btn-action { transition: transform 0.2s, box-shadow 0.2s; border: 1px solid transparent; }
        .btn-action:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        
        /* Modal Overlay Styles */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 30px; border-radius: 12px; width: 400px; box-shadow: 0 5px 20px rgba(0,0,0,0.2); }
        .btn-cancel-link { color: #e74c3c; text-decoration: none; font-size: 0.8rem; font-weight: bold; margin-left: 10px; }
        .btn-resched-small { background: #f39c12; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 0.75rem; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-concierge-bell"></i> Welcome, <%= user.getFullName() %></h2>
                <span><i class="fas fa-map-marker-alt"></i> Branch: <%= user.getBranchId() %></span>
            </div>

            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-top: 20px;">
                
                <%-- Success/Error Alerts --%>
                <% if (request.getParameter("msg") != null) { %>
                    <div style="background: #d4edda; color: #155724; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                        <i class="fas fa-check-circle"></i> Action Successful: <%= request.getParameter("msg") %>
                    </div>
                <% } %>
                <% if (request.getAttribute("errorMessage") != null) { %>
                    <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                        <i class="fas fa-exclamation-triangle"></i> <%= request.getAttribute("errorMessage") %>
                    </div>
                <% } %>

                <%-- Appointment Table --%>
                <div class="schedule-container">
                    <div class="filter-section">
                        <h3 style="margin:0;"><i class="fas fa-calendar-day"></i> Appointment Schedule</h3>
                        
                        <form action="<%= request.getContextPath() %>/receptionist/appointment-controller" method="GET" class="date-picker-form">
                            <input type="hidden" name="action" value="viewDashboard">
                            <label for="filterDate" style="font-size: 0.9rem; color: #666;">View Date:</label>
                            <input type="date" id="filterDate" name="filterDate" class="date-input" 
                                   value="<%= (selectedDate != null) ? selectedDate : today %>" 
                                   onchange="this.form.submit()">
                        </form>
                    </div>

                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="text-align: left; color: #888; font-size: 0.85rem; border-bottom: 2px solid #f9f9f9;">
                                <th style="padding: 12px;">TIME</th>
                                <th style="padding: 12px;">PATIENT</th>
                                <th style="padding: 12px;">DENTIST</th>
                                <th style="padding: 12px;">STATUS</th>
                                <th style="padding: 12px;">ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                if (appts != null && !appts.isEmpty()) {
                                    for (Map<String, Object> a : appts) {
                                        String status = a.get("status").toString().toLowerCase();
                                        int apptId = (Integer) a.get("appointmentId");
                            %>
                                <tr style="border-bottom: 1px solid #fcfcfc;">
                                    <td style="padding: 15px; font-weight: bold; color: #333;"><%= a.get("startTime") %></td>
                                    <td style="padding: 15px;"><%= a.get("patientName") %></td>
                                    <td style="padding: 15px; color: #666;">Dr. <%= a.get("dentistName") %></td>
                                    <td style="padding: 15px;">
                                        <span class="status-pill status-<%= status %>"><%= status %></span>
                                    </td>
                                    <td style="padding: 15px;">
                                        <% if (status.equals("scheduled")) { %>
                                            <button class="btn-resched-small" 
                                                onclick="openRescheduleModal('<%= apptId %>', '<%= a.get("patientName") %>', '<%= (selectedDate != null ? selectedDate : today) %>', '<%= a.get("startTime") %>')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <a href="<%= request.getContextPath() %>/receptionist/appointment-controller?action=cancel&appointmentId=<%= apptId %>" 
                                               class="btn-cancel-link" onclick="return confirm('Force cancel this appointment?')">
                                                <i class="fas fa-times"></i> Cancel
                                            </a>
                                        <% } %>
                                    </td>
                                </tr>
                            <% 
                                    }
                                } else { 
                            %>
                                <tr><td colspan="5" style="padding: 40px; text-align: center; color: #999;">No appointments for this date.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <%-- Operations Cards --%>
                <div class="card" style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                    <h3>Patient Operations</h3>
                    <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 15px;">
                        <a href="<%= request.getContextPath() %>/receptionist/patient/register.jsp" class="btn-action" style="background: #ebf5ff; color: #007bff; padding: 15px; text-decoration: none; border-radius: 5px;">
                            <i class="fas fa-user-plus"></i> Register New Patient
                        </a>
                        <a href="<%= request.getContextPath() %>/receptionist/appointment-controller?action=searchPatient&query=" class="btn-action" style="background: #e7f3ed; color: #28a745; padding: 15px; text-decoration: none; border-radius: 5px;">
                            <i class="fas fa-calendar-check"></i> Schedule New Appointment
                        </a>
                        <a href="<%= request.getContextPath() %>/receptionist/patient-controller?action=search&query=" class="btn-action" style="background: #f3e5f5; color: #8e44ad; padding: 15px; text-decoration: none; border-radius: 5px;">
                            <i class="fas fa-users"></i> View Patient List
                        </a>
                    </div>
                </div>

                <div class="card" style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                    <h3>Finance & Leave</h3>
                    <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 15px;">
                        <a href="<%= request.getContextPath() %>/billing?action=searchPatient&query=" class="btn-action" style="background: #fff4e5; color: #ff9800; padding: 15px; text-decoration: none; border-radius: 5px;">
                            <i class="fas fa-file-invoice-dollar"></i> Look up Bills
                        </a>
                        <a href="<%= request.getContextPath() %>/billing?action=viewDebts" class="btn-action" style="background: #fdf2f2; color: #d32f2f; padding: 15px; text-decoration: none; border-radius: 5px;">
                            <i class="fas fa-exclamation-triangle"></i> Debt List
                        </a>
                        <a href="<%= request.getContextPath() %>/leave/apply.jsp" class="btn-action" style="background: #eafaf1; color: #27ae60; padding: 15px; text-decoration: none; border-radius: 5px;">
                            <i class="fas fa-plane-departure"></i> Apply for Leave
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <%-- RESCHEDULE MODAL --%>
    <div id="rescheduleModal" class="modal-overlay">
        <div class="modal-content">
            <h3 style="margin-top:0;">Reschedule Appointment</h3>
            <p id="modalPatientName" style="font-weight: bold; color: #2c3e50; margin-bottom: 5px;"></p>
            <p id="modalCurrentSlot" style="font-size: 0.85rem; color: #666; margin-bottom: 20px;"></p>
            
            <form action="<%= request.getContextPath() %>/receptionist/appointment-controller" method="POST" onsubmit="return validateReschedule(this)">
                <input type="hidden" name="action" value="reschedule">
                <input type="hidden" name="appointmentId" id="modalApptId">
                
                <div style="margin-bottom: 15px;">
                    <label style="display:block; font-size: 0.85rem; margin-bottom: 5px;">New Date</label>
                    <input type="date" name="newDate" id="reschDate" required min="<%= today %>" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                </div>
                
                <div style="margin-bottom: 20px;">
                    <label style="display:block; font-size: 0.85rem; margin-bottom: 5px;">New Time</label>
                    <input type="time" name="newTime" id="reschTime" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                </div>
                
                <div style="display: flex; gap: 10px;">
                    <button type="submit" style="flex: 2; background: #27ae60; color: white; border: none; padding: 12px; border-radius: 6px; cursor: pointer; font-weight: bold;">Confirm Change</button>
                    <button type="button" onclick="closeModal()" style="flex: 1; background: #eee; border: none; padding: 12px; border-radius: 6px; cursor: pointer;">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openRescheduleModal(id, patient, date, time) {
            document.getElementById('modalApptId').value = id;
            document.getElementById('modalPatientName').innerText = "Patient: " + patient;
            document.getElementById('modalCurrentSlot').innerText = "Current: " + date + " @ " + time;
            document.getElementById('rescheduleModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('rescheduleModal').style.display = 'none';
        }

        function validateReschedule(form) {
            const dateVal = form.newDate.value;
            const timeVal = form.newTime.value;
            const selectedDateTime = new Date(dateVal + 'T' + timeVal);
            const now = new Date();

            if (selectedDateTime < now) {
                alert("Error: You cannot reschedule an appointment to a time that has already passed.");
                return false;
            }
            return true;
        }

        window.onclick = function(event) {
            if (event.target == document.getElementById('rescheduleModal')) closeModal();
        }
    </script>
</body>
</html>