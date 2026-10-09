package com.dentalclinic.servlets;

import com.dentalclinic.database.DatabaseConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/admin/reports")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String type = request.getParameter("type");

        if ("revenue".equals(type)) {
            generateRevenueCSV(response);
        }
    }

    private void generateRevenueCSV(HttpServletResponse response) throws IOException {
        // 1. Set the headers so the browser treats this as a file download
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=Revenue_Report.csv");

        try (PrintWriter writer = response.getWriter()) {
            // 2. Write CSV Header
            writer.println("Invoice ID,Patient ID,Total Amount,Amount Paid,Status,Date");

            // 3. Fetch Data
            DatabaseConnection db = DatabaseConnection.getInstance();
            String sql = "SELECT invoice_id, patient_id, total_amount, amount_paid, status, created_at FROM invoices";
            
            try (ResultSet rs = db.executeQuery(sql)) {
                while (rs.next()) {
                    writer.printf("%d,%d,%.2f,%.2f,%s,%s%n",
                        rs.getInt("invoice_id"),
                        rs.getInt("patient_id"),
                        rs.getDouble("total_amount"),
                        rs.getDouble("amount_paid"),
                        rs.getString("status"),
                        rs.getTimestamp("created_at").toString()
                    );
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}