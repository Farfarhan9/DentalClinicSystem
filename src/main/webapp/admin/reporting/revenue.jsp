<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.database.AdminDAO, java.util.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    // Sidebar variables
    pageContext.setAttribute("user", currentUser);
    pageContext.setAttribute("userRole", "admin");
    pageContext.setAttribute("contextPath", request.getContextPath());

    // Capture filters
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");

    AdminDAO adminDAO = new AdminDAO();
    // Updated call with date parameters
    List<Map<String, Object>> revenueData = adminDAO.getRevenueReport(startDate, endDate);
    
    double grandTotal = 0;

    // --- LOGIC FOR SUMMARY BOXES ---
    String mostProfitableName = "No Data";
    double maxRevenue = -1;
    
    String mostCommonName = "No Data";
    int maxSessions = -1;

    for (Map<String, Object> row : revenueData) {
        Object revObj = row.get("revenue");
        double rev = (revObj instanceof java.math.BigDecimal) ? ((java.math.BigDecimal)revObj).doubleValue() : 0.0;
        int sessions = (Integer)row.get("count");
        
        if (rev > maxRevenue) {
            maxRevenue = rev;
            mostProfitableName = (String)row.get("name");
        }
        
        if (sessions > maxSessions) {
            maxSessions = sessions;
            mostCommonName = (String)row.get("name");
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Revenue Analytics | Admin</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .report-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .summary-tile { 
            background: white; padding: 20px; border-radius: 10px; 
            border-left: 5px solid #3498db; box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; flex-direction: column; justify-content: center;
        }
        .summary-tile.profitable { border-left-color: #27ae60; }
        .summary-tile.common { border-left-color: #f1c40f; }
        .tile-label { font-size: 0.8rem; color: #7f8c8d; text-transform: uppercase; font-weight: bold; letter-spacing: 0.5px; }
        .tile-value { font-size: 1.25rem; color: #2c3e50; margin-top: 5px; font-weight: bold; }
        .tile-sub { font-size: 0.85rem; color: #95a5a6; margin-top: 3px; }

        /* Filter Section Styles */
        .filter-container { background: white; padding: 20px; border-radius: 10px; margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .filter-form { display: flex; gap: 20px; align-items: flex-end; flex-wrap: wrap; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-group label { font-size: 0.8rem; font-weight: bold; color: #7f8c8d; }
        .filter-group input { padding: 8px; border: 1px solid #ddd; border-radius: 4px; }

        .status-badge { font-size: 0.7rem; padding: 2px 8px; border-radius: 10px; font-weight: bold; margin-left: 8px; text-transform: uppercase; display: inline-block; vertical-align: middle; }
        .status-active { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }
        .status-retired { background: #fef9e7; color: #9a7d0a; border: 1px solid #f9e79f; }

        @media print {
            .dashboard-sidebar, .header-bar button, .filter-container { display: none; }
            .main-content-wrapper { margin-left: 0; padding: 0; }
        }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-chart-line"></i> Financial Reporting and Analytics</h2>
                <button onclick="window.print()" style="background:#2c3e50; color:white; padding:8px 15px; border:none; border-radius:4px; cursor:pointer;">
                    <i class="fas fa-print"></i> Print Report
                </button>
            </div>

            <div class="filter-container">
                <form method="GET" class="filter-form">
                    <div class="filter-group">
                        <label>Start Date</label>
                        <input type="date" name="startDate" value="<%= startDate != null ? startDate : "" %>">
                    </div>
                    <div class="filter-group">
                        <label>End Date</label>
                        <input type="date" name="endDate" value="<%= endDate != null ? endDate : "" %>">
                    </div>
                    <button type="submit" style="background:#3498db; color:white; padding:10px 20px; border:none; border-radius:4px; cursor:pointer; font-weight:bold;">
                        <i class="fas fa-filter"></i> Apply Filter
                    </button>
                    <a href="revenue.jsp" style="text-decoration:none; color:#95a5a6; font-size:0.9rem; margin-bottom:10px;">Reset Filter</a>
                </form>
            </div>

            <div class="summary-grid">
                <div class="summary-tile profitable">
                    <div class="tile-label"><i class="fas fa-trophy"></i> Most Profitable Item</div>
                    <div class="tile-value"><%= mostProfitableName %></div>
                    <% if(maxRevenue > 0) { %>
                        <div class="tile-sub">Generated RM <%= String.format("%.2f", maxRevenue) %> total</div>
                    <% } %>
                </div>

                <div class="summary-tile common">
                    <div class="tile-label"><i class="fas fa-star"></i> Highest Demand</div>
                    <div class="tile-value"><%= mostCommonName %></div>
                    <% if(maxSessions > 0) { %>
                        <div class="tile-sub">Performed <%= maxSessions %> times</div>
                    <% } %>
                </div>
            </div>

            <div class="report-card">
                <h3>Revenue Breakdown</h3>
                <hr style="opacity:0.1; margin-bottom:20px;">
                
                <table style="width:100%; border-collapse: collapse;">
                    <thead>
                        <tr style="text-align:left; border-bottom: 2px solid #f4f7f6; color:#7f8c8d;">
                            <th style="padding:12px;">Treatment Type</th>
                            <th style="padding:12px;">Total Sessions</th>
                            <th style="padding:12px;">Patients Treated</th>
                            <th style="padding:12px; text-align:right;">Total Revenue</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            for (Map<String, Object> row : revenueData) { 
                                Object revObj = row.get("revenue");
                                double amount = (revObj instanceof java.math.BigDecimal) ? ((java.math.BigDecimal)revObj).doubleValue() : 0.0;
                                grandTotal += amount;
                                int isActive = (Integer) row.get("isActive");
                        %>
                        <tr style="border-bottom: 1px solid #f4f7f6;">
                            <td style="padding:12px;">
                                <span style="font-weight:bold;"><%= row.get("name") %></span>
                                <% if (isActive == 1) { %>
                                    <span class="status-badge status-active">Active</span>
                                <% } else { %>
                                    <span class="status-badge status-retired">Retired</span>
                                <% } %>
                            </td>
                            <td style="padding:12px;"><%= row.get("count") %> visits</td>
                            <td style="padding:12px;">
                                <span style="background: #eef2f7; padding: 4px 8px; border-radius: 4px; font-size: 0.9em;">
                                    <i class="fas fa-users" style="color: #3498db;"></i> <%= row.get("patients") %>
                                </span>
                            </td>
                            <td style="padding:12px; text-align:right; color:#27ae60; font-weight:bold;">
                                RM <%= String.format("%.2f", amount) %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                    <tfoot>
                        <tr style="background:#f8f9fa; font-size:1.2rem;">
                            <td colspan="3" style="padding:15px; font-weight:bold;">Grand Total Revenue</td>
                            <td style="padding:15px; text-align:right; color:#27ae60; font-weight:bold;">
                                RM <%= String.format("%.2f", grandTotal) %>
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </main>
    </div>
</body>
</html>