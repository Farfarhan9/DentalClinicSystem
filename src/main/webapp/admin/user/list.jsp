<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.database.UserDAO, java.util.List" %>
<% 
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    com.dentalclinic.database.UserDAO userDAO = new com.dentalclinic.database.UserDAO();
    java.util.List<User> staffList = userDAO.getAllUsers();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Staff | Admin</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        /* Table Styles */
        .staff-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; margin-top: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .staff-table th, .staff-table td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        .deactivated-row { opacity: 0.5; background: #f9f9f9; }
        
        /* Button Visibility Fix */
        .action-btn { 
            padding: 8px 12px; border-radius: 4px; border: none; cursor: pointer; 
            font-size: 14px; margin-right: 5px; transition: 0.3s; color: white;
            display: inline-flex; align-items: center; text-decoration: none;
        }
        .btn-edit { background: #3498db; } .btn-edit:hover { background: #2980b9; }
        .btn-deactivate { background: #e67e22; }
        .btn-reactivate { background: #27ae60; }
        .btn-delete { background: #e74c3c; }

        /* Modal Styles */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 10% auto; padding: 25px; border-radius: 8px; width: 400px; position: relative; }
        .modal-header { border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 15px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .modal-footer { text-align: right; margin-top: 20px; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container"> 
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-users"></i> Staff Directory</h2>
                <a href="${pageContext.request.contextPath}/admin/user/create.jsp" class="action-btn" style="background: #2c3e50;">
                    <i class="fas fa-plus"></i> &nbsp; Add New Staff
                </a>
            </div>

            <table class="staff-table">
                <thead>
                    <tr>
                        <th>Full Name</th>
                        <th>Username</th>
                        <th>Role</th>
                        <th>Branch</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (User s : staffList) { 
                        boolean isActive = userDAO.isUserActive(s.getUserId());
                    %>
                    <tr class="<%= !isActive ? "deactivated-row" : "" %>">
                        <td><strong><%= s.getFullName() %></strong></td>
                        <td><%= s.getUsername() %></td>
                        <td><%= s.getRole() %></td>
                        <td>Branch <%= s.getBranchId() %></td>
                        <td>
                            <button class="action-btn btn-edit" onclick="openEditModal('<%= s.getUserId() %>', '<%= s.getFullName() %>', '<%= s.getUsername() %>', '<%= s.getRole() %>', '<%= s.getBranchId() %>')">
                                <i class="fas fa-edit"></i>
                            </button>

                            <% if (isActive) { %>
                                <button class="action-btn btn-deactivate" onclick="handleUser('deactivate', <%= s.getUserId() %>, '<%= s.getFullName() %>')"><i class="fas fa-user-slash"></i></button>
                            <% } else { %>
                                <button class="action-btn btn-reactivate" onclick="handleUser('reactivate', <%= s.getUserId() %>, '<%= s.getFullName() %>')"><i class="fas fa-user-check"></i></button>
                            <% } %>

                            <button class="action-btn btn-delete" onclick="handleUser('delete', <%= s.getUserId() %>, '<%= s.getFullName() %>')"><i class="fas fa-trash"></i></button>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </main>
    </div>

    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header"><h3>Edit Staff Profile</h3></div>
            <form action="${pageContext.request.contextPath}/admin/user/manage" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userId" id="editUserId">
                
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="fullName" id="editFullName" required>
                </div>
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" name="username" id="editUsername" required>
                </div>
                <div class="form-group">
                    <label>New Password (Leave blank to keep current)</label>
                    <input type="password" name="password" placeholder="********">
                </div>
                <div class="form-group">
                    <label>Role</label>
                    <select name="role" id="editRole">
                        <option value="receptionist">Receptionist</option>
                        <option value="dentist">Dentist</option>
                        <option value="hr">HR</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Branch Assignment</label>
                    <select name="branchId" id="editBranch">
                        <option value="1">Branch 1</option>
                        <option value="2">Branch 2</option>
                    </select>
                </div>
                <div class="modal-footer">
                    <button type="button" onclick="closeModal()" style="padding: 8px 15px;">Cancel</button>
                    <button type="submit" class="action-btn btn-edit" style="padding: 8px 15px;">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(id, name, user, role, branch) {
            document.getElementById('editUserId').value = id;
            document.getElementById('editFullName').value = name;
            document.getElementById('editUsername').value = user;
            document.getElementById('editRole').value = role.toLowerCase();
            document.getElementById('editBranch').value = branch;
            document.getElementById('editModal').style.display = 'block';
        }

        function closeModal() { document.getElementById('editModal').style.display = 'none'; }

        function handleUser(action, userId, name) {
            if (confirm("Are you sure you want to " + action + " " + name + "?")) {
                window.location.href = "${pageContext.request.contextPath}/admin/user/manage?action=" + action + "&userId=" + userId;
            }
        }
    </script>
</body>
</html>