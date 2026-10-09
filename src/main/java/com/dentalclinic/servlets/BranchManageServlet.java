package com.dentalclinic.servlets;

import com.dentalclinic.database.BranchDAO;
import com.dentalclinic.models.Branch;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/branch/manage")
public class BranchManageServlet extends HttpServlet {
    private BranchDAO branchDAO = new BranchDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        Branch b = new Branch();
        
        b.setBranchName(request.getParameter("branchName"));
        b.setAddress(request.getParameter("address"));
        b.setPhone(request.getParameter("phone"));
        b.setEmail(request.getParameter("email"));

        boolean success = false;
        if ("add".equals(action)) {
            success = branchDAO.insertBranch(b);
        } else if ("update".equals(action)) {
            b.setBranchId(Integer.parseInt(request.getParameter("branchId")));
            success = branchDAO.updateBranch(b);
        }

        response.sendRedirect(request.getContextPath() + "/admin/config/branch.jsp?status=" + (success ? "success" : "error"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int branchId = Integer.parseInt(request.getParameter("branchId"));
            branchDAO.deleteBranch(branchId);
        }
        response.sendRedirect(request.getContextPath() + "/admin/config/branch.jsp");
    }
}