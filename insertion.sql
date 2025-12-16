USE HRMS;






INSERT INTO LineManager (employee_id, team_size, supervised_departments, approval_limit)
SELECT employee_id, 5, 'General', 1000
FROM Employee
WHERE email = 'philo@example.com'; -- <--- PUT THE EMAIL YOU REGISTERED HERE



DECLARE @MyManagerID INT;
SELECT @MyManagerID = employee_id FROM Employee WHERE email = 'philo@example.com'; -- <--- PUT YOUR EMAIL HERE

-- 1. Make Sara report to you
UPDATE Employee 
SET manager_id = @MyManagerID 
WHERE employee_id = 2; -- Sara's ID

-- 2. Create a Pending Leave Request for Sara
INSERT INTO LeaveRequest (employee_id, leave_id, justification, duration, status, approval_timing)
VALUES (2, 1, 'Need a vacation test', 5, 'Pending', GETDATE());

-------------------------
-- 1. Currency
-------------------------
INSERT INTO Currency (CurrencyCode, CurrencyName, ExchangeRate, CreatedDate, LastUpdated)
VALUES 
('USD', 'US Dollar', 1.00, GETDATE(), GETDATE()),
('EUR', 'Euro', 1.10, GETDATE(), GETDATE()),
('EGP', 'Egyptian Pound', 30.50, GETDATE(), GETDATE());

-------------------------
-- 2. PayGrade
-------------------------
INSERT INTO PayGrade (grade_name, min_salary, max_salary)
VALUES 
('Grade A', 3000.00, 5000.00),
('Grade B', 5001.00, 8000.00),
('Grade C', 8001.00, 12000.00);

-------------------------
-- 3. TaxForm
-------------------------
INSERT INTO TaxForm (jurisdiction, validity_period, form_content)
VALUES 
('Egypt', '2025', 'Income Tax Form Egypt 2025'),
('USA', '2025', 'US W-4 Form');

-------------------------
-- 4. SalaryType
-------------------------
INSERT INTO SalaryType (type, payment_frequency, currency)
VALUES 
('Hourly', 'Monthly', 'USD'),
('Monthly', 'Monthly', 'USD'),
('Contract', 'One-time', 'EUR');

-------------------------
-- 5. HourlySalaryType
-------------------------
INSERT INTO HourlySalaryType (salary_type_id, hourly_rate, max_monthly_hours)
VALUES
(1, '50', 160);

-------------------------
-- 6. MonthlySalaryType
-------------------------
INSERT INTO MonthlySalaryType (salary_type_id, tax_rule, contribution_scheme)
VALUES
(2, 'Standard Tax', 'Social Security 10%');

-------------------------
-- 7. ContractSalaryType
-------------------------
INSERT INTO ContractSalaryType (salary_type_id, contract_value, installment_details)
VALUES
(3, '50000', '50% upfront, 50% after completion');

-------------------------
-- 8. Contract
-------------------------
INSERT INTO Contract (type, start_date, end_date, current_state)
VALUES
('Full-Time', '2020-01-01', '2025-12-31', 'Active'),
('Part-Time', '2022-01-01', '2025-12-31', 'Active'),
('Consultant', '2023-01-01', '2023-12-31', 'Completed'),
('Internship', '2025-06-01', '2025-12-31', 'Active');

-------------------------
-- 9. Specialized Contracts
-------------------------
INSERT INTO FullTimeContract (contract_id, leave_entitlement, insurance_eligibility, weekly_working_hours)
VALUES (1, '30 days', 'Yes', 40);

INSERT INTO PartTimeContract (contract_id, working_hours, hourly_rate)
VALUES (2, '20 hours/week', 30);

INSERT INTO ConsultantContract (contract_id, project_scope, fees, payment_schedule)
VALUES (3, 'Software Development', '20000', 'Monthly');

