package com.dentalclinic.database;

import java.sql.*;
import java.util.*;

public class AdminDAO {
    private DatabaseConnection dbConnection;

    public AdminDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }

    public Map<String, Object> getClinicStats() {
        Map<String, Object> stats = new HashMap<>();
        try {
            ResultSet rs1 = dbConnection.executeQuery("SELECT COUNT(*) FROM patients");
            if (rs1.next()) stats.put("totalPatients", rs1.getInt(1));

            ResultSet rs2 = dbConnection.executeQuery("SELECT COUNT(*) FROM appointments WHERE appointment_date = CURDATE()");
            if (rs2.next()) stats.put("todayAppointments", rs2.getInt(1));

            ResultSet rs3 = dbConnection.executeQuery("SELECT SUM(amount_paid) FROM bills");
            if (rs3.next()) stats.put("totalRevenue", rs3.getDouble(1));

        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return stats;
    }

    public List<Map<String, Object>> getAllUsersWithStatus() {
        List<Map<String, Object>> users = new ArrayList<>();
        String sql = "SELECT user_id, username, full_name, role, is_active FROM users WHERE role != 'admin'";
        try (ResultSet rs = dbConnection.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> u = new HashMap<>();
                u.put("userId", rs.getInt("user_id"));
                u.put("username", rs.getString("username"));
                u.put("fullName", rs.getString("full_name"));
                u.put("role", rs.getString("role"));
                u.put("isActive", rs.getBoolean("is_active"));
                users.add(u);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return users;
    }

    /**
     * Requirement #3: Data Integrity & Filtering
     * Uses LEFT JOINs so Manual Bills appear as "Manual/Other Fees".
     * This ensures the Grand Total here matches the Dashboard Total.
     */
    public List<Map<String, Object>> getRevenueReport(String startDate, String endDate) {
        List<Map<String, Object>> report = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT " +
            "  COALESCE(t.treatment_name, 'Manual/Other Fees') as t_name, " +
            "  COUNT(b.bill_id) as total_sessions, " +
            "  COUNT(DISTINCT b.patient_id) as unique_patients, " +
            "  SUM(b.amount_paid) as total_revenue, " +
            "  COALESCE(MAX(t.is_active), 1) as status " +
            "FROM bills b " +
            "LEFT JOIN appointments a ON b.appointment_id = a.appointment_id " +
            "LEFT JOIN treatments t ON a.treatment_id = t.treatment_id " +
            "WHERE b.payment_status IN ('paid', 'partial') "
        );

        if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
            sql.append(" AND b.created_at BETWEEN '").append(startDate).append(" 00:00:00' AND '")
               .append(endDate).append(" 23:59:59' ");
        }

        sql.append(" GROUP BY t.treatment_id, t.treatment_name ORDER BY total_revenue DESC");
                     
        try (ResultSet rs = dbConnection.executeQuery(sql.toString())) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", rs.getString("t_name"));
                row.put("count", rs.getInt("total_sessions"));
                row.put("patients", rs.getInt("unique_patients"));
                row.put("revenue", rs.getBigDecimal("total_revenue"));
                row.put("isActive", rs.getInt("status")); 
                report.add(row);
            }
        } catch (SQLException e) { 
            System.err.println("Revenue Report Error: " + e.getMessage());
        }
        return report;
    }
}