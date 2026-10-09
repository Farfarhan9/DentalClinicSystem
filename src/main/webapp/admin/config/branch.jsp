<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Branch, com.dentalclinic.database.BranchDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    BranchDAO branchDAO = new BranchDAO();
    List<Branch> branchList = branchDAO.getAllBranches();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Branches | Admin</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .grid-container { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; margin-top: 20px; }
        .branch-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); border-top: 4px solid #3498db; position: relative; }
        .branch-card h3 { margin: 0 0 10px 0; color: #2c3e50; display: flex; justify-content: space-between; align-items: center; }
        .branch-info { font-size: 14px; color: #7f8c8d; margin-bottom: 8px; }
        .branch-info i { width: 20px; color: #3498db; }
        
        .action-link { cursor: pointer; color: #3498db; text-decoration: none; font-size: 13px; font-weight: bold; transition: 0.2s; }
        .action-link:hover { color: #2980b9; text-decoration: underline; }
        .delete-link { color: #e74c3c; margin-left: 15px; }

        /* Modal Styles */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 10% auto; padding: 25px; border-radius: 8px; width: 450px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; font-size: 14px; }
        .form-group input, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .modal-footer { text-align: right; margin-top: 20px; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-code-branch"></i> Clinic Branches</h2>
                <button onclick="openBranchModal('add')" style="background:#3498db; color:white; padding:10px 20px; border-radius:4px; border:none; cursor:pointer; font-weight:bold;">
                    <i class="fas fa-plus"></i> Register New Branch
                </button>
            </div>

            <div class="grid-container">
                <% for (Branch b : branchList) { %>
                    <div class="branch-card">
                        <h3>
                            <%= b.getBranchName() %>
                            <span style="font-size: 12px; color: #bdc3c7;">ID: #<%= b.getBranchId() %></span>
                        </h3>
                        <div class="branch-info"><i class="fas fa-map-marker-alt"></i> <%= b.getAddress() %></div>
                        <div class="branch-info"><i class="fas fa-phone"></i> <%= b.getPhone() %></div>
                        <div class="branch-info"><i class="fas fa-envelope"></i> <%= b.getEmail() != null ? b.getEmail() : "No email set" %></div>
                        
                        <div style="margin-top: 20px; padding-top: 15px; border-top: 1px solid #eee;">
                            <a class="action-link" onclick="openBranchModal('edit', '<%= b.getBranchId() %>', '<%= b.getBranchName() %>', '<%= b.getAddress() %>', '<%= b.getPhone() %>', '<%= b.getEmail() %>')">
                                <i class="fas fa-edit"></i> Edit Details
                            </a>
                            <a class="action-link delete-link" onclick="deleteBranch(<%= b.getBranchId() %>, '<%= b.getBranchName() %>')">
                                <i class="fas fa-trash"></i> Delete
                            </a>
                        </div>
                    </div>
                <% } %>
            </div>
        </main>
    </div>

    <div id="branchModal" class="modal">
        <div class="modal-content">
            <h3 id="modalTitle">Register New Branch</h3>
            <form action="${pageContext.request.contextPath}/admin/branch/manage" method="POST">
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="branchId" id="fieldId">
                
                <div class="form-group">
                    <label>Branch Name</label>
                    <input type="text" name="branchName" id="fieldName" required>
                </div>
                <div class="form-group">
                    <label>Address</label>
                    <textarea name="address" id="fieldAddress" rows="2" required style="width:100%; border:1px solid #ddd; border-radius:4px;"></textarea>
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone" id="fieldPhone" required>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" id="fieldEmail">
                </div>
                
                <div class="modal-footer">
                    <button type="button" onclick="closeModal()" style="padding: 10px 15px; background:#bdc3c7; border:none; border-radius:4px; cursor:pointer;">Cancel</button>
                    <button type="submit" style="padding: 10px 15px; background:#27ae60; color:white; border:none; border-radius:4px; cursor:pointer; font-weight:bold;">Save Branch</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openBranchModal(mode, id, name, addr, phone, email) {
            const modal = document.getElementById('branchModal');
            document.getElementById('formAction').value = (mode === 'edit') ? 'update' : 'add';
            document.getElementById('modalTitle').innerText = (mode === 'edit') ? 'Edit Branch Details' : 'Register New Branch';
            
            // Clear or Fill fields
            document.getElementById('fieldId').value = id || '';
            document.getElementById('fieldName').value = name || '';
            document.getElementById('fieldAddress').value = addr || '';
            document.getElementById('fieldPhone').value = phone || '';
            document.getElementById('fieldEmail').value = email || '';
            
            modal.style.display = 'block';
        }

        function closeModal() { document.getElementById('branchModal').style.display = 'none'; }

        function deleteBranch(id, name) {
            if (confirm("Permanently delete " + name + "? This may cause issues if users are assigned here.")) {
                window.location.href = "${pageContext.request.contextPath}/admin/branch/manage?action=delete&branchId=" + id;
            }
        }
    </script>
</body>
</html>