INSERT INTO InternshipContract (contract_id, mentoring, evaluation, stipend_related)
VALUES (4, 'Assigned Mentor', 'End-of-internship report', 'Monthly stipend 500');

-------------------------
-- 10. Position
-------------------------
INSERT INTO Position (position_title, responsibilities, status)
VALUES
('Software Engineer', 'Develop software applications', 'Active'),
('HR Specialist', 'Manage HR operations', 'Active'),
('Manager', 'Supervise teams', 'Active');

-------------------------
-- 11. Department
-------------------------
INSERT INTO Department (department_name, purpose)
VALUES
('IT Department', 'Develop and maintain software'),
('HR Department', 'Manage human resources');

-------------------------
-- 12. Employee
-------------------------
-- Ahmed: password 'Password123'
INSERT INTO Employee (first_name, last_name, full_name, national_id, date_of_birth, country_of_birth, phone, email,
                      address, emergency_contact_name, emergency_contact_phone, relationship, biography, employment_progress,
                      account_status, employment_status, hire_date, is_active, profile_completion, department_id, position_id, manager_id,
                      contract_id, tax_form_id, salary_type_id, pay_grade, password_hash)
VALUES
('Ahmed', 'Hossam', 'Ahmed Hossam', '12345678901234', '1990-05-10', 'Egypt', '+201234567890', 'ahmed@example.com',
 'Cairo, Egypt', 'Hossam', '+201234567891', 'Brother', 'Experienced software engineer', 'Active', 'Active', 'Full-time', 
 '2020-01-01', 1, 100, 1, 1, NULL, 1, 1, 2, 1,
 HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), 'Password123'))),

('Sara', 'Ali', 'Sara Ali', '98765432109876', '1988-08-15', 'Egypt', '+201112223334', 'sara@example.com',
 'Cairo, Egypt', 'Mohamed Ali', '+201112223335', 'Father', 'HR specialist', 'Active', 'Active', 'Full-time', 
 '2018-03-01', 1, 90, 2, 2, 1, 2, 2, 2, 2,
 HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), 'Password123')));

-------------------------
-- 13. HRAdministrator, SystemAdministrator, LineManager, PayrollSpecialist
-------------------------
INSERT INTO HRAdministrator (employee_id, approval_level, record_access_scope, document_validation_rights)
VALUES (2, 'Level 1', 'Department', 'Yes');

INSERT INTO SystemAdministrator (employee_id, system_privilege_level, configurable_fields, audit_visibility_scope)
VALUES (1, 'Full', 'All', 'All');

INSERT INTO LineManager (employee_id, team_size, supervised_departments, approval_limit)
VALUES (1, 5, 'IT Department', '5000');

INSERT INTO PayrollSpecialist (employee_id, assigned_region, processing_frequency, last_processed_period)
VALUES (2, 'Cairo', 'Monthly', '2025-10');

INSERT INTO Role (role_name, purpose) VALUES ('SystemAdmin', 'Full system access');
INSERT INTO Role (role_name, purpose) VALUES ('HRAdmin', 'Manage HR processes');
INSERT INTO Role (role_name, purpose) VALUES ('LineManager', 'Manage team and approvals');
INSERT INTO Role (role_name, purpose) VALUES ('PayrollSpecialist', 'Handle payroll processing');
INSERT INTO Role (role_name, purpose) VALUES ('Employee', 'Regular employee');

-------------------------
-- 14. Skills and Employee_Skill
-------------------------
INSERT INTO Skill (skill_name, description)
VALUES
('Java Programming', 'Ability to write Java code'),
('HR Management', 'Manage HR operations');

INSERT INTO Employee_Skill (employee_id, skill_id, proficiency_level)
VALUES
(1, 1, 'Expert'),
(2, 2, 'Intermediate');

-------------------------
-- 15. Verification and Employee_Verification
-------------------------
INSERT INTO Verification (verification_type, issuer, issue_date, expiry_period)
VALUES
('Degree Certificate', 'University of Cairo', '2012-06-01', '2025-06-01');

