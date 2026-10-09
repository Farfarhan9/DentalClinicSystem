package com.dentalclinic.servlets;

import com.dentalclinic.database.PatientDAO;
import com.dentalclinic.models.Patient;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class PatientLoginServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String identifier = request.getParameter("identifier"); 
        String password = request.getParameter("password");

        try {
            PatientDAO dao = new PatientDAO();
            Patient patient = dao.login(identifier, password); 

            if (patient != null) {
                HttpSession session = request.getSession();
                session.setAttribute("patientUser", patient);
                session.setAttribute("userRole", "patient");
                
                // FIXED: Redirect to the controller instead of the JSP file
                // This ensures the appointment list is loaded before the page displays
                response.sendRedirect(request.getContextPath() + "/patient/booking-controller?action=viewDashboard");
            } else {
                response.sendRedirect("patient_login.jsp?error=invalid");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("patient_login.jsp?error=system_error");
        }
    }
}