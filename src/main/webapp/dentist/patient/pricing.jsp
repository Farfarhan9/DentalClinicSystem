<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Treatment, com.dentalclinic.database.TreatmentDAO, java.util.List" %>
<%
    // Security check: Ensure user is logged in as a dentist
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("dentist")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    
    // Set attributes for the shared includes
    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "dentist");
    pageContext.setAttribute("contextPath", request.getContextPath());

    // Fetch and Manipulate Data via TreatmentDAO (OOP Requirement #4)
    TreatmentDAO treatmentDAO = new TreatmentDAO();
    String search = request.getParameter("search");
    String sort = request.getParameter("sort");
    
    List<Treatment> treatments;
    
    // Logic: If user searched, use search method. Otherwise, check for sorting.
    if (search != null && !search.trim().isEmpty()) {
        treatments = treatmentDAO.searchTreatments(search);
    } else if (sort != null && !sort.trim().isEmpty()) {
        treatments = treatmentDAO.getSortedTreatments(sort);
    } else {
        treatments = treatmentDAO.getAllTreatments();
    }
%>
<%@ include file="/includes/_dashboard_style.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Treatment Pricing | Dentist</title>
    <style>
        .panel { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .price-tag { font-family: 'Courier New', monospace; font-weight: bold; color: #2c3e50; }
        
        .table-controls { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 20px; 
            gap: 15px;
        }
        .input-style { 
            padding: 10px 15px; 
            border: 1px solid #ddd; 
            border-radius: 8px; 
            outline: none;
        }
        .btn-submit { 
            background: #4a6fa5; 
            color: white; 
            border: none; 
            cursor: pointer; 
            font-weight: 500;
            transition: 0.3s;
        }
        .btn-submit:hover { background: #2c3e50; }
        .treatment-row:hover { background-color: #f9f9f9; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-list-ol"></i> Treatment Item and Pricing List</h2>
            </div>
            
            <div class="panel">
                <form action="pricing.jsp" method="GET" class="table-controls">
                    <div style="display: flex; gap: 5px;">
                        <input type="text" name="search" class="input-style" placeholder="Search treatments..." value="<%= search != null ? search : "" %>">
                        <button type="submit" class="input-style btn-submit">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>

                    <div>
                        <label style="font-size: 0.9rem; color: #7f8c8d; margin-right: 5px;">Order by:</label>
                        <select name="sort" class="input-style" onchange="this.form.submit()">
                            <option value="">Default</option>
                            <option value="name_asc" <%= "name_asc".equals(sort) ? "selected" : "" %>>Name (A-Z)</option>
                            <option value="price_asc" <%= "price_asc".equals(sort) ? "selected" : "" %>>Price (Low to High)</option>
                            <option value="price_desc" <%= "price_desc".equals(sort) ? "selected" : "" %>>Price (High to Low)</option>
                        </select>
                        <a href="pricing.jsp" class="input-style" style="text-decoration: none; background: #eee; color: #333;">Reset</a>
                    </div>
                </form>

                <table style="width:100%; border-collapse: collapse;" id="priceTable">
                    <thead>
                        <tr style="border-bottom: 2px solid #eee; text-align: left;">
                            <th style="padding: 15px;">Treatment Name</th>
                            <th style="padding: 15px;">Description</th>
                            <th style="padding: 15px;">Standard Price</th>
                        </tr>
                    </thead>
                    <tbody id="treatmentBody">
                        <% if (treatments != null && !treatments.isEmpty()) { 
                            for (Treatment t : treatments) { %>
                            <tr class="treatment-row" style="border-bottom: 1px solid #f1f1f1;">
                                <td style="padding: 15px; font-weight: bold;">
                                    <%= t.getTreatmentName() %>
                                </td>
                                <td style="padding: 15px; color: #666;">
                                    <%= (t.getDescription() != null) ? t.getDescription() : "-" %>
                                </td>
                                <td style="padding: 15px;" class="price-tag">
                                    RM <%= String.format("%.2f", t.getPrice()) %>
                                </td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr>
                                <td colspan="3" style="padding: 30px; text-align: center; color: #95a5a6;">
                                    No treatments found matching your criteria.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>