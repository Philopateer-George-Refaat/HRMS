Create Database HRMS
Use HRMS


--------
CREATE TABLE Currency (
    CurrencyCode VARCHAR(10) PRIMARY KEY ,
    CurrencyName VARCHAR(100),
    ExchangeRate DECIMAL(10,2),
    CreatedDate DATETIME,
    LastUpdated DATETIME
);
CREATE TABLE PayGrade (
    pay_grade_id INT PRIMARY KEY IDENTITY,
    grade_name VARCHAR(50),
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2)
);

CREATE TABLE TaxForm (
    tax_form_id INT PRIMARY KEY IDENTITY,
    jurisdiction VARCHAR(100),
    validity_period VARCHAR(100),
    form_content TEXT
);
--------
CREATE TABLE SalaryType (
    salary_type_id INT PRIMARY KEY IDENTITY,
    type VARCHAR(50),
    payment_frequency VARCHAR(50),
    currency VARCHAR(10),
    FOREIGN KEY (currency) REFERENCES Currency(CurrencyCode)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE HourlySalaryType (
    salary_type_id INT PRIMARY KEY ,
    hourly_rate VARCHAR(MAX),
    max_monthly_hours INT,
    FOREIGN KEY (salary_type_id) REFERENCES SalaryType(salary_type_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE MonthlySalaryType (
    salary_type_id INT PRIMARY KEY ,
    tax_rule VARCHAR(255),
    contribution_scheme VARCHAR(255),
    FOREIGN KEY (salary_type_id) REFERENCES SalaryType(salary_type_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ContractSalaryType (
    salary_type_id INT PRIMARY KEY ,
    contract_value VARCHAR(255),
    installment_details VARCHAR(255),
    FOREIGN KEY (salary_type_id) REFERENCES SalaryType(salary_type_id)ON DELETE CASCADE ON UPDATE CASCADE
);
--------
CREATE TABLE Contract (
    contract_id INT PRIMARY KEY IDENTITY,
    type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    current_state VARCHAR(50)
);

CREATE TABLE FullTimeContract (
    contract_id INT PRIMARY KEY,
    leave_entitlement VARCHAR(100),
    insurance_eligibility VARCHAR(100),
    weekly_working_hours INT,
    FOREIGN KEY (contract_id) REFERENCES Contract(contract_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PartTimeContract (
    contract_id INT PRIMARY KEY,
    working_hours VARCHAR(100),
    hourly_rate DECIMAL(10,2),
    FOREIGN KEY (contract_id) REFERENCES Contract(contract_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ConsultantContract (
    contract_id INT PRIMARY KEY,
    project_scope VARCHAR(255),
    fees VARCHAR(100),
    payment_schedule VARCHAR(100),
    FOREIGN KEY (contract_id) REFERENCES Contract(contract_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE InternshipContract (
    contract_id INT PRIMARY KEY,
    mentoring VARCHAR(255),
    evaluation VARCHAR(255),
    stipend_related VARCHAR(255),
    FOREIGN KEY (contract_id) REFERENCES Contract(contract_id)ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE Termination (
    termination_id INT PRIMARY KEY IDENTITY,
    date DATE,
    reason VARCHAR(255),
    contract_id INT,
    FOREIGN KEY (contract_id) REFERENCES Contract(contract_id)ON DELETE CASCADE ON UPDATE CASCADE
);

-------
CREATE TABLE Position (
    position_id INT PRIMARY KEY IDENTITY,
    position_title VARCHAR(100),
    responsibilities VARCHAR(MAX),
    status VARCHAR(50)
);

CREATE TABLE Department (
    department_id INT PRIMARY KEY IDENTITY,
    department_name VARCHAR(100),
    purpose VARCHAR(255),
    department_head_id INT,
    --FOREIGN KEY (department_head_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE
);

-------

CREATE TABLE Employee (
    employee_id INT PRIMARY KEY IDENTITY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    full_name VARCHAR(120),
    national_id VARCHAR(20),
    date_of_birth DATE,
    country_of_birth VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(MAX),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    relationship VARCHAR(50),
    biography TEXT,
    profile_image VARBINARY(MAX),
    employment_progress VARCHAR(100),
    account_status VARCHAR(30),
    employment_status VARCHAR(30),
    hire_date DATE,
    is_active BIT,
    profile_completion INT,
    department_id INT,
    position_id INT,
    manager_id INT,
    contract_id INT,
    tax_form_id INT,
    salary_type_id INT,
    pay_grade INT,

    FOREIGN KEY (position_id) REFERENCES Position(position_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (pay_grade) REFERENCES PayGrade(pay_grade_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tax_form_id) REFERENCES TaxForm(tax_form_id) ON DELETE CASCADE ON UPDATE CASCADE,
    --FOREIGN KEY (department_id) REFERENCES Department(department_id) ON DELETE CASCADE ON UPDATE CASCADE,
    --FOREIGN KEY (manager_id) REFERENCES Employee(employee_id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (salary_type_id) REFERENCES SalaryType(salary_type_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (contract_id) REFERENCES Contract(contract_id)ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE Employee
ADD FOREIGN KEY (department_id)
    REFERENCES Department(department_id);

ALTER TABLE Employee
ADD FOREIGN KEY (manager_id)
    REFERENCES Employee(employee_id);

ALTER TABLE Department
ADD FOREIGN KEY (department_head_id)
    REFERENCES Employee(employee_id);

ALTER TABLE Employee
ADD password_hash VARBINARY(64),
    password_salt VARBINARY(32);

-------
  

CREATE TABLE HRAdministrator (
    employee_id INT PRIMARY KEY,
    approval_level VARCHAR(MAX),
    record_access_scope VARCHAR(MAX),
    document_validation_rights VARCHAR(MAX),
    
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE SystemAdministrator (
    employee_id INT PRIMARY KEY,
    system_privilege_level VARCHAR(MAX),
    configurable_fields VARCHAR(MAX),
    audit_visibility_scope VARCHAR(MAX),

    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE LineManager (
    employee_id INT PRIMARY KEY,
    team_size INT,
    supervised_departments VARCHAR(MAX),
    approval_limit VARCHAR(MAX),

    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PayrollSpecialist (
    employee_id INT PRIMARY KEY,
    assigned_region VARCHAR(100),
    processing_frequency VARCHAR(50),
    last_processed_period VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-------

CREATE TABLE Skill (
    skill_id INT PRIMARY KEY IDENTITY,
    skill_name VARCHAR(100),
    description TEXT
);

CREATE TABLE Employee_Skill (
    employee_id INT,
    skill_id INT,
    proficiency_level VARCHAR(50),
    PRIMARY KEY (employee_id, skill_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skill(skill_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Verification (
    verification_id INT PRIMARY KEY IDENTITY,
    verification_type VARCHAR(100),
    issuer VARCHAR(100),
    issue_date DATE,
    expiry_period DATE
);

CREATE TABLE Employee_Verification (
    employee_id INT,
    verification_id INT,
    PRIMARY KEY (employee_id, verification_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (verification_id) REFERENCES Verification(verification_id)ON DELETE CASCADE ON UPDATE CASCADE
);
-------
CREATE TABLE Role (
    role_id INT PRIMARY KEY IDENTITY,
    role_name VARCHAR(100),
    purpose VARCHAR(255)
);

CREATE TABLE EmployeeRole (
    employee_id INT PRIMARY KEY,
    role_id INT,
    assigned_date DATETIME ,--CHANGED TO DATETIME
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (role_id) REFERENCES Role(role_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE RolePermission (
    role_id INT,
    permission_name VARCHAR(100),
    allowed_action VARCHAR(100),
    PRIMARY KEY (role_id, permission_name),
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
);

-------
CREATE TABLE Insurance (
    insurance_id INT PRIMARY KEY IDENTITY,
    type VARCHAR(100),
    contribution_rate DECIMAL(9,2),
    coverage VARCHAR(255)
);

CREATE TABLE Reimbursement (
    reimbursement_id INT PRIMARY KEY IDENTITY,
    type VARCHAR(100),
    claim_type VARCHAR(100),
    approval_date DATE,
    current_status VARCHAR(50),
    employee_id INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Mission (
    mission_id INT PRIMARY KEY IDENTITY,
    destination VARCHAR(255),
    start_date DATE,
    end_date DATE,
    status VARCHAR(50),
    employee_id INT,
    manager_id INT,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(employee_id)
);
-------

CREATE TABLE Leave (
    leave_id INT PRIMARY KEY IDENTITY,
    leave_type VARCHAR(50),
    leave_description TEXT
);

CREATE TABLE VacationLeave (
    leave_id INT PRIMARY KEY,
    carry_over_days DECIMAL(5,2),
    approving_manager VARCHAR(100),
    FOREIGN KEY (leave_id) REFERENCES Leave(leave_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE SickLeave (
    leave_id INT PRIMARY KEY,
    medical_cert_required VARCHAR(100),
    physician_id VARCHAR(100),
    FOREIGN KEY (leave_id) REFERENCES Leave(leave_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ProbationLeave (
    leave_id INT PRIMARY KEY,
    eligibility_start_date DATE,
    probation_period VARCHAR(100),
    FOREIGN KEY (leave_id) REFERENCES Leave(leave_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE HolidayLeave (
    leave_id INT PRIMARY KEY,
    holiday_name VARCHAR(100),
    official_recognition VARCHAR(100),
    regional_scope VARCHAR(100),
    FOREIGN KEY (leave_id) REFERENCES Leave(leave_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE LeavePolicy (
    policy_id INT PRIMARY KEY IDENTITY,
    name VARCHAR(100),
    purpose VARCHAR(255),
    eligibility_rules TEXT,
    notice_period INT,
    special_leave_type VARCHAR(50),
    reset_on_new_year BIT
);

CREATE TABLE LeaveRequest (
    request_id INT PRIMARY KEY IDENTITY,
    employee_id INT,
    leave_id INT,
    justification TEXT,
    duration INT,
    approval_timing VARCHAR(100),
    status VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (leave_id) REFERENCES Leave(leave_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE LeaveEntitlement (
    employee_id INT ,
    leave_type_id INT ,
    entitlement DECIMAL(5,2),
    PRIMARY KEY (employee_id, leave_type_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES Leave(leave_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE LeaveDocument (
    document_id INT PRIMARY KEY IDENTITY,
    leave_request_id INT,
    file_path VARCHAR(255),
    uploaded_at DATETIME,
    FOREIGN KEY (leave_request_id) REFERENCES LeaveRequest(request_id)ON DELETE CASCADE ON UPDATE CASCADE
);
-------
CREATE TABLE Exception (
    exception_id INT PRIMARY KEY IDENTITY,
    name VARCHAR(100),
    category VARCHAR(100),
    date DATE,
    status VARCHAR(50)
);

CREATE TABLE ShiftSchedule (
    shift_id INT PRIMARY KEY IDENTITY,
    name VARCHAR(100),
    type VARCHAR(50),
    start_time TIME,
    end_time TIME,
    break_duration INT, 
    shift_date DATE,
    status BIT
);


CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY IDENTITY,
    employee_id INT,
    shift_id INT,
    entry_time TIME,
    exit_time TIME,
    duration VARCHAR(20),
    login_method VARCHAR(50),
    logout_method VARCHAR(50),
    exception_id INT,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (shift_id) REFERENCES ShiftSchedule(shift_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (exception_id) REFERENCES Exception(exception_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AttendanceLog (
    attendance_log_id INT ,
    attendance_id INT,
    actor INT,
    timestamp DATETIME,
    reason VARCHAR(255),
    PRIMARY KEY(attendance_log_id, attendance_id),
    FOREIGN KEY (attendance_id) REFERENCES Attendance(attendance_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AttendanceCorrectionRequest (
    request_id INT PRIMARY KEY IDENTITY,
    employee_id INT,
    date DATE,
    correction_type VARCHAR(50),
    reason VARCHAR(255),
    status VARCHAR(50),
    recorded_by INT,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (recorded_by) REFERENCES Employee(employee_id)
);


CREATE TABLE ShiftAssignment (
    assignment_id INT PRIMARY KEY IDENTITY,
    employee_id INT,
    shift_id INT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (shift_id) REFERENCES ShiftSchedule(shift_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Employee_Exception (
    employee_id INT,
    exception_id INT,
    PRIMARY KEY (employee_id, exception_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (exception_id) REFERENCES Exception(exception_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ShiftCycle (
    cycle_id INT PRIMARY KEY IDENTITY,
    cycle_name VARCHAR(100),
    description VARCHAR(255)
);

CREATE TABLE ShiftCycleAssignment (
    cycle_id INT ,
    shift_id INT ,
    order_number INT,
    PRIMARY KEY (cycle_id, shift_id),
    FOREIGN KEY (cycle_id) REFERENCES ShiftCycle(cycle_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (shift_id) REFERENCES ShiftSchedule(shift_id)ON DELETE CASCADE ON UPDATE CASCADE
);
-------

CREATE TABLE Payroll (
    payroll_id INT PRIMARY KEY IDENTITY,
    employee_id INT,
    taxes DECIMAL(10,2),
    period_start DATE,
    period_end DATE,
    base_amount DECIMAL(10,2),
    adjustments DECIMAL(10,2),
    contributions DECIMAL(10,2),
    actual_pay DECIMAL(10,2),
    net_salary DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AllowanceDeduction (
    ad_id INT PRIMARY KEY IDENTITY,
    payroll_id INT,
    employee_id INT,
    type VARCHAR(100),
    amount DECIMAL(10,2),
    currency VARCHAR(10),
    duration INT,
    timezone VARCHAR(50),

    FOREIGN KEY (payroll_id) REFERENCES Payroll(payroll_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (currency) REFERENCES Currency(CurrencyCode)
);

CREATE TABLE PayrollPolicy (
    policy_id INT PRIMARY KEY IDENTITY,
    effective_date DATE ,
    type VARCHAR(50) ,
    description VARCHAR(255)
);

CREATE TABLE OvertimePolicy (
    policy_id INT PRIMARY KEY ,
    weekday_rate_multiplier DECIMAL(5,2) ,
    weekend_rate_multiplier DECIMAL(5,2) ,
    max_hours_per_month INT ,
    FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(policy_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE LatenessPolicy (
    policy_id INT PRIMARY KEY ,
    grace_period_mins INT ,
    deduction_rate VARCHAR(255) ,
    FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(policy_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE BonusPolicy (
    policy_id INT PRIMARY KEY ,
    bonus_type VARCHAR(50) ,
    eligibility_criteria VARCHAR(255),
    FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(policy_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE DeductionPolicy (
    policy_id INT PRIMARY KEY ,
    deduction_reason VARCHAR(100) ,
    calculation_mode VARCHAR(50),
    FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(policy_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PayrollPolicy_ID (
    payroll_id INT ,
    policy_id INT ,
    PRIMARY KEY (payroll_id, policy_id),
    FOREIGN KEY (payroll_id) REFERENCES Payroll(payroll_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(policy_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Payroll_Log (
    payroll_log_id INT ,
    payroll_id INT ,
    actor INT, --CHANGED TO INT
    change_date DATETIME,
    modification_type VARCHAR(50),
    PRIMARY KEY (payroll_log_id, payroll_id),
    FOREIGN KEY (payroll_id) REFERENCES Payroll(payroll_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PayrollPeriod (
    payroll_period_id INT PRIMARY KEY IDENTITY,
    payroll_id INT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (payroll_id) REFERENCES Payroll(payroll_id)ON DELETE CASCADE ON UPDATE CASCADE
);
-------

CREATE TABLE Notification (
    notification_id INT PRIMARY KEY IDENTITY,
    message_content VARCHAR(255),
    timestamp DATETIME,
    urgency VARCHAR(20),
    read_status VARCHAR(20),
    notification_type VARCHAR(50)
);

CREATE TABLE Employee_Notification (
    employee_id INT ,
    notification_id INT ,
    delivery_status VARCHAR(30),
    delivered_at DATETIME,
    PRIMARY KEY (employee_id, notification_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (notification_id) REFERENCES Notification(notification_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE EmployeeHierarchy (
    employee_id INT ,
    manager_id INT ,
    hierarchy_level INT,
    PRIMARY KEY (employee_id, manager_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(employee_id) 
);
-------
CREATE TABLE Device (
    device_id INT PRIMARY KEY IDENTITY,
    device_type VARCHAR(50),
    terminal_id VARCHAR(50),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AttendanceSource (
    attendance_id INT ,
    device_id INT ,
    source_type VARCHAR(50),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    recorded_at DATETIME,
    PRIMARY KEY (attendance_id, device_id),
    FOREIGN KEY (attendance_id) REFERENCES Attendance(attendance_id),
    FOREIGN KEY (device_id) REFERENCES Device(device_id)
);


-------
CREATE TABLE ApprovalWorkflow (
    workflow_id INT PRIMARY KEY IDENTITY,
    workflow_type VARCHAR(50),
    threshold_amount DECIMAL(10,2),
    approver_role VARCHAR(MAX),
    created_by  VARCHAR(MAX),
    status VARCHAR(50),
   
); 


CREATE TABLE ApprovalWorkflowStep (
    workflow_id INT ,
    step_number INT ,
    role_id INT,
    action_required VARCHAR(255),
    PRIMARY KEY (workflow_id, step_number),
    FOREIGN KEY (workflow_id) REFERENCES ApprovalWorkflow(workflow_id)ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (role_id) REFERENCES Role(role_id)ON DELETE CASCADE ON UPDATE CASCADE
);
-------
CREATE TABLE ManagerNotes (
    note_id INT PRIMARY KEY IDENTITY,
    employee_id INT,
    manager_id INT,
    note_content TEXT,
    created_at DATETIME,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(employee_id)
);
-------

