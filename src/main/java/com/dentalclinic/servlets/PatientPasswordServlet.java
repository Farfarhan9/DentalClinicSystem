package com.dentalclinic.servlets;

import com.dentalclinic.database.PatientDAO;
import com.dentalclinic.models.Patient;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/patient/change-password")
public class PatientPasswordServlet extends HttpServlet {
    private PatientDAO patientDAO;

    @Override
    public void init() {
        this.patientDAO = new PatientDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Patient patient = (Patient) session.getAttribute("patientUser");
        String contextPath = request.getContextPath();
        String redirectPath = contextPath + "/patient/profile/view.jsp";

        // 1. Session Check
        if (patient == null) {
            response.sendRedirect(contextPath + "/patient_login.jsp");
            return;
        }

        String currentPwd = request.getParameter("currentPassword");
        String newPwd = request.getParameter("newPassword");
        String confirmPwd = request.getParameter("confirmPassword");

        // 2. Logic Validations & Null Safety
        String errorMsg = "";
        
        // Safety check to prevent NullPointerException if DAO didn't load password
        if (patient.getPassword() == null) {
            response.sendRedirect(redirectPath + "?error=system_error");
            return;
        }

        if (!patient.getPassword().equals(currentPwd)) {
            errorMsg = "wrong_current";
        } else if (newPwd == null || newPwd.trim().isEmpty()) {
            errorMsg = "empty_new";
        } else if (!newPwd.equals(confirmPwd)) {
            errorMsg = "mismatch";
        }

        if (!errorMsg.isEmpty()) {
            response.sendRedirect(redirectPath + "?error=" + errorMsg);
            return;
        }

        // 3. Database Update
        boolean success = patientDAO.updatePassword(patient.getPatientId(), newPwd);
        
        if (success) {
            patient.setPassword(newPwd);
            session.setAttribute("patientUser", patient);
            response.sendRedirect(redirectPath + "?status=pwd_success");
        } else {
            response.sendRedirect(redirectPath + "?error=db_error");
        }
    }
}