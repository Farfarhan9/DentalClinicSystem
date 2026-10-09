
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.LeaveRequest, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("hr")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }
    
    List<LeaveRequest> leaveRequests = (List<LeaveRequest>) request.getAttribute("leaveRequests");
    if (leaveRequests != null && !leaveRequests.isEmpty()) {
        for (LeaveRequest req : leaveRequests) {
%>
<!DOCTYPE html>
<html>
<head>
    <title>Leave Approval Center</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        .approval-center-container { max-width: 1200px; margin: 0 auto; }
        .status-overview { display: flex; gap: 20px; margin-bottom: 25px; }
        .status-card { background: #f8f9fa; border-radius: 8px; padding: 18px 30px; text-align: center; flex: 1; }
        .status-card .count { font-size: 2.2rem; font-weight: bold; }
        .filter-bar { display: flex; gap: 12px; margin-bottom: 18px; align-items: center; }
        .filter-bar select, .filter-bar input[type="text"], .filter-bar input[type="date"] { padding: 6px 10px; border-radius: 4px; border: 1px solid #ccc; }
        .pending-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .pending-table th, .pending-table td { padding: 10px; border-bottom: 1px solid #eee; }
        .pending-table th { background: #f4f7f6; }
        .btn { padding: 7px 16px; border-radius: 4px; border: none; cursor: pointer; }
        .btn-approve { background: #27ae60; color: #fff; }
        .btn-reject { background: #e74c3c; color: #fff; }
        .btn-bulk { background: #2980b9; color: #fff; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background: rgba(0,0,0,0.3); }
        .modal-content { background: #fff; margin: 60px auto; padding: 30px; border-radius: 8px; width: 500px; position: relative; }
        .modal-header { font-size: 1.3rem; font-weight: bold; margin-bottom: 15px; }
        .modal-close { position: absolute; right: 18px; top: 12px; font-size: 1.2rem; cursor: pointer; color: #888; }
        .bulk-actions-bar { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        .urgent-indicator { color: #e74c3c; font-weight: bold; }
    </style>
    <script>
        // Simple modal logic
        function openModal(id) { document.getElementById(id).style.display = 'block'; }
        function closeModal(id) { document.getElementById(id).style.display = 'none'; }
        window.onclick = function(event) {
            document.querySelectorAll('.modal').forEach(function(modal) {
                if (event.target == modal) modal.style.display = "none";
            });
        }
        // Bulk select logic
        function toggleSelectAll(source) {
            let checkboxes = document.querySelectorAll('.request-checkbox');
            checkboxes.forEach(cb => cb.checked = source.checked);
            updateSelectedCount();
        }
        function updateSelectedCount() {
            let count = document.querySelectorAll('.request-checkbox:checked').length;
            document.getElementById('selectedCount').innerText = count;
        }
    </script>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-clipboard-check"></i> Leave Management Portal</h2>
            </div>
            <div class="approval-center-container">
                <!-- Status Overview -->
                <div class="status-overview">
                    <div class="status-card">
                        <div class="count">5</div>
                        <div>Pending</div>
                    </div>
                    <div class="status-card">
                        <div class="count">2</div>
                        <div>Today</div>
                    </div>
                    <div class="status-card">
                        <div class="count">7</div>
                        <div>This Week</div>
                    </div>
                </div>
                <!-- Filter Bar -->
                <form class="filter-bar" method="get">
                    <select name="filter">
                        <option>All Requests</option>
                        <option>My Team Only</option>
                    </select>
                    <select name="department">
                        <option>All Departments</option>
                        <option>Dental</option>
                        <option>Reception</option>
                        <option>HR</option>
                    </select>
                    <select name="leaveType">
                        <option>All Leave Types</option>
                        <option>Annual</option>
                        <option>Sick</option>
                        <option>Emergency</option>
                        <option>Unpaid</option>
                    </select>
                    <input type="date" name="from">
                    <input type="date" name="to">
                    <input type="text" name="search" placeholder="Search...">
                    <button class="btn" style="background:#3498db; color:#fff;">Filter</button>
                </form>
                <!-- Bulk Actions Bar -->
                <div class="bulk-actions-bar">
                    <input type="checkbox" onclick="toggleSelectAll(this)">
                    <span id="selectedCount">0</span> requests selected
                    <button type="button" class="btn btn-bulk" onclick="openModal('bulkApproveModal')"><i class="fas fa-check-double"></i> Approve Selected</button>
                    <button type="button" class="btn btn-reject" onclick="openModal('bulkRejectModal')"><i class="fas fa-times"></i> Reject Selected</button>
                </div>
                <!-- Pending Requests Table -->
                <table class="pending-table">
                    <thead>
                        <tr>
                            <th><input type="checkbox" onclick="toggleSelectAll(this)"></th>
                            <th>Employee ID</th>
                            <th>Employee Name</th>
                            <th>Leave Type</th>
                            <th>Dates</th>
                            <th>Duration</th>
                            <th>Coverage Person</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Example row, replace with dynamic data -->
					  <tr>
					    <td><input type="checkbox" class="request-checkbox" onclick="updateSelectedCount()"></td>
					    <td><%= req.getEmployeeId() %></td>
					    <td><%= req.getEmployeeName() %></td>
					    <td><%= req.getLeaveType() %></td>
					    <td><%= req.getFromDate() %> to <%= req.getToDate() %></td>
					    <td>
					        <%
					            long diff = req.getToDate().getTime() - req.getFromDate().getTime();
					            long days = (diff / (1000 * 60 * 60 * 24)) + 1;
					        %>
					        <%= days %> days
					    </td>
					    <td><%= req.getCoveragePerson() %></td>
					    <td>
					        <button class="btn btn-approve" onclick="openModal('approveModal')"><i class="fas fa-check"></i></button>
					        <button class="btn btn-reject" onclick="openModal('rejectModal')"><i class="fas fa-times"></i></button>
					    </td>
					</tr>
					<%
					        }
					    } else {
					%>
					<tr><td colspan="8" style="text-align:center;">No pending leave requests.</td></tr>
					<%
					    }
					%>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
    <!-- Approve Modal -->
    <div id="approveModal" class="modal">
        <div class="modal-content">
            <span class="modal-close" onclick="closeModal('approveModal')">&times;</span>
            <div class="modal-header">Approve Leave Request</div>
            <div>
                <strong>Employee:</strong> Jane Doe (EMP001)<br>
                <strong>Department:</strong> Dental<br>
                <strong>Position:</strong> Dental Assistant<br>
                <strong>Manager:</strong> Dr. Smith<br>
                <hr>
                <strong>Leave Type:</strong> Annual<br>
                <strong>Dates:</strong> 2025-07-10 to 2025-07-12<br>
                <strong>Duration:</strong> 3 days<br>
                <strong>Reason:</strong> Family event<br>
                <strong>Coverage:</strong> John Smith<br>
                <hr>
                <strong>Leave Balance:</strong> 12/18 used, 6 remaining <span style="color:green;">&#10003;</span><br>
                <strong>Team on leave:</strong> None<br>
                <label>Approver Comments (optional):</label>
                <textarea style="width:100%;"></textarea>
                <div style="margin-top:15px; text-align:right;">
                    <button class="btn" onclick="closeModal('approveModal')">Cancel</button>
                    <button class="btn btn-approve">Approve & Notify</button>
                </div>
            </div>
        </div>
    </div>
    <!-- Reject Modal -->
    <div id="rejectModal" class="modal">
        <div class="modal-content">
            <span class="modal-close" onclick="closeModal('rejectModal')">&times;</span>
            <div class="modal-header">Reject Leave Request</div>
            <div>
                <label>Reason for Rejection:</label>
                <select style="width:100%;">
                    <option>Insufficient team coverage</option>
                    <option>Critical business period</option>
                    <option>Policy violation</option>
                    <option>Insufficient leave balance</option>
                    <option>Other</option>
                </select>
                <label>Details (min 20 chars):</label>
                <textarea style="width:100%;" minlength="20"></textarea>
                <label>Suggest Alternative Dates (optional):</label>
                <input type="date"> to <input type="date"><br>
                <label><input type="checkbox" checked> Notify employee</label>
                <label><input type="checkbox"> Notify manager</label>
                <label><input type="checkbox"> Keep request in pending</label>
                <div style="margin-top:15px; text-align:right;">
                    <button class="btn" onclick="closeModal('rejectModal')">Cancel</button>
                    <button class="btn btn-reject">Reject & Notify</button>
                </div>
            </div>
        </div>
    </div>
    <!-- Bulk Approve Modal -->
    <div id="bulkApproveModal" class="modal">
        <div class="modal-content">
            <span class="modal-close" onclick="closeModal('bulkApproveModal')">&times;</span>
            <div class="modal-header">Bulk Approve Requests</div>
            <div>
                <p>Approve all selected requests? (List of requests shown here)</p>
                <label>Approval Comment (optional):</label>
                <textarea style="width:100%;"></textarea>
                <div style="margin-top:15px; text-align:right;">
                    <button class="btn" onclick="closeModal('bulkApproveModal')">Cancel</button>
                    <button class="btn btn-approve">Approve All</button>
                </div>
            </div>
        </div>
    </div>
    <!-- Bulk Reject Modal -->
    <div id="bulkRejectModal" class="modal">
        <div class="modal-content">
            <span class="modal-close" onclick="closeModal('bulkRejectModal')">&times;</span>
            <div class="modal-header">Bulk Reject Requests</div>
            <div>
                <p>Reject all selected requests? (List of requests shown here)</p>
                <label>Rejection Reason:</label>
                <select style="width:100%;">
                    <option>Insufficient team coverage</option>
                    <option>Critical business period</option>
                    <option>Policy violation</option>
                    <option>Insufficient leave balance</option>
                    <option>Other</option>
                </select>
                <label>Details (min 20 chars):</label>
                <textarea style="width:100%;" minlength="20"></textarea>
                <div style="margin-top:15px; text-align:right;">
                    <button class="btn" onclick="closeModal('bulkRejectModal')">Cancel</button>
                    <button class="btn btn-reject">Reject All</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
