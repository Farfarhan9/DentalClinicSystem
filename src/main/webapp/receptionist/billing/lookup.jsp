<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Patient, com.dentalclinic.models.Bill, java.util.List" %>
<% 
    // 1. Security & Variable Setup
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("receptionist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    // Get Data from request attributes (passed by BillingServlet)
    List<Patient> patientResults = (List<Patient>) request.getAttribute("patientResults");
    List<Bill> invoiceHistory = (List<Bill>) request.getAttribute("invoiceHistory");
    
    // Status and Patient Context for persistence
    String status = request.getParameter("status");
    String currentPatientId = request.getParameter("patientId");

    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "receptionist");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Billing and Invoices | Clinic Manager</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .billing-grid { display: grid; grid-template-columns: 1fr 2fr; gap: 20px; padding: 20px; }
        .status-pill { padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .status-paid { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .status-pending { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .status-partial { background: #e1f5fe; color: #01579b; border: 1px solid #b3e5fc; }
        .amount-text { font-family: 'Monaco', 'Courier New', monospace; font-weight: bold; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        
        /* Modal Style */
        #paymentModal { display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); backdrop-filter: blur(2px); }
        .modal-content { background:white; margin:10% auto; padding:25px; border-radius:12px; width:350px; box-shadow:0 10px 25px rgba(0,0,0,0.2); }
        
        .alert-toast { padding: 12px; margin-bottom: 15px; border-radius: 6px; border-left: 5px solid; }
        .alert-success { background: #d4edda; color: #155724; border-left-color: #28a745; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container"> 
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper"> 
            <div class="header-bar">
                <h2><i class="fas fa-file-invoice-dollar"></i> Billing and Payment Management</h2>
            </div>

            <div class="content-body" style="padding: 20px;">
                
                <% if ("payment_success".equals(status)) { %>
                    <div class="alert-toast alert-success">
                        <i class="fas fa-check-circle"></i> Payment recorded successfully!
                    </div>
                <% } else if ("created".equals(status)) { %>
                    <div class="alert-toast alert-success">
                        <i class="fas fa-plus-circle"></i> New invoice generated.
                    </div>
                <% } %>

                <div class="billing-grid">
					<div class="card">
					    <h3>1. Find Patient</h3>
					    <form action="<%= request.getContextPath() %>/billing" method="GET">
					        <input type="hidden" name="action" value="searchPatient">
					        <div style="display: flex; flex-direction: column; gap: 10px;">
					            <div style="display: flex; gap: 5px;">
					                <input type="text" name="query" placeholder="Name or Phone..." 
					                       value="<%= request.getParameter("query") != null ? request.getParameter("query") : "" %>"
					                       style="flex:1; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
					                <button type="submit" style="background:#3498db; color:white; border:none; padding: 8px 15px; border-radius:4px; cursor:pointer;">
					                    <i class="fas fa-search"></i>
					                </button>
					            </div>
					            
					            <%-- ADDED: Sorting Filter --%>
					            <select name="sortBy" onchange="this.form.submit()" 
					                    style="padding: 8px; border: 1px solid #ddd; border-radius: 4px; background: #f9f9f9; font-size: 13px;">
					                <option value="name" <%= "name".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by Name (A-Z)</option>
					                <option value="name_desc" <%= "name_desc".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by Name (Z-A)</option>
					                <option value="id" <%= "id".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by ID</option>
					                <option value="status" <%= "status".equals(request.getParameter("sortBy")) ? "selected" : "" %>>Sort by Status</option>
					            </select>
					        </div>
					    </form>

                        <div style="margin-top:20px;">
                            <% if (patientResults != null) { 
                                for (Patient p : patientResults) { %>
                                <div style="padding:12px; border-bottom:1px solid #eee; display:flex; justify-content:space-between; align-items:center;">
                                    <div>
                                        <strong><%= p.getFullName() %></strong><br>
                                        <small style="color:#666;"><%= p.getPhone() %></small>
                                    </div>
                                    <a href="<%= request.getContextPath() %>/billing?action=viewHistory&patientId=<%= p.getPatientId() %>" 
                                       style="text-decoration:none; font-size:12px; background:#f1f1f1; padding:6px 12px; border-radius:4px; color:#333; font-weight:bold;">Select</a>
                                </div>
                            <% } } %>
                        </div>
                    </div>

                    <div class="card">
                        <h3>2. Invoice History & Actions</h3>
                        <table style="width:100%; border-collapse:collapse; margin-bottom: 20px;">
                            <thead>
                                <tr style="text-align:left; border-bottom:2px solid #eee; color: #7f8c8d;">
                                    <th style="padding:10px;">ID</th>
                                    <th style="padding:10px;">Total</th>
                                    <th style="padding:10px;">Paid</th>
                                    <th style="padding:10px;">Status</th>
                                    <th style="padding:10px;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (invoiceHistory != null && !invoiceHistory.isEmpty()) { 
                                    for (Bill inv : invoiceHistory) { 
                                        String dbStatus = inv.getPaymentStatus().name().toLowerCase();
                                        String pillClass = "status-pending";
                                        if ("paid".equals(dbStatus)) pillClass = "status-paid";
                                        else if ("partial".equals(dbStatus)) pillClass = "status-partial";
                                %>
                                    <tr style="border-bottom:1px solid #eee;">
                                        <td style="padding:10px;">#<%= inv.getBillId() %></td>
                                        <td class="amount-text" style="color:#2c3e50;">RM <%= String.format("%.2f", inv.getTotalAmount()) %></td>
                                        <td class="amount-text" style="color:#27ae60;">RM <%= String.format("%.2f", inv.getAmountPaid()) %></td>
                                        <td style="padding:10px;">
                                            <span class="status-pill <%= pillClass %>"><%= dbStatus %></span>
                                        </td>
                                        <td style="padding:10px;">
                                            <% if (!"paid".equals(dbStatus)) { %>
                                                <button onclick="openPaymentModal('<%= inv.getBillId() %>', '<%= inv.getTotalAmount().subtract(inv.getAmountPaid()) %>', '<%= currentPatientId %>')" 
                                                        style="cursor:pointer; background:#3498db; color:white; border:none; padding:5px 10px; border-radius:4px; font-size:12px;">
                                                    Pay
                                                </button>
                                            <% } else { %>
                                                <span style="color:#27ae60; font-size:12px;"><i class="fas fa-check"></i> Settled</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="5" style="padding:40px; text-align:center; color:#999;">
                                        <i class="fas fa-search" style="font-size:24px; display:block; margin-bottom:10px;"></i>
                                        Search and select a patient to view invoices.
                                    </td></tr>
                                <% } %>
                            </tbody>
                        </table>
                        
                        <hr style="margin:20px 0; border:0; border-top:1px solid #eee;">
                        
                        <h4>Generate Manual Bill</h4>
                        <% if (currentPatientId != null) { %>
                            <form action="<%= request.getContextPath() %>/billing" method="POST" style="display:flex; gap:10px; background: #f9f9f9; padding: 15px; border-radius: 6px;">
                                <input type="hidden" name="action" value="create">
                                <input type="hidden" name="patientId" value="<%= currentPatientId %>">
                                
                                <div style="flex:1;">
                                    <label style="font-size:12px; color:#666;">Total Amount (RM)</label>
                                    <input type="number" name="amount" placeholder="0.00" step="0.01" required style="width:100%; padding:8px; border:1px solid #ddd; border-radius:4px;">
                                </div>
                                <div style="flex:1;">
                                    <label style="font-size:12px; color:#666;">Type</label>
                                    <select name="type" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:4px;">
                                        <option value="walk_in">Walk-in Service</option>
                                        <option value="misc">Miscellaneous</option>
                                        <option value="medicine">Medicine/Products</option>
                                    </select>
                                </div>
                                <button type="submit" style="align-self: flex-end; background:#27ae60; color:white; border:none; padding:10px 15px; border-radius:4px; cursor:pointer; font-weight: bold;">
                                    Create Bill
                                </button>
                            </form>
                        <% } else { %>
                            <p style="color: #95a5a6; font-style: italic; font-size: 13px;">Please select a patient first to create a new manual bill.</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <div id="paymentModal">
        <div class="modal-content">
            <h3 style="margin-top:0;"><i class="fas fa-cash-register"></i> Collect Payment</h3>
            <form action="<%= request.getContextPath() %>/billing" method="GET">
                <input type="hidden" name="action" value="recordPayment">
                <input type="hidden" name="invoiceId" id="modalBillId">
                <input type="hidden" name="patientId" id="modalPatientId">
                
                <div style="background:#f8f9fa; padding:15px; border-radius:8px; margin-bottom:15px;">
                    <span style="color:#666; font-size:13px;">Remaining Balance:</span><br>
                    <span id="modalBalanceText" style="font-size:20px; font-weight:bold; color:#2c3e50;"></span>
                </div>
                
                <label style="font-weight:bold; font-size:14px;">Payment Amount (RM):</label>
                <input type="number" name="amount" id="modalAmountInput" step="0.01" required 
                       style="width:100%; padding:10px; margin:8px 0 20px 0; border:1px solid #ddd; border-radius:4px; font-size:16px;">
                
                <div style="display:flex; gap:10px;">
                    <button type="submit" style="flex:1; background:#27ae60; color:white; border:none; padding:12px; border-radius:6px; cursor:pointer; font-weight:bold;">Record Payment</button>
                    <button type="button" onclick="closeModal()" style="flex:1; background:#bdc3c7; color:white; border:none; padding:12px; border-radius:6px; cursor:pointer;">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
    function openPaymentModal(billId, balance, patientId) {
        document.getElementById('modalBillId').value = billId;
        document.getElementById('modalPatientId').value = patientId;
        document.getElementById('modalBalanceText').innerText = "RM " + parseFloat(balance).toFixed(2);
        document.getElementById('modalAmountInput').value = balance; // Default to full balance
        document.getElementById('modalAmountInput').max = balance;   // Prevent overpaying
        document.getElementById('paymentModal').style.display = 'block';
    }

    function closeModal() {
        document.getElementById('paymentModal').style.display = 'none';
    }

    // Close modal if clicking outside of the white box
    window.onclick = function(event) {
        let modal = document.getElementById('paymentModal');
        if (event.target == modal) closeModal();
    }
    </script>
</body>
</html>