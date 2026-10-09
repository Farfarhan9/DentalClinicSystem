package com.dentalclinic.models;

import java.util.Date;

// INHERITANCE: Patient extends User
public class Patient extends User {
    private int patientId;
    private String phone;
    private Date dob;           
    private String gender;      
    private String address;    
    private String medicalNotes;
    private Date createdAt;
    private String status = "Active";

    public Patient() {
        super();
        this.role = "patient"; // Automatically set role
    }
    
    public Patient(String fullName, String phone, String email) {
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.createdAt = new Date();
        this.role = "patient";
    }
    
    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    
    public Date getDob() { return dob; }
    public void setDob(Date dob) { this.dob = dob; }
    
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    
    public String getMedicalNotes() { return medicalNotes; }
    public void setMedicalNotes(String medicalNotes) { this.medicalNotes = medicalNotes; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // Display info logic remains same
    public String getDisplayInfo() {
        return fullName + " | " + phone;
    }
    
    public String getDetailedInfo() {
        return "Patient: " + fullName + "\nPhone: " + phone + "\nEmail: " + email;
    }
    
    public boolean isValidPatient() {
        return fullName != null && !fullName.trim().isEmpty() 
               && phone != null && phone.matches("\\d{10,11}");
    }
}