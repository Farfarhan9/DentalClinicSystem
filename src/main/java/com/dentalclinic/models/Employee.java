package com.dentalclinic.models;

import java.math.BigDecimal;
import java.util.Date;

// INHERITANCE: Employee extends User
public class Employee extends User {
    private int employeeId;
    private String nricPassport;
    private BigDecimal baseSalary;
    private Date hireDate;
    private Date contractExpiry;
    private String epfNumber;
    private String bankAccount;
    private String bankName;

    public Employee() {
        super(); // Calls User() constructor
    }

    // Getters and Setters (userId, fullName, role are now handled by User parent)
    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public String getNricPassport() { return nricPassport; }
    public void setNricPassport(String nricPassport) { this.nricPassport = nricPassport; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public Date getHireDate() { return hireDate; }
    public void setHireDate(Date hireDate) { this.hireDate = hireDate; }

    public Date getContractExpiry() { return contractExpiry; }
    public void setContractExpiry(Date contractExpiry) { this.contractExpiry = contractExpiry; }

    public String getEpfNumber() { return epfNumber; }
    public void setEpfNumber(String epfNumber) { this.epfNumber = epfNumber; }

    public String getBankAccount() { return bankAccount; }
    public void setBankAccount(String bankAccount) { this.bankAccount = bankAccount; }

    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }
}