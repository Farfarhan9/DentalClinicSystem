
package com.dentalclinic.servlets;

import com.dentalclinic.database.LeaveDAO;
import java.util.List;
import com.dentalclinic.models.LeaveRequest;
import com.dentalclinic.models.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Date;

@WebServlet("/leave")
public class LeaveServlet extends HttpServlet {
    private LeaveDAO leaveDAO;

    @Override
    public void init() throws ServletException {
        try {
            leaveDAO = new LeaveDAO();
        } catch (SQLException e) {
            throw new ServletException("LeaveDAO initialization failed", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
            return;
        }

        try {
            if ("apply".equals(action)) {
                LeaveRequest leave = new LeaveRequest();
                leave.setUserId(user.getUserId());
                leave.setLeaveType(request.getParameter("leaveType"));
                leave.setFromDate(Date.valueOf(request.getParameter("fromDate")));
                leave.setToDate(Date.valueOf(request.getParameter("toDate")));
                leave.setReason(request.getParameter("reason"));
                leave.setCoveragePerson(request.getParameter("coveragePerson"));
                leave.setStatus("Pending");

                boolean success = leaveDAO.applyLeave(leave);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/leave/apply.jsp?success=1");
                } else {
                    response.sendRedirect(request.getContextPath() + "/leave/apply.jsp?error=db");
                }
            } else if ("approve".equals(action)) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                String comments = request.getParameter("approverComments");
                boolean success = leaveDAO.approveLeaveRequest(requestId, comments);
                response.sendRedirect(request.getContextPath() + "/hr/leave/approve.jsp?approved=" + success);
            } else if ("reject".equals(action)) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                String reason = request.getParameter("rejectionReason");
                String details = request.getParameter("rejectionDetails");
                boolean success = leaveDAO.rejectLeaveRequest(requestId, reason, details);
                response.sendRedirect(request.getContextPath() + "/hr/leave/approve.jsp?rejected=" + success);
            } else {
                response.sendRedirect(request.getContextPath() + "/leave/apply.jsp?error=invalid_action");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/leave/apply.jsp?error=exception");
        }
    }

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    try {
        List<LeaveRequest> pending = leaveDAO.getPendingLeaveRequests();
        request.setAttribute("leaveRequests", pending);
        request.getRequestDispatcher("/hr/leave/approve.jsp").forward(request, response);
    } catch (Exception e) {
        response.sendRedirect(request.getContextPath() + "/error.jsp");
    }
}

}
