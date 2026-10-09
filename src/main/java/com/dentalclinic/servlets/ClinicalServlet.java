package com.dentalclinic.servlets;

import com.dentalclinic.models.TreatmentRecord;
import com.dentalclinic.database.ClinicalRecordDAO;
import com.dentalclinic.database.PatientDAO;
import com.dentalclinic.models.Appointment;
import com.dentalclinic.models.Patient;
import com.dentalclinic.models.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/clinical")
public class ClinicalServlet extends HttpServlet {
    private ClinicalRecordDAO clinicalDAO = new ClinicalRecordDAO();
    private PatientDAO patientDAO = new PatientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=timeout");
            return;
        }

        try {
            if ("viewQueue".equals(action) || action == null) {
                request.setAttribute("todayQueue", clinicalDAO.getTodayQueue(user.getUserId()));
                request.getRequestDispatcher("/dentist/patient/queue.jsp").forward(request, response);
            } 
            else if ("start".equals(action)) {
                String idParam = request.getParameter("id");
                if (idParam != null) {
                    int appointmentId = Integer.parseInt(idParam);
                    Appointment appt = clinicalDAO.getAppointmentById(appointmentId);
                    
                    if (appt != null) {
                        request.setAttribute("appointment", appt);
                        request.getRequestDispatcher("/dentist/patient/treatment_form.jsp").forward(request, response);
                        return;
                    }
                }
                response.sendRedirect(request.getContextPath() + "/dentist/dashboard.jsp?error=not_found");
            }
            else if ("finalizeList".equals(action)) {
                // NEW: Fetch appointments that are 'completed' but not yet 'billed'
                List<Appointment> completed = clinicalDAO.getCompletedAppointmentsToday(user.getUserId());
                request.setAttribute("completedList", completed);
                request.getRequestDispatcher("/dentist/patient/finalize_billing.jsp").forward(request, response);
            }
            else if ("searchPatient".equals(action)) {
                String query = request.getParameter("query");
                String sortBy = request.getParameter("sortBy");
                if (sortBy == null) sortBy = "name";
                
                List<Patient> patients = patientDAO.searchPatients(query, sortBy);
                request.setAttribute("patientResults", patients);
                request.getRequestDispatcher("/dentist/patient/lookup.jsp").forward(request, response);
            } 
            else if ("viewHistory".equals(action)) {
                int patientId = Integer.parseInt(request.getParameter("patientId"));
                List<TreatmentRecord> history = clinicalDAO.getPatientHistory(patientId);
                request.setAttribute("history", history);
                request.setAttribute("patientId", patientId);
                request.getRequestDispatcher("/dentist/patient/history.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Clinical Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String contextPath = request.getContextPath();
        
        try {
            if ("updateMedicalNotes".equals(action)) {
                int patientId = Integer.parseInt(request.getParameter("patientId"));
                String notes = request.getParameter("medicalNotes");
                
                Patient p = patientDAO.findPatientById(patientId);
                if (p != null) {
                    p.setMedicalNotes(notes);
                    boolean success = patientDAO.updatePatient(p);
                    if (success) {
                        response.sendRedirect(contextPath + "/clinical?action=searchPatient&status=updated&query=");
                        return;
                    }
                }
                response.sendRedirect(contextPath + "/clinical?action=searchPatient&error=update_failed");
                
            } else {
                // COMPLETE TREATMENT (from treatment_form.jsp)
                String apptIdRaw = request.getParameter("appointmentId");
                int appointmentId = Integer.parseInt(apptIdRaw);
                String diagnosis = request.getParameter("diagnosis");
                String notes = request.getParameter("treatment_notes"); 
                boolean success = clinicalDAO.completeTreatment(appointmentId, diagnosis, notes);
                
                // Redirect to finalize billing list so the dentist can enter prices immediately
                response.sendRedirect(contextPath + "/clinical?action=finalizeList&status=" + (success ? "completed" : "error"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(contextPath + "/dentist/dashboard.jsp?error=invalid_data");
        }
    }
}