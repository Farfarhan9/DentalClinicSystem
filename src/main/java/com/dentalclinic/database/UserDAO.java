package com.dentalclinic.database;

import com.dentalclinic.models.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO handles all database operations related to User accounts (Logins)
 * and coordinates with the Employee table for HR integration.
 */
public class UserDAO {
    
    private DatabaseConnection dbConnection;

    public UserDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) {
            System.err.println("FATAL: Failed to initialize UserDAO: " + e.getMessage());
        }
    }

    /**
     * Changes is_active status (True for reactivation, False for deactivation)
     */
    public boolean toggleUserStatus(int userId, boolean status) {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
        try {
            return dbConnection.executeUpdate(sql, status, userId) > 0;
        } catch (SQLException e) {
            System.err.println("Error toggling user status: " + e.getMessage());
            return false;
        }
    }

    /**
     * Permanently deletes user and their employee profile in a transaction.
     */
    public boolean deleteUserPermanently(int userId) {
        String sql1 = "DELETE FROM employees WHERE user_id = ?";
        String sql2 = "DELETE FROM users WHERE user_id = ?";
        Connection conn = null;
        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction
            
            try (PreparedStatement s1 = conn.prepareStatement(sql1);
                 PreparedStatement s2 = conn.prepareStatement(sql2)) {
                
                s1.setInt(1, userId);
                s1.executeUpdate();
                
                s2.setInt(1, userId);
                int affectedRows = s2.executeUpdate();
                
                if (affectedRows > 0) {
                    conn.commit(); // Save changes
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            }
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } }
            System.err.println("Error deleting user: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); } }
        }
    }

    /**
     * Authenticates a user based on username and branch ID.
     */
    public User findUserForLogin(String username, int branchId) {
        String sql = "SELECT user_id, username, password_hash, full_name, role, branch_id " +
                     "FROM users WHERE username = ? AND branch_id = ? AND is_active = TRUE";
        
        try (ResultSet rs = dbConnection.executeQuery(sql, username, branchId)) {
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password_hash")); 
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setBranchId(rs.getInt("branch_id"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Database error during user retrieval: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Retrieves a user by their ID.
     */
    public User findUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (ResultSet rs = dbConnection.executeQuery(sql, userId)) {
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setBranchId(rs.getInt("branch_id"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Database error during user ID retrieval: " + e.getMessage());
        }
        return null;
    }

    /**
     * Basic user insertion (Legacy support).
     */
    public boolean insertUser(User user) {
        String sql = "INSERT INTO users (username, password_hash, full_name, role, branch_id) VALUES (?, ?, ?, ?, ?)";
        try {
            int rowsAffected = dbConnection.executeUpdate(sql, 
                user.getUsername(), user.getPassword(), user.getFullName(), user.getRole(), user.getBranchId()
            );
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error inserting new user: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Creates a User and an Employee profile in one transaction.
     */
    public boolean insertUserWithEmployee(User user) {
        String userSql = "INSERT INTO users (username, password_hash, full_name, role, branch_id) VALUES (?, ?, ?, ?, ?)";
        String empSql = "INSERT INTO employees (user_id, hire_date, base_salary) VALUES (?, CURDATE(), 0.00)";
        Connection conn = null;
        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement uStmt = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS)) {
                uStmt.setString(1, user.getUsername());
                uStmt.setString(2, user.getPassword());
                uStmt.setString(3, user.getFullName());
                uStmt.setString(4, user.getRole());
                uStmt.setInt(5, user.getBranchId());
                uStmt.executeUpdate();
                try (ResultSet rs = uStmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newUserId = rs.getInt(1);
                        try (PreparedStatement eStmt = conn.prepareStatement(empSql)) {
                            eStmt.setInt(1, newUserId);
                            eStmt.executeUpdate();
                        }
                    }
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } }
            return false;
        } finally {
            if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); } }
        }
    }
    
    /**
     * Returns all users (excluding admins) for the management list.
     */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT user_id, username, full_name, role, branch_id FROM users WHERE role != 'admin'";
        
        try (ResultSet rs = dbConnection.executeQuery(sql)) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setRole(rs.getString("role"));
                u.setBranchId(rs.getInt("branch_id"));
                list.add(u);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching user list: " + e.getMessage());
        }
        return list;
    }

    /**
     * Checks if a user is currently active.
     */
    public boolean isUserActive(int userId) {
        String sql = "SELECT is_active FROM users WHERE user_id = ?";
        try (ResultSet rs = dbConnection.executeQuery(sql, userId)) {
            if (rs.next()) return rs.getBoolean("is_active");
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
    
    /**
     * Filters users by role and branch.
     */
    public List<User> getUsersByRole(String role, int branchId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT user_id, full_name, role, branch_id FROM users WHERE role = ? AND branch_id = ? AND is_active = TRUE";
        try (ResultSet rs = dbConnection.executeQuery(sql, role, branchId)) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setRole(rs.getString("role"));
                u.setBranchId(rs.getInt("branch_id"));
                list.add(u);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    /**
     * UPDATES an existing user's profile details.
     */
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET full_name = ?, username = ?, role = ?, branch_id = ? " +
                     (user.getPassword() != null && !user.getPassword().isEmpty() ? ", password_hash = ? " : "") +
                     "WHERE user_id = ?";
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getUsername());
            stmt.setString(3, user.getRole());
            stmt.setInt(4, user.getBranchId());
            
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                stmt.setString(5, user.getPassword());
                stmt.setInt(6, user.getUserId());
            } else {
                stmt.setInt(5, user.getUserId());
            }
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user: " + e.getMessage());
            return false;
        }
    }
}