<%-- Standard imports and Security Check as before --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Employee, com.dentalclinic.database.HrDAO, java.util.Map, java.util.List, java.math.BigDecimal" %>
<% 
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("hr")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    HrDAO hrDAO = new HrDAO();
    Map<String, Object> hrStats = hrDAO.getHrStats();
    BigDecimal totalExpenditure = (BigDecimal) hrStats.getOrDefault("totalSalary", BigDecimal.ZERO);
    int staffCount = (int) hrStats.getOrDefault("staffCount", 0);
    List<Employee> allEmployees = hrDAO.getAllEmployees();
%>
<%@ include file="/includes/_dashboard_style.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HR Dashboard | Clinic Manager</title>
    <style>
        .stats-container { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { padding: 20px; color: white; border-radius: 10px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .bg-orange { background: #f39c12; }
        .bg-blue { background: #3498db; }
        .stat-value { font-size: 2.2rem; font-weight: bold; display: block; }
        .dashboard-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; }
        .panel { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .full-width { grid-column: 1 / -1; margin-bottom: 25px; }
        .action-list { display: flex; flex-direction: column; gap: 12px; margin-top: 15px; }
        .btn-action { padding: 12px; border: none; border-radius: 5px; text-align: left; font-weight: 500; transition: 0.2s; text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .btn-hr { background: #f8f9fa; color: #2c3e50; border: 1px solid #dee2e6; }
        .btn-hr:hover { background: #e9ecef; border-color: #adb5bd; }
        .section-icon { color: #3498db; margin-right: 8px; }
        .pending-table { width:100%; border-collapse: collapse; margin-top: 10px; }
        .pending-table th { text-align: left; padding: 10px; border-bottom: 2px solid #eee; color: #7f8c8d; }
        .pending-table td { padding: 10px; border-bottom: 1px solid #eee; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-users-cog"></i> HR Management: <%= user.getFullName() %></h2>
            </div>

            <div class="stats-container">
                <div class="stat-card bg-orange">
                    <span class="stat-value"><%= hrStats.get("nextPayroll") %></span>
                    <span>Next Payroll Date</span>
                </div>
                <div class="stat-card bg-blue">
                    <span class="stat-value">RM <%= (totalExpenditure != null) ? String.format("%.2f", totalExpenditure) : "0.00" %></span>
                    <span>Monthly Salary Expenditure (<%= staffCount %> Employees)</span>
                </div>
            </div>

            <div class="panel full-width">
                <h3><i class="fas fa-exclamation-circle" style="color:#e67e22"></i> Action Required: Complete New Employee Profiles</h3>
                <table class="pending-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            boolean foundPending = false;
                            for(Employee emp : allEmployees) { 
                                // Logic: If NRIC is missing, HR hasn't registered them yet
                                if(emp.getNricPassport() == null || emp.getNricPassport().isEmpty()) {
                                    foundPending = true;
                        %>
                        <tr>
                            <td><%= emp.getFullName() %></td>
                            <td><span class="role-badge"><%= emp.getRole() %></span></td>
                            <td><span style="color:#e67e22; font-size: 0.85em;"><i class="fas fa-clock"></i> Missing HR Info</span></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/hr/employee/register.jsp?userId=<%= emp.getUserId() %>" 
                                   style="color:#3498db; font-weight:bold; text-decoration:none;">
                                   <i class="fas fa-plus-circle"></i> Complete Registration
                                </a>
                            </td>
                        </tr>
                        <%      }
                            } 
                            if(!foundPending) { %>
                            <tr><td colspan="4" style="padding:15px; text-align:center; color:gray;">All staff profiles are fully registered.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="dashboard-grid">
                <div class="panel">
                    <h3><i class="fas fa-id-card section-icon"></i> Employee Records</h3>
                    <div class="action-list">
                        <a href="<%= request.getContextPath() %>/hr/employee/records.jsp" class="btn-action btn-hr">
                            <i class="fas fa-users"></i> View All Employee Records
                        </a>
                    </div>
                </div>
  <%-- No function here 
                <div class="panel">
                    <h3><i class="fas fa-calendar-check section-icon"></i> Attendance and Leave</h3>
                    <div class="action-list">
                        <a href="<%= request.getContextPath() %>/hr/leave/approve.jsp" class="btn-action btn-hr">
                            <i class="fas fa-clipboard-check"></i> Approve Leave Requests
                        </a>
                        <a href="<%= request.getContextPath() %>/hr/attendance/report.jsp" class="btn-action btn-hr">
                            <i class="fas fa-business-time"></i> View Monthly Attendance
                        </a>
                    </div>
                </div>

                <div class="panel">
                    <h3><i class="fas fa-chart-pie section-icon"></i> Branch Statistics</h3>
                    <div class="action-list">
                        <a href="<%= request.getContextPath() %>/hr/branch/staff_count.jsp" class="btn-action btn-hr">
                            <i class="fas fa-hospital-user"></i> Staff Count by Branch
                        </a>
                        <a href="<%= request.getContextPath() %>/hr/reports/turnover.jsp" class="btn-action btn-hr">
                            <i class="fas fa-user-minus"></i> Staff Turnover Report
                        </a>
                    </div>
                </div>
                
                <div class="panel">
                    <h3><i class="fas fa-cogs"></i> Leave</h3>
                    <div class="action-list">
						                        
						<!-- Add this inside the main dashboard action/card area for each role -->
						<a href="<%= request.getContextPath() %>/leave/apply.jsp" class="btn-action" style="background: #eafaf1; color: #27ae60; padding: 15px; text-decoration: none; border-radius: 5px;">
						    <i class="fas fa-plane-departure"></i> Apply for Leave
						</a> 

                    </div>
                </div> --%>
            </div>
        </main>
    </div>
</body>
</html>