package com.dentalclinic.servlets;

import com.dentalclinic.database.AppointmentDAO;
import com.dentalclinic.database.BranchDAO;
import com.dentalclinic.models.Appointment;
import com.dentalclinic.models.Patient;
import com.dentalclinic.models.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

@WebServlet("/patient/booking-controller")
public class PatientBookingServlet extends HttpServlet {
    
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
        
        HttpSession session = request.getSession();
        Patient currentPatient = (Patient) session.getAttribute("patientUser");

        if (currentPatient == null) {
            response.sendRedirect(request.getContextPath() + "/patient_login.jsp?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");

        if ("viewAppointments".equals(action)) {
            List<Map<String, Object>> myAppointments = appointmentDAO.getPatientAppointments(currentPatient.getPatientId());
            request.setAttribute("myAppointments", myAppointments);
            request.getRequestDispatcher("/patient/appointments/view.jsp").forward(request, response);
            return;
        }

        if ("cancel".equals(action)) {
            try {
                int apptId = Integer.parseInt(request.getParameter("appointmentId"));
                String result = appointmentDAO.cancelAppointment(apptId, false);
                
                if (result.equals("SUCCESS")) {
                    response.sendRedirect(request.getContextPath() + "/patient/booking-controller?action=viewAppointments&msg=cancelled");
                } else {
                    request.setAttribute("errorMessage", result.replace("ERROR: ", ""));
                    showViewPage(request, response, currentPatient);
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/patient/booking-controller?action=viewAppointments&error=cancelFailed");
            }
            return;
        }

        if ("showBookingPage".equals(action)) {
            request.setAttribute("branches", branchDAO.getAllBranches());
            request.getRequestDispatcher("/patient/appointments/book.jsp").forward(request, response);
            return;
        }
        
        if ("getAvailable".equals(action)) {
            try {
                int branchId = Integer.parseInt(request.getParameter("branchId"));
                String date = request.getParameter("date");
                String time = request.getParameter("time");
                List<User> available = appointmentDAO.getAvailableDentists(branchId, date, time);
                request.setAttribute("availableDentists", available);
                request.setAttribute("selectedDate", date);
                request.setAttribute("selectedTime", time);
                request.setAttribute("selectedBranch", branchId);
                request.setAttribute("branches", branchDAO.getAllBranches()); 
                request.getRequestDispatcher("/patient/appointments/book.jsp").forward(request, response);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/patient/booking-controller?action=viewDashboard");
            }
            return; 
        }

        showDashboard(request, response, currentPatient);
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response, Patient p) throws ServletException, IOException {
        List<Map<String, Object>> myAppointments = appointmentDAO.getPatientAppointments(p.getPatientId());
        request.setAttribute("myAppointments", myAppointments);
        request.getRequestDispatcher("/patient/dashboard.jsp").forward(request, response);
    }

    private void showViewPage(HttpServletRequest request, HttpServletResponse response, Patient p) throws ServletException, IOException {
        List<Map<String, Object>> myAppointments = appointmentDAO.getPatientAppointments(p.getPatientId());
        request.setAttribute("myAppointments", myAppointments);
        request.getRequestDispatcher("/patient/appointments/view.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Patient currentPatient = (Patient) session.getAttribute("patientUser");
        String action = request.getParameter("action");

        if (currentPatient == null) {
            response.sendRedirect(request.getContextPath() + "/patient_login.jsp?error=unauthorized");
            return;
        }

        if ("reschedule".equals(action)) {
            try {
                int apptId = Integer.parseInt(request.getParameter("appointmentId"));
                String newDateStr = request.getParameter("newDate");
                String newStartTime = request.getParameter("newTime"); // HTML sends HH:mm
                
                // Flexible time parsing to prevent "Index 2" error
                if (newStartTime.length() == 5) newStartTime += ":00";
                
                Calendar cal = Calendar.getInstance();
                String[] parts = newStartTime.split(":");
                cal.set(Calendar.HOUR_OF_DAY, Integer.parseInt(parts[0]));
                cal.set(Calendar.MINUTE, Integer.parseInt(parts[1]));
                cal.add(Calendar.MINUTE, 30);
                
                String newEndTime = String.format("%02d:%02d:00", cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE));
                Date newDate = new SimpleDateFormat("yyyy-MM-dd").parse(newDateStr);
                
                String result = appointmentDAO.rescheduleAppointment(apptId, newDate, newStartTime, newEndTime, false);
                
                if ("SUCCESS".equals(result)) {
                    response.sendRedirect(request.getContextPath() + "/patient/booking-controller?action=viewAppointments&msg=rescheduled");
                } else {
                    request.setAttribute("errorMessage", result.replace("ERROR: ", ""));
                    showViewPage(request, response, currentPatient);
                }
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Format Error: Please ensure date and time are valid.");
                showViewPage(request, response, currentPatient);
            }
            return;
        }

        // NEW BOOKING LOGIC
        try {
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
            appt.setPatientId(currentPatient.getPatientId());
            appt.setDentistId(dentistId);
            appt.setBranchId(branchId);
            appt.setAppointmentDate(new SimpleDateFormat("yyyy-MM-dd").parse(dateStr));
            appt.setStartTime(startTime);
            appt.setEndTime(endTime);
            appt.setNotes("[" + request.getParameter("notes_prefix") + "] " + request.getParameter("notes"));
            appt.setCreatedBy(currentPatient.getPatientId());

            String result = appointmentDAO.bookAppointment(appt);

            if (result.equals("SUCCESS")) {
                response.sendRedirect(request.getContextPath() + "/patient/booking-controller?action=viewDashboard&msg=booked");
            } else {
                request.setAttribute("errorMessage", result.replace("ERROR: ", ""));
                request.setAttribute("branches", branchDAO.getAllBranches());
                request.getRequestDispatcher("/patient/appointments/book.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Booking Error: " + e.getMessage());
            request.setAttribute("branches", branchDAO.getAllBranches());
            request.getRequestDispatcher("/patient/appointments/book.jsp").forward(request, response);
        }
    }
}