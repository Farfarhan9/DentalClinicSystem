package com.dentalclinic.servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get the existing session (do not create a new one)
        HttpSession session = request.getSession(false); 

        // Default redirect path
        String redirectPath = "/login?status=loggedout";

        // 2. Check if the session is active
        if (session != null) {
            // Identify if the user is a patient before destroying the session
            String role = (String) session.getAttribute("userRole");
            Object patientObj = session.getAttribute("patientUser");

            if ("patient".equals(role) || patientObj != null) {
                // If it's a patient, we change the destination
                redirectPath = "/patient_login.jsp?status=loggedout";
            }

            // 3. Invalidate the session, removing all stored attributes
            session.invalidate();
            System.out.println("Session invalidated successfully. Redirecting to: " + redirectPath);
        }
        
        // 4. Redirect the user back to the appropriate login page
        response.sendRedirect(request.getContextPath() + redirectPath);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}