package com.dentalclinic.models;

public class Branch {
    
    // Encapsulation: Private fields matching the SQL 'branches' table
    private int branchId;
    private String branchName;
    private String address;
    private String phone;
    private String email;
    private int totalSurgeries; // New field for number of surgeries
    
    // Default Constructor (Required for many frameworks and Servlets)
    public Branch() {}
    
    // Comprehensive Constructor
    public Branch(int branchId, String branchName, String address, String phone, String email) {
        this.branchId = branchId;
        this.branchName = branchName;
        this.address = address;
        this.phone = phone;
        this.email = email;
    }

    // --- Getter and Setter methods (Accessors/Mutators) ---

    public int getBranchId() { return branchId; }
    public void setBranchId(int branchId) { this.branchId = branchId; }

    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public int getTotalSurgeries() { return totalSurgeries; }
    public void setTotalSurgeries(int totalSurgeries) { this.totalSurgeries = totalSurgeries; }

    
    // --- Business Logic Methods (Polymorphism Example) ---
    
    /**
     * Gets the simple display name for use in dropdowns (like login.jsp).
     */
    public String getDisplayName() {
        return this.branchName + " (" + this.address.split(",")[1].trim() + ")"; 
    }
    
    /**
     * Checks if the branch is fully operational (e.g., has a valid address/phone).
     */
    public boolean isOperational() {
        return this.address != null && this.phone != null;
    }
}