package com.dentalclinic.servlets;

import com.dentalclinic.database.UserDAO;
import com.dentalclinic.models.User;
import com.dentalclinic.utils.PasswordUtil;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    public void init() throws ServletException {
        try {
            this.userDAO = new UserDAO();
        } catch (Exception e) {
            System.err.println("FATAL: UserDAO initialization failed: " + e.getMessage());
            throw new ServletException("Failed to initialize system resources.", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            redirectToDashboard(request, response, user.getRole());
            return;
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String branchIdParam = request.getParameter("branch"); 
        
        if (branchIdParam == null || branchIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login?error=missingbranch");
            return;
        }

        try {
            int branchId = Integer.parseInt(branchIdParam);
            User user = userDAO.findUserForLogin(username, branchId); 
            
            if (user != null) {
                boolean passwordMatch = PasswordUtil.verifyPassword(password, user.getPassword());
                
                if (passwordMatch) {
                    HttpSession session = request.getSession();
                    user.setPassword(null); // Safety
                    session.setAttribute("user", user);
                    session.setMaxInactiveInterval(30 * 60);
                    
                    redirectToDashboard(request, response, user.getRole());
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/login?error=invalid");
            
        } catch (Exception e) {
            e.printStackTrace(); 
            response.sendRedirect(request.getContextPath() + "/error.jsp"); 
        }
    }
    
    /**
     * UPDATED: Role-based redirection logic.
     * Note how Receptionist now goes through the controller action.
     */
    private void redirectToDashboard(HttpServletRequest request, HttpServletResponse response, String role) 
            throws IOException {
        String context = request.getContextPath();
        String target;
        
        switch (role.toLowerCase()) {
            case "admin":
                target = "/admin/dashboard.jsp";
                break;
            case "receptionist":
                // FIX: Instead of going to .jsp, go to the Servlet Action to load data!
                target = "/receptionist/appointment-controller?action=viewDashboard";
                break;
            case "dentist":
                target = "/dentist/dashboard.jsp";
                break;
            case "hr":
                target = "/hr/dashboard.jsp";
                break;
            default:
                target = "/login?error=unauthorized";
                break;
        }
        response.sendRedirect(context + target);
    }
}