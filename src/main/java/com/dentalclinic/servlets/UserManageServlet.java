package com.dentalclinic.servlets;

import com.dentalclinic.database.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import com.dentalclinic.models.User;

@WebServlet("/admin/user/manage")
public class UserManageServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");
        
        if (userIdStr != null && action != null) {
            int userId = Integer.parseInt(userIdStr);
            boolean success = false;

            if (action.equals("reactivate")) {
                success = userDAO.toggleUserStatus(userId, true);
            } else if (action.equals("deactivate")) {
                success = userDAO.toggleUserStatus(userId, false);
            } else if (action.equals("delete")) {
                success = userDAO.deleteUserPermanently(userId);
            }

            response.sendRedirect(request.getContextPath() + "/admin/user/list.jsp?status=" + (success ? "ok" : "err"));
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("update".equals(action)) {
            User u = new User();
            u.setUserId(Integer.parseInt(request.getParameter("userId")));
            u.setFullName(request.getParameter("fullName"));
            u.setUsername(request.getParameter("username"));
            u.setRole(request.getParameter("role"));
            u.setBranchId(Integer.parseInt(request.getParameter("branchId")));
            u.setPassword(request.getParameter("password")); // Handle logic in DAO to ignore if empty

            if (userDAO.updateUser(u)) {
                response.sendRedirect(request.getContextPath() + "/admin/user/list.jsp?status=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/user/list.jsp?error=update_failed");
            }
        }
    }
}