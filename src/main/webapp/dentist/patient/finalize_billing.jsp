<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.*, com.dentalclinic.database.TreatmentDAO, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    List<Appointment> completed = (List<Appointment>) request.getAttribute("completedList");
    TreatmentDAO treatmentDAO = new TreatmentDAO();
    List<Treatment> treatments = treatmentDAO.getAllTreatments();
    String status = (String) request.getAttribute("status");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<%@ include file="/includes/_dashboard_style.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Finalize Billing | Dentist</title>
    <style>
        .panel { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .billing-table { width:100%; border-collapse: collapse; margin-top: 15px; }
        .billing-table th, .billing-table td { padding: 12px; border-bottom: 1px solid #eee; text-align: left; }
        
        /* Modal Style */
        .modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 25px; border-radius: 8px; width: 500px; max-width: 90%; }
        .treatment-tag { display: inline-block; background: #e1f0ff; color: #007bff; padding: 5px 10px; border-radius: 15px; margin: 3px; font-size: 13px; }
        .treatment-tag i { cursor: pointer; margin-left: 5px; color: #ff7675; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-file-invoice"></i> Finalize Billing</h2>
            </div>

            <div class="panel">
                <h3>Completed Treatments (Today)</h3>
                <% if(completed != null && !completed.isEmpty()) { %>
                    <table class="billing-table">
                        <thead>
                            <tr>
                                <th>Patient</th>
                                <th>Services Selected</th>
                                <th>Total (RM)</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(Appointment a : completed) { %>
                                <tr id="row-<%= a.getAppointmentId() %>">
                                    <td><strong><%= a.getPatientName() %></strong></td>
                                    <td>
                                        <div id="list-<%= a.getAppointmentId() %>" style="min-height: 30px; border: 1px dashed #ccc; padding: 5px; border-radius: 4px;">
                                            <span style="color:#999; font-size: 12px;">Click 'Add Treatment' to start</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span id="total-display-<%= a.getAppointmentId() %>" style="font-weight: bold; color: #27ae60;">0.00</span>
                                    </td>
                                    <td>
                                        <form action="<%= request.getContextPath() %>/billing" method="POST" onsubmit="return validateForm(<%= a.getAppointmentId() %>)">
                                            <input type="hidden" name="action" value="create">
                                            <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                                            <input type="hidden" name="patientId" value="<%= a.getPatientId() %>">
                                            <input type="hidden" name="amount" id="input-amount-<%= a.getAppointmentId() %>" value="0">
                                            
                                            <button type="button" onclick="openTreatmentModal(<%= a.getAppointmentId() %>)" class="btn-primary-alt" style="padding: 5px 10px; margin-bottom: 5px;">
                                                <i class="fas fa-plus"></i> Add Treatment
                                            </button>
                                            <button type="submit" class="btn-success-alt" style="padding: 5px 10px; width: 100%;">
                                                Finalize Bill
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <p style="text-align: center; color: #999; padding: 40px;">No pending treatments found.</p>
                <% } %>
            </div>
        </main>
    </div>

    <div id="treatmentModal" class="modal-overlay">
        <div class="modal-content">
            <h4>Select Treatment</h4>
            <select id="modalSelector" class="form-select" style="width: 100%; padding: 10px; margin: 15px 0;">
                <option value="">-- Choose Treatment --</option>
                <% for(Treatment t : treatments) { %>
                    <option value="<%= t.getTreatmentId() %>" data-price="<%= t.getPrice() %>" data-name="<%= t.getTreatmentName() %>">
                        <%= t.getTreatmentName() %> (RM <%= t.getPrice() %>)
                    </option>
                <% } %>
            </select>
            <div style="display: flex; gap: 10px; justify-content: flex-end;">
                <button type="button" onclick="closeModal()" class="btn-back" style="background: #eee; color: #333;">Cancel</button>
                <button type="button" onclick="addTreatmentToRow()" class="btn-save" style="background: #007bff; color: white; padding: 10px 20px; border-radius: 4px; border:none;">Add to Bill</button>
            </div>
        </div>
    </div>

    <script>
        let currentApptId = null;
        let billData = {}; // Stores { apptId: [ {name, price} ] }

        function openTreatmentModal(apptId) {
            currentApptId = apptId;
            document.getElementById('treatmentModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('treatmentModal').style.display = 'none';
        }

        function addTreatmentToRow() {
            const selector = document.getElementById('modalSelector');
            const selectedOption = selector.options[selector.selectedIndex];
            
            if (!selectedOption.value) return;

            const tName = selectedOption.getAttribute('data-name');
            const tPrice = parseFloat(selectedOption.getAttribute('data-price'));

            if (!billData[currentApptId]) billData[currentApptId] = [];
            billData[currentApptId].push({ name: tName, price: tPrice });

            updateDisplay(currentApptId);
            closeModal();
            selector.selectedIndex = 0;
        }

        function updateDisplay(apptId) {
            const listDiv = document.getElementById('list-' + apptId);
            const totalSpan = document.getElementById('total-display-' + apptId);
            const inputAmount = document.getElementById('input-amount-' + apptId);
            
            listDiv.innerHTML = '';
            let total = 0;

            billData[apptId].forEach((item, index) => {
                total += item.price;
                listDiv.innerHTML += `
                    <span class="treatment-tag">
                        ${item.name} (RM ${item.price.toFixed(2)})
                        <i class="fas fa-times-circle" onclick="removeItem(${apptId}, ${index})"></i>
                    </span>`;
            });

            totalSpan.innerText = total.toFixed(2);
            inputAmount.value = total.toFixed(2);
        }

        function removeItem(apptId, index) {
            billData[apptId].splice(index, 1);
            updateDisplay(apptId);
        }

        function validateForm(apptId) {
            const amount = parseFloat(document.getElementById('input-amount-' + apptId).value);
            if (amount <= 0) {
                alert("Please add at least one treatment before billing.");
                return false;
            }
            return true;
        }
    </script>
</body>
</html>