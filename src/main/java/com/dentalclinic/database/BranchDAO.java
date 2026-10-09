package com.dentalclinic.database;

import com.dentalclinic.models.Branch;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BranchDAO {
    private DatabaseConnection dbConnection;

    public BranchDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) {
            System.err.println("BranchDAO Connection Error: " + e.getMessage());
        }
    }

    /**
     * Retrieves all branches (Used for Login dropdown and Admin management)
     */
    public List<Branch> getAllBranches() {
        List<Branch> list = new ArrayList<>();
        String sql = "SELECT * FROM branches ORDER BY branch_id ASC";
        
        try (ResultSet rs = dbConnection.executeQuery(sql)) {
            while (rs.next()) {
                Branch b = new Branch();
                b.setBranchId(rs.getInt("branch_id"));
                b.setBranchName(rs.getString("branch_name"));
                b.setAddress(rs.getString("address"));
                b.setPhone(rs.getString("phone"));
                b.setEmail(rs.getString("email"));
                list.add(b);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching branches: " + e.getMessage());
        }
        return list;
    }

    /**
     * Adds a new branch to the system
     */
    public boolean insertBranch(Branch b) {
        String sql = "INSERT INTO branches (branch_name, address, phone, email) VALUES (?, ?, ?, ?)";
        try {
            int rows = dbConnection.executeUpdate(sql, 
                b.getBranchName(), 
                b.getAddress(), 
                b.getPhone(), 
                b.getEmail()
            );
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error inserting branch: " + e.getMessage());
            return false;
        }
    }
    /**
     * Updates an existing branch's details
     */
    public boolean updateBranch(Branch b) {
        String sql = "UPDATE branches SET branch_name = ?, address = ?, phone = ?, email = ? WHERE branch_id = ?";
        try {
            int rows = dbConnection.executeUpdate(sql, 
                b.getBranchName(), b.getAddress(), b.getPhone(), b.getEmail(), b.getBranchId()
            );
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating branch: " + e.getMessage());
            return false;
        }
    }

    /**
     * Deletes a branch permanently
     */
    public boolean deleteBranch(int branchId) {
        String sql = "DELETE FROM branches WHERE branch_id = ?";
        try {
            int rows = dbConnection.executeUpdate(sql, branchId);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting branch: " + e.getMessage());
            return false;
        }
    }
}