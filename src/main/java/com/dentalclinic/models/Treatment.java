package com.dentalclinic.models;

import java.math.BigDecimal;

public class Treatment {
    
    private int treatmentId;
    private String treatmentName;
    private String description;
    private BigDecimal price;
    private Integer branchId;
    private Integer createdBy;
    private int isActive; // NEW: 1 for active, 0 for soft-deleted

    public Treatment() {}
    
    public Treatment(int treatmentId, String treatmentName, String description, 
                     BigDecimal price, Integer branchId, Integer createdBy, int isActive) {
        this.treatmentId = treatmentId;
        this.treatmentName = treatmentName;
        this.description = description;
        this.price = price;
        this.branchId = branchId;
        this.createdBy = createdBy;
        this.isActive = isActive;
    }

    // Accessors and Mutators
    public int getTreatmentId() { return treatmentId; }
    public void setTreatmentId(int treatmentId) { this.treatmentId = treatmentId; }

    public String getTreatmentName() { return treatmentName; }
    public void setTreatmentName(String treatmentName) { this.treatmentName = treatmentName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public Integer getBranchId() { return branchId; }
    public void setBranchId(Integer branchId) { this.branchId = branchId; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public int getIsActive() { return isActive; }
    public void setIsActive(int isActive) { this.isActive = isActive; }
    
    public String getDisplayPrice() {
        return this.treatmentName + ": RM" + this.price.toString();
    }
}