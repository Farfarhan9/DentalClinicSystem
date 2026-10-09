package com.dentalclinic.models;

import java.math.BigDecimal;
import java.util.Date;

public class Bill {

    public enum PaymentStatus {
        PAID, PENDING, PARTIAL 
    }

    public enum PaymentMethod {
        CASH, CARD, INSURANCE, ONLINE 
    }
    
    private int billId;
    private Integer appointmentId; 
    private int patientId;
    private String patientName; // ADDED THIS FIELD
    private BigDecimal totalAmount; 
    private BigDecimal amountPaid;  
    private PaymentMethod paymentMethod; 
    private PaymentStatus paymentStatus;
    private Date createdAt;
    
    public Bill() {
        this.amountPaid = BigDecimal.ZERO; 
        this.paymentStatus = PaymentStatus.PENDING;
        this.createdAt = new Date();
    }
    
    public Bill(int billId, Integer appointmentId, int patientId, BigDecimal totalAmount, 
                BigDecimal amountPaid, PaymentMethod paymentMethod, PaymentStatus paymentStatus, 
                Date createdAt) {
        this.billId = billId;
        this.appointmentId = appointmentId;
        this.patientId = patientId;
        this.totalAmount = totalAmount;
        this.amountPaid = amountPaid;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.createdAt = createdAt;
    }

    public Bill(int patientId, Integer appointmentId, BigDecimal totalAmount) {
        this(); 
        this.patientId = patientId;
        this.appointmentId = appointmentId;
        this.totalAmount = totalAmount;
    }

    // --- Getter and Setter methods ---
    
    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }

    public Integer getAppointmentId() { return appointmentId; }
    public void setAppointmentId(Integer appointmentId) { this.appointmentId = appointmentId; }

    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    // ADDED GETTER AND SETTER FOR NAME
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getAmountPaid() { return amountPaid; }
    public void setAmountPaid(BigDecimal amountPaid) { this.amountPaid = amountPaid; }

    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

    public PaymentStatus getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(PaymentStatus paymentStatus) { this.paymentStatus = paymentStatus; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    
    public BigDecimal getOutstandingBalance() {
        return this.totalAmount.subtract(this.amountPaid);
    }
    
    public boolean isPaid() {
        return getOutstandingBalance().compareTo(BigDecimal.ZERO) <= 0;
    }
}