
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Apply for Leave</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-plane-departure"></i> Apply for Leave</h2>
            </div>
            <form action="<%= request.getContextPath() %>/leave" method="POST" style="max-width: 500px; margin: 30px auto; background: white; padding: 30px; border-radius: 8px;">
                <input type="hidden" name="action" value="apply">
                <div style="margin-bottom: 20px;">
                    <label>Leave Type</label>
                    <select name="leaveType" required>
                        <option value="">Select</option>
                        <option value="Annual">Annual Leave</option>
                        <option value="Sick">Sick Leave</option>
                        <option value="Emergency">Emergency Leave</option>
                        <option value="Unpaid">Unpaid Leave</option>
                    </select>
                </div>
                <div style="margin-bottom: 20px;">
                    <label>From Date</label>
                    <input type="date" name="fromDate" required>
                </div>
                <div style="margin-bottom: 20px;">
                    <label>To Date</label>
                    <input type="date" name="toDate" required>
                </div>
                <div style="margin-bottom: 20px;">
                    <label>Reason</label>
                    <textarea name="reason" rows="3" required></textarea>
                </div>
                <div style="margin-bottom: 20px;">
                    <label>Coverage Person (optional)</label>
                    <input type="text" name="coveragePerson">
                </div>
                <button type="submit" style="background: #27ae60; color: white; border: none; padding: 12px 25px; border-radius: 4px; font-weight: bold;">
                    Submit Leave Application
                </button>
            </form>
        </main>
    </div>
</body>
</html>
