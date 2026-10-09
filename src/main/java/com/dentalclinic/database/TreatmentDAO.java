package com.dentalclinic.database;

import com.dentalclinic.models.Treatment;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class TreatmentDAO {
    private DatabaseConnection dbConnection;

    public TreatmentDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) { 
            System.err.println("Failed to connect to DB in TreatmentDAO: " + e.getMessage());
        }
    }

    /**
     * READ: Fetches only ACTIVE treatments (is_active = 1)
     * This protects historical data in other tables.
     */
    public List<Treatment> getAllTreatments() {
        List<Treatment> list = new ArrayList<>();
        // IMPORTANT: Standard lists only show active ones
        String sql = "SELECT * FROM treatments WHERE is_active = 1";
        
        try (ResultSet rs = dbConnection.executeQuery(sql)) {
            while (rs.next()) {
                Treatment t = new Treatment();
                t.setTreatmentId(rs.getInt("treatment_id"));
                t.setTreatmentName(rs.getString("treatment_name"));
                t.setDescription(rs.getString("description"));
                t.setPrice(rs.getBigDecimal("price")); 
                t.setCreatedBy(rs.getInt("created_by"));
                // Map the new field if you want to use it in logic later
                // t.setIsActive(rs.getInt("is_active")); 
                list.add(t);
            }
        } catch (SQLException e) { /* log error */ }
        return list;
    }

    /**
     * Requirement #4: OOP Sorting
     */
    public List<Treatment> getSortedTreatments(String criteria) {
        List<Treatment> list = getAllTreatments();
        if (list == null || criteria == null) return list;

        if (criteria.equalsIgnoreCase("price_asc")) {
            Collections.sort(list, Comparator.comparing(Treatment::getPrice));
        } else if (criteria.equalsIgnoreCase("price_desc")) {
            Collections.sort(list, (t1, t2) -> t2.getPrice().compareTo(t1.getPrice()));
        } else if (criteria.equalsIgnoreCase("name_asc")) {
            Collections.sort(list, (t1, t2) -> t1.getTreatmentName().compareToIgnoreCase(t2.getTreatmentName()));
        }
        return list;
    }

    /**
     * Requirement #4: OOP Searching
     */
    public List<Treatment> searchTreatments(String query) {
        List<Treatment> list = getAllTreatments();
        if (query == null || query.trim().isEmpty()) return list;
        String lowerQuery = query.toLowerCase();
        return list.stream()
                   .filter(t -> t.getTreatmentName().toLowerCase().contains(lowerQuery))
                   .collect(Collectors.toList());
    }

    public boolean insertTreatment(Treatment t) {
        // Ensure is_active is set to 1 on creation
        String sql = "INSERT INTO treatments (treatment_name, description, price, created_by, is_active) VALUES (?, ?, ?, ?, 1)";
        try {
            return dbConnection.executeUpdate(sql, t.getTreatmentName(), t.getDescription(), t.getPrice(), t.getCreatedBy()) > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean updateTreatment(Treatment t) {
        String sql = "UPDATE treatments SET treatment_name = ?, description = ?, price = ? WHERE treatment_id = ?";
        try {
            return dbConnection.executeUpdate(sql, t.getTreatmentName(), t.getDescription(), t.getPrice(), t.getTreatmentId()) > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    /**
     * SOFT DELETE: Updates is_active to 0.
     * Solves Foreign Key constraint errors and preserves Revenue data.
     */
    public boolean deleteTreatment(int treatmentId) {
        String sql = "UPDATE treatments SET is_active = 0 WHERE treatment_id = ?";
        try {
            int rowsAffected = dbConnection.executeUpdate(sql, treatmentId);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error deactivating treatment: " + e.getMessage());
            return false;
        }
    }
}