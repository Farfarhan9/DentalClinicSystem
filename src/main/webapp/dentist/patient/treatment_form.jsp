<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dentalclinic.models.User, com.dentalclinic.models.Appointment" %>
<% 
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    // FIX: Retrieve the full Appointment object sent by the Servlet
    Appointment appt = (Appointment) request.getAttribute("appointment");
    
    if (appt == null) {
        // Redirect if page is accessed directly without passing through the servlet
        response.sendRedirect(request.getContextPath() + "/clinical?action=viewQueue");
        return;
    }

    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userRole", "dentist");
    pageContext.setAttribute("contextPath", request.getContextPath());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Treatment Entry | Putra DentalCare</title>
    <%@ include file="/includes/_dashboard_style.jsp" %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        .treatment-container {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            max-width: 850px;
            margin: 10px auto;
        }
        .info-banner {
            background: #f0f7ff;
            border-left: 4px solid #007bff;
            padding: 15px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .patient-info {
            background: #fff9db;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            border: 1px solid #ffe066;
            color: #856404;
        }
        .form-label {
            display: block;
            font-weight: 600;
            margin-bottom: 10px;
            color: #2c3e50;
            font-size: 15px;
        }
        .text-area-custom {
            width: 100%;
            padding: 12px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-family: inherit;
            font-size: 14px;
            transition: border-color 0.2s;
        }
        .text-area-custom:focus {
            border-color: #007bff;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
        }
        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .btn-main { padding: 12px 25px; border-radius: 6px; font-weight: bold; cursor: pointer; border: none; transition: 0.3s; }
        .btn-save { background: #28a745; color: white; flex: 2; }
        .btn-save:hover { background: #218838; }
        .btn-back { background: #6c757d; color: white; text-decoration: none; text-align: center; flex: 1; line-height: 1.5; }
        .btn-back:hover { background: #5a6268; }
    </style>
</head>
<body class="dashboard-layout">
    <div class="app-container">
        <%@ include file="/includes/_dashboard_sidebar.jsp" %>
        
        <main class="main-content-wrapper">
            <div class="header-bar">
                <h2><i class="fas fa-notes-medical"></i> Clinical Record Entry</h2>
                <div class="user-badge">
                    <i class="fas fa-user-md"></i> Dr. <%= user.getFullName() %>
                </div>
            </div>

            <div class="treatment-container">
                <div class="info-banner">
                    <i class="fas fa-info-circle" style="color: #007bff; font-size: 24px;"></i>
                    <div>
                        <strong>Active Session: Appointment #<%= appt.getAppointmentId() %></strong><br>
                        <small>Please document diagnosis and treatment details. This will finalize the session.</small>
                    </div>
                </div>

                <div class="patient-info">
                    <i class="fas fa-user"></i> <strong>Patient:</strong> <%= appt.getPatientName() %> 
                    <span style="margin-left: 20px;"><i class="fas fa-clock"></i> <strong>Time:</strong> <%= appt.getStartTime() %></span>
                </div>

                <%-- Submit form back to ClinicalServlet doPost --%>
                <form action="<%= request.getContextPath() %>/clinical" method="POST">
                    <%-- Important: This matches the "else" block in ClinicalServlet.doPost --%>
                    <input type="hidden" name="appointmentId" value="<%= appt.getAppointmentId() %>">
                    
                    <div style="margin-bottom: 25px;">
                        <label class="form-label"><i class="fas fa-stethoscope"></i> Diagnosis and Findings</label>
                        <textarea name="diagnosis" class="text-area-custom" rows="3" required 
                                  placeholder="Describe the condition (e.g., Deep caries on tooth 36)"></textarea>
                    </div>

                    <div style="margin-bottom: 10px;">
                        <label class="form-label"><i class="fas fa-file-prescription"></i> Treatment Provided / Clinical Notes</label>
                        <textarea name="treatment_notes" class="text-area-custom" rows="6" required 
                                  placeholder="Detail the procedure (e.g., Composite restoration, local anesthesia given)"></textarea>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn-main btn-save">
                            <i class="fas fa-check-circle"></i> Save and Complete Treatment
                        </button>
                        <a href="<%= request.getContextPath() %>/clinical?action=viewQueue" class="btn-main btn-back">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </main>
    </div>
</body>
</html>