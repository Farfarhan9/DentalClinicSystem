<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Employee, com.dentalclinic.database.HrDAO, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("hr")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    HrDAO hrDAO = new HrDAO();
    List<Employee> employeeList = hrDAO.getAllEmployees();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Records | HR</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .table-container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-top: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background-color: #f8f9fa; color: #333; }
        
        .modal-overlay { 
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; 
        }
        .modal-content { 
            background: white; padding: 30px; border-radius: 10px; width: 500px; 
            box-shadow: 0 5px 15px rgba(0,0,0,0.3); position: relative;
        }
        .close-modal { position: absolute; top: 15px; right: 20px; font-size: 24px; cursor: pointer; color: #7f8c8d; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 5px; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
        .btn-save { background: #27ae60; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; width: 100%; font-weight: bold; }
        
        /* Deactivate Button Styling */
        .btn-deactivate { color: #e74c3c; margin-left: 10px; text-decoration: none; font-size: 0.9em; }
        .btn-deactivate:hover { text-decoration: underline; }

        .alert-banner {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 6px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideIn 0.3s ease-out;
        }
        .success-msg { background: #d4edda; color: #155724; border-left: 5px solid #28a745; }
        .error-msg { background: #f8d7da; color: #721c24; border-left: 5px solid #dc3545; }
        
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-users"></i> Employee Master Records</h2>
            </div>
            
            <% if (request.getParameter("success") != null) { %>
                <div id="statusMsg" class="alert-banner success-msg">
                    <i class="fas fa-check-circle"></i> Operation successful!
                </div>
            <% } else if (request.getParameter("error") != null) { %>
                <div id="statusMsg" class="alert-banner error-msg">
                    <i class="fas fa-exclamation-triangle"></i> Operation failed. Please try again.
                </div>
            <% } %>
                            
            <script>
                setTimeout(() => {
                    const msg = document.getElementById('statusMsg');
                    if (msg) {
                        msg.style.transition = "opacity 0.5s ease";
                        msg.style.opacity = "0";
                        setTimeout(() => msg.remove(), 500);
                    }
                }, 4000);
            </script>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Full Name</th>
                            <th>NRIC / Passport</th>
                            <th>Hire Date</th>
                            <th>Base Salary</th>
                            <th>EPF Number</th>
                            <th>Bank Details</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (employeeList.isEmpty()) { %>
                            <tr><td colspan="7" style="text-align:center;">No employees found.</td></tr>
                        <% } else { 
                            for (Employee emp : employeeList) { %>
                            <tr>
                                <td><strong><%= emp.getFullName() %></strong><br>
                                    <small style="color:#7f8c8d;"><%= emp.getRole().toUpperCase() %></small>
                                </td>
                                <td><%= (emp.getNricPassport() == null) ? "<em>Pending</em>" : emp.getNricPassport() %></td>
                                <td><%= (emp.getHireDate() == null) ? "<em>Pending</em>" : emp.getHireDate() %></td>
                                <td>RM <%= String.format("%.2f", emp.getBaseSalary()) %></td>
                                <td><%= (emp.getEpfNumber() == null || emp.getEpfNumber().isEmpty()) ? "-" : emp.getEpfNumber() %></td>
                                <td>
                                    <% if (emp.getBankName() != null && !emp.getBankName().isEmpty()) { %>
                                        <strong><%= emp.getBankName() %></strong><br>
                                        <small><%= emp.getBankAccount() %></small>
                                    <% } else { %>
                                        <em>Not set</em>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="javascript:void(0)" class="btn-edit" 
                                       onclick="openEditModal('<%= emp.getUserId() %>', '<%= emp.getEmployeeId() %>', '<%= emp.getFullName() %>', '<%= emp.getNricPassport() %>', '<%= emp.getBaseSalary() %>', '<%= emp.getEpfNumber() %>', '<%= emp.getBankName() %>', '<%= emp.getBankAccount() %>')">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    <a href="javascript:void(0)" class="btn-deactivate" 
                                       onclick="confirmDeactivate('<%= emp.getUserId() %>', '<%= emp.getFullName() %>')">
                                        <i class="fas fa-user-slash"></i> Deactivate
                                    </a>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <%-- Edit Modal (Remains same) --%>
    <div id="editModal" class="modal-overlay">
        <div class="modal-content">
            <span class="close-modal" onclick="closeModal()">&times;</span>
            <h3 id="modalTitle">Edit Employee Details</h3>
            <hr>
            <form action="${pageContext.request.contextPath}/hr/employee/update" method="POST">
                <input type="hidden" id="modalUserId" name="userId">
                <input type="hidden" id="modalEmpId" name="employeeId">
                <div class="form-group"><label>NRIC / Passport</label><input type="text" id="modalNric" name="nricPassport" required></div>
                <div class="form-group"><label>Base Salary (RM)</label><input type="number" step="0.01" id="modalSalary" name="baseSalary" required></div>
                <div class="form-group"><label>EPF Number</label><input type="text" id="modalEpf" name="epfNumber"></div>
                <div class="form-group"><label>Bank Name</label><input type="text" id="modalBankName" name="bankName"></div>
                <div class="form-group"><label>Bank Account</label><input type="text" id="modalBankAccount" name="bankAccount"></div>
                <button type="submit" class="btn-save">Update Records</button>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(userId, empId, name, nric, salary, epf, bank, account) {
            document.getElementById('modalTitle').innerText = "Editing: " + name;
            document.getElementById('modalUserId').value = userId;
            document.getElementById('modalEmpId').value = empId;
            document.getElementById('modalNric').value = (nric === 'null' || !nric) ? '' : nric;
            document.getElementById('modalSalary').value = (salary === 'null' || !salary) ? '0.00' : salary;
            document.getElementById('modalEpf').value = (epf === 'null' || !epf) ? '' : epf;
            document.getElementById('modalBankName').value = (bank === 'null' || !bank) ? '' : bank;
            document.getElementById('modalBankAccount').value = (account === 'null' || !account) ? '' : account;
            document.getElementById('editModal').style.display = 'flex';
        }

        function closeModal() { document.getElementById('editModal').style.display = 'none'; }

        function confirmDeactivate(userId, name) {
            if (confirm("Are you sure you want to deactivate " + name + "? They will no longer be able to log in or appear in active lists.")) {
                window.location.href = "${pageContext.request.contextPath}/hr/employee/deactivate?userId=" + userId;
            }
        }

        window.onclick = function(event) {
            if (event.target == document.getElementById('editModal')) { closeModal(); }
        }
    </script>
</body>
</html>