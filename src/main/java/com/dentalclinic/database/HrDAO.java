package com.dentalclinic.database;

import com.dentalclinic.models.Employee;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class HrDAO {
    private DatabaseConnection dbConnection;

    public HrDAO() {
        try {
            this.dbConnection = DatabaseConnection.getInstance();
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }

    /**
     * Deactivates an employee by setting is_active to FALSE in the users table.
     */
    public boolean deactivateEmployee(int userId) {
        String sql = "UPDATE users SET is_active = FALSE WHERE user_id = ?";
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Employee getEmployeeByUserId(int userId) {
        String sql = "SELECT u.user_id, u.full_name, u.role, e.employee_id, " +
                     "e.nric_passport, e.base_salary, e.epf_number, e.bank_name, e.bank_account, e.hire_date " +
                     "FROM users u " +
                     "LEFT JOIN employees e ON u.user_id = e.user_id " +
                     "WHERE u.user_id = ?";
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Employee emp = new Employee();
                    emp.setUserId(rs.getInt("user_id"));
                    emp.setFullName(rs.getString("full_name"));
                    emp.setRole(rs.getString("role"));
                    emp.setEmployeeId(rs.getInt("employee_id"));
                    emp.setNricPassport(rs.getString("nric_passport"));
                    BigDecimal salary = rs.getBigDecimal("base_salary");
                    emp.setBaseSalary(salary != null ? salary : BigDecimal.ZERO);
                    emp.setEpfNumber(rs.getString("epf_number"));
                    emp.setBankName(rs.getString("bank_name"));
                    emp.setBankAccount(rs.getString("bank_account"));
                    emp.setHireDate(rs.getDate("hire_date"));
                    return emp;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean saveOrUpdateEmployee(Employee emp) {
        String sql;
        boolean isInsert = (emp.getEmployeeId() == 0);
        if (isInsert) {
            sql = "INSERT INTO employees (nric_passport, base_salary, epf_number, bank_name, bank_account, user_id, hire_date) " +
                  "VALUES (?, ?, ?, ?, ?, ?, CURRENT_DATE)";
        } else {
            sql = "UPDATE employees SET nric_passport = ?, base_salary = ?, epf_number = ?, " +
                  "bank_name = ?, bank_account = ? WHERE user_id = ?";
        }
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql)) {
            stmt.setString(1, emp.getNricPassport());
            stmt.setBigDecimal(2, emp.getBaseSalary());
            stmt.setString(3, emp.getEpfNumber());
            stmt.setString(4, emp.getBankName());
            stmt.setString(5, emp.getBankAccount());
            stmt.setInt(6, emp.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<String, Object> getHrStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT SUM(base_salary) as total_salary, COUNT(*) as staff_count FROM employees";
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                BigDecimal total = rs.getBigDecimal("total_salary");
                stats.put("totalSalary", total != null ? total : BigDecimal.ZERO);
                stats.put("staffCount", rs.getInt("staff_count"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        stats.put("nextPayroll", "25/12/2025"); 
        return stats;
    }

    public List<Employee> getAllEmployees() {
        List<Employee> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.role, e.employee_id, " +
                     "e.nric_passport, e.base_salary, e.hire_date, e.epf_number, " +
                     "e.bank_name, e.bank_account " +
                     "FROM users u " +
                     "LEFT JOIN employees e ON u.user_id = e.user_id " +
                     "WHERE u.is_active = TRUE AND u.role != 'admin'";
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Employee emp = new Employee();
                emp.setUserId(rs.getInt("user_id"));
                emp.setFullName(rs.getString("full_name"));
                emp.setRole(rs.getString("role"));
                emp.setEmployeeId(rs.getInt("employee_id")); 
                emp.setNricPassport(rs.getString("nric_passport"));
                BigDecimal salary = rs.getBigDecimal("base_salary");
                emp.setBaseSalary(salary != null ? salary : BigDecimal.ZERO);
                emp.setEpfNumber(rs.getString("epf_number"));
                emp.setBankName(rs.getString("bank_name"));
                emp.setBankAccount(rs.getString("bank_account"));
                emp.setHireDate(rs.getDate("hire_date"));
                list.add(emp);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Employee getEmployeeById(int empId) {
        String sql = "SELECT e.*, u.full_name, u.role FROM employees e " +
                     "JOIN users u ON e.user_id = u.user_id WHERE e.employee_id = ?";
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql)) {
            stmt.setInt(1, empId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Employee emp = new Employee();
                    emp.setEmployeeId(rs.getInt("employee_id"));
                    emp.setUserId(rs.getInt("user_id"));
                    emp.setFullName(rs.getString("full_name"));
                    emp.setRole(rs.getString("role"));
                    emp.setNricPassport(rs.getString("nric_passport"));
                    emp.setBaseSalary(rs.getBigDecimal("base_salary"));
                    emp.setEpfNumber(rs.getString("epf_number"));
                    emp.setBankName(rs.getString("bank_name"));
                    emp.setBankAccount(rs.getString("bank_account"));
                    emp.setHireDate(rs.getDate("hire_date"));
                    return emp;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
}