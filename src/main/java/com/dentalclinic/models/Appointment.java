package com.dentalclinic.models;

import java.util.Date;

public class Appointment {
    
    // Encapsulation: Private fields matching the SQL 'appointments' table
	private String patientName; // ADDED: To store name from JOIN
    private int appointmentId;
    private int patientId;
    private int dentistId;      // Maps to dentist_id in SQL (the doctor assigned)
    private int branchId;       // Essential for centralized multi-branch system
    private Date appointmentDate; // Maps to DATE in SQL (Date only, consistent with Patient.java)
    private String startTime;   // Maps to TIME in SQL (e.g., "09:00:00")
    private String endTime;     // Maps to TIME in SQL
    private String status;      // Maps to ENUM('scheduled', 'completed', 'cancelled', 'no_show')
    private Integer treatmentId; // Maps to treatment_id (Can be NULL, so use Integer wrapper)
    private String notes;       // Additional notes for the appointment
    private Integer createdBy;  // User who created the appointment (Can be NULL, use Integer wrapper)
    private Date createdAt;     // Timestamp of creation (consistent with Patient.java)

    // Default Constructor (Required for many frameworks and Servlets)
    public Appointment() {}
    
    // Comprehensive Constructor
    public Appointment(int appointmentId, int patientId, int dentistId, int branchId,
                       Date appointmentDate, String startTime, String endTime, 
                       String status, Integer treatmentId, String notes, Integer createdBy, Date createdAt) {
        this.appointmentId = appointmentId;
        this.patientId = patientId;
        this.dentistId = dentistId;
        this.branchId = branchId;
        this.appointmentDate = appointmentDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.status = status;
        this.treatmentId = treatmentId;
        this.notes = notes;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }
    
    // Simplified Constructor for scheduling a new appointment
    public Appointment(int patientId, int dentistId, int branchId,
                       Date appointmentDate, String startTime, String endTime, String notes, int createdBy) {
        this.patientId = patientId;
        this.dentistId = dentistId;
        this.branchId = branchId;
        this.appointmentDate = appointmentDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.notes = notes;
        this.createdBy = createdBy;
        this.status = "scheduled"; // Default status
        this.createdAt = new Date();
    }

    // --- Getter and Setter methods (Accessors/Mutators) ---

    public int getAppointmentId() { return appointmentId; }
    public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }

    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    public int getDentistId() { return dentistId; }
    public void setDentistId(int dentistId) { this.dentistId = dentistId; }

    public int getBranchId() { return branchId; }
    public void setBranchId(int branchId) { this.branchId = branchId; }

    public Date getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(Date appointmentDate) { this.appointmentDate = appointmentDate; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getTreatmentId() { return treatmentId; }
    public void setTreatmentId(Integer treatmentId) { this.treatmentId = treatmentId; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    
    // --- Business Logic Methods (Polymorphism Example) ---
    
    /**
     * Checks if the appointment is currently active (not cancelled or completed).
     */
    public boolean isActive() {
        return this.status.equals("scheduled") || 
               this.status.equals("completed") || 
               this.status.equals("billed");
    }
    
    /**
     * Utility method to combine Date and Time for display or conversion.
     * Note: This simple concatenation is useful for display but the Service layer 
     * must handle proper date/time object creation for comparison logic.
     */
    public String getFullDateTime() {
        // 
        return this.appointmentDate.toString() + " " + this.startTime;
    }
}