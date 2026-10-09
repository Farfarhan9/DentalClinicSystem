package com.dentalclinic.servlets;

import com.dentalclinic.database.HrDAO;
import com.dentalclinic.models.Employee;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/hr/employee/update")
public class EmployeeServlet extends HttpServlet {
    private HrDAO hrDAO = new HrDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            int empId = Integer.parseInt(request.getParameter("employeeId")); 
            
            Employee emp = new Employee();
            emp.setUserId(userId);
            emp.setEmployeeId(empId);
            emp.setNricPassport(request.getParameter("nricPassport"));
            emp.setBaseSalary(new BigDecimal(request.getParameter("baseSalary")));
            emp.setEpfNumber(request.getParameter("epfNumber"));
            emp.setBankName(request.getParameter("bankName"));
            emp.setBankAccount(request.getParameter("bankAccount"));

            if (hrDAO.saveOrUpdateEmployee(emp)) {
                response.sendRedirect(request.getContextPath() + "/hr/employee/records.jsp?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/hr/employee/records.jsp?error=db");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/hr/employee/records.jsp?error=invalid_data");
        }
    }
}