package com.dentalclinic.servlets;

import com.dentalclinic.database.HrDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/hr/employee/deactivate")
public class DeactivateEmployeeServlet extends HttpServlet {
    private HrDAO hrDAO = new HrDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            
            if (hrDAO.deactivateEmployee(userId)) {
                response.sendRedirect(request.getContextPath() + "/hr/employee/records.jsp?success=deactivated");
            } else {
                response.sendRedirect(request.getContextPath() + "/hr/employee/records.jsp?error=fail");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/hr/employee/records.jsp?error=invalid");
        }
    }
}