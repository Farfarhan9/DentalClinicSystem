package com.dentalclinic.models;

public class User {
    // Protected fields allow subclasses to inherit them
    protected int userId;
    protected String username;
    protected String password;
    protected String fullName;
    protected String email; // ADDED THIS to fix Patient.java error
    protected String role;
    protected int branchId;
    
    public User() {}
    
    public User(int id, String username, String password, String role, int branchId) {
        this.userId = id;
        this.username = username;
        this.password = password;
        this.role = role;
        this.branchId = branchId;
    }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    // ADDED EMAIL METHODS
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public int getBranchId() { return branchId; }
    public void setBranchId(int branchId) { this.branchId = branchId; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public boolean checkPassword(String inputPassword) {
        return this.password != null && this.password.equals(inputPassword);
    }
    
    public String getDashboardUrl() {
        return "/dashboard.jsp";
    }
}