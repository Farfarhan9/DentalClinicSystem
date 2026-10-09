<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.Patient, java.text.SimpleDateFormat" %>
<%
    Patient patient = (Patient) session.getAttribute("patientUser");
    if (patient == null) {
        response.sendRedirect(request.getContextPath() + "/patient_login.jsp");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String dobStr = (patient.getDob() != null) ? sdf.format(patient.getDob()) : "";
    
    String status = request.getParameter("status");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Profile | Putra DentalCare</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .profile-card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); max-width: 800px; margin: 0 auto 20px auto; }
        .info-row { display: grid; grid-template-columns: 180px 1fr; padding: 15px 0; border-bottom: 1px solid #f5f5f5; }
        .info-label { font-weight: bold; color: #7f8c8d; }
        .info-value { color: #2c3e50; }
        .edit-section { display: none; margin-top: 20px; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; color: #34495e; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; }
        .full-width { grid-column: span 2; }
        .btn-action { padding: 10px 20px; border-radius: 6px; cursor: pointer; border: none; font-weight: bold; transition: 0.3s; }
        .btn-edit { background: #3498db; color: white; }
        .btn-save { background: #27ae60; color: white; margin-top: 20px; }
        .alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; max-width: 800px; margin-left: auto; margin-right: auto; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-id-card"></i> My Profile</h2>
                <button class="btn-action btn-edit" id="toggleBtn" onclick="toggleEdit()">
                    <i class="fas fa-user-edit"></i> Edit Profile
                </button>
            </div>

            <% if ("updated".equals(status)) { %>
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> Profile updated successfully!</div>
            <% } else if ("pwd_success".equals(status)) { %>
                <div class="alert alert-success"><i class="fas fa-shield-alt"></i> Password updated successfully!</div>
            <% } %>

            <% if (error != null) { %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> 
                    <%= "wrong_current".equals(error) ? "Current password is incorrect." : 
                        "mismatch".equals(error) ? "New passwords do not match." : "An error occurred. Please try again." %>
                </div>
            <% } %>
            
            <% if (error != null) { %>
			    <div class="alert alert-error">
			        <i class="fas fa-exclamation-circle"></i> 
			        <% 
			           if("wrong_current".equals(error)) out.print("Current password is incorrect.");
			           else if("mismatch".equals(error)) out.print("New passwords do not match.");
			           else if("system_error".equals(error)) out.print("Session error. Please logout and login again.");
			           else out.print("An error occurred. Please try again.");
			        %>
			    </div>
			<% } %>

            <div class="profile-card">
                <div id="viewMode">
                    <div class="info-row"><span class="info-label">Full Name</span><span class="info-value"><%= patient.getFullName() %></span></div>
                    <div class="info-row"><span class="info-label">Phone Number</span><span class="info-value"><%= patient.getPhone() %></span></div>
                    <div class="info-row"><span class="info-label">Email Address</span><span class="info-value"><%= patient.getEmail() %></span></div>
                    <div class="info-row"><span class="info-label">Date of Birth</span><span class="info-value"><%= dobStr.isEmpty() ? "Not specified" : dobStr %></span></div>
                    <div class="info-row"><span class="info-label">Gender</span><span class="info-value" style="text-transform: capitalize;"><%= patient.getGender() %></span></div>
                    <div class="info-row"><span class="info-label">Medical History</span><span class="info-value"><%= patient.getMedicalNotes() != null ? patient.getMedicalNotes() : "No medical notes on file." %></span></div>
                    <div class="info-row" style="border-bottom: none;"><span class="info-label">Address</span><span class="info-value"><%= patient.getAddress() != null ? patient.getAddress() : "No address provided" %></span></div>
                </div>

                <div id="editMode" class="edit-section">
                    <form action="${pageContext.request.contextPath}/patient/profile-controller" method="POST">
                        <div class="form-grid">
                            <div class="form-group"><label>Full Name</label><input type="text" name="fullName" value="<%= patient.getFullName() %>" required></div>
                            <div class="form-group"><label>Phone Number</label><input type="text" name="phone" value="<%= patient.getPhone() %>" required></div>
                            <div class="form-group"><label>Email Address</label><input type="email" name="email" value="<%= patient.getEmail() %>" required></div>
                            <div class="form-group">
                                <label>Gender</label>
                                <select name="gender">
                                    <option value="Male" <%= "Male".equalsIgnoreCase(patient.getGender()) ? "selected" : "" %>>Male</option>
                                    <option value="Female" <%= "Female".equalsIgnoreCase(patient.getGender()) ? "selected" : "" %>>Female</option>
                                    <option value="Other" <%= "Other".equalsIgnoreCase(patient.getGender()) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>
                            <div class="form-group"><label>Date of Birth</label><input type="date" name="dob" value="<%= dobStr %>"></div>
                            <div class="form-group full-width">
							    <label>Medical Notes / Allergies</label>
							    <textarea name="medicalNotes" rows="3"><%= patient.getMedicalNotes() != null ? patient.getMedicalNotes() : "" %></textarea>
							</div>
                            <div class="form-group full-width"><label>Home Address</label><textarea name="address" rows="3"><%= patient.getAddress() != null ? patient.getAddress() : "" %></textarea></div>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <button type="submit" class="btn-action btn-save">Update Profile</button>
                            <button type="button" class="btn-action btn-save" style="background:#95a5a6;" onclick="toggleEdit()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="profile-card">
                <h3><i class="fas fa-key"></i> Security Settings</h3>
               <form action="<%= request.getContextPath() %>/patient/change-password" method="POST">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Current Password</label>
                            <input type="password" name="currentPassword" required>
                        </div>
                        <div class="form-group"></div>
                        <div class="form-group">
                            <label>New Password</label>
                            <input type="password" name="newPassword" required>
                        </div>
                        <div class="form-group">
                            <label>Confirm New Password</label>
                            <input type="password" name="confirmPassword" required>
                        </div>
                    </div>
                    <button type="submit" class="btn-action" style="background:#e67e22; color:white; margin-top:15px;">
                        Change Password
                    </button>
                </form>
            </div>
        </main>
    </div>

    <script>
        function toggleEdit() {
            const view = document.getElementById('viewMode');
            const edit = document.getElementById('editMode');
            const btn = document.getElementById('toggleBtn');
            if (view.style.display === 'none') {
                view.style.display = 'block'; edit.style.display = 'none'; btn.style.display = 'block';
            } else {
                view.style.display = 'none'; edit.style.display = 'block'; btn.style.display = 'none';
            }
        }
    </script>
</body>
</html>