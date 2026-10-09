
package com.dentalclinic.database;

import com.dentalclinic.models.LeaveRequest;
import java.sql.*;
import java.util.*;

public class LeaveDAO {
    private DatabaseConnection dbConnection;

    public LeaveDAO() throws SQLException {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // Fetch all pending leave requests for approval center
    public List<LeaveRequest> getPendingLeaveRequests() throws SQLException {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, u.full_name, u.role, e.employee_id " +
                     "FROM leave_requests lr " +
                     "JOIN users u ON lr.user_id = u.user_id " +
                     "JOIN employees e ON lr.user_id = e.user_id " +
                     "WHERE lr.status = 'Pending'";
        try (PreparedStatement stmt = dbConnection.getConnection().prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                LeaveRequest req = new LeaveRequest();
                req.setRequestId(rs.getInt("request_id"));
                req.setUserId(rs.getInt("user_id"));
                req.setEmployeeId(rs.getInt("employee_id"));
                req.setEmployeeName(rs.getString("full_name"));
                req.setRole(rs.getString("role"));
                req.setLeaveType(rs.getString("leave_type"));
                req.setFromDate(rs.getDate("from_date"));
                req.setToDate(rs.getDate("to_date"));
                req.setReason(rs.getString("reason"));
                req.setCoveragePerson(rs.getString("coverage_person"));
                req.setStatus(rs.getString("status"));
                list.add(req);
            }
        }
        return list;
    }

    // Approve a leave request
    public boolean approveLeaveRequest(int requestId, String approverComments) throws SQLException {
        String sql = "UPDATE leave_requests SET status = 'Approved', approver_comments = ?, approved_at = NOW() WHERE request_id = ?";
        try (PreparedStatement stmt = dbConnection.getConnection().prepareStatement(sql)) {
            stmt.setString(1, approverComments);
            stmt.setInt(2, requestId);
            return stmt.executeUpdate() > 0;
        }
    }

    // Reject a leave request
    public boolean rejectLeaveRequest(int requestId, String rejectionReason, String details) throws SQLException {
        String sql = "UPDATE leave_requests SET status = 'Rejected', rejection_reason = ?, rejection_details = ?, rejected_at = NOW() WHERE request_id = ?";
        try (PreparedStatement stmt = dbConnection.getConnection().prepareStatement(sql)) {
            stmt.setString(1, rejectionReason);
            stmt.setString(2, details);
            stmt.setInt(3, requestId);
            return stmt.executeUpdate() > 0;
        }
    }

 // Add this method inside LeaveDAO class

 public boolean applyLeave(LeaveRequest leave) throws SQLException {
     String sql = "INSERT INTO leave_requests (user_id, leave_type, from_date, to_date, reason, coverage_person, status, applied_at) " +
                  "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
     try (PreparedStatement stmt = dbConnection.getConnection().prepareStatement(sql)) {
         stmt.setInt(1, leave.getUserId());
         stmt.setString(2, leave.getLeaveType());
         stmt.setDate(3, leave.getFromDate());
         stmt.setDate(4, leave.getToDate());
         stmt.setString(5, leave.getReason());
         stmt.setString(6, leave.getCoveragePerson());
         stmt.setString(7, leave.getStatus());
         return stmt.executeUpdate() > 0;
     }
 }


    // You can add more methods for bulk actions, audit logging, etc.
}
