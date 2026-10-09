package com.dentalclinic.servlets;

import com.dentalclinic.database.TreatmentDAO;
import com.dentalclinic.models.Treatment;
import com.dentalclinic.models.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/treatments")
public class TreatmentServlet extends HttpServlet {
    private TreatmentDAO treatmentDAO = new TreatmentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("user");
        String action = request.getParameter("action"); 

        try {
            Treatment t = new Treatment();
            t.setTreatmentName(request.getParameter("treatmentName")); 
            t.setDescription(request.getParameter("description"));
            t.setPrice(new java.math.BigDecimal(request.getParameter("price")));
            t.setCreatedBy(admin.getUserId());

            boolean success = false;
            if ("create".equals(action)) {
                success = treatmentDAO.insertTreatment(t);
            } else if ("edit".equals(action)) {
                t.setTreatmentId(Integer.parseInt(request.getParameter("treatmentId")));
                success = treatmentDAO.updateTreatment(t);
            }

            response.sendRedirect(request.getContextPath() + "/admin/config/services.jsp?status=" + (success ? "success" : "error"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/config/services.jsp?error=invalid_data");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String idParam = request.getParameter("treatmentId");
        
        if ("delete".equals(action) && idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                // This now calls the DAO update (Soft Delete) instead of a Hard Delete
                boolean success = treatmentDAO.deleteTreatment(id);
                response.sendRedirect(request.getContextPath() + "/admin/config/services.jsp?status=" + (success ? "deleted" : "delete_error"));
                return;
            } catch (NumberFormatException e) { e.printStackTrace(); }
        }
        response.sendRedirect(request.getContextPath() + "/admin/config/services.jsp");
    }
}