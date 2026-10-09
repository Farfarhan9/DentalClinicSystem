<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.Patient, com.dentalclinic.models.Treatment, com.dentalclinic.database.TreatmentDAO, java.util.List" %>
<%
    // Security check
    Patient patient = (Patient) session.getAttribute("patientUser");
    if (patient == null) {
        response.sendRedirect(request.getContextPath() + "/patient_login.jsp?error=unauthorized");
        return;
    }
    
    // Set attributes for the shared includes
    pageContext.setAttribute("user", patient);
    pageContext.setAttribute("userRole", "patient");
    pageContext.setAttribute("contextPath", request.getContextPath());

    // Fetch and Manipulate Data via OOP Methods
    TreatmentDAO treatmentDAO = new TreatmentDAO();
    String search = request.getParameter("search");
    String sort = request.getParameter("sort");
    
    List<Treatment> treatments;
    
    if (search != null && !search.trim().isEmpty()) {
        treatments = treatmentDAO.searchTreatments(search);
    } else if (sort != null && !sort.trim().isEmpty()) {
        treatments = treatmentDAO.getSortedTreatments(sort);
    } else {
        treatments = treatmentDAO.getAllTreatments();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Treatments and Prices | Putra DentalCare</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .panel { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
        .price-tag { font-weight: 700; color: #27ae60; background: #f0fff4; padding: 5px 10px; border-radius: 5px; }
        .table-controls { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 10px; }
        .input-style { padding: 10px; border: 1px solid #ddd; border-radius: 8px; outline: none; }
        .btn-submit { background: #3498db; color: white; border: none; cursor: pointer; font-weight: bold; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-hand-holding-usd"></i> Our Treatments & Service Prices</h2>
            </div>

            <div class="panel">
                <form action="pricing.jsp" method="GET" class="table-controls">
                    <div>
                        <input type="text" name="search" class="input-style" placeholder="Search treatment..." value="<%= search != null ? search : "" %>">
                        <button type="submit" class="input-style btn-submit">Search</button>
                    </div>
                    
                    <select name="sort" class="input-style" onchange="this.form.submit()">
                        <option value="">Sort By...</option>
                        <option value="name_asc" <%= "name_asc".equals(sort) ? "selected" : "" %>>Name (A-Z)</option>
                        <option value="price_asc" <%= "price_asc".equals(sort) ? "selected" : "" %>>Price (Low to High)</option>
                        <option value="price_desc" <%= "price_desc".equals(sort) ? "selected" : "" %>>Price (High to Low)</option>
                    </select>
                </form>

                <table style="width:100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom: 2px solid #eee; text-align: left; color: #34495e;">
                            <th style="padding: 15px;">Service Name</th>
                            <th style="padding: 15px;">Details</th>
                            <th style="padding: 15px;">Price (EST)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (treatments != null && !treatments.isEmpty()) { 
                            for (Treatment t : treatments) { %>
                            <tr style="border-bottom: 1px solid #f1f1f1;">
                                <td style="padding: 18px; font-weight: 600; color: #2c3e50;">
                                    <i class="fas fa-tooth" style="color: #3498db; margin-right: 8px;"></i>
                                    <%= t.getTreatmentName() %>
                                </td>
                                <td style="padding: 18px; color: #636e72;">
                                    <%= (t.getDescription() != null) ? t.getDescription() : "N/A" %>
                                </td>
                                <td style="padding: 18px;">
                                    <span class="price-tag">RM <%= String.format("%.2f", t.getPrice()) %></span>
                                </td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr><td colspan="3" style="padding: 30px; text-align: center; color: #95a5a6;">No records found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>