<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.database.TreatmentDAO, com.dentalclinic.models.Treatment, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    TreatmentDAO treatmentDAO = new TreatmentDAO();
    
    // Requirement #4: OOP Manipulation (Search/Sort)
    String search = request.getParameter("search");
    String sort = request.getParameter("sort");
    List<Treatment> treatmentList;

    if (search != null && !search.trim().isEmpty()) {
        treatmentList = treatmentDAO.searchTreatments(search);
    } else if (sort != null && !sort.trim().isEmpty()) {
        treatmentList = treatmentDAO.getSortedTreatments(sort);
    } else {
        treatmentList = treatmentDAO.getAllTreatments();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Services | Admin</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <style>
        .service-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .service-table th, .service-table td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        .service-table tr:hover { background-color: #fcfcfc; }
        .action-btn { border: none; background: none; cursor: pointer; padding: 5px 10px; border-radius: 4px; transition: 0.2s; }
        .btn-edit { color: #3498db; } .btn-edit:hover { background: #ebf5ff; }
        .btn-delete { color: #e74c3c; font-weight: bold; } .btn-delete:hover { background: #fff5f5; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 8% auto; padding: 25px; border-radius: 8px; width: 450px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar" style="display: flex; justify-content: space-between; align-items: center;">
                <h2><i class="fas fa-tooth"></i> Treatment Management</h2>
                <button onclick="openModal('create')" style="background:#27ae60; color:white; padding:10px 20px; border-radius:4px; border:none; cursor:pointer; font-weight:bold;">
                    <i class="fas fa-plus"></i> Add New Treatment
                </button>
            </div>

            <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px; display: flex; gap: 15px; align-items: center;">
                <form action="services.jsp" method="GET" style="display: flex; gap: 10px; flex-grow: 1;">
                    <input type="text" name="search" placeholder="Search treatment name..." value="<%= search != null ? search : "" %>" style="padding: 8px; border: 1px solid #ddd; border-radius: 4px; width: 250px;">
                    <button type="submit" style="padding: 8px 15px; background: #34495e; color: white; border: none; border-radius: 4px; cursor: pointer;">Search</button>
                </form>
                
                <form action="services.jsp" method="GET">
                    <select name="sort" onchange="this.form.submit()" style="padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <option value="">Sort By...</option>
                        <option value="name_asc" <%= "name_asc".equals(sort) ? "selected" : "" %>>Name (A-Z)</option>
                        <option value="price_asc" <%= "price_asc".equals(sort) ? "selected" : "" %>>Price (Low to High)</option>
                        <option value="price_desc" <%= "price_desc".equals(sort) ? "selected" : "" %>>Price (High to Low)</option>
                    </select>
                </form>
                <a href="services.jsp" style="color: #7f8c8d; text-decoration: none; font-size: 0.9rem;">Reset</a>
            </div>

            <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                <table class="service-table">
                    <thead>
                        <tr>
                            <th>Treatment Name</th>
                            <th>Description</th>
                            <th>Price (RM)</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (treatmentList != null && !treatmentList.isEmpty()) { 
                            for (Treatment t : treatmentList) { %>
                        <tr>
                            <td style="font-weight: bold;"><%= t.getTreatmentName() %></td>
                            <td style="color: #666; font-size: 14px;"><%= t.getDescription() %></td>
                            <td style="color: #27ae60; font-weight: bold;">RM <%= String.format("%.2f", t.getPrice()) %></td>
                            <td>
                                <button class="action-btn btn-edit" onclick="openModal('edit', '<%= t.getTreatmentId() %>', '<%= t.getTreatmentName() %>', '<%= t.getDescription() %>', '<%= t.getPrice() %>')">
                                    <i class="fas fa-edit"></i> Edit
                                </button>
                            </td>
                        </tr>
                        <% } } else { %>
                            <tr><td colspan="4" style="text-align: center; padding: 20px; color: #95a5a6;">No treatments found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <div id="treatmentModal" class="modal">
        <div class="modal-content">
            <h3 id="modalTitle">Treatment Details</h3>
            <form action="${pageContext.request.contextPath}/admin/treatments" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="treatmentId" id="fieldId">
                
                <div class="form-group">
                    <label>Treatment Name</label>
                    <input type="text" name="treatmentName" id="fieldName" required>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" id="fieldDesc" rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label>Price (RM)</label>
                    <input type="number" step="0.01" name="price" id="fieldPrice" required>
                </div>
                
                <div style="display: flex; justify-content: space-between; margin-top: 20px;">
                    <button type="button" id="deleteBtn" onclick="handleDelete()" class="btn-delete" style="display:none; border: 1px solid #e74c3c; background: white; padding: 10px 15px; border-radius: 4px; cursor: pointer;">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                    <div>
                        <button type="button" onclick="closeModal()" style="padding: 10px 15px; border: none; background: #eee; border-radius: 4px; cursor: pointer; margin-right: 5px;">Cancel</button>
                        <button type="submit" style="background:#27ae60; color:white; padding:10px 20px; border:none; border-radius:4px; cursor:pointer; font-weight: bold;">Save Change</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal(mode, id, name, desc, price) {
            document.getElementById('formAction').value = mode;
            document.getElementById('modalTitle').innerText = mode === 'edit' ? 'Edit Treatment' : 'Add New Treatment';
            document.getElementById('fieldId').value = id || '';
            document.getElementById('fieldName').value = name || '';
            document.getElementById('fieldDesc').value = desc || '';
            document.getElementById('fieldPrice').value = price || '';
            document.getElementById('deleteBtn').style.display = mode === 'edit' ? 'block' : 'none';
            document.getElementById('treatmentModal').style.display = 'block';
        }

        function closeModal() { document.getElementById('treatmentModal').style.display = 'none'; }

        function handleDelete() {
            const id = document.getElementById('fieldId').value;
            const name = document.getElementById('fieldName').value;
            if (confirm("Are you sure you want to permanently delete '" + name + "'?")) {
                window.location.href = "${pageContext.request.contextPath}/admin/treatments?action=delete&treatmentId=" + id;
            }
        }
    </script>
</body>
</html>