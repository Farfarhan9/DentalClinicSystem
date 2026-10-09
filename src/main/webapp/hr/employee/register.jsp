<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.Employee, com.dentalclinic.database.HrDAO" %>
<%
    HrDAO hrDAO = new HrDAO();
    String userIdParam = request.getParameter("userId");
    Employee emp = (userIdParam != null) ? hrDAO.getEmployeeByUserId(Integer.parseInt(userIdParam)) : null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HR - Register Employee Details</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-user-edit"></i> Employee Registration</h2>
            </div>

            <div class="card" style="max-width: 600px; margin: 30px auto; padding: 30px; background: white; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
                <% if (emp == null) { %>
                    <h3>Select Staff to Register</h3>
                    <p>Enter a User ID or go to the <a href="../dashboard.jsp">Dashboard</a> to see pending staff.</p>
                    <form method="GET" action="register.jsp">
                        <input type="number" name="userId" placeholder="Enter User ID" required style="width:100%; padding:10px; margin:10px 0;">
                        <button type="submit" class="btn-primary" style="width:100%">Find Staff</button>
                    </form>
                <% } else { %>
                    <h3>Completing Profile: <%= emp.getFullName() %></h3>
                    <p style="color:#7f8c8d; margin-bottom:20px;">Role: <%= emp.getRole().toUpperCase() %></p>
                    
                    <form action="${pageContext.request.contextPath}/hr/employee/update" method="POST">
                        <%-- Crucial: Keep track of both IDs --%>
                        <input type="hidden" name="userId" value="<%= emp.getUserId() %>">
                        <input type="hidden" name="employeeId" value="<%= emp.getEmployeeId() %>">
                        
                        <div style="margin-bottom:15px;">
                            <label style="display:block; font-weight:bold;">NRIC / Passport Number</label>
                            <input type="text" name="nricPassport" value="<%= emp.getNricPassport() != null ? emp.getNricPassport() : "" %>" required style="width:100%; padding:10px; border:1px solid #ccc; border-radius:4px;">
                        </div>

                        <div style="margin-bottom:15px;">
                            <label style="display:block; font-weight:bold;">Monthly Base Salary (RM)</label>
                            <input type="number" step="0.01" name="baseSalary" value="<%= emp.getBaseSalary() %>" required style="width:100%; padding:10px; border:1px solid #ccc; border-radius:4px;">
                        </div>

                        <div style="margin-bottom:15px;">
                            <label style="display:block; font-weight:bold;">EPF Number</label>
                            <input type="text" name="epfNumber" value="<%= emp.getEpfNumber() != null ? emp.getEpfNumber() : "" %>" style="width:100%; padding:10px; border:1px solid #ccc; border-radius:4px;">
                        </div>

                        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px; margin-bottom:15px;">
                            <div>
                                <label style="display:block; font-weight:bold;">Bank Name</label>
                                <input type="text" name="bankName" value="<%= emp.getBankName() != null ? emp.getBankName() : "" %>" placeholder="e.g. Maybank" style="width:100%; padding:10px; border:1px solid #ccc; border-radius:4px;">
                            </div>
                            <div>
                                <label style="display:block; font-weight:bold;">Bank Account</label>
                                <input type="text" name="bankAccount" value="<%= emp.getBankAccount() != null ? emp.getBankAccount() : "" %>" style="width:100%; padding:10px; border:1px solid #ccc; border-radius:4px;">
                            </div>
                        </div>

                        <button type="submit" style="width:100%; background:#27ae60; color:white; border:none; padding:12px; border-radius:4px; cursor:pointer; font-weight:bold;">
                            Confirm and Save Profile
                        </button>
                    </form>
                <% } %>
            </div>
        </main>
    </div>
</body>
</html>