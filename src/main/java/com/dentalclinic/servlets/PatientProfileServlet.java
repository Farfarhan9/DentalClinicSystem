package com.dentalclinic.servlets;

import com.dentalclinic.database.PatientDAO;
import com.dentalclinic.models.Patient;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/patient/profile-controller")
public class PatientProfileServlet extends HttpServlet {
    
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        this.patientDAO = new PatientDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Patient currentPatient = (Patient) session.getAttribute("patientUser");

        if (currentPatient == null) {
            response.sendRedirect(request.getContextPath() + "/patient_login.jsp");
            return;
        }

        try {
            // 1. Update the currentPatient object with form data
            currentPatient.setFullName(request.getParameter("fullName"));
            currentPatient.setPhone(request.getParameter("phone"));
            currentPatient.setEmail(request.getParameter("email"));
            currentPatient.setGender(request.getParameter("gender"));
            currentPatient.setAddress(request.getParameter("address"));
            
            String dobStr = request.getParameter("dob");
            if (dobStr != null && !dobStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                currentPatient.setDob(sdf.parse(dobStr));
            }

            // 2. Use your existing updatePatient method from PatientDAO
            boolean success = patientDAO.updatePatient(currentPatient);

            if (success) {
                // Refresh session data so dashboard shows new name
                session.setAttribute("patientUser", currentPatient);
                response.sendRedirect(request.getContextPath() + "/patient/profile/view.jsp?status=updated");
            } else {
                request.setAttribute("errorMessage", "Database update failed. Please try again.");
                request.getRequestDispatcher("/patient/profile/view.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/patient/profile/view.jsp?error=invalid");
        }
    }
}