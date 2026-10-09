<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Patient, java.util.List" %>
<% 
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("receptionist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    List<Patient> results = (List<Patient>) request.getAttribute("searchResults");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Patients | Receptionist</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .modal-overlay {
            display: none; position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.6); z-index: 1000;
            justify-content: center; align-items: center;
        }
        .modal-content {
            background: white; padding: 30px; border-radius: 8px;
            width: 500px; max-width: 90%; box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group select, .form-group textarea { 
            width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; 
        }
        .profile-row { display: flex; border-bottom: 1px solid #f0f0f0; padding: 10px 0; }
        .profile-label { width: 120px; font-weight: bold; color: #7f8c8d; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-users"></i> Patient Management</h2>
            </div>

            <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                <form action="<%= request.getContextPath() %>/receptionist/patient-controller" method="GET" style="margin-bottom: 20px; display: flex; gap: 10px;">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="query" placeholder="Search by name or phone..." style="flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                    <button type="submit" style="background: #3498db; color: white; border: none; padding: 10px 25px; border-radius: 4px; cursor: pointer;">
                        <i class="fas fa-search"></i> Search
                    </button>
                    <select name="sortBy" onchange="this.form.submit()" style="padding: 10px; border: 1px solid #ddd; border-radius: 4px; background: white;">
                        <option value="name" <%= "name".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by Name (A-Z)</option>
                        <option value="name_desc" <%= "name_desc".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by Name (Z-A)</option>
                        <option value="id" <%= "id".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by ID</option>
                        <option value="status" <%= "status".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by Status</option>
                    </select>
                </form>

                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: #f8f9fa; border-bottom: 2px solid #eee; text-align: left;">
                            <th style="padding: 12px;">ID</th>
                            <th style="padding: 12px;">Full Name</th>
                            <th style="padding: 12px;">Phone</th>
                            <th style="padding: 12px;">Status</th> 
                            <th style="padding: 12px; text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (results != null && !results.isEmpty()) { 
                            for (Patient p : results) { 
                                String currentStatus = p.getStatus() != null ? p.getStatus() : "Active";
                                String safeNotes = p.getMedicalNotes() != null ? p.getMedicalNotes().replace("'", "\\'").replace("\n", " ") : "";
                                String safeAddr = p.getAddress() != null ? p.getAddress().replace("'", "\\'").replace("\n", " ") : "";
                                String safeEmail = p.getEmail() != null ? p.getEmail() : "";
                        %>
                            <tr style="border-bottom: 1px solid #eee;">
                                <td style="padding: 12px;"><%= p.getPatientId() %></td>
                                <td style="padding: 12px; font-weight: bold;"><%= p.getFullName() %></td>
                                <td style="padding: 12px;"><%= p.getPhone() %></td>
                                <td style="padding: 12px;">
                                    <span style="background: <%= currentStatus.equalsIgnoreCase("Active") ? "#2ecc71" : "#e74c3c" %>; color: white; padding: 4px 8px; border-radius: 12px; font-size: 11px;">
                                        <%= currentStatus.toUpperCase() %>
                                    </span>
                                </td>
                                <td style="padding: 12px; text-align: center;">
                                    <button type="button" onclick="showProfile('<%= p.getPatientId() %>', '<%= p.getFullName() %>', '<%= p.getPhone() %>', '<%= p.getDob() %>', '<%= p.getGender() %>', '<%= safeAddr %>', '<%= safeNotes %>', '<%= currentStatus %>', '<%= safeEmail %>')"
                                            style="background: none; border: none; color: #7f8c8d; cursor: pointer; font-size: 14px; margin-right:10px;">
                                        <i class="fas fa-eye"></i> View
                                    </button>
                                    <button type="button" onclick="openEditModal('<%= p.getPatientId() %>', '<%= p.getFullName() %>', '<%= p.getPhone() %>', '<%= safeEmail %>', '<%= currentStatus %>', '<%= safeNotes %>', '<%= safeAddr %>')"
                                            style="background: none; border: none; color: #3498db; cursor: pointer; font-size: 14px;">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="5" style="padding: 30px; text-align: center; color: #7f8c8d;">No records found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <div id="profileModal" class="modal-overlay">
        <div class="modal-content">
            <h3 style="margin-top: 0;"><i class="fas fa-id-card"></i> Patient Profile</h3>
            <hr>
            <div class="profile-row"><div class="profile-label">ID:</div><div id="p-id"></div></div>
            <div class="profile-row"><div class="profile-label">Full Name:</div><div id="p-name"></div></div>
            <div class="profile-row"><div class="profile-label">Phone:</div><div id="p-phone"></div></div>
            <div class="profile-row"><div class="profile-label">Email:</div><div id="p-email"></div></div>
            <div class="profile-row"><div class="profile-label">DOB:</div><div id="p-dob"></div></div>
            <div class="profile-row"><div class="profile-label">Gender:</div><div id="p-gender"></div></div>
            <div class="profile-row"><div class="profile-label">Address:</div><div id="p-address"></div></div>
            <div class="profile-row"><div class="profile-label">Notes:</div><div id="p-notes" style="color: #e67e22;"></div></div>
            <button type="button" onclick="closeProfile()" style="width: 100%; margin-top: 20px; padding: 10px; background: #95a5a6; color: white; border: none; border-radius: 4px; cursor: pointer;">Close</button>
        </div>
    </div>

    <div id="editModal" class="modal-overlay">
        <div class="modal-content">
            <h3 style="margin-top: 0;"><i class="fas fa-user-edit"></i> Edit Patient Status</h3>
            <hr>
            <form action="<%= request.getContextPath() %>/receptionist/patient-controller" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" id="editPatientId" name="patientId">
                <div class="form-group"><label>Full Name</label><input type="text" id="editFullName" name="fullName" required></div>
                <div class="form-group"><label>Phone</label><input type="text" id="editPhone" name="phone" required></div>
                <div class="form-group"><label>Email</label><input type="email" id="editEmail" name="email"></div>
                <div class="form-group"><label>Address</label><input type="text" id="editAddress" name="address"></div>
                <div class="form-group"><label>Medical Notes</label><textarea id="editMedicalNotes" name="medicalNotes" rows="3"></textarea></div>
                <div class="form-group">
                    <label>Status</label>
                    <select id="editStatus" name="status">
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                        <option value="Deceased">Deceased</option>
                    </select>
                </div>
                <div style="display: flex; gap: 10px; margin-top: 20px;">
                    <button type="submit" style="flex: 1; background: #27ae60; color: white; border: none; padding: 12px; border-radius: 4px; cursor: pointer;">Save</button>
                    <button type="button" onclick="closeEditModal()" style="flex: 1; background: #e74c3c; color: white; border: none; padding: 12px; border-radius: 4px; cursor: pointer;">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function showProfile(id, name, phone, dob, gender, addr, notes, status, email) {
            document.getElementById('p-id').innerText = "#" + id;
            document.getElementById('p-name').innerText = name;
            document.getElementById('p-phone').innerText = phone;
            document.getElementById('p-email').innerText = email || "N/A";
            document.getElementById('p-dob').innerText = dob;
            document.getElementById('p-gender').innerText = gender;
            document.getElementById('p-address').innerText = addr || "N/A";
            document.getElementById('p-notes').innerText = notes || "No notes";
            document.getElementById('profileModal').style.display = 'flex';
        }
        function closeProfile() { document.getElementById('profileModal').style.display = 'none'; }
        
        function openEditModal(id, name, phone, email, status, notes, addr) {
            document.getElementById('editPatientId').value = id;
            document.getElementById('editFullName').value = name;
            document.getElementById('editPhone').value = phone;
            document.getElementById('editEmail').value = email;
            document.getElementById('editStatus').value = status;
            document.getElementById('editMedicalNotes').value = notes;
            document.getElementById('editAddress').value = addr;
            document.getElementById('editModal').style.display = 'flex';
        }
        function closeEditModal() { document.getElementById('editModal').style.display = 'none'; }

        window.onclick = function(event) {
            if (event.target.classList.contains('modal-overlay')) {
                closeProfile();
                closeEditModal();
            }
        }
    </script>
</body>
</html>