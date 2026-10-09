package com.dentalclinic.servlets;

import com.dentalclinic.database.PatientDAO;
import com.dentalclinic.models.Patient;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/receptionist/patient-controller")
public class PatientServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PatientDAO patientDAO = new PatientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String contextPath = request.getContextPath();
        
        if ("search".equals(action)) {
            String query = request.getParameter("query");
            String sortBy = request.getParameter("sortBy"); 
            List<Patient> results = patientDAO.searchPatients(query, sortBy);
            request.setAttribute("searchResults", results);
            request.getRequestDispatcher("/receptionist/patient/list.jsp").forward(request, response);
        } else if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Patient p = patientDAO.findPatientById(id);
                request.setAttribute("patient", p);
                request.getRequestDispatcher("/receptionist/patient/register.jsp").forward(request, response);
            } catch (Exception e) {
                response.sendRedirect(contextPath + "/receptionist/dashboard.jsp");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String contextPath = request.getContextPath();
        String fromDentist = request.getParameter("fromDentist");
        
        // Debug Log to see what's happening in your IDE Console
        System.out.println("DEBUG: PatientServlet POST - Action: " + action + ", fromDentist: " + fromDentist);

        try {
            String idStr = request.getParameter("patientId");
            int patientId = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : 0;
            
            if ("update".equals(action)) {
                if (patientId == 0) throw new Exception("Error: Patient ID is 0 or Null");

                Patient p = patientDAO.findPatientById(patientId);
                if (p == null) throw new Exception("Error: Patient with ID " + patientId + " not found");

                // Update text fields only if provided in request
                if (request.getParameter("fullName") != null) p.setFullName(request.getParameter("fullName"));
                if (request.getParameter("phone") != null) p.setPhone(request.getParameter("phone"));
                if (request.getParameter("email") != null) p.setEmail(request.getParameter("email"));
                if (request.getParameter("gender") != null) p.setGender(request.getParameter("gender"));
                if (request.getParameter("address") != null) p.setAddress(request.getParameter("address"));
                if (request.getParameter("medicalNotes") != null) p.setMedicalNotes(request.getParameter("medicalNotes"));
                if (request.getParameter("status") != null) p.setStatus(request.getParameter("status"));

                // Safe Date Parsing
                String dobStr = request.getParameter("dob");
                if (dobStr != null && !dobStr.isEmpty() && !dobStr.equals("null") && dobStr.length() > 5) {
                    try {
                        p.setDob(new SimpleDateFormat("yyyy-MM-dd").parse(dobStr));
                    } catch (Exception e) {
                        System.err.println("DEBUG: Date format error skipped: " + dobStr);
                    }
                }

                boolean success = patientDAO.updatePatient(p);
                
                if (success) {
                    if ("true".equals(fromDentist)) {
                        // Redirect back to Dentist Search
                        response.sendRedirect(contextPath + "/clinical?action=searchPatient&status=updated&query=" + java.net.URLEncoder.encode(p.getFullName(), "UTF-8"));
                    } else {
                        // Redirect back to Receptionist List
                        response.sendRedirect(contextPath + "/receptionist/patient-controller?action=search&query=");
                    }
                } else {
                    throw new Exception("Database update operation failed in DAO");
                }
            } else if ("register".equals(action)) {
                Patient newP = new Patient();
                newP.setFullName(request.getParameter("fullName"));
                newP.setPhone(request.getParameter("phone"));
                newP.setEmail(request.getParameter("email"));
                newP.setStatus("Active");
                int result = patientDAO.insertPatient(newP);
                response.sendRedirect(contextPath + "/receptionist/dashboard.jsp?msg=" + (result != -1 ? "patient_success" : "error"));
            }
        } catch (Exception e) {
            System.err.println("FATAL ERROR in PatientServlet: " + e.getMessage());
            e.printStackTrace(); 
            
            // If the call came from the dentist, we MUST redirect back to dentist area, even on error
            if ("true".equals(fromDentist)) {
                response.sendRedirect(contextPath + "/clinical?action=searchPatient&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            } else {
                response.sendRedirect(contextPath + "/receptionist/dashboard.jsp?error=exception");
            }
        }
    }
}