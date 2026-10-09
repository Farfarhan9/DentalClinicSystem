<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    // Set variables for sidebar logic
    pageContext.setAttribute("user", currentUser);
    pageContext.setAttribute("userRole", "admin");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Treatment | Admin</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-plus-circle"></i> Add New Treatment Service</h2>
                <a href="${pageContext.request.contextPath}/admin/config/services.jsp" style="color: #7f8c8d; text-decoration: none;">
                    <i class="fas fa-arrow-left"></i> Back to List
                </a>
            </div>

            <div style="max-width: 600px; margin: 20px auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <form action="${pageContext.request.contextPath}/admin/treatments" method="POST">
                    <input type="hidden" name="action" value="create">
                    
                    <div style="margin-bottom: 20px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 8px;">Treatment Name</label>
                        <input type="text" name="treatmentName" required placeholder="e.g., Scaling & Polishing" 
                               style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px;">
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 8px;">Description</label>
                        <textarea name="description" rows="3" placeholder="Briefly describe the procedure..." 
                                  style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; resize: vertical;"></textarea>
                    </div>

                    <div style="margin-bottom: 25px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 8px;">Standard Price (RM)</label>
                        <input type="number" step="0.01" name="price" required placeholder="0.00" 
                               style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px;">
                        <small style="color: #7f8c8d;">This price will be used across all clinic branches.</small>
                    </div>

                    <button type="submit" style="width: 100%; background: #27ae60; color: white; border: none; padding: 14px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 16px;">
                        <i class="fas fa-save"></i> Save Treatment Item
                    </button>
                </form>
            </div>
        </main>
    </div>
</body>
</html>