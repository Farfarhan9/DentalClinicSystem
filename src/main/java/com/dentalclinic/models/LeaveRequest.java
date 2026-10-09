
package com.dentalclinic.models;

import java.sql.Date;

public class LeaveRequest {
    private int requestId;
    private int userId;
    private int employeeId;
    private String employeeName;
    private String role;
    private String leaveType;
    private Date fromDate;
    private Date toDate;
    private String reason;
    private String coveragePerson;
    private String status;

    // Getters and setters for all fields
    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getLeaveType() { return leaveType; }
    public void setLeaveType(String leaveType) { this.leaveType = leaveType; }
    public Date getFromDate() { return fromDate; }
    public void setFromDate(Date fromDate) { this.fromDate = fromDate; }
    public Date getToDate() { return toDate; }
    public void setToDate(Date toDate) { this.toDate = toDate; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getCoveragePerson() { return coveragePerson; }
    public void setCoveragePerson(String coveragePerson) { this.coveragePerson = coveragePerson; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
