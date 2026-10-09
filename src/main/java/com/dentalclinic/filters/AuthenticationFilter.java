package com.dentalclinic.filters;

import com.dentalclinic.models.User;
import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// Apply this filter to all URLs under the role-specific directories
@WebFilter({"/admin/*", "/receptionist/*", "/dentist/*", "/hr/*"})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code (not strictly necessary here)
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false); // Do not create a new session
        
        String loginURI = req.getContextPath() + "/login";
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        
        if (isLoggedIn) {
            // User is logged in. Get the role for finer access control.
            User user = (User) session.getAttribute("user");
            String path = req.getRequestURI().substring(req.getContextPath().length());
            
            // Simplified Role-Based Access Control (RBAC) check:
            // Ensure the user's role matches the dashboard they are trying to access.
            boolean hasPermission = false;
            String userRole = user.getRole().toLowerCase();

            if (path.startsWith("/admin/") && userRole.equals("admin")) {
                hasPermission = true;
            } else if (path.startsWith("/receptionist/") && userRole.equals("receptionist")) {
                hasPermission = true;
            } else if (path.startsWith("/dentist/") && userRole.equals("dentist")) {
                hasPermission = true;
            } else if (path.startsWith("/hr/") && userRole.equals("hr")) {
                hasPermission = true;
            }
            // 
            
            if (hasPermission) {
                // User has session and permission, allow access to the resource
                chain.doFilter(request, response);
            } else {
                // Logged in but trying to access a restricted page (e.g., Dentist trying to see Admin page)
                res.sendRedirect(loginURI + "?error=unauthorized");
            }
            
        } else {
            // User is NOT logged in, redirect them to the login page
            res.sendRedirect(loginURI + "?error=timeout");
        }
    }

    @Override
    public void destroy() {
        // Cleanup code (not strictly necessary here)
    }
}