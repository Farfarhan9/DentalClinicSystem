package com.dentalclinic.database;

import com.dentalclinic.models.Appointment;
import com.dentalclinic.models.Patient;
import com.dentalclinic.models.User;
import java.sql.*;
import java.util.*;
import java.util.Date;

public class AppointmentDAO {
    private DatabaseConnection dbConnection;

    public AppointmentDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) {
            System.err.println("Database Error: " + e.getMessage());
        }
    }

    public void updatePastAppointments() {
        String sql = "UPDATE appointments SET status = 'no-show' " +
                     "WHERE status = 'scheduled' AND " +
                     "CAST(CONCAT(appointment_date, ' ', start_time) AS DATETIME) < NOW()";
        try {
            dbConnection.executeUpdate(sql);
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public List<User> getAvailableDentists(int branchId, String date, String time) {
        List<User> dentists = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'dentist' AND branch_id = ? AND user_id NOT IN (" +
                     "SELECT dentist_id FROM appointments WHERE appointment_date = ? AND start_time = ? AND status NOT IN ('cancelled', 'no-show'))";
        try (ResultSet rs = dbConnection.executeQuery(sql, branchId, date, time)) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                dentists.add(u);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return dentists;
    }

    public List<Map<String, Object>> getBranchAppointments(int branchId, String targetDate) {
        updatePastAppointments();
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT a.*, p.full_name as patient_name, u.full_name as dentist_name " +
                     "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id " +
                     "JOIN users u ON a.dentist_id = u.user_id " +
                     "WHERE a.branch_id = ? AND a.appointment_date = ? AND a.status != 'cancelled' " +
                     "ORDER BY a.start_time ASC";
        try (ResultSet rs = dbConnection.executeQuery(sql, branchId, targetDate)) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("appointmentId", rs.getInt("appointment_id"));
                row.put("startTime", rs.getString("start_time"));
                row.put("patientName", rs.getString("patient_name"));
                row.put("dentistName", rs.getString("dentist_name"));
                row.put("status", rs.getString("status"));
                row.put("date", rs.getDate("appointment_date"));
                row.put("notes", rs.getString("notes"));
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String, Object>> getPatientAppointments(int patientId) {
        updatePastAppointments();
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name as dentist_name, b.branch_name " +
                     "FROM appointments a JOIN users u ON a.dentist_id = u.user_id " +
                     "JOIN branches b ON a.branch_id = b.branch_id " +
                     "WHERE a.patient_id = ? ORDER BY a.appointment_date DESC, a.start_time DESC";
        try (ResultSet rs = dbConnection.executeQuery(sql, patientId)) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("appointmentId", rs.getInt("appointment_id"));
                row.put("date", rs.getDate("appointment_date"));
                row.put("startTime", rs.getString("start_time"));
                row.put("status", rs.getString("status"));
                row.put("dentistName", rs.getString("dentist_name"));
                row.put("branchName", rs.getString("branch_name"));
                row.put("notes", rs.getString("notes"));
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Patient> searchActivePatients(String query) {
        List<Patient> patients = new ArrayList<>();
        String searchQuery = "%" + (query == null ? "" : query) + "%";
        String sql = "SELECT patient_id, full_name, phone FROM patients WHERE (full_name LIKE ? OR phone LIKE ?) AND status = 'Active'";
        try (ResultSet rs = dbConnection.executeQuery(sql, searchQuery, searchQuery)) {
            while (rs.next()) {
                Patient p = new Patient();
                p.setPatientId(rs.getInt("patient_id"));
                p.setFullName(rs.getString("full_name"));
                p.setPhone(rs.getString("phone"));
                patients.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return patients;
    }

    public String bookAppointment(Appointment appt) {
        // --- NEW VALIDATION: Check if appointment is in the past ---
        java.util.Date now = new java.util.Date();
        // Combine Date and Time for comparison
        Calendar targetCal = Calendar.getInstance();
        targetCal.setTime(appt.getAppointmentDate());
        String[] timeParts = appt.getStartTime().split(":");
        targetCal.set(Calendar.HOUR_OF_DAY, Integer.parseInt(timeParts[0]));
        targetCal.set(Calendar.MINUTE, Integer.parseInt(timeParts[1]));

        if (targetCal.getTime().before(now)) {
            return "ERROR: Cannot book an appointment in the past.";
        }
        // --- END NEW VALIDATION ---

        String conflictReason = checkBookingConflict(appt, -1);
        if (conflictReason != null) return "ERROR: " + conflictReason;
        
        String sql = "INSERT INTO appointments (patient_id, dentist_id, branch_id, appointment_date, start_time, end_time, status, notes, created_by) VALUES (?, ?, ?, ?, ?, ?, 'scheduled', ?, ?)";
        try {
            int result = dbConnection.executeUpdate(sql, appt.getPatientId(), appt.getDentistId(), appt.getBranchId(), new java.sql.Date(appt.getAppointmentDate().getTime()), appt.getStartTime(), appt.getEndTime(), appt.getNotes(), appt.getCreatedBy());
            return result > 0 ? "SUCCESS" : "ERROR: Database insertion failed.";
        } catch (SQLException e) { return "ERROR: " + e.getMessage(); }
    }

    public String cancelAppointment(int appointmentId, boolean isStaff) {
        if (!isStaff) {
            String checkSql = "SELECT appointment_date, start_time FROM appointments WHERE appointment_id = ?";
            try (ResultSet rs = dbConnection.executeQuery(checkSql, appointmentId)) {
                if (rs.next()) {
                    String dbDate = rs.getDate("appointment_date").toString();
                    String dbTime = rs.getString("start_time");
                    // Ensure HH:mm:ss format for Timestamp.valueOf
                    if (dbTime.length() == 5) dbTime += ":00";
                    if (dbTime.length() == 4) dbTime = "0" + dbTime + ":00";
                    
                    Timestamp apptTime = Timestamp.valueOf(dbDate + " " + dbTime);
                    long diff = apptTime.getTime() - System.currentTimeMillis();
                    if (diff < (48 * 3600000)) {
                        return "ERROR: Cancellations must be made at least 48 hours in advance.";
                    }
                }
            } catch (Exception e) { return "ERROR: Date validation failed."; }
        }
        // REMOVED 'updated_at' column to avoid "Unknown column" error
        String sql = "UPDATE appointments SET status = 'cancelled' WHERE appointment_id = ?";
        try {
            int result = dbConnection.executeUpdate(sql, appointmentId);
            return result > 0 ? "SUCCESS" : "ERROR: Cancellation failed.";
        } catch (SQLException e) { return "ERROR: " + e.getMessage(); }
    }

    private String checkBookingConflict(Appointment appt, int excludeApptId) {
        java.sql.Date sqlDate = new java.sql.Date(appt.getAppointmentDate().getTime());
        
        String dSql = "SELECT COUNT(*) FROM appointments WHERE dentist_id = ? AND appointment_date = ? AND status = 'scheduled' AND appointment_id != ? AND (start_time < ? AND end_time > ?)";
        try (ResultSet rs = dbConnection.executeQuery(dSql, appt.getDentistId(), sqlDate, excludeApptId, appt.getEndTime(), appt.getStartTime())) {
            if (rs.next() && rs.getInt(1) > 0) return "The selected dentist is already booked.";
        } catch (SQLException e) { e.printStackTrace(); }

        String pSql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND appointment_date = ? AND status = 'scheduled' AND appointment_id != ? AND (start_time < ? AND end_time > ?)";
        try (ResultSet rs = dbConnection.executeQuery(pSql, appt.getPatientId(), sqlDate, excludeApptId, appt.getEndTime(), appt.getStartTime())) {
            if (rs.next() && rs.getInt(1) > 0) return "You already have another appointment at this time.";
        } catch (SQLException e) { e.printStackTrace(); }

        return null; 
    }

    public String rescheduleAppointment(int appointmentId, java.util.Date newDate, String newStartTime, String newEndTime, boolean isStaff) {
        String timeCheckSql = "SELECT appointment_date, start_time, patient_id, dentist_id, branch_id FROM appointments WHERE appointment_id = ?";
        Appointment appt = new Appointment();
        try (ResultSet rs = dbConnection.executeQuery(timeCheckSql, appointmentId)) {
            if (rs.next()) {
                if (!isStaff) {
                    String dbDate = rs.getDate("appointment_date").toString();
                    String dbTime = rs.getString("start_time");
                    if (dbTime.length() == 5) dbTime += ":00";
                    
                    Timestamp apptTime = Timestamp.valueOf(dbDate + " " + dbTime);
                    if (apptTime.getTime() - System.currentTimeMillis() < (48 * 3600000)) {
                        return "ERROR: Rescheduling must be done at least 48 hours in advance.";
                    }
                }
                appt.setPatientId(rs.getInt("patient_id"));
                appt.setDentistId(rs.getInt("dentist_id"));
                appt.setBranchId(rs.getInt("branch_id"));
                appt.setAppointmentDate(newDate);
                appt.setStartTime(newStartTime);
                appt.setEndTime(newEndTime);
            }
        } catch (Exception e) { return "ERROR: Validation error."; }

        String conflict = checkBookingConflict(appt, appointmentId); 
        if (conflict != null) return "ERROR: " + conflict;

        // REMOVED 'updated_at' column to avoid "Unknown column" error
        String sql = "UPDATE appointments SET appointment_date = ?, start_time = ?, end_time = ?, status = 'scheduled' WHERE appointment_id = ?";
        try {
            int result = dbConnection.executeUpdate(sql, new java.sql.Date(newDate.getTime()), newStartTime, newEndTime, appointmentId);
            return result > 0 ? "SUCCESS" : "ERROR: Reschedule failed.";
        } catch (SQLException e) { return "ERROR: " + e.getMessage(); }
    }
}