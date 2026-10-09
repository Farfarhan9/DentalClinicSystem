package com.dentalclinic.servlets;

import com.dentalclinic.database.UserDAO;
import com.dentalclinic.models.User;
import com.dentalclinic.utils.PasswordUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/staff")
public class StaffServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String fullName = request.getParameter("fullName");
            String username = request.getParameter("username");
            String role = request.getParameter("role");
            String branchIdStr = request.getParameter("branchId");
            String plainPassword = request.getParameter("password");

            // SAFETY CHECK: Prevent the NullPointerException
            if (plainPassword == null || plainPassword.isEmpty()) {
                plainPassword = "password123"; 
            }

            // 1. Prepare the User object
            User newUser = new User();
            newUser.setFullName(fullName);
            newUser.setUsername(username);
            newUser.setRole(role);
            
            try {
                newUser.setBranchId(Integer.parseInt(branchIdStr));
            } catch (NumberFormatException e) {
                newUser.setBranchId(1); 
            }
            
            // 2. Hash the password
            String hashedPassword = PasswordUtil.hashPassword(plainPassword);
            newUser.setPassword(hashedPassword);

            // 3. Conditional Save Logic
            boolean success;
            if ("admin".equalsIgnoreCase(role)) {
                // Admins don't need HR/Salary records
                success = userDAO.insertUser(newUser);
            } else {
                // Everyone else gets a Login + Employee record
                success = userDAO.insertUserWithEmployee(newUser);
            }

            // 4. Redirect based on result
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/user/list.jsp?msg=created");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/user/create.jsp?error=db_error");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/user/list.jsp");
    }
}