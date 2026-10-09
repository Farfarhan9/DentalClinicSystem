package com.dentalclinic.servlets;

import com.dentalclinic.database.AppointmentDAO;
import com.dentalclinic.database.BranchDAO;
import com.dentalclinic.models.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/receptionist/appointment-controller")
public class AppointmentServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private AppointmentDAO appointmentDAO;
    private BranchDAO branchDAO;

    @Override
    public void init() throws ServletException {
        this.appointmentDAO = new AppointmentDAO();
        this.branchDAO = new BranchDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if ("cancel".equals(action)) {
            try {
                int apptId = Integer.parseInt(request.getParameter("appointmentId"));
                String result = appointmentDAO.cancelAppointment(apptId, true); 
                String msg = result.equals("SUCCESS") ? "msg=cancelled" : "error=" + result.replace("ERROR: ", "");
                response.sendRedirect(request.getContextPath() + "/receptionist/appointment-controller?action=viewDashboard&" + msg);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/receptionist/appointment-controller?action=viewDashboard&error=cancelFailed");
            }
            return;
        }

        if ("viewDashboard".equals(action) || action == null) {
            showDashboard(request, response, user);
        } else {
            // Always load branches for the calendar view
            request.setAttribute("branchList", branchDAO.getAllBranches());
            
            if ("searchPatient".equals(action)) {
                String query = request.getParameter("query");
                List<Patient> patients = appointmentDAO.searchActivePatients(query == null ? "" : query);
                request.setAttribute("patientResults", patients);
                loadState(request);
                request.getRequestDispatcher("/receptionist/schedule/calendar.jsp").forward(request, response);
            } else if ("getAvailable".equals(action)) {
                try {
                    int branchId = Integer.parseInt(request.getParameter("branchId"));
                    String date = request.getParameter("date");
                    String time = request.getParameter("time");
                    List<User> available = appointmentDAO.getAvailableDentists(branchId, date, time);
                    request.setAttribute("availableDentists", available);
                    loadState(request);
                    request.getRequestDispatcher("/receptionist/schedule/calendar.jsp").forward(request, response);
                } catch (Exception e) {
                    showDashboard(request, response, user);
                }
            }
        }
    }

    private void loadState(HttpServletRequest request) {
        request.setAttribute("retainedPatientId", request.getParameter("patientId"));
        request.setAttribute("selectedDate", request.getParameter("date"));
        request.setAttribute("selectedTime", request.getParameter("time"));
        request.setAttribute("selectedBranch", request.getParameter("branchId"));
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        String filterDate = request.getParameter("filterDate");
        if (filterDate == null || filterDate.isEmpty()) {
            filterDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        }
        List<Map<String, Object>> branchAppointments = appointmentDAO.getBranchAppointments(user.getBranchId(), filterDate);
        request.setAttribute("selectedDate", filterDate);
        request.setAttribute("branchAppointments", branchAppointments);
        request.getRequestDispatcher("/receptionist/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        try {
            if ("reschedule".equals(action)) {
                int apptId = Integer.parseInt(request.getParameter("appointmentId"));
                String newDateStr = request.getParameter("newDate");
                String newStartTime = request.getParameter("newTime");
                if (newStartTime.length() == 5) newStartTime += ":00";
                
                Calendar cal = Calendar.getInstance();
                String[] parts = newStartTime.split(":");
                cal.set(Calendar.HOUR_OF_DAY, Integer.parseInt(parts[0]));
                cal.set(Calendar.MINUTE, Integer.parseInt(parts[1]));
                cal.add(Calendar.MINUTE, 30);
                String newEndTime = String.format("%02d:%02d:00", cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE));
                
                Date newDate = new SimpleDateFormat("yyyy-MM-dd").parse(newDateStr);
                String result = appointmentDAO.rescheduleAppointment(apptId, newDate, newStartTime, newEndTime, true); 
                
                response.sendRedirect(request.getContextPath() + "/receptionist/appointment-controller?action=viewDashboard&msg=" + result.toLowerCase());
                return;
            }

            // Booking Logic
            int patientId = Integer.parseInt(request.getParameter("patientId"));
            int dentistId = Integer.parseInt(request.getParameter("dentistId"));
            int branchId = Integer.parseInt(request.getParameter("branchId"));
            String dateStr = request.getParameter("appointmentDate");
            String startTime = request.getParameter("startTime");
            if (startTime.length() == 5) startTime += ":00";

            Calendar cal = Calendar.getInstance();
            String[] parts = startTime.split(":");
            cal.set(Calendar.HOUR_OF_DAY, Integer.parseInt(parts[0]));
            cal.set(Calendar.MINUTE, Integer.parseInt(parts[1]));
            cal.add(Calendar.MINUTE, 30);
            String endTime = String.format("%02d:%02d:00", cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE));

            Appointment appt = new Appointment();
            appt.setPatientId(patientId);
            appt.setDentistId(dentistId);
            appt.setBranchId(branchId);
            appt.setAppointmentDate(new SimpleDateFormat("yyyy-MM-dd").parse(dateStr));
            appt.setStartTime(startTime);
            appt.setEndTime(endTime);
            appt.setNotes(request.getParameter("notes"));
            appt.setCreatedBy(currentUser.getUserId());

            String result = appointmentDAO.bookAppointment(appt);

            if ("SUCCESS".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/receptionist/appointment-controller?action=viewDashboard&msg=booked");
            } else {
                request.setAttribute("errorMessage", result);
                request.setAttribute("branchList", branchDAO.getAllBranches());
                request.getRequestDispatcher("/receptionist/schedule/calendar.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/receptionist/schedule/calendar.jsp").forward(request, response);
        }
    }
}