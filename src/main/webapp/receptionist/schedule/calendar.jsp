<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.*, java.util.List, java.time.LocalDate" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("receptionist")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
        return;
    }
    
    String retainedId = (request.getAttribute("retainedPatientId") != null) ? request.getAttribute("retainedPatientId").toString() : "";
    String selDate = (request.getAttribute("selectedDate") != null) ? (String)request.getAttribute("selectedDate") : "";
    String selTime = (request.getAttribute("selectedTime") != null) ? (String)request.getAttribute("selectedTime") : "";
    String selBranch = (request.getAttribute("selectedBranch") != null) ? (String)request.getAttribute("selectedBranch") : String.valueOf(user.getBranchId());
    
    // Get current date for the 'min' attribute
    String today = LocalDate.now().toString();
    
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Schedule Appointment | Receptionist</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .conflict-alert { background: #fff5f5; color: #c53030; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 5px solid #e53e3e; display: flex; align-items: center; gap: 10px; }
        .step-box { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; position: relative; }
        .search-area { background: #f0f7ff; border: 1px dashed #3498db; padding: 20px; border-radius: 8px; margin-bottom: 25px; display: <%= (request.getAttribute("patientResults") != null) ? "block" : "none" %>; }
        .close-search-btn { position: absolute; top: 10px; right: 10px; background: none; border: none; font-size: 1.2rem; cursor: pointer; color: #7f8c8d; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="conflict-alert">
                    <i class="fas fa-exclamation-circle fa-lg"></i>
                    <div><strong>Action Required:</strong> <%= request.getAttribute("errorMessage") %></div>
                </div>
            <% } %>

            <div class="header-bar" style="display: flex; justify-content: space-between; align-items: center;">
                <h2><i class="fas fa-calendar-plus"></i> Schedule New Appointment</h2>
                <button type="button" onclick="toggleSearch()" class="btn-secondary" style="background: #3498db; color: white; padding: 8px 15px; border-radius: 5px; border: none; cursor: pointer;">
                    <i class="fas fa-search"></i> Find Patient
                </button>
            </div>

            <div id="patientSearchSection" class="search-area">
                <button type="button" class="close-search-btn" onclick="toggleSearch()">&times;</button>
                <h3>1. Find Patient</h3>
                <form action="${pageContext.request.contextPath}/receptionist/appointment-controller" method="GET" style="display: flex; gap: 10px;">
                    <input type="hidden" name="action" value="searchPatient">
                    <input type="text" name="query" placeholder="Name or Phone..." value="<%= request.getParameter("query") != null ? request.getParameter("query") : "" %>" style="flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                    <button type="submit" style="background: #3498db; color: white; border: none; padding: 0 20px; border-radius: 4px; cursor: pointer;">Search</button>
                </form>
            
                <% List<Patient> results = (List<Patient>) request.getAttribute("patientResults");
                   if (results != null) { %>
                    <div style="margin-top: 15px; background: white; border: 1px solid #ddd; border-radius: 4px; max-height: 200px; overflow-y: auto;">
                        <% for(Patient p : results) { %>
                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 10px; border-bottom: 1px solid #eee;">
                                <span><strong><%= p.getFullName() %></strong> <small>(ID: <%= p.getPatientId() %>)</small></span>
                                <button type="button" class="patient-select-btn" onclick="selectPatient('<%= p.getPatientId() %>', '<%= p.getFullName() %>', this)" style="background: #2ecc71; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">Select</button>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <div class="step-box">
                <h3>2. Check Availability</h3>
                <form action="${pageContext.request.contextPath}/receptionist/appointment-controller" method="GET" onsubmit="return validateDateTime(this)" style="display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 15px;">
                    <input type="hidden" name="action" value="getAvailable">
                    <input type="hidden" name="patientId" id="hiddenPatientId" value="<%= retainedId %>">
                    
                    <div class="form-group">
                        <label>Branch</label>
                        <select name="branchId" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                            <% List<Branch> branches = (List<Branch>) request.getAttribute("branchList");
                               if(branches != null) { 
                                   for(Branch b : branches) { %>
                                    <option value="<%= b.getBranchId() %>" <%= selBranch.equals(String.valueOf(b.getBranchId())) ? "selected" : "" %>><%= b.getBranchName() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" name="date" id="inputDate" required min="<%= today %>" value="<%= selDate %>" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                    </div>
                    <div class="form-group">
                        <label>Time</label>
                        <input type="time" name="time" id="inputTime" required value="<%= selTime %>" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                    </div>
                    <div class="form-group">
                        <label>&nbsp;</label>
                        <button type="submit" style="width: 100%; background: #3498db; color: white; border: none; padding: 10px; border-radius: 4px; cursor: pointer;">Check</button>
                    </div>
                </form>
            </div>

            <div class="step-box">
                <h3>3. Confirm Booking</h3>
                <form action="${pageContext.request.contextPath}/receptionist/appointment-controller" method="POST">
                    <input type="hidden" name="patientId" id="targetPatientId" value="<%= retainedId %>">
                    <input type="hidden" name="branchId" value="<%= selBranch %>">
                    <input type="hidden" name="appointmentDate" value="<%= selDate %>">
                    <input type="hidden" name="startTime" value="<%= selTime %>">

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div class="form-group">
                            <label>Selected Patient</label>
                            <input type="text" id="displayPatientName" readonly value="<%= retainedId.isEmpty() ? "None Selected" : "ID: " + retainedId %>" style="width: 100%; padding: 10px; background: #f4f4f4; border: 1px solid #ddd; border-radius: 4px;">
                        </div>
                        <div class="form-group">
                            <label>Available Dentists</label>
                            <select name="dentistId" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                                <% List<User> available = (List<User>) request.getAttribute("availableDentists");
                                   if (available != null && !available.isEmpty()) { %>
                                    <option value="">-- Select Doctor --</option>
                                    <% for(User d : available) { %>
                                        <option value="<%= d.getUserId() %>">Dr. <%= d.getFullName() %></option>
                                    <% } %>
                                <% } else { %>
                                    <option value="">Run "Check" first</option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <div style="margin-top: 15px;">
                        <label>Notes</label>
                        <textarea name="notes" placeholder="Reason for visit..." style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; height: 80px;"></textarea>
                    </div>
                    <button type="submit" id="bookBtn" <%= (available == null || available.isEmpty() || retainedId.isEmpty()) ? "disabled" : "" %> 
                            style="margin-top: 20px; width: 100%; background: #27ae60; color: white; border: none; padding: 15px; border-radius: 5px; font-weight: bold; cursor: pointer;">
                        Book Appointment
                    </button>
                </form>
            </div>
        </main>
    </div>

    <script>
    function toggleSearch() {
        const section = document.getElementById('patientSearchSection');
        section.style.display = (section.style.display === 'none' || section.style.display === '') ? 'block' : 'none';
    }

    function validateDateTime(form) {
        const dateVal = document.getElementById('inputDate').value; // yyyy-mm-dd
        const timeVal = document.getElementById('inputTime').value; // hh:mm
        
        if(!dateVal || !timeVal) return true; // Let HTML5 validation catch empty fields

        const selectedDateTime = new Date(dateVal + 'T' + timeVal);
        const now = new Date();

        if (selectedDateTime < now) {
            alert("Error: You cannot select a date or time that has already passed.");
            return false; // Prevents form from submitting to the Servlet
        }
        return true;
    }

    function selectPatient(id, name, btn) {
        document.getElementById('targetPatientId').value = id;
        document.getElementById('hiddenPatientId').value = id;
        document.getElementById('displayPatientName').value = id + " - " + name;
        
        // Update visual style
        document.querySelectorAll('.patient-select-btn').forEach(b => {
            b.innerText = "Select";
            b.style.background = "#2ecc71";
        });
        btn.innerText = "Selected";
        btn.style.background = "#27ae60";
        
        // Enable book button if we have all data
        checkBookButtonState();
    }

    // Function to manage button state
    function checkBookButtonState() {
        const patientId = document.getElementById('targetPatientId').value;
        const bookBtn = document.getElementById('bookBtn');
        if (patientId && patientId !== "") {
            bookBtn.disabled = false;
            bookBtn.style.opacity = "1";
            bookBtn.style.cursor = "pointer";
        }
    }
    </script>
</body>
</html>