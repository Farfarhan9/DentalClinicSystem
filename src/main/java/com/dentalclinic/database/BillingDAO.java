package com.dentalclinic.database;

import com.dentalclinic.models.Bill;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class BillingDAO {
    private DatabaseConnection dbConnection;

    public BillingDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Bill> getDebtList(String searchName, String sortBy) {
        List<Bill> list = new ArrayList<>();
        String orderBy = "b.created_at ASC"; 
        if ("balance_desc".equals(sortBy)) {
            orderBy = "(b.total_amount - b.amount_paid) DESC";
        } else if ("balance_asc".equals(sortBy)) {
            orderBy = "(b.total_amount - b.amount_paid) ASC";
        } else if ("name".equals(sortBy)) {
            orderBy = "p.full_name ASC";
        }

        String sql = "SELECT b.*, p.full_name " +
                     "FROM bills b " +
                     "LEFT JOIN patients p ON b.patient_id = p.patient_id " +
                     "WHERE b.payment_status != 'paid' " +
                     "AND (COALESCE(b.total_amount, 0) - COALESCE(b.amount_paid, 0)) > 0 ";
        
        if (searchName != null && !searchName.trim().isEmpty()) {
            sql += "AND p.full_name LIKE ? ";
        }
        sql += "ORDER BY " + orderBy;
        
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql)) {
            if (searchName != null && !searchName.trim().isEmpty()) {
                stmt.setString(1, "%" + searchName + "%");
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Bill b = new Bill();
                    b.setBillId(rs.getInt("bill_id"));
                    b.setPatientId(rs.getInt("patient_id"));
                    b.setPatientName(rs.getString("full_name") != null ? rs.getString("full_name") : "Unknown Patient");
                    b.setAppointmentId((Integer) rs.getObject("appointment_id"));
                    b.setTotalAmount(rs.getBigDecimal("total_amount"));
                    b.setAmountPaid(rs.getBigDecimal("amount_paid"));
                    
                    String statusStr = rs.getString("payment_status");
                    if (statusStr != null) {
                        b.setPaymentStatus(Bill.PaymentStatus.valueOf(statusStr.toUpperCase()));
                    }
                    b.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createBill(Bill bill) {
        // We initialize amount_paid as 0.00 and status as 'pending'
        String sql = "INSERT INTO bills (appointment_id, patient_id, total_amount, amount_paid, payment_status, created_at) " +
                     "VALUES (?, ?, ?, 0.00, 'pending', NOW())";
        try {
            return dbConnection.executeUpdate(sql, 
                bill.getAppointmentId(), 
                bill.getPatientId(), 
                bill.getTotalAmount()) > 0;
        } catch (SQLException e) { 
            e.printStackTrace(); 
            return false; 
        }
    }

    public boolean recordPayment(int billId, BigDecimal paymentAmount) {
        String sql = "UPDATE bills SET amount_paid = amount_paid + ?, " +
                     "payment_status = CASE WHEN (amount_paid + ?) >= total_amount THEN 'paid' ELSE 'partial' END " +
                     "WHERE bill_id = ?";
        try {
            return dbConnection.executeUpdate(sql, paymentAmount, paymentAmount, billId) > 0;
        } catch (SQLException e) { 
            e.printStackTrace(); 
            return false; 
        }
    }

    public List<Bill> getBillsByPatient(int patientId) {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT * FROM bills WHERE patient_id = ? ORDER BY created_at DESC";
        try (ResultSet rs = dbConnection.executeQuery(sql, patientId)) {
            while (rs.next()) {
                Bill b = new Bill();
                b.setBillId(rs.getInt("bill_id"));
                b.setAppointmentId((Integer) rs.getObject("appointment_id"));
                b.setTotalAmount(rs.getBigDecimal("total_amount"));
                b.setAmountPaid(rs.getBigDecimal("amount_paid"));
                b.setPaymentStatus(Bill.PaymentStatus.valueOf(rs.getString("payment_status").toUpperCase()));
                b.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(b);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return list;
    }
}