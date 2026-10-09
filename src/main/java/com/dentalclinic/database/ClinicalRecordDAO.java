package com.dentalclinic.database;

import com.dentalclinic.models.TreatmentRecord;
import com.dentalclinic.models.Appointment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClinicalRecordDAO {
    private DatabaseConnection dbConnection;

    public ClinicalRecordDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Appointment> getTodayQueue(int dentistId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.full_name FROM appointments a " +
                     "JOIN patients p ON a.patient_id = p.patient_id " +
                     "WHERE a.dentist_id = ? AND a.appointment_date = CURDATE() " +
                     "AND a.status = 'scheduled' " +
                     "ORDER BY a.start_time ASC";
        
        try (ResultSet rs = dbConnection.executeQuery(sql, dentistId)) {
            while (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentId(rs.getInt("appointment_id"));
                a.setPatientId(rs.getInt("patient_id"));
                a.setPatientName(rs.getString("full_name"));
                a.setAppointmentDate(rs.getDate("appointment_date"));
                a.setStartTime(rs.getString("start_time"));
                a.setStatus(rs.getString("status"));
                list.add(a);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // NEW METHOD: Fetch single appointment details for the Treatment Form
    public Appointment getAppointmentById(int apptId) {
        String sql = "SELECT a.*, p.full_name FROM appointments a " +
                     "JOIN patients p ON a.patient_id = p.patient_id " +
                     "WHERE a.appointment_id = ?";
        try (ResultSet rs = dbConnection.executeQuery(sql, apptId)) {
            if (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentId(rs.getInt("appointment_id"));
                a.setPatientId(rs.getInt("patient_id"));
                a.setPatientName(rs.getString("full_name"));
                a.setAppointmentDate(rs.getDate("appointment_date"));
                a.setStartTime(rs.getString("start_time"));
                a.setStatus(rs.getString("status"));
                return a;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean completeTreatment(int apptId, String diagnosis, String notes) {
        try {
            // 1. Save the clinical notes first
            String sqlRecord = "INSERT INTO treatment_records (appointment_id, diagnosis, treatment_notes) VALUES (?, ?, ?)";
            int recordResult = dbConnection.executeUpdate(sqlRecord, apptId, diagnosis, notes);
            
            if (recordResult > 0) {
                // 2. Mark appointment as completed
                String sqlAppt = "UPDATE appointments SET status = 'completed' WHERE appointment_id = ?";
                return dbConnection.executeUpdate(sqlAppt, apptId) > 0;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("DAO Error in completeTreatment: " + e.getMessage());
            return false;
        }
    }

    public List<TreatmentRecord> getPatientHistory(int patientId) {
        List<TreatmentRecord> history = new ArrayList<>();
        String sql = "SELECT tr.*, a.appointment_date, u.full_name as dentist_name " +
                     "FROM treatment_records tr " +
                     "JOIN appointments a ON tr.appointment_id = a.appointment_id " +
                     "JOIN users u ON a.dentist_id = u.user_id " +
                     "WHERE a.patient_id = ? " +
                     "ORDER BY a.appointment_date DESC";
                     
        try (ResultSet rs = dbConnection.executeQuery(sql, patientId)) {
            while (rs.next()) {
                TreatmentRecord rec = new TreatmentRecord();
                rec.setRecordId(rs.getInt("record_id"));
                rec.setAppointmentId(rs.getInt("appointment_id"));
                rec.setDiagnosis(rs.getString("diagnosis"));
                rec.setTreatmentNotes(rs.getString("treatment_notes"));
                rec.setAppointmentDate(rs.getDate("appointment_date"));
                rec.setDentistName(rs.getString("dentist_name"));
                history.add(rec);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return history;
    }

    public List<Appointment> getCompletedAppointmentsToday(int dentistId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.full_name FROM appointments a " +
                "JOIN patients p ON a.patient_id = p.patient_id " +
                "WHERE a.dentist_id = ? AND a.status = 'completed' " +
                "AND a.appointment_date = CURDATE()";
                     
        try (ResultSet rs = dbConnection.executeQuery(sql, dentistId)) {
            while (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentId(rs.getInt("appointment_id"));
                a.setPatientId(rs.getInt("patient_id"));
                a.setPatientName(rs.getString("full_name"));
                a.setStartTime(rs.getString("start_time"));
                a.setStatus(rs.getString("status"));
                list.add(a);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}