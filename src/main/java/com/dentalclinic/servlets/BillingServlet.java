package com.dentalclinic.servlets;

import com.dentalclinic.database.BillingDAO;
import com.dentalclinic.database.PatientDAO;
import com.dentalclinic.database.DatabaseConnection;
import com.dentalclinic.models.Bill;
import com.dentalclinic.models.Patient;
import com.dentalclinic.models.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.math.BigDecimal;

@WebServlet("/billing")
public class BillingServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;

    private BillingDAO getBillingDAO() { return new BillingDAO(); }
    private PatientDAO getPatientDAO() { return new PatientDAO(); }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        BillingDAO billingDAO = getBillingDAO();
        PatientDAO patientDAO = getPatientDAO();

        if ("viewDebts".equals(action)) {
            String searchName = request.getParameter("patientSearch");
            String sortBy = request.getParameter("sortBy");
            List<Bill> debts = billingDAO.getDebtList(searchName, sortBy); 
            request.setAttribute("debtList", debts); 
            request.getRequestDispatcher("/receptionist/billing/debtors.jsp").forward(request, response);
            
        } else if ("searchPatient".equals(action)) {
            String query = request.getParameter("query");
            String sortBy = request.getParameter("sortBy");
            String searchQuery = (query == null) ? "" : query.trim();
            List<Patient> patients = patientDAO.searchPatients(searchQuery, sortBy);
            request.setAttribute("patientResults", patients);
            request.getRequestDispatcher("/receptionist/billing/lookup.jsp").forward(request, response);
            
        } else if ("viewHistory".equals(action)) {
            String pIdRaw = request.getParameter("patientId");
            if (pIdRaw != null) {
                int patientId = Integer.parseInt(pIdRaw);
                List<Bill> history = billingDAO.getBillsByPatient(patientId);
                request.setAttribute("invoiceHistory", history);
                request.setAttribute("patientId", patientId);
            }
            request.getRequestDispatcher("/receptionist/billing/lookup.jsp").forward(request, response);
            
        } else if ("recordPayment".equals(action)) {
            int billId = Integer.parseInt(request.getParameter("invoiceId"));
            BigDecimal amount = new BigDecimal(request.getParameter("amount"));
            billingDAO.recordPayment(billId, amount);
            
            String pId = request.getParameter("patientId");
            String statusParam = "status=payment_success";
            String redirectUrl = request.getContextPath() + "/billing?action=searchPatient&" + statusParam;
            
            if (pId != null && !pId.isEmpty()) {
                redirectUrl = request.getContextPath() + "/billing?action=viewHistory&patientId=" + pId + "&" + statusParam;
            }
            response.sendRedirect(redirectUrl);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            try {
                int patientId = Integer.parseInt(request.getParameter("patientId"));
                BigDecimal amount = new BigDecimal(request.getParameter("amount"));
                String apptIdStr = request.getParameter("appointmentId");
                Integer apptId = (apptIdStr != null && !apptIdStr.isEmpty()) ? Integer.parseInt(apptIdStr) : null;
                
                // create the main bill
                Bill newBill = new Bill(patientId, apptId, amount);
                boolean success = getBillingDAO().createBill(newBill);
                
                if (success) {
                    // Update appointment status to 'billed'
                    if (apptId != null) {
                        DatabaseConnection.getInstance().executeUpdate(
                            "UPDATE appointments SET status = 'billed' WHERE appointment_id = ?", 
                            apptId);
                    }
                    
                    HttpSession session = request.getSession();
                    User user = (User) session.getAttribute("user");
                    String userRole = (user != null) ? user.getRole() : "";

                    if ("receptionist".equalsIgnoreCase(userRole)) {
                        response.sendRedirect(request.getContextPath() + "/billing?action=viewHistory&patientId=" + patientId + "&status=created");
                    } else {
                        // Dentist redirect
                        response.sendRedirect(request.getContextPath() + "/clinical?action=finalizeList&status=success");
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/clinical?action=finalizeList&error=db_error");
                }
            } catch (Exception e) {
                e.printStackTrace(); 
                response.sendRedirect(request.getContextPath() + "/clinical?action=finalizeList&error=exception");
            }
        }
    }
}