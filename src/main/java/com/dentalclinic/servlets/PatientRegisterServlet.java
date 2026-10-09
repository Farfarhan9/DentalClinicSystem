package com.dentalclinic.servlets;

import com.dentalclinic.database.PatientDAO;
import com.dentalclinic.models.Patient;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;

@WebServlet("/patientRegister")
public class PatientRegisterServlet extends HttpServlet {
    private PatientDAO patientDAO = new PatientDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 1. Capture parameters from patient_register.jsp
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String dobStr = request.getParameter("dob");
            String gender = request.getParameter("gender");
            String password = request.getParameter("password");

            // 2. Create and populate Patient object
            Patient newPatient = new Patient();
            newPatient.setFullName(fullName);
            newPatient.setEmail(email);
            newPatient.setPhone(phone);
            newPatient.setGender(gender);
            newPatient.setPassword(password); // Set the user's chosen password
            newPatient.setRole("patient");

            // Parse Date
            if (dobStr != null && !dobStr.isEmpty()) {
                newPatient.setDob(new SimpleDateFormat("yyyy-MM-dd").parse(dobStr));
            }

            // 3. Use the NEW self-registration method
            int result = patientDAO.selfRegisterPatient(newPatient);

            if (result > 0) {
                // Success: Redirect to login page
                response.sendRedirect("patient_login.jsp?registration=success");
            } else {
                // Failure: Go back to register with error
                response.sendRedirect("patient_register.jsp?error=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("patient_register.jsp?error=system");
        }
    }
}