INSERT INTO Employee_Verification (employee_id, verification_id)
VALUES
(1, 1);

-------------------------
-- 16. EmployeeRole and RolePermission
-------------------------
INSERT INTO EmployeeRole (employee_id, role_id, assigned_date)
VALUES
(1, 2, GETDATE()),
(2, 1, GETDATE());

INSERT INTO RolePermission ( permission_name, allowed_action)
VALUES
( 'Approve Leave', 'Yes'),
( 'System Configuration', 'Yes');

-------------------------
-- 17. Insurance
-------------------------
INSERT INTO Insurance (type, contribution_rate, coverage)
VALUES
('Health', 5.00, 'Full Coverage');

-------------------------
-- 18. Reimbursement
-------------------------
INSERT INTO Reimbursement (type, claim_type, approval_date, current_status, employee_id)
VALUES
('Medical', 'Hospital', GETDATE(), 'Approved', 1);

-------------------------
-- 19. Mission
-------------------------
INSERT INTO Mission (destination, start_date, end_date, status, employee_id, manager_id)
VALUES
('Alexandria', '2025-11-01', '2025-11-03', 'Completed', 1, 1);

-------------------------
-- 20. Leave types and policies
-------------------------
INSERT INTO Leave (leave_type, leave_description)
VALUES
('Vacation', 'Annual leave'),
('Sick', 'Medical leave'),
('Probation', 'Probation leave'),
('Holiday', 'Public holidays');

INSERT INTO VacationLeave (leave_id, carry_over_days, approving_manager)
VALUES (1, 5, 'Line Manager');

INSERT INTO SickLeave (leave_id, medical_cert_required, physician_id)
VALUES (2, 'Yes', 'PH001');

INSERT INTO ProbationLeave (leave_id, eligibility_start_date, probation_period)
VALUES (3, '2025-01-01', '3 months');

INSERT INTO HolidayLeave (leave_id, holiday_name, official_recognition, regional_scope)
VALUES (4, 'Eid al-Fitr', 'National', 'Egypt');

INSERT INTO LeavePolicy (name, purpose, eligibility_rules, notice_period, special_leave_type, reset_on_new_year)
VALUES ('Annual Vacation Policy', 'Define vacation rules', 'All employees', 30, 'Vacation', 1);

INSERT INTO LeaveRequest (employee_id, leave_id, justification, duration, approval_timing, status)
VALUES (1, 1, 'Family vacation', 5, 'Immediate', 'Approved');

INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
VALUES (1, 1, 25.00);

INSERT INTO LeaveDocument (leave_request_id, file_path, uploaded_at)
VALUES (1, 'C:/Documents/LeaveDoc1.pdf', GETDATE());

-------------------------
-- 21. Exception and Attendance
-------------------------
INSERT INTO Exception (name, category, date, status)
VALUES ('Late Arrival', 'Attendance', '2025-11-01', 'Open');

INSERT INTO ShiftSchedule (name, type, start_time, end_time, break_duration, shift_date, status)
VALUES ('Morning Shift', 'Regular', '09:00', '17:00', 60, '2025-11-01', 1);

INSERT INTO Attendance (employee_id, shift_id, entry_time, exit_time, duration, login_method, logout_method, exception_id)
VALUES (1, 1, '2025-11-01 09:05', '2025-11-01 17:00', '7:55', 'Biometric', 'Biometric', 1);

INSERT INTO AttendanceLog (attendance_log_id, attendance_id, actor, timestamp, reason)
VALUES (1, 1, 1, GETDATE(), 'Late login correction');

INSERT INTO AttendanceCorrectionRequest (employee_id, date, correction_type, reason, status, recorded_by)
VALUES (1, '2025-11-01', 'Entry Time', 'Forgot swipe', 'Approved', 1);

