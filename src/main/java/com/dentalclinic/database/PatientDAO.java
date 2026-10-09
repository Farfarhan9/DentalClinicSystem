package com.dentalclinic.database;

import com.dentalclinic.models.Patient;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO {
    
    private DatabaseConnection dbConnection;

    public PatientDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) {
            System.err.println("FATAL: Failed to initialize PatientDAO: " + e.getMessage());
        }
    }

    public Patient login(String identifier, String password) {
        String sql = "SELECT * FROM patients WHERE (phone = ? OR email = ?) AND password = ? AND status = 'Active'";
        try (ResultSet rs = dbConnection.executeQuery(sql, identifier, identifier, password)) {
            if (rs.next()) {
                return extractPatientFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("Database error during patient login: " + e.getMessage());
        }
        return null;
    }

    public int insertPatient(Patient patient) {
        String sql = "INSERT INTO patients (full_name, phone, email, dob, gender, address, medical_notes, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            int rowsAffected = dbConnection.executeUpdate(sql, 
                    patient.getFullName(), 
                    patient.getPhone(), 
                    patient.getEmail(),
                    patient.getDob() != null ? new java.sql.Date(patient.getDob().getTime()) : null, 
                    patient.getGender(),
                    patient.getAddress(),
                    patient.getMedicalNotes(),
                    patient.getStatus()
                );
            return rowsAffected > 0 ? 1 : -1;
        } catch (SQLException e) {
            System.err.println("Error inserting new patient: " + e.getMessage());
            return -1;
        }
    }
    
    public boolean updatePatient(Patient patient) {
        // We use patient.getPatientId() explicitly
        String sql = "UPDATE patients SET full_name=?, phone=?, email=?, dob=?, " +
                     "gender=?, address=?, medical_notes=?, status=? WHERE patient_id=?";
        try {
            return dbConnection.executeUpdate(sql, 
                patient.getFullName(), 
                patient.getPhone(), 
                patient.getEmail(),
                patient.getDob() != null ? new java.sql.Date(patient.getDob().getTime()) : null,
                patient.getGender(),
                patient.getAddress(),
                patient.getMedicalNotes(),
                patient.getStatus(),
                patient.getPatientId() // Ensure this is the PK from patients table
            ) > 0;
        } catch (SQLException e) {
            System.err.println("DAO Error: " + e.getMessage());
            return false;
        }
    }

    public Patient findPatientById(int patientId) {
        String sql = "SELECT * FROM patients WHERE patient_id = ?";
        try (ResultSet rs = dbConnection.executeQuery(sql, patientId)) {
            if (rs.next()) {
                return extractPatientFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("Database error retrieving patient by ID: " + e.getMessage());
        }
        return null;
    }

    public List<Patient> searchPatients(String query, String sortBy) {
        List<Patient> patients = new ArrayList<>();
        String searchQuery = "%" + (query == null ? "" : query) + "%";
        
        String orderByClause = "full_name ASC"; 
        if ("id".equals(sortBy)) orderByClause = "patient_id ASC";
        else if ("status".equals(sortBy)) orderByClause = "status ASC";
        else if ("name_desc".equals(sortBy)) orderByClause = "full_name DESC";

        String sql = "SELECT * FROM patients WHERE (full_name LIKE ? OR phone LIKE ?) ORDER BY " + orderByClause;
        
        try (ResultSet rs = dbConnection.executeQuery(sql, searchQuery, searchQuery)) {
            while (rs.next()) {
                patients.add(extractPatientFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("Database error during patient search: " + e.getMessage());
        }
        return patients;
    }

    public List<Patient> searchActivePatients(String query) {
        List<Patient> patients = new ArrayList<>();
        String searchQuery = "%" + query + "%"; 
        String sql = "SELECT * FROM patients WHERE (full_name LIKE ? OR phone LIKE ?) AND status = 'Active'";
        try (ResultSet rs = dbConnection.executeQuery(sql, searchQuery, searchQuery)) {
            while (rs.next()) {
                patients.add(extractPatientFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("Database error during active patient search: " + e.getMessage());
        }
        return patients;
    }
    
    public int selfRegisterPatient(Patient patient) {
        String sql = "INSERT INTO patients (full_name, phone, email, dob, gender, address, password, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'Active')";
        try {
            int rowsAffected = dbConnection.executeUpdate(sql, 
                    patient.getFullName(), 
                    patient.getPhone(), 
                    patient.getEmail(),
                    patient.getDob() != null ? new java.sql.Date(patient.getDob().getTime()) : null, 
                    patient.getGender(),
                    patient.getAddress(),
                    patient.getPassword()
                );
            return rowsAffected > 0 ? 1 : -1;
        } catch (SQLException e) {
            System.err.println("Error during patient self-registration: " + e.getMessage());
            return -1;
        }
    }
    
    public boolean updatePassword(int patientId, String newPassword) {
        String sql = "UPDATE patients SET password = ? WHERE patient_id = ?";
        try {
            int rows = dbConnection.executeUpdate(sql, newPassword, patientId);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating password: " + e.getMessage());
            return false;
        }
    }

    private Patient extractPatientFromResultSet(ResultSet rs) throws SQLException {
        Patient patient = new Patient();
        patient.setPatientId(rs.getInt("patient_id"));
        patient.setFullName(rs.getString("full_name"));
        patient.setPhone(rs.getString("phone"));
        patient.setEmail(rs.getString("email"));
        patient.setDob(rs.getDate("dob"));
        patient.setGender(rs.getString("gender"));
        patient.setAddress(rs.getString("address"));
        patient.setMedicalNotes(rs.getString("medical_notes"));
        patient.setStatus(rs.getString("status"));
        patient.setCreatedAt(rs.getTimestamp("created_at"));
        patient.setPassword(rs.getString("password")); 
        return patient;
    }
}