<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("dentist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    List<Patient> results = (List<Patient>) request.getAttribute("patientResults");
    String status = request.getParameter("status");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Patient Lookup | Dentist</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .record-card {
            background: #fff; padding: 15px; border-bottom: 1px solid #eee;
            display: flex; justify-content: space-between; align-items: center;
        }
        .btn-action {
            padding: 8px 15px; border-radius: 4px; border: none; cursor: pointer;
            font-size: 13px; font-weight: 600; text-decoration: none;
        }
        .btn-view { background: #3498db; color: white; margin-right: 5px; }
        .btn-profile { background: #95a5a6; color: white; }
        
        /* Modal Styles */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.7); z-index: 1000; justify-content: center; align-items: center;
        }
        .modal-content {
            background: white; padding: 25px; border-radius: 8px; width: 550px; max-width: 95%;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        .profile-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 15px; }
        .profile-row { border-bottom: 1px solid #f0f0f0; padding: 8px 0; }
        .profile-label { font-weight: bold; color: #7f8c8d; font-size: 12px; }
        .profile-value { color: #2c3e50; font-size: 14px; }

        /* Alert Styling */
        .alert-toast {
            color: white; padding: 15px 25px;
            border-radius: 4px; position: fixed; top: 20px; right: 20px;
            z-index: 2000; box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            display: flex; align-items: center; gap: 10px;
            animation: slideIn 0.5s ease-out;
        }
        .toast-success { background: #27ae60; }
        .toast-error { background: #e74c3c; }
        
        @keyframes slideIn { from { transform: translateX(100%); } to { transform: translateX(0); } }
    </style>
</head>
<body class="dashboard-layout">
    
    <% if ("updated".equals(status)) { %>
        <div id="statusToast" class="alert-toast toast-success">
            <i class="fas fa-check-circle"></i>
            <span>Patient clinical notes updated successfully!</span>
        </div>
    <% } else if (error != null) { %>
        <div id="statusToast" class="alert-toast toast-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Error: <%= error %></span>
        </div>
    <% } %>

    <script>
        if(document.getElementById('statusToast')) {
            setTimeout(() => { document.getElementById('statusToast').style.display = 'none'; }, 4000);
        }
    </script>

    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar"><h2><i class="fas fa-search"></i> Patient Record Lookup</h2></div>
            
            <div style="background:white; padding:25px; border-radius:8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                <form action="<%= request.getContextPath() %>/clinical" method="GET" style="display:flex; gap:10px; margin-bottom: 20px;">
                    <input type="hidden" name="action" value="searchPatient">
                    <input type="text" name="query" placeholder="Enter Patient Name or Phone..." 
                           value="<%= (request.getParameter("query") != null && !request.getParameter("query").isEmpty()) ? request.getParameter("query") : "" %>"
                           style="flex:1; padding:10px; border:1px solid #ddd; border-radius:4px;">
                    
                    <select name="sortBy" onchange="this.form.submit()" style="padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                        <option value="name" <%= "name".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Name (A-Z)</option>
                        <option value="name_desc" <%= "name_desc".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Name (Z-A)</option>
                        <option value="id" <%= "id".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Patient ID</option>
                    </select>
                    <button type="submit" class="btn-action" style="background:#007bff; color:white;">Search</button>
                </form>

                <% if (results != null) { %>
                    <div>
                        <% for (Patient p : results) { 
                            String safeNotes = p.getMedicalNotes() != null ? p.getMedicalNotes().replace("'", "\\'").replace("\n", " ") : "";
                            String safeAddr = p.getAddress() != null ? p.getAddress().replace("'", "\\'").replace("\n", " ") : "";
                            String safeEmail = p.getEmail() != null ? p.getEmail().replace("'", "\\'") : "";
                        %>
                            <div class="record-card">
                                <div><strong><%= p.getFullName() %></strong><br><small>ID: <%= p.getPatientId() %> | <%= p.getPhone() %></small></div>
                                <div>
                                    <button class="btn-action btn-profile" onclick="showProfile('<%= p.getPatientId() %>', '<%= p.getFullName() %>', '<%= p.getPhone() %>', '<%= p.getDob() %>', '<%= p.getGender() %>', '<%= safeAddr %>', '<%= safeNotes %>', '<%= p.getStatus() %>', '<%= safeEmail %>')">
                                        <i class="fas fa-user-md"></i> Clinical Profile
                                    </button>
                                    <a href="<%= request.getContextPath() %>/clinical?action=viewHistory&patientId=<%= p.getPatientId() %>" class="btn-action btn-view">
                                        <i class="fas fa-history"></i> History
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </main>
    </div>

    <div id="profileModal" class="modal-overlay">
        <div class="modal-content">
            <h3 style="margin-top:0; color:#2c3e50;"><i class="fas fa-file-medical"></i> Patient Clinical Profile</h3>
            <hr>
            <div class="profile-grid">
                <div class="profile-row"><div class="profile-label">ID</div><div class="profile-value" id="disp-id"></div></div>
                <div class="profile-row"><div class="profile-label">Full Name</div><div class="profile-value" id="disp-name"></div></div>
                <div class="profile-row"><div class="profile-label">Phone</div><div class="profile-value" id="disp-phone"></div></div>
                <div class="profile-row"><div class="profile-label">DOB/Gender</div><div class="profile-value" id="disp-meta"></div></div>
                <div class="profile-row"><div class="profile-label">Email</div><div class="profile-value" id="disp-email"></div></div>
            </div>
            <div class="profile-row" style="border:none;"><div class="profile-label">Address</div><div class="profile-value" id="disp-address"></div></div>
            
            <form action="<%= request.getContextPath() %>/clinical" method="POST" style="margin-top:15px; border-top: 2px solid #eee; padding-top: 15px;">
                <input type="hidden" name="action" value="updateMedicalNotes">
                <input type="hidden" name="patientId" id="p-id-input">

                <label style="font-weight:bold; font-size:13px; color:#e67e22;">Medical Notes (Allergies, Chronic Conditions):</label>
                <textarea name="medicalNotes" id="p-notes-area" rows="5" 
                          style="width:100%; margin-top:5px; padding:10px; border:1px solid #ccc; border-radius:4px; font-family:inherit;"></textarea>
                
                <div style="display:flex; gap:10px; margin-top:15px;">
                    <button type="submit" style="flex:2; background:#27ae60; color:white; border:none; padding:12px; border-radius:4px; cursor:pointer; font-weight:bold;">Save Clinical Updates</button>
                    <button type="button" onclick="closeProfile()" style="flex:1; background:#95a5a6; color:white; border:none; padding:12px; border-radius:4px; cursor:pointer;">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function showProfile(id, name, phone, dob, gender, addr, notes, status, email) {
            document.getElementById('p-id-input').value = id;
            document.getElementById('disp-id').innerText = "#" + id;
            document.getElementById('disp-name').innerText = name;
            document.getElementById('disp-phone').innerText = phone;
            document.getElementById('disp-meta').innerText = gender + " | " + dob;
            document.getElementById('disp-email').innerText = email || "N/A";
            document.getElementById('disp-address').innerText = addr || "N/A";
            document.getElementById('p-notes-area').value = (notes && notes !== 'null' && notes !== 'undefined') ? notes : "";
            document.getElementById('profileModal').style.display = 'flex';
        }
        function closeProfile() { document.getElementById('profileModal').style.display = 'none'; }
        
        window.onclick = function(e) { 
            if(e.target.classList.contains('modal-overlay')) closeProfile(); 
        }
    </script>
</body>
</html>