INSERT INTO ShiftAssignment (employee_id, shift_id, start_date, end_date, status)
VALUES (1, 1, '2025-11-01', '2025-11-30', 'Active');

INSERT INTO Employee_Exception (employee_id, exception_id)
VALUES (1, 1);

INSERT INTO ShiftCycle (cycle_name, description)
VALUES ('Monthly Cycle', 'Shift rotation for November');

INSERT INTO ShiftCycleAssignment (cycle_id, shift_id, order_number)
VALUES (1, 1, 1);

-------------------------
-- 22. Payroll & Policies
-------------------------
INSERT INTO Payroll (employee_id, taxes, period_start, period_end, base_amount, adjustments, contributions, actual_pay, net_salary, payment_date)
VALUES (1, 300, '2025-11-01', '2025-11-30', 5000, 0, 200, 4800, 4500, '2025-11-30');

INSERT INTO AllowanceDeduction (payroll_id, employee_id, type, amount, currency, duration, timezone)
VALUES (1, 1, 'Transport Allowance', 100, 'USD', 30, 'Cairo');

INSERT INTO PayrollPolicy (effective_date, type, description)
VALUES ('2025-01-01', 'Overtime', 'Overtime and deduction rules');

INSERT INTO OvertimePolicy (policy_id, weekday_rate_multiplier, weekend_rate_multiplier, max_hours_per_month)
VALUES (1, 1.5, 2, 20);

INSERT INTO LatenessPolicy (policy_id, grace_period_mins, deduction_rate)
VALUES (1, 10, 'Per minute');

INSERT INTO BonusPolicy (policy_id, bonus_type, eligibility_criteria)
VALUES (1, 'Performance', 'Exceed targets');

INSERT INTO DeductionPolicy (policy_id, deduction_reason, calculation_mode)
VALUES (1, 'Late Arrival', 'Per minute');

INSERT INTO PayrollPolicy_ID (payroll_id, policy_id)
VALUES (1, 1);

INSERT INTO Payroll_Log (payroll_log_id, payroll_id, actor, change_date, modification_type)
VALUES (1, 1, 1, GETDATE(), 'Initial Payroll');

INSERT INTO PayrollPeriod (payroll_id, start_date, end_date, status)
VALUES (1, '2025-11-01', '2025-11-30', 'Completed');

-------------------------
-- 23. Notifications
-------------------------
INSERT INTO Notification (message_content, timestamp, urgency, read_status, notification_type)
VALUES ('Payroll processed for November', GETDATE(), 'High', 'Unread', 'Payroll');

INSERT INTO Employee_Notification (employee_id, notification_id, delivery_status, delivered_at)
VALUES (1, 1, 'Delivered', GETDATE());

INSERT INTO EmployeeHierarchy (employee_id, manager_id, hierarchy_level)
VALUES (1, NULL, 1), (2, 1, 2);

-------------------------
-- 24. Devices & AttendanceSource
-------------------------
INSERT INTO Device (device_type, terminal_id, latitude, longitude, employee_id)
VALUES ('Biometric', 'TERM001', 30.06263, 31.24967, 1);

INSERT INTO AttendanceSource (attendance_id, device_id, source_type, latitude, longitude, recorded_at)
VALUES (1, 1, 'Biometric', 30.06263, 31.24967, GETDATE());

-------------------------
-- 25. Approval Workflow
-------------------------
INSERT INTO ApprovalWorkflow (workflow_type, threshold_amount, approver_role, created_by, status)
VALUES ('Leave Approval', 1000, 'Line Manager', 'HR System', 'Active');

INSERT INTO ApprovalWorkflowStep (workflow_id, step_number, role_id, action_required)
VALUES (1, 1, 3, 'Approve Leave Request');

-------------------------
-- 26. Manager Notes
-------------------------
INSERT INTO ManagerNotes (employee_id, manager_id, note_content, created_at)
VALUES (1, 1, 'Excellent performance this month', GETDATE());
