package com.dentalclinic.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DatabaseConnection {
    private static DatabaseConnection instance;
    private Connection connection = null;
    private String url = "jdbc:mysql://localhost:3306/dental_clinic_db?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    private String username = "root";
    private String password = ""; 
    
    private DatabaseConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            this.connection = DriverManager.getConnection(url, username, password);
            System.out.println("Database connection established!");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }
    }
    
    public static DatabaseConnection getInstance() throws SQLException {
        if (instance == null || instance.getConnection() == null || instance.getConnection().isClosed()) {
            instance = new DatabaseConnection();
        } 
        return instance;
    }

    public Connection getConnection() {
        return connection;
    }

    // New DAO Method: Utility for SELECT queries
    public ResultSet executeQuery(String sql, Object... params) throws SQLException {
        PreparedStatement stmt = connection.prepareStatement(sql);
        for (int i = 0; i < params.length; i++) {
            stmt.setObject(i + 1, params[i]);
        }
        return stmt.executeQuery();
    }
    
    // New DAO Method: Utility for INSERT/UPDATE/DELETE (Auto-closes Statement)
    public int executeUpdate(String sql, Object... params) throws SQLException {
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                stmt.setObject(i + 1, params[i]);
            }
            return stmt.executeUpdate();
        }
    }

    // LEGACY SUPPORT: This fixes the errors in PatientLogin/Register Servlets
    public PreparedStatement prepareStatement(String sql, Object... params) throws SQLException {
        PreparedStatement stmt = connection.prepareStatement(sql);
        for (int i = 0; i < params.length; i++) {
            stmt.setObject(i + 1, params[i]);
        }
        return stmt;
    }
    
    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}