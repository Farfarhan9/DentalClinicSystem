<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Bill, java.util.List" %>
<%
    // 1. Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("receptionist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    // 2. Retrieve data from Servlet
    // We cast to List<Bill> - this comes from request.setAttribute("debtList", debts) in the Servlet
    List<Bill> debtList = (List<Bill>) request.getAttribute("debtList");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Debt List | Clinic Manager</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .debt-container { padding: 20px; }
        .debt-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .debt-table th { background: #e74c3c; color: white; padding: 15px; text-align: left; font-size: 14px; }
        .debt-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 14px; }
        .balance-due { color: #e74c3c; font-weight: bold; font-family: 'Courier New', monospace; }
        .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .status-partial { background: #fef9e7; color: #f39c12; border: 1px solid #fbd38d; }
        .status-pending { background: #fdedec; color: #e74c3c; border: 1px solid #feb2b2; }
        .btn-collect { background: #3498db; color: white; padding: 7px 15px; border-radius: 4px; text-decoration: none; font-size: 12px; font-weight: bold; }
        .btn-collect:hover { background: #2980b9; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-exclamation-circle"></i> Outstanding Debtors List</h2>
                <p style="color: #666;">Total Records Found: <%= (debtList != null) ? debtList.size() : 0 %></p>
            </div>

            <div class="debt-container">
			    <div style="background: white; padding: 15px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); display: flex; justify-content: space-between; align-items: center;">
			        <form action="<%= request.getContextPath() %>/billing" method="GET" style="display: flex; gap: 10px; flex: 1;">
			            <input type="hidden" name="action" value="viewDebts">
			            <input type="text" name="patientSearch" placeholder="Filter debtors by name..." 
			                   style="padding: 10px; border: 1px solid #ddd; border-radius: 4px; width: 300px;">
			            
			            <select name="sortBy" onchange="this.form.submit()" style="padding: 10px; border: 1px solid #ddd; border-radius: 4px; background: white;">
			                <option value="balance_desc">Highest Debt First</option>
			                <option value="balance_asc">Lowest Debt First</option>
			                <option value="name">Patient Name (A-Z)</option>
			            </select>
			            
			            <button type="submit" style="background: #e74c3c; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold;">
			                <i class="fas fa-filter"></i> Apply
			            </button>
			        </form>
			    </div>
                <% if (debtList == null || debtList.isEmpty()) { %>
                    <div style="text-align:center; padding:60px; background:white; border-radius:8px; border: 1px solid #eee;">
                        <i class="fas fa-check-circle" style="font-size:48px; color:#27ae60; margin-bottom: 15px;"></i>
                        <h3 style="color: #2c3e50;">No Outstanding Debts</h3>
                        <p style="color: #7f8c8d;">All accounts are currently settled.</p>
                    </div>
                <% } else { %>
                    <table class="debt-table">
                        <thead>
                            <tr>
                                <th>Invoice ID</th>
                                <th>Patient Info</th>
                                <th>Total Bill</th>
                                <th>Amount Paid</th>
                                <th>Balance Due</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Bill inv : debtList) { 
							    String currentStatus = inv.getPaymentStatus().name().toLowerCase();
							%>
							<tr>
							    <td><strong>#<%= inv.getBillId() %></strong></td>
							    <td>
							        <strong><%= (inv.getPatientName() != null) ? inv.getPatientName() : "Patient #" + inv.getPatientId() %></strong><br>
							        <small style="color: #7f8c8d;">ID: <%= inv.getPatientId() %></small>
							    </td>
							    <td>RM <%= String.format("%.2f", inv.getTotalAmount()) %></td>
							    <td>RM <%= String.format("%.2f", inv.getAmountPaid()) %></td>
							    <td class="balance-due">RM <%= String.format("%.2f", inv.getOutstandingBalance()) %></td>
							    <td>
							        <span class="status-badge status-<%= currentStatus %>">
							            <%= currentStatus %>
							        </span>
							    </td>
							    <td>
							        <a href="<%= request.getContextPath() %>/billing?action=viewHistory&patientId=<%= inv.getPatientId() %>" class="btn-collect">
							            <i class="fas fa-dollar-sign"></i> Collect Payment
							        </a>
							    </td>
							</tr>
							<% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </main>
    </div>
</body>
</html>