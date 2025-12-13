USE HRMS
-- START OF SYSTEMADMIN.SQL --
 -- 1 Retrieve complete information for any employee using their ID --
GO
CREATE PROC ViewEmployeeInfo 
@EmployeeID int
AS
IF @EmployeeID IS NULL PRINT 'EmployeeID cannot be NULL'
ELSE
SELECT* FROM Employee WHERE employee_id = @EmployeeID;

-- 2 Add anew employee to the system --
GO
CREATE PROC AddEmployee 
    @FullName varchar(200),
    @NationalID varchar(50),
    @DateOfBirth date,
    @CountryOfBirth varchar(100),
    @Phone varchar(50),
    @Email varchar(100),
    @Address varchar(255),
    @EmergencyContactName varchar(100),
    @EmergencyContactPhone varchar(50),
    @Relationship varchar(50),
    @Biography varchar(max),
    @EmploymentProgress varchar(100),
    @AccountStatus varchar(50),
    @EmploymentStatus varchar(50),
    @HireDate date, 
    @IsActive bit, 
    @ProfileCompletion int, 
    @DepartmentID int,
    @PositionID int,
    @ManagerID int,
    @ContractID int,
    @TaxFormID int,
    @SalaryTypeID int,
    @PayGrade varchar(50)
AS
BEGIN 
    /*IF @FullName IS NULL OR @Email IS NULL OR @DepartmentID IS NULL 
    OR @PositionID IS NULL OR @HireDate IS NULL
        BEGIN
        PRINT 'One of the inputs is null'
        RETURN;
        END
    ELSE*/
        BEGIN 
        INSERT INTO Employee(full_name,national_id,date_of_birth,country_of_birth,phone,
        email,address,emergency_contact_name,emergency_contact_phone,relationship,biography,
        employment_progress,account_status,employment_status,hire_date,is_active,profile_completion,
        department_id,position_id,manager_id,contract_id,tax_form_id,salary_type_id,pay_grade)

        

        VALUES(@FullName ,@NationalID ,@DateOfBirth ,@CountryOfBirth ,@Phone ,@Email , @Address , @EmergencyContactName ,
        @EmergencyContactPhone ,@Relationship ,@Biography ,@EmploymentProgress ,@AccountStatus ,@EmploymentStatus ,@HireDate , 
        @IsActive , @ProfileCompletion ,@DepartmentID, @PositionID ,@ManagerID ,@ContractID ,@TaxFormID ,@SalaryTypeID ,
        @PayGrade );
        PRINT 'Employee information inserted successfully.'
        END
END;
-- 3 Update an employees contact or personal details --
GO
CREATE PROC UpdateEmployeeInfo  
@EmployeeID int, @Email varchar(100), @Phone varchar(20),@Address varchar(150) 
AS
BEGIN 
 IF @EmployeeID IS NULL
    BEGIN
        PRINT 'EmployeeID cannot be NULL';
        RETURN;
    END;
    IF NOT EXISTS (SELECT * FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        PRINT 'Employee does not exist';
        RETURN;
    END;

UPDATE Employees
SET email = @Email, phone = @Phone, address = @Address
WHERE employee_id = @EmployeeID;
PRINT 'Employee information updated successfully.';
END;
-- 4 Assign system roles to employees --
GO
CREATE PROC AssignRole 
@EmployeeID int, @RoleID int
AS 
BEGIN 
    IF @EmployeeID IS NULL OR @RoleID IS NULL
        BEGIN
        PRINT 'EmployeeID or RoleID cannot be NULL'
        RETURN;
        END
    ELSE
        BEGIN 
        INSERT INTO EmployeeRole(employee_id,role_id)
        VALUES(@EmployeeID, @RoleID);
        PRINT 'Role assigned to employee successfully.'
        END
END;
-- 5 Retrieve a summary of employee distribution across departments --
GO
CREATE PROC GetDepartmentEmployeeStats
AS
BEGIN
    SELECT d.department_name AS Department,d.department_id AS DepartmentID, COUNT(e.employee_id) AS EmployeeCount
    FROM Department d INNER JOIN Employee e ON d.department_id = e.department_id
    GROUP BY d.department_name , d.department_id;
END;
-- 6 Ressaign an employee to a new manager --

GO
CREATE PROC ReassignManager 
@EmployeeID int, @NewManagerID int
AS 
  Begin
      IF @EmployeeID IS NULL
        BEGIN
            PRINT 'EmployeeID cannot be NULL';
            RETURN;
        END;

        IF @NewManagerID IS NULL
        BEGIN
            PRINT 'NewManagerID cannot be NULL';
            RETURN;
        END;

        IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
        BEGIN
            PRINT 'Employee does not exist';
            RETURN;
        END;

        IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @NewManagerID)
        BEGIN
            PRINT 'Manager does not exist';
            RETURN;
        END;
       UPDATE Employee
       SET manager_id = @NewManagerID
       WHERE employee_id = @EmployeeID;
       PRINT 'Manager reassigned successfully.';
  END;
  -- 7 Ressaign an employee to a new department or manager within the hierarchy --

GO 
CREATE PROC ReassignHierarchy 
@EmployeeID int, @NewDepartmentID int, @NewManagerID int 
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        PRINT 'Employee does not exist';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Department WHERE department_id = @NewDepartmentID)
    BEGIN
        PRINT 'Department does not exist';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @NewManagerID)
    BEGIN
        PRINT 'Manager does not exist';
        RETURN;
    END;
    IF @NewDepartmentID IS NOT NULL
    BEGIN
        UPDATE Employee
        SET department_id = @NewDepartmentID
        WHERE employee_id = @EmployeeID;
    END;

    IF @NewManagerID IS NOT NULL
    BEGIN
        UPDATE Employee
        SET manager_id = @NewManagerID
        WHERE employee_id = @EmployeeID;
    END;

    IF @NewManagerID IS NOT NULL
    BEGIN
        
        DELETE FROM EmployeeHierarchy
        WHERE employee_id = @EmployeeID; /*not sure about this */

        INSERT INTO EmployeeHierarchy (employee_id, manager_id, hierarchy_level)
        VALUES (@EmployeeID, @NewManagerID, NULL);
    END;


    PRINT 'Hierarchy reassigned successfully.';
END; 
    -- 8 Notify all affected employees --

GO
CREATE PROC NotifyStructureChange
@AffectedEmployees VARCHAR(500),
@Message VARCHAR(200)
AS
BEGIN


DECLARE @NotificationID INT;
INSERT INTO Notification (message_content, timestamp, notification_type)
VALUES (@Message, GETDATE(), 'Structural Change');

SET @NotificationID = SCOPE_IDENTITY();

INSERT INTO Employee_Notification (employee_id, notification_id,  delivered_at)
SELECT CAST(value AS INT), @NotificationID, GETDATE()
FROM STRING_SPLIT(@AffectedEmployees, ',');

SELECT 'Notifications sent successfully.' AS ConfirmationMessage;
END;
-- 9 view the complete organizational hierarchy --
GO
CREATE PROC ViewOrgHierarchy
AS
BEGIN
    SELECT 
        E.employee_id,
        E.full_name AS employee_name, M.full_name AS manager_name,
        D.department_name,P.position_title, H.hierarchy_level
    FROM Employee E
    LEFT JOIN EmployeeHierarchy H ON E.employee_id = H.employee_id

    LEFT JOIN Employee M ON H.manager_id = M.employee_id

    LEFT JOIN Department D ON E.department_id = D.department_id

    LEFT JOIN Position P ON E.position_id = P.position_id
    ORDER BY 
        H.hierarchy_level ASC
END;
-- 10 Assign shifts to employees for a specified term --

GO
CREATE PROC AssignShiftToEmployee 
@EmployeeID int, @ShiftID int, @StartDate date, @EndDate date
AS
  BEGIN
        /*IF @EmployeeID IS NULL OR @ShiftID IS NULL OR @StartDate IS NULL OR @EndDate IS NULL
        BEGIN
            PRINT 'Inputs cannot be NULL';
            RETURN;
        END;*/

        IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
        BEGIN
            PRINT 'Employee does not exist';
            RETURN;
        END;

        IF NOT EXISTS (SELECT 1 FROM ShiftSchedule WHERE shift_id = @ShiftID)
        BEGIN
            PRINT 'Shift does not exist';
            RETURN;
        END;

        INSERT INTO ShiftAssignment (employee_id, shift_id, start_date, end_date)
        VALUES (@EmployeeID, @ShiftID, @StartDate, @EndDate);

        
        DECLARE @ShiftName VARCHAR(100), @ShiftType VARCHAR(50);
        SELECT @ShiftName = name, @ShiftType = type
        FROM ShiftSchedule
        WHERE shift_id = @ShiftID;

        PRINT 'Shift "' + @ShiftName + '" of type "' + @ShiftType + '" assigned successfully to employee.';
END;
-- 11 update shift status --

GO
CREATE PROC UpdateShiftStatus 
@ShiftAssignmentID int, @Status varchar(20)
AS
BEGIN  
    IF @ShiftAssignmentID IS NULL OR @Status IS NULL
        BEGIN
            PRINT 'Inputs cannot be NULL';
            RETURN;
        END;
    IF @Status NOT IN ('Approved', 'Cancelled', 'Entered', 'Expired', 'Postponed', 'Rejected', 'Submitted')
        BEGIN
            PRINT 'Invalid status value';
            RETURN;
        END;
    IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE shift_assignment_id = @ShiftAssignmentID)
        BEGIN
        PRINT 'Shift Assignment does not exist';
        RETURN;
        END;

        UPDATE ShiftAssignment
        SET status = @Status
        WHERE assignment_id = @ShiftAssignmentID;
        PRINT 'Shift assignment status updated successfully to "' + @Status + '".';
END;
-- 12 Assign shift schedules by department --
GO
CREATE PROC AssignShiftToDepartment 
@DepartmentID int, @ShiftID int, @StartDate date, @EndDate date
AS
BEGIN
    /*IF @DepartmentID IS NULL OR @ShiftID IS NULL OR @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        PRINT 'Inputs cannot be NULL';
        RETURN;
    END;*/
    IF NOT EXISTS (SELECT 1 FROM Department WHERE department_id = @DepartmentID)
    BEGIN
        PRINT 'Department does not exist';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM ShiftSchedule WHERE shift_id = @ShiftID)
    BEGIN
        PRINT 'Shift does not exist';
        RETURN;
    END;
    INSERT INTO ShiftAssignment (employee_id, shift_id, start_date, end_date) 
    SELECT employee_id, @ShiftID, @StartDate, @EndDate
    FROM Employee
    WHERE department_id = @DepartmentID; 
    PRINT 'Shift assigned successfully to the department.';
END;

-- 13 Assign custom shifts to individual employees for unique --

GO
CREATE PROC AssignCustomShift 
@EmployeeID int, @ShiftName varchar(50), @ShiftType varchar(50), 
@StartTime time,@EndTime time, @StartDate date, @EndDate date
AS
  BEGIN
    /*IF @EmployeeID IS NULL OR @ShiftName IS NULL OR @ShiftType IS NULL OR @StartTime IS NULL OR @EndTime IS NULL OR @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        PRINT 'Inputs cannot be NULL';
        RETURN;
    END;*/
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        PRINT 'Employee does not exist';
        RETURN;
    END;
    DECLARE @ShiftID int;
    INSERT INTO ShiftSchedule (name, type, start_time, end_time)
    VALUES (@ShiftName, @ShiftType, @StartTime, @EndTime);

    SET @ShiftID = SCOPE_IDENTITY();

    INSERT INTO ShiftAssignment (employee_id, shift_id, start_date, end_date)
    VALUES (@EmployeeID, @ShiftID, @StartDate, @EndDate);

    PRINT 'Custom shift "' + @ShiftName + '" assigned successfully to employee.';
  END;
    
  -- 14 Configure split shifts --
GO
  CREATE PROCEDURE ConfigureShift
    @ShiftName VARCHAR(50),
    @FirstSlotStart TIME,
    @FirstSlotEnd TIME,
    @SecondSlotStart TIME = NULL,
    @SecondSlotEnd TIME = NULL
AS
BEGIN
   

    
    /*IF @FirstSlotStart IS NULL OR @FirstSlotEnd IS NULL
    BEGIN
        RAISERROR('First slot start and end times cannot be NULL.', 16, 1);
        RETURN;
    END*/
    IF @FirstSlotStart >= @FirstSlotEnd
    BEGIN
        RAISERROR('First slot start time must be before end time.', 16, 1);
        RETURN;
    END

   
    IF @SecondSlotStart IS NOT NULL AND @SecondSlotEnd IS NOT NULL
    BEGIN
        IF @SecondSlotStart >= @SecondSlotEnd
        BEGIN
            RAISERROR('Second slot start time must be before end time.', 16, 1);
            RETURN;
        END

        IF @SecondSlotStart <= @FirstSlotEnd
        BEGIN
            RAISERROR('Second slot must start after the first slot ends.', 16, 1);
            RETURN;
        END

        
        DECLARE @BreakDuration INT;
        SET @BreakDuration = DATEDIFF(MINUTE, @FirstSlotEnd, @SecondSlotStart);

        INSERT INTO ShiftSchedule (name, type, start_time, end_time, break_duration)
        VALUES (@ShiftName, 'Split', @FirstSlotStart, @FirstSlotEnd, @BreakDuration);

       
        INSERT INTO ShiftSchedule (name, type, start_time, end_time, break_duration)
        VALUES (@ShiftName, 'Split', @SecondSlotStart, @SecondSlotEnd, 0);

        PRINT 'Split shift "' + @ShiftName + '" configured successfully. Break duration: ' + CAST(@BreakDuration AS VARCHAR) + ' minutes.';
    END
    ELSE
    BEGIN
    
        INSERT INTO ShiftSchedule (name, type, start_time, end_time, break_duration, status)
        VALUES (@ShiftName, 'Normal', @FirstSlotStart, @FirstSlotEnd, 0, 1);

        PRINT 'Normal shift "' + @ShiftName + '" configured successfully.';
    END
END;
-- 15 Enable first in / last out attendance --

GO
CREATE PROC EnableFirstInLastOut
@Enable BIT
AS
BEGIN
    IF @Enable IS NULL
    BEGIN
        PRINT 'Input cannot be NULL';
        RETURN;
    END

    IF @Enable = 1
        PRINT 'First-In/Last-Out attendance processing enabled.';
    ELSE
        PRINT 'First-In/Last-Out attendance processing disabled.';
END

-- 16 Tag attendance by device ,terminal ID , or GPS --

GO 
CREATE PROC TagAttendanceSource
@AttendanceID int, @SourceType varchar(20), @DeviceID int, @Latitude decimal(10,7), @Longitude decimal(10,7)
AS
  BEGIN
  IF @AttendanceID IS NULL OR @SourceType IS NULL
    BEGIN
        PRINT 'Inputs cannot be NULL';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Attendance WHERE attendance_id = @AttendanceID)
    BEGIN
        PRINT 'Attendance record does not exist';
        RETURN;
    END;
    INSERT INTO AttendanceSource (attendance_id, device_id, source_type, latitude, longitude, recorded_at)
    VALUES (@AttendanceID, @DeviceID, @SourceType, @Latitude, @Longitude, GETDATE());
    PRINT 'Attendance source tagged successfully.';
  END;

-- 17 Allow attendance devices to store records offline and sync later --
GO


    CREATE PROCEDURE SyncOfflineAttendance
    @DeviceID INT,
    @EmployeeID INT,
    @ClockTime DATETIME,
    @Type VARCHAR(10)  -- 'IN' or 'OUT'
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Device WHERE device_id = @DeviceID)
    BEGIN
        SELECT 'Error: Device not found.' AS Message;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        SELECT 'Error: Employee not found.' AS Message;
        RETURN;
    END

    DECLARE @AttendanceID INT;

    IF @Type = 'IN'
    BEGIN
        INSERT INTO Attendance (employee_id, entry_time, login_method)
        VALUES (@EmployeeID, @ClockTime, 'DeviceSync');

        SET @AttendanceID = SCOPE_IDENTITY();
    END
    ELSE IF @Type = 'OUT'
    BEGIN
        
        SELECT @AttendanceID = attendance_id
        FROM Attendance
        WHERE employee_id = @EmployeeID AND exit_time IS NULL;

        IF @AttendanceID IS NULL
        BEGIN
            SELECT 'Error: No open attendance record for clock-out.' AS Message;
            RETURN;
        END

        UPDATE Attendance
        SET exit_time = @ClockTime, logout_method = 'DeviceSync'
        WHERE attendance_id = @AttendanceID;
    END
    ELSE
    BEGIN
        SELECT 'Error: Type must be IN or OUT.' AS Message;
        RETURN;
    END

  
    INSERT INTO AttendanceSource (attendance_id, device_id, source_type, recorded_at)
    VALUES (@AttendanceID, @DeviceID, 'OfflineSync', GETDATE());

  
    SELECT 'Attendance synced successfully.' AS Message;
END

    -- ------------------------------------------------------------------ --

GO
GO
CREATE PROC LogAttendanceEdit
    @AttendanceID   INT,
    @EditedBy       INT,
    @OldValue       DATETIME,
    @NewValue       DATETIME,
    @EditTimestamp  DATETIME
AS
BEGIN
   
    IF NOT EXISTS (
        SELECT 1 
        FROM AttendanceLog 
        WHERE attendance_id = @AttendanceID
          AND timestamp = @OldValue
    )
    BEGIN
        PRINT 'ERROR: Attendance log row not found for the provided OldValue.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EditedBy)
    BEGIN
        PRINT 'ERROR: EditedBy employee does not exist.';
        RETURN;
    END


    UPDATE AttendanceLog
    SET 
        timestamp = @NewValue
    WHERE attendance_id = @AttendanceID
      AND timestamp = @OldValue;

  
    PRINT CONCAT('Attendance log updated successfully. New value: ', CONVERT(VARCHAR, @NewValue, 120));
END;
GO

  -- 19  Apply holiday overrides to employee shifts --
  GO
CREATE PROCEDURE ApplyHolidayOverrides
    @HolidayID INT,
    @EmployeeID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM HolidayLeave WHERE leave_id = @HolidayID)
    BEGIN
        SELECT 'Error: Holiday ID does not exist.' AS Message;
        RETURN;
    END
    
    
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        SELECT 'Error: Employee ID does not exist.' AS Message;
        RETURN;
    END
    
   
    IF NOT EXISTS (
        SELECT 1 
        FROM LeaveEntitlement 
        WHERE employee_id = @EmployeeID 
        AND leave_type_id = @HolidayID
    )
    BEGIN
        PRINT 'Error: Employee does not have entitlement for this holiday leave type.' 
        RETURN;
    END
    
   
    UPDATE ShiftAssignment
    SET status = 'Cancelled'
    WHERE employee_id = @EmployeeID
    AND shift_id IN (
        SELECT shift_id 
        FROM ShiftSchedule 
        WHERE shift_date = (SELECT GETDATE())
        AND status = 1
    );
    
    -- Return success confirmation
    PRINT  'Holiday override successfully applied for the Employee ' 
        
END;
-- 20 Create and manage user accounts and roles for payroll access --
GO
CREATE PROC ManageUserAccounts
    @UserID INT,
    @Role VARCHAR(50),
    @Action VARCHAR(20)  
AS
BEGIN
    
    IF @UserID IS NULL OR @Role IS NULL OR @Action IS NULL
    BEGIN
        PRINT 'ERROR: Missing parameters';
        RETURN;
    END

    IF @Action NOT IN ('ADD','REMOVE','UPDATE')
    BEGIN
        PRINT 'ERROR: Action must be ADD, REMOVE or UPDATE';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @UserID AND is_active = 1)
    BEGIN
        PRINT 'ERROR: Employee not found or inactive';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Role WHERE role_name = @Role)
    BEGIN
        PRINT 'ERROR: Role not found';
        RETURN;
    END


    IF @Action = 'ADD'
    BEGIN
        IF EXISTS (SELECT 1 FROM EmployeeRole WHERE employee_id = @UserID)
            PRINT 'ERROR: Employee already has a role';
        ELSE
        BEGIN
            INSERT INTO EmployeeRole (employee_id, role_id, assigned_date)
            SELECT @UserID, role_id, GETDATE()
            FROM Role WHERE role_name = @Role;

            PRINT 'Role ' + @Role + ' added successfully';
        END
        RETURN;
    END

    
    IF @Action = 'REMOVE'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE employee_id = @UserID)
            PRINT 'ERROR: No role to remove';
        ELSE
        BEGIN
            DELETE FROM EmployeeRole
            WHERE employee_id = @UserID;

            PRINT 'Role removed successfully';
        END
        RETURN;
    END

    
    IF @Action = 'UPDATE'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE employee_id = @UserID)
            PRINT 'ERROR: No role to update - use ADD first';
        ELSE
        BEGIN
            UPDATE EmployeeRole
            SET role_id = (SELECT role_id FROM Role WHERE role_name = @Role),
                assigned_date = GETDATE()
            WHERE employee_id = @UserID;

            PRINT 'Role updated to ' + @Role + ' successfully';
        END
        RETURN;
    END

END;
GO
-- END OF SYSTEMADMIN --

-- START OF HR_ADMIN --
-- 1  Create a new employment contract
GO
CREATE PROC CreateContract
    @EmployeeID INT,
    @Type VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    

    DECLARE @ContractID INT;

    INSERT INTO Contract (type, start_date, end_date, current_state)
    VALUES (@Type, @StartDate, @EndDate, 'Active');

    SET @ContractID = SCOPE_IDENTITY();

    IF @Type = 'FullTime'
    BEGIN
        INSERT INTO FullTimeContract (contract_id) VALUES (@ContractID);
    END
    ELSE IF @Type = 'PartTime'
    BEGIN
        INSERT INTO PartTimeContract (contract_id) VALUES (@ContractID);
    END
    ELSE IF @Type = 'Consultant'
    BEGIN
        INSERT INTO ConsultantContract (contract_id) VALUES (@ContractID);
    END
    ELSE IF @Type = 'Internship'
    BEGIN
        INSERT INTO InternshipContract (contract_id) VALUES (@ContractID);
    END

    UPDATE Employee
    SET contract_id = @ContractID
    WHERE employee_id = @EmployeeID;

    PRINT 'Contract created successfully.';
END;
GO
-- 2  Renew or extend an existing contract
CREATE PROC RenewContract
    @ContractID INT,
    @NewEndDate DATE
AS
BEGIN
    UPDATE Contract
    SET end_date = @NewEndDate
        /*,current_state = 'Extended'*/
    WHERE contract_id = @ContractID;

    PRINT 'Contract renewed successfully.';
END;
GO

-- 3 Approve or reject leave requests from employees

GO
CREATE PROC ApproveLeaveRequest
    @LeaveRequestID INT,
    @ApproverID INT,
    @Status VARCHAR(20)
AS
BEGIN
  

    IF @LeaveRequestID IS NULL OR @ApproverID IS NULL OR @Status IS NULL
    BEGIN
        SELECT 'ERROR: Missing required parameters.' AS Message;
        RETURN;
    END

   
    IF @Status NOT IN ('APPROVED', 'REJECTED')
    BEGIN
        SELECT 'ERROR: Status must be APPROVED, REJECTED.' AS Message;
        RETURN;
    END

   
    IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE request_id = @LeaveRequestID)
    BEGIN
        SELECT 'ERROR: Leave request does not exist.' AS Message;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @ApproverID)
    BEGIN
        SELECT 'ERROR: Approver ID does not belong to any employee.' AS Message;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = @ApproverID)
    BEGIN
        SELECT 'ERROR: Approver is NOT an HR Administrator and cannot approve leave requests.' AS Message;
        RETURN;
    END

    
    UPDATE LeaveRequest
    SET 
        status = @Status,
        approval_timing = GETDATE()
    WHERE request_id = @LeaveRequestID;

  
    SELECT CONCAT('Leave Request ', @LeaveRequestID, ' updated to ', @Status, ' by HR Admin ', @ApproverID, '.') AS Message;
END;
GO


-- 4  Assign missions to employees 
GO
CREATE PROC AssignMission
    @EmployeeID INT,
    @ManagerID INT,
    @Destination VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN

    
    INSERT INTO Mission (destination, start_date, end_date/*, status*/, employee_id, manager_id)
    VALUES (@Destination, @StartDate, @EndDate/*, 'Assigned'*/, @EmployeeID, @ManagerID);

    
    SELECT 'Mission assigned successfully.' AS Message;
END;
-- 5  Approve or reject reimbursement claims
GO
CREATE PROC ReviewReimbursement
    @ClaimID INT,
    @ApproverID INT,
    @Decision VARCHAR(20)
AS
BEGIN
   

   /* -- Validate decision
    IF (@Decision NOT IN ('Approved', 'Rejected'))
    BEGIN
        RAISERROR ('Decision must be either ''Approved'' or ''Rejected''.', 16, 1);
        RETURN;
    END;
    */
    IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = @ApproverID)
    BEGIN
        PRINT 'Error: Approver is not authorized HR Administrator.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Reimbursement WHERE reimbursement_id = @ClaimID)
    BEGIN
        RAISERROR ('Reimbursement claim not found.', 16, 1);
        RETURN;
    END;

    UPDATE Reimbursement
    SET 
        current_status = @Decision,
        approval_date = CASE WHEN @Decision = 'Approved' THEN GETDATE() ELSE approval_date END
    WHERE reimbursement_id = @ClaimID;

   
    PRINT 'Reimbursement updated successfully.';
END;
-- 6 View all active employment contracts
GO
CREATE PROC GetActiveContracts
AS
BEGIN
    SELECT 
        c.contract_id,
        c.type,
        c.start_date,
        c.end_date,
        c.current_state,
        e.employee_id,
        e.full_name,
        e.department_id,
        e.position_id
    FROM Contract c
    INNER JOIN Employee e
        ON e.contract_id = c.contract_id
    WHERE c.current_state = 'Active';
END;
-- 7 Retrieve a list of employees under a specific manager
GO
CREATE PROC GetTeamByManager
    @ManagerID INT
AS
BEGIN
    SELECT 
        employee_id,
        full_name
    FROM Employee
    WHERE manager_id = @ManagerID
     
END;
-- 8 Update leave policy details
GO
CREATE PROC UpdateLeavePolicy
@PolicyID int, @EligibilityRules varchar(200), @NoticePeriod int
AS
BEGIN
    UPDATE LeavePolicy
    SET eligibility_rules = @EligibilityRules,
    notice_period = @NoticePeriod 
    WHERE policy_id = @PolicyID;

    PRINT 'Leave policy updated successfully.';
END;

-- 9 Retrieve contracts nearing expiration
GO
CREATE PROC GetExpiringContracts
    @DaysBefore INT
AS
BEGIN
    SELECT 
        c.contract_id,
        c.type,
        c.start_date,
        c.end_date,
        c.current_state,
        e.employee_id,
        e.full_name
    FROM Contract c
    INNER JOIN Employee e ON e.contract_id = c.contract_id
    WHERE c.end_date BETWEEN GETDATE() AND DATEADD(DAY, @DaysBefore, GETDATE())
  
END;
-- 10 Assign a department head
GO
CREATE PROC AssignDepartmentHead
    @DepartmentID INT,
    @ManagerID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @ManagerID)
    BEGIN
        RAISERROR('Manager does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Department
    SET department_head_id = @ManagerID  
    WHERE department_id = @DepartmentID;

    PRINT 'Department head assigned successfully.';
END;
-- 11  Create a new employee profile from a hiring form
GO
ALTER PROC CreateEmployeeProfile
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DepartmentID INT,
    @RoleID INT,
    @HireDate DATE,
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @NationalID VARCHAR(50),
    @DateOfBirth DATE,
    @CountryOfBirth VARCHAR(100)
AS
BEGIN
    DECLARE @FullName VARCHAR(120) = @FirstName + ' ' + @LastName;
    DECLARE @NewEmployeeID INT;

    -- Retrieve hashed password and salt from SESSION_CONTEXT
    DECLARE @PasswordHash VARBINARY(64) = SESSION_CONTEXT(N'PasswordHash');
    

    INSERT INTO Employee 
    (
        first_name,
        last_name,
        full_name,
        department_id,
        hire_date,
        email,
        phone,
        national_id,
        date_of_birth,
        country_of_birth,
        password_hash,
        
    )
    VALUES 
    (
        @FirstName,
        @LastName,
        @FullName,
        @DepartmentID,
        @HireDate,
        @Email,
        @Phone,
        @NationalID,
        @DateOfBirth,
        @CountryOfBirth,
        @PasswordHash,
       
    );

    SET @NewEmployeeID = SCOPE_IDENTITY();

    INSERT INTO EmployeeRole (employee_id, role_id)
    VALUES (@NewEmployeeID, @RoleID);

    PRINT 'Employee profile created successfully.';
    SELECT @NewEmployeeID AS EmployeeID;
END;

/*CREATE PROC CreateEmployeeProfile
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DepartmentID INT,
    @RoleID INT,
    @HireDate DATE,
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @NationalID VARCHAR(50),
    @DateOfBirth DATE,
    @CountryOfBirth VARCHAR(100)
AS
BEGIN

    DECLARE @FullName VARCHAR(120) = @FirstName + ' ' + @LastName;
    DECLARE @NewEmployeeID INT;

    INSERT INTO Employee 
    (
        first_name,
        last_name,
        full_name,
        department_id,
        hire_date,
        email,
        phone,
        national_id,
        date_of_birth,
        country_of_birth
    )
    VALUES 
    (
        @FirstName,
        @LastName,
        @FullName,
        @DepartmentID,
        @HireDate,
        @Email,
        @Phone,
        @NationalID,
        @DateOfBirth,
        @CountryOfBirth
    );

    SET @NewEmployeeID = SCOPE_IDENTITY();

    INSERT INTO EmployeeRole (employee_id, role_id)
    VALUES (@NewEmployeeID, @RoleID);

    PRINT 'Employee profile created successfully.' 
    SELECT @NewEmployeeID AS EmployeeID;
END;*/

-- 12  Edit or update any part of an employee profile
GO
CREATE PROC UpdateEmployeeProfile
    @EmployeeID INT,
    @FieldName VARCHAR(50),
    @NewValue VARCHAR(255)
AS
BEGIN
    BEGIN
       IF (@FieldName = 'first_name')
    UPDATE Employee SET first_name = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'last_name')
    UPDATE Employee SET last_name = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'email')
    UPDATE Employee SET email = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'phone')
    UPDATE Employee SET phone = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'national_id')
    UPDATE Employee SET national_id = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'country_of_birth')
    UPDATE Employee SET country_of_birth = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'address')
    UPDATE Employee SET address = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'emergency_contact_name')
    UPDATE Employee SET emergency_contact_name = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'emergency_contact_phone')
    UPDATE Employee SET emergency_contact_phone = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'relationship')
    UPDATE Employee SET relationship = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'employment_progress')
    UPDATE Employee SET employment_progress = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'account_status')
    UPDATE Employee SET account_status = @NewValue WHERE employee_id = @EmployeeID;

ELSE IF (@FieldName = 'employment_status')
    UPDATE Employee SET employment_status = @NewValue WHERE employee_id = @EmployeeID;

ELSE
     PRINT 'Error: Invalid field name.';

    END
    SELECT 'Employee profile updated successfully.' AS Message;
END;

-- 13  Set and track employee profile completeness percentage.
GO
CREATE PROC SetProfileCompleteness
    @EmployeeID INT,
    @CompletenessPercentage INT
AS
BEGIN
    UPDATE Employee
    SET profile_completion = @CompletenessPercentage
    WHERE employee_id = @EmployeeID;

    SELECT 'Profile completeness updated.' AS Message, @CompletenessPercentage AS Completeness;
END;

-- 14 Search and generate compliance or diversity reports (e.g., by gender, department).
GO
CREATE PROC GenerateProfileReport
    @FilterField VARCHAR(50),
    @FilterValue VARCHAR(100)
AS
BEGIN

    IF @FilterField = 'employment_status'
    BEGIN
        SELECT * FROM Employee WHERE employment_status = @FilterValue;
        RETURN;
    END

    IF @FilterField = 'account_status'
    BEGIN
        SELECT * FROM Employee WHERE account_status = @FilterValue;
        RETURN;
    END

    IF @FilterField = 'department_id'
    BEGIN
        SELECT * FROM Employee WHERE department_id = CAST(@FilterValue AS INT);
        RETURN;
    END

    IF @FilterField = 'position_id'
    BEGIN
        SELECT * FROM Employee WHERE position_id = CAST(@FilterValue AS INT);
        RETURN;
    END

    IF @FilterField = 'country_of_birth'
    BEGIN
        SELECT * FROM Employee WHERE country_of_birth = @FilterValue;
        RETURN;
    END

    IF @FilterField = 'full_name'
    BEGIN
        SELECT * FROM Employee WHERE full_name = @FilterValue;
        RETURN;
    END

    IF @FilterField = 'email'
    BEGIN
        SELECT * FROM Employee WHERE email = @FilterValue;
        RETURN;
    END

    IF @FilterField = 'hire_date'
    BEGIN
        SELECT * FROM Employee WHERE hire_date = CAST(@FilterValue AS DATE);
        RETURN;
    END

    RAISERROR('Invalid filter field.', 16, 1);
END;
GO

-- 15  Define multiple shift types (Normal, Split, Overnight, Mission, etc.)
GO
CREATE PROC CreateShiftType
   @ShiftID int,@Name time,@Break_Duration varchar(100),@Type int,@Shift_Date varchar(50),
 @Start_Time time,@End_Time date,@Status varchar(50)
AS
BEGIN
    INSERT INTO ShiftSchedule (shift_id, name, type, shift_date, start_time, end_time, break_duration, status)
    VALUES (@ShiftID, @Name, @Type, @ShiftDate, @StartTime, @EndTime, @BreakDuration, @Status);

    SELECT 'Shift type created successfully.' AS Message;
END;
-- 16  Assign employees to rotational shifts (Morning/Evening/Night)
GO
CREATE PROC AssignRotationalShift
    @EmployeeID INT,
    @ShiftCycleID INT,
    @StartDate DATE,
    @EndDate DATE,
    @Status VARCHAR(20)
AS
BEGIN
    ;
    
    DECLARE @CurrentDate DATE = @StartDate;
    DECLARE @DayCounter INT = 0;
    DECLARE @ShiftCount INT;
    DECLARE @ShiftID INT;
    
    SELECT @ShiftCount = COUNT(*) 
    FROM ShiftCycleAssignment 
    WHERE cycle_id = @ShiftCycleID;
    
    WHILE @CurrentDate <= @EndDate
    BEGIN
        SELECT @ShiftID = shift_id
        FROM ShiftCycleAssignment
        WHERE cycle_id = @ShiftCycleID 
        AND order_number = (@DayCounter % @ShiftCount) + 1;
        
        INSERT INTO ShiftAssignment (employee_id, shift_id, start_date, end_date, status)
        VALUES (@EmployeeID, @ShiftID, @CurrentDate, @CurrentDate, @Status);
        
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
        SET @DayCounter = @DayCounter + 1;
    END
    
    PRINT 'Shifts assigned successfully.';
END;

GO
CREATE PROC NotifyShiftExpiry
@EmployeeID INT,
@ShiftAssignmentID INT,
@ExpiryDate DATE
AS
BEGIN
   

    
    IF EXISTS (
        SELECT 1
        FROM ShiftAssignment
        WHERE assignment_id = @ShiftAssignmentID
          AND employee_id = @EmployeeID
          AND DATEDIFF(DAY, @ExpiryDate, end_date) BETWEEN 0 AND 3
    )
    BEGIN
        INSERT INTO Notification (message_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Your shift assignment ID ', @ShiftAssignmentID, ' will expire soon on ', CONVERT(VARCHAR, @ExpiryDate, 23), '.'),
            GETDATE(),
            'High',
            'Unread',
            'ShiftExpiry'
        );

        INSERT INTO Employee_Notification (employee_id, notification_id, delivery_status, delivered_at)
        VALUES (
            @EmployeeID,
            SCOPE_IDENTITY(),
            'Pending',
            NULL
        );

        SELECT 'Notification created successfully.' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No notification created. Shift is not near expiry.' AS Message;
    END


END;


GO
CREATE PROC DefineShortTimeRules
    @RuleName VARCHAR(50),
    @LateMinutes INT,
    @EarlyLeaveMinutes INT,
    @PenaltyType VARCHAR(50)
AS
BEGIN
    

    INSERT INTO LatenessPolicy (policy_id, grace_period_mins, deduction_rate)
    SELECT 
        policy_id,
        @LateMinutes,
        @PenaltyType
    FROM PayrollPolicy
    WHERE type = @RuleName;

    SELECT 'Short time rule defined successfully for: ' + @RuleName AS Message;
END;

GO
CREATE PROC SetGracePeriod
    @Minutes INT
AS
BEGIN
    

    
    UPDATE LatenessPolicy
    SET grace_period_mins = @Minutes;

    
    SELECT CONCAT('Grace period successfully set to ', @Minutes, ' minutes.') AS Message;
END;

GO

CREATE PROC DefinePenaltyThreshold
    @LateMinutes INT,
    @DeductionType VARCHAR(50)
AS
BEGIN
    
    
    UPDATE LatenessPolicy
    SET deduction_rate = @DeductionType,
        grace_period_mins = @LateMinutes
    WHERE grace_period_mins <= @LateMinutes;

    
    SELECT CONCAT('Penalty threshold set: Late ', @LateMinutes, ' mins = ', @DeductionType) AS Message;
END;

GO
CREATE PROCEDURE DefinePermissionLimits
    @MinHours INT,
    @MaxHours INT
AS
BEGIN
 

    
    IF @MinHours < 0 OR @MaxHours < 0 OR @MinHours > @MaxHours
    BEGIN
        RAISERROR('Invalid input: MinHours must be >= 0 and <= MaxHours', 16, 1);
        RETURN;
    END

    
    DECLARE @PolicyID INT;

    IF EXISTS (SELECT 1 FROM LatenessPolicy WHERE deduction_rate LIKE 'PermissionLimit%')
    BEGIN
        SELECT @PolicyID = policy_id FROM LatenessPolicy WHERE deduction_rate LIKE 'PermissionLimit%';

        UPDATE LatenessPolicy
        SET deduction_rate = 'PermissionLimit: ' + CAST(@MinHours AS VARCHAR) + '-' + CAST(@MaxHours AS VARCHAR)
        WHERE policy_id = @PolicyID;
    END
    ELSE
    BEGIN
        INSERT INTO PayrollPolicy (type, effective_date, description)
        VALUES ('PermissionLimit', GETDATE(), 'Defines min/max hours allowed for permissions');

        SET @PolicyID = SCOPE_IDENTITY();

        INSERT INTO LatenessPolicy (policy_id, grace_period_mins, deduction_rate)
        VALUES (@PolicyID, 0, 'PermissionLimit: ' + CAST(@MinHours AS VARCHAR) + '-' + CAST(@MaxHours AS VARCHAR));
    END

    
    SELECT 'Permission limits set successfully.' AS Message;
END;

GO
CREATE PROC EscalatePendingRequests
    @Deadline DATETIME
AS
BEGIN
    

    
    UPDATE LR
    SET LR.status = 'Escalated'
    FROM LeaveRequest LR
    INNER JOIN Employee E ON LR.employee_id = E.employee_id
    WHERE LR.status = 'Pending'
      AND LR.approval_timing <= @Deadline;

    SELECT 'Pending requests have been escalated to higher managers.' AS ConfirmationMessage;
END;

GO
CREATE PROC LinkVacationToShift
    @VacationPackageID INT,
    @EmployeeID INT
AS
BEGIN
   

    
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        RAISERROR('Employee does not exist.', 16, 1);
        RETURN;
    END

   
    IF NOT EXISTS (SELECT 1 FROM VacationLeave WHERE leave_id = @VacationPackageID)
    BEGIN
        RAISERROR('Vacation package does not exist.', 16, 1);
        RETURN;
    END

    
    INSERT INTO ShiftAssignment (employee_id, shift_id, start_date, end_date)
    SELECT 
        @EmployeeID,
        shift_id,                
        GETDATE(),                 
        DATEADD(DAY, 1, GETDATE()); 
        
    SELECT 'Vacation package linked to employee schedule successfully.' AS ConfirmationMessage;
END;

GO
CREATE PROC ConfigureLeavePolicies
AS
BEGIN
    

    
    INSERT INTO LeavePolicy (name, purpose, eligibility_rules, notice_period, special_leave_type, reset_on_new_year)
    VALUES 
        ('Holiday', 'Official public holidays', 'All employees eligible', 'N/A', 'None', 1),
        ('Vacation', 'Annual vacation leave', 'All full-time employees', '2 weeks notice', 'None', 1),
        ('Probation', 'Leave during probation period', 'Employees under probation', '1 week notice', 'Probation', 0),
        ('Sick', 'Sick leave for medical reasons', 'All employees eligible', 'Immediate notice', 'Medical', 0);

    
    SELECT 'Leave configuration process initiated with default policies.' AS ConfirmationMessage;
END;


GO
CREATE PROC AuthenticateLeaveAdmin
    @AdminID INT,
    @Password VARCHAR(100)
AS
BEGIN
    
    
   
    IF EXISTS (
        SELECT 1 
        FROM HRAdministrator 
        WHERE employee_id = @AdminID
        AND password_hash = HASHBYTES('SHA2_256', @Password)
    )
    BEGIN
        SELECT 'Administrator credentials authenticated successfully.' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'Authentication failed. Invalid administrator credentials.' AS Message;
    END
END;

GO
CREATE PROC ApplyLeaveConfiguration
AS
BEGIN
    

   
    UPDATE LeaveRequest
    SET status = 'Applied',
        approval_timing = GETDATE()
    WHERE status = 'Validated';

    SELECT 'Leave configurations have been successfully applied.' AS Message;

END;

GO
CREATE PROC ApplyLeaveConfiguration
AS
BEGIN
    

   
    UPDATE LeaveRequest
    SET status = 'Applied',
        approval_timing = GETDATE()
    WHERE status = 'Validated';

    SELECT 'Leave configurations have been successfully applied.' AS Message;

END;

GO
CREATE PROC UpdateLeaveEntitlements
    @EmployeeID INT
AS
BEGIN
    
    
    DECLARE @YearsOfService INT;
    
    
    SELECT @YearsOfService = DATEDIFF(YEAR, hire_date, GETDATE())
    FROM Employee
    WHERE employee_id = @EmployeeID;
   
    UPDATE LeaveEntitlement
    SET entitlement = 14 + @YearsOfService
    WHERE employee_id = @EmployeeID;
    
    
    INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
    SELECT @EmployeeID, leave_id, 14 + @YearsOfService
    FROM Leave
    WHERE leave_id NOT IN (
        SELECT leave_type_id 
        FROM LeaveEntitlement 
        WHERE employee_id = @EmployeeID
    );
    
    SELECT 'Leave entitlements updated successfully.' AS ConfirmationMessage;
END
GO

CREATE PROC ConfigureLeaveEligibility
    @LeaveType VARCHAR(50),
    @MinTenure INT,
    @EmployeeType VARCHAR(50)
AS
BEGIN
    
   
    IF EXISTS (SELECT 1 FROM LeavePolicy WHERE name = @LeaveType)
    BEGIN
        UPDATE LeavePolicy
        SET eligibility_rules = CONCAT('MinTenure:', @MinTenure, '; EmployeeType:', @EmployeeType)
        WHERE name = @LeaveType;
    END
    ELSE
    BEGIN
        INSERT INTO LeavePolicy (name, eligibility_rules)
        VALUES (@LeaveType, CONCAT('MinTenure:', @MinTenure, '; EmployeeType:', @EmployeeType));
    END

    SELECT 'Eligibility rules configured successfully.' AS Message;
END
GO

CREATE PROC ManageLeaveTypes
    @LeaveType VARCHAR(50),
    @Description VARCHAR(200)
AS
BEGIN


    
    IF EXISTS (SELECT 1 FROM Leave WHERE leave_type = @LeaveType)
    BEGIN
        UPDATE Leave
        SET leave_description = @Description
        WHERE leave_type = @LeaveType;
    END
    ELSE
    BEGIN
        INSERT INTO Leave (leave_type, leave_description)
        VALUES (@LeaveType, @Description);
    END

    SELECT 'Leave type managed successfully.' AS Message;
END
GO

CREATE PROC AssignLeaveEntitlement
    @EmployeeID INT,
    @LeaveType VARCHAR(50),
    @Entitlement DECIMAL(5,2)
AS
BEGIN

    DECLARE @LeaveID INT;
    SELECT @LeaveID = leave_id FROM Leave WHERE leave_type = @LeaveType;

    IF EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID)
    BEGIN
        UPDATE LeaveEntitlement
        SET entitlement = @Entitlement
        WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID;
    END
    ELSE
    BEGIN
        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
        VALUES (@EmployeeID, @LeaveID, @Entitlement);
    END

    SELECT 'Leave entitlement assigned successfully.' AS Message;
END
GO


CREATE PROC ConfigureLeaveRules
    @LeaveType VARCHAR(50),
    @MaxDuration INT,
    @NoticePeriod INT,
    @WorkflowType VARCHAR(50)
AS
BEGIN
   
    IF EXISTS (SELECT 1 FROM LeavePolicy WHERE special_leave_type = @LeaveType)
        UPDATE LeavePolicy
        SET notice_period = @NoticePeriod,
            eligibility_rules = 'Max duration: ' + CAST(@MaxDuration AS VARCHAR(10)) + ' days'
        WHERE special_leave_type = @LeaveType;
    ELSE
        INSERT INTO LeavePolicy (name, notice_period, special_leave_type, eligibility_rules)
        VALUES (@LeaveType + ' Policy', @NoticePeriod, @LeaveType, 'Max duration: ' + CAST(@MaxDuration AS VARCHAR(10)) + ' days');
    
    IF EXISTS (SELECT 1 FROM ApprovalWorkflow WHERE workflow_type = @WorkflowType)
        UPDATE ApprovalWorkflow
        SET status = 'Active'
        WHERE workflow_type = @WorkflowType;
    ELSE
        INSERT INTO ApprovalWorkflow (workflow_type, status)
        VALUES (@WorkflowType, 'Active');
    
    SELECT 'Leave rules configured successfully.' AS Message;
END;
GO


CREATE PROC ConfigureSpecialLeave
    @LeaveType VARCHAR(50),
    @Rules VARCHAR(200)
AS
BEGIN
   

    IF EXISTS (SELECT 1 FROM LeavePolicy WHERE name = @LeaveType)
        UPDATE LeavePolicy
        SET eligibility_rules = @Rules
        WHERE name = @LeaveType;
    ELSE
        INSERT INTO LeavePolicy (name, eligibility_rules)
        VALUES (@LeaveType, @Rules);

    SELECT 'Special leave configured successfully.' AS Message;
END;

GO
CREATE PROC SetLeaveYearRules
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    
    
    IF @EndDate <= @StartDate
    BEGIN
        SELECT 'Error: EndDate must be after StartDate.' AS Message;
        RETURN;
    END
    
    UPDATE Contract
    SET start_date = @StartDate,
        end_date = @EndDate;
    
    UPDATE LeavePolicy
    SET reset_on_new_year = 1;
    
    SELECT 'Leave year rules defined and reset applied successfully.' AS Message;
END;

GO
CREATE PROC AdjustLeaveBalance
    @EmployeeID INT,
    @LeaveType VARCHAR(50),
    @Adjustment DECIMAL(5,2)
AS
BEGIN
    
    
    DECLARE @LeaveID INT;

    SELECT @LeaveID = leave_id
    FROM Leave
    WHERE leave_type = @LeaveType;

    IF @LeaveID IS NULL
    BEGIN
        RAISERROR('Invalid LeaveType: Not found in Leave table.', 16, 1);
        RETURN;
    END

    
    IF EXISTS (
        SELECT 1 FROM LeaveEntitlement
        WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID
    )
    BEGIN
        UPDATE LeaveEntitlement
        SET entitlement = entitlement + @Adjustment
        WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID;
    END
    ELSE
    BEGIN
      
        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
        VALUES (@EmployeeID, @LeaveID, @Adjustment);
    END

    SELECT 'Leave balance adjusted successfully.' AS Message;
END;

GO
CREATE PROC ManageLeaveRoles
    @RoleID INT,
    @Permissions VARCHAR(200)
AS
BEGIN
   
   
    IF EXISTS (SELECT 1 FROM RolePermission WHERE role_id = @RoleID)
    BEGIN
        UPDATE RolePermission
        SET permission_name = @Permissions,
            allowed_action = 'Allowed'
        WHERE role_id = @RoleID;
    END
    ELSE
    BEGIN
        INSERT INTO RolePermission (role_id, permission_name, allowed_action)
        VALUES (@RoleID, @Permissions, 'Allowed');
    END

    SELECT 'Leave role permissions saved successfully.' AS Message;
END;

GO
CREATE PROC FinalizeLeaveRequest
    @LeaveRequestID INT
AS
BEGIN
   

    
    UPDATE LeaveRequest
    SET status = 'Finalized'
    WHERE request_id = @LeaveRequestID
      AND status = 'Approved';

    SELECT 'Leave request finalized successfully.' AS Message;
END;

GO
CREATE PROC OverrideLeaveDecision
    @LeaveRequestID INT,
    @Reason VARCHAR(200)
AS
BEGIN
  
    UPDATE LeaveRequest
    SET status = 'Overridden',
        justification = @Reason
    WHERE request_id = @LeaveRequestID;

    SELECT 'Leave decision overridden successfully.' AS Message;
END;

GO
CREATE PROC BulkProcessLeaveRequests
    @LeaveRequestIDs VARCHAR(500)
AS
BEGIN
    

    UPDATE LeaveRequest
    SET status = 'Processed'
    WHERE request_id = @LeaveRequestIDs;

    SELECT 'Leave requests processed successfully.' AS Message;
END;

GO
CREATE PROC VerifyMedicalLeave
    @LeaveRequestID INT,
    @DocumentID INT
AS
BEGIN
    
    
    IF NOT EXISTS (
        SELECT 1
        FROM LeaveRequest lr
        JOIN SickLeave sl ON lr.leave_id = sl.leave_id
        WHERE lr.request_id = @LeaveRequestID
    )
    BEGIN
        SELECT 'Error: Invalid leave request. Not a medical leave.' AS ConfirmationMessage;
        RETURN;
    END
    
    IF NOT EXISTS (
        SELECT 1
        FROM LeaveDocument
        WHERE document_id = @DocumentID
          AND leave_request_id = @LeaveRequestID
    )
    BEGIN
        SELECT 'Error: Invalid document. Does not belong to this leave request.' AS ConfirmationMessage;
        RETURN;
    END
    
    UPDATE LeaveRequest
    SET status = 'Verified'
    WHERE request_id = @LeaveRequestID;
    
    SELECT 'Medical leave document verified successfully.' AS ConfirmationMessage;
END

GO
CREATE PROC SyncLeaveBalances
    @LeaveRequestID INT
AS
BEGIN
   
    
    DECLARE @EmployeeID INT,
            @LeaveID INT,
            @Duration DECIMAL(5,2),
            @CurrentBalance DECIMAL(5,2);
    
    SELECT 
        @EmployeeID = employee_id,
        @LeaveID = leave_id,
        @Duration = CAST(duration AS DECIMAL(5,2))
    FROM LeaveRequest
    WHERE request_id = @LeaveRequestID
      AND status = 'Approved';
    
    IF @EmployeeID IS NULL
    BEGIN
        SELECT 'Error: Leave request not found or not approved.' AS ConfirmationMessage;
        RETURN;
    END
    
    SELECT @CurrentBalance = entitlement
    FROM LeaveEntitlement
    WHERE employee_id = @EmployeeID
      AND leave_type_id = @LeaveID;
    
    IF @CurrentBalance IS NULL
    BEGIN
        SELECT 'Error: No leave entitlement found for this employee.' AS ConfirmationMessage;
        RETURN;
    END
    
    IF @CurrentBalance < @Duration
    BEGIN
        SELECT 'Error: Insufficient leave balance.' AS ConfirmationMessage;
        RETURN;
    END
    
    UPDATE LeaveEntitlement
    SET entitlement = entitlement - @Duration
    WHERE employee_id = @EmployeeID
      AND leave_type_id = @LeaveID;
    
    SELECT 'Leave balances synchronized successfully.' AS ConfirmationMessage;
END

GO
CREATE PROC ProcessLeaveCarryForward
    @Year INT
AS
BEGIN
    
    UPDATE LeaveEntitlement
    SET entitlement = entitlement + vl.carry_over_days
    FROM LeaveEntitlement le
    INNER JOIN VacationLeave vl ON le.leave_type_id = vl.leave_id;
    
    SELECT 'Leave carry-forward processed successfully.' AS ConfirmationMessage;
END;

GO
CREATE PROCEDURE SyncLeaveToAttendance
    @LeaveRequestID INT
AS
BEGIN
  
    DECLARE 
        @EmployeeID INT,
        @LeaveType VARCHAR(50),
        @ShiftID INT,
        @ShiftDate DATE,
        @ExceptionID INT,
        @Today DATE = CAST(GETDATE() AS DATE);
    
    SELECT 
        @EmployeeID = lr.employee_id,
        @LeaveType = l.leave_type
    FROM LeaveRequest lr
    JOIN Leave l ON lr.leave_id = l.leave_id
    WHERE lr.request_id = @LeaveRequestID
      AND lr.status = 'Approved';
    
    IF @EmployeeID IS NULL
    BEGIN
        SELECT 'Error: Leave request not found or not approved.' AS ConfirmationMessage;
        RETURN;
    END
    
    SELECT TOP 1 
        @ShiftID = sa.shift_id,
        @ShiftDate = s.shift_date
    FROM ShiftAssignment sa
    JOIN ShiftSchedule s ON sa.shift_id = s.shift_id
    WHERE sa.employee_id = @EmployeeID
      AND s.shift_date = @Today;
    
    IF @ShiftID IS NULL
    BEGIN
        SELECT 'Error: No shift found for today.' AS ConfirmationMessage;
        RETURN;
    END
    
    INSERT INTO Exception (name, category, date, status)
    VALUES (@LeaveType + ' Leave', 'Leave', @ShiftDate, 'Approved');
    
    SET @ExceptionID = SCOPE_IDENTITY();
    
    IF EXISTS (SELECT 1 FROM Attendance WHERE employee_id = @EmployeeID AND shift_id = @ShiftID)
    BEGIN
        UPDATE Attendance
        SET exception_id = @ExceptionID
        WHERE employee_id = @EmployeeID
          AND shift_id = @ShiftID;
    END
    ELSE
    BEGIN
        INSERT INTO Attendance (employee_id, shift_id, exception_id)
        VALUES (@EmployeeID, @ShiftID, @ExceptionID);
    END
    
    SELECT 'Leave synced with attendance successfully.' AS ConfirmationMessage;
END;

GO
CREATE PROC UpdateInsuranceBrackets
    @BracketID INT,
    @NewMinSalary DECIMAL(10,2),
    @NewMaxSalary DECIMAL(10,2),
    @NewEmployeeContribution DECIMAL(5,2),
    @NewEmployerContribution DECIMAL(5,2),
    @UpdatedBy INT
AS
BEGIN
    
    
    
    IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = @UpdatedBy)
    BEGIN
        SELECT 'Error: Only HR Administrators can update insurance brackets.' AS NotificationMessage;
        RETURN;
    END
    
    
    IF NOT EXISTS (SELECT 1 FROM Insurance WHERE insurance_id = @BracketID)
    BEGIN
        SELECT 'Error: Insurance bracket not found.' AS NotificationMessage;
        RETURN;
    END
    
    UPDATE PayGrade
    SET 
        min_salary = @NewMinSalary,
        max_salary = @NewMaxSalary
    WHERE pay_grade_id = @BracketID;
    
    UPDATE Insurance
    SET 
        contribution_rate = @NewEmployeeContribution,
        coverage = CONCAT('MinSalary: ', @NewMinSalary, 
                        ', MaxSalary: ', @NewMaxSalary,
                        ', EmployerContribution: ', @NewEmployerContribution)
    WHERE insurance_id = @BracketID;
    
    
    SELECT 'Insurance bracket updated successfully by Employee ID: ' + CAST(@UpdatedBy AS VARCHAR(10)) AS NotificationMessage;
    
END;
GO

CREATE PROCEDURE ApprovePolicyUpdate
    @PolicyID INT,
    @ApprovedBy INT
AS
BEGIN

    IF EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = @ApprovedBy)
    BEGIN
        UPDATE PayrollPolicy
        SET description = 'Approved by EmployeeID ' + CAST(@ApprovedBy AS VARCHAR(10))
        WHERE policy_id = @PolicyID;

        SELECT 'Policy approved successfully.' AS ConfirmationMessage;
    END
    ELSE
    BEGIN
        SELECT 'Error: Only HR administrators can approve policies.' AS ConfirmationMessage;
    END
END;
GO
-- END OF HR_ADMIN -- 


-- START OF PAYROLL OFFICER -- 

-- 1  Generate payroll for a specific pay period --
GO
CREATE PROC GeneratePayroll
@StartDate date, @EndDate date
AS
BEGIN 
    INSERT INTO Payroll (
        employee_id,
        period_start,
        period_end,
        base_amount,
        taxes,
        adjustments,
        contributions,
        actual_pay,
        net_salary,
        payment_date
    )
    SELECT
        e.employee_id,
        @StartDate AS period_start,
        @EndDate AS period_end,
        
        p.min_salary AS base_amount,
        p.min_salary * 0.15 AS taxes,                 -- 15% tax
        0 AS adjustments,                             -- default adjustments
        p.min_salary * 0.05 AS contributions,        -- 5% contributions
        p.min_salary - (p.min_salary * 0.15) AS actual_pay,
        (p.min_salary - (p.min_salary * 0.15) + 0) AS net_salary,
        GETDATE() AS payment_date
    FROM Employee e
    INNER JOIN Contract c ON e.contract_id = c.contract_id
    INNER JOIN PayGrade p ON e.pay_grade = p.pay_grade_id
    WHERE e.is_active = 1;
    
END;
GO

-- 2 Add or modify allowances and deductions for an employee -- 
CREATE PROC AdjustPayrollItem
    @PayrollID INT,
    @Type VARCHAR(50),
    @Amount DECIMAL(10,2),
    @duration INT,
    @timezone VARCHAR(20)
AS
BEGIN
    

    DECLARE @EmployeeID INT;

   
    SELECT @EmployeeID = employee_id
    FROM Payroll
    WHERE payroll_id = @PayrollID;

    IF @EmployeeID IS NULL
    BEGIN
        RAISERROR('Payroll ID not found.', 16, 1);
        RETURN;
    END

   
    IF EXISTS (
        SELECT 1 
        FROM AllowanceDeduction
        WHERE payroll_id = @PayrollID
          AND employee_id = @EmployeeID
          AND type = @Type
    )
    BEGIN
        UPDATE AllowanceDeduction
        SET amount = @Amount,
            duration = @duration,
            timezone = @timezone
        WHERE payroll_id = @PayrollID
          AND employee_id = @EmployeeID
          AND type = @Type;

        PRINT 'Allowance/Deduction updated successfully.';
    END
    ELSE
    BEGIN
        INSERT INTO AllowanceDeduction (payroll_id, employee_id, type, amount, duration, timezone)
        VALUES (@PayrollID, @EmployeeID, @Type, @Amount, @duration, @timezone);

        PRINT 'Allowance/Deduction added successfully.';
    END

END;

-- ---------------------------------------------------------------- --

GO
CREATE PROC CalculateNetSalary
    @PayrollID INT,
    @NetSalary DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @NetSalary = net_salary
    FROM Payroll
    WHERE payroll_id = @PayrollID;
END;

-- 4  Apply payroll policies (bonus, overtime, deductions) --
GO
CREATE PROC ApplyPayrollPolicy
    @PolicyID INT,
    @PayrollID INT,
    @Type VARCHAR(20),
    @Duration INT,
    @Description VARCHAR(50)
AS
BEGIN
    
    
    DECLARE @NewPolicyID INT;
    
  
    IF NOT EXISTS (SELECT 1 FROM Payroll WHERE payroll_id = @PayrollID)
    BEGIN
        PRINT 'ERROR: Payroll record not found';
        RETURN;
    END
    
    IF @Type NOT IN ('BONUS', 'OVERTIME', 'DEDUCTION', 'LATENESS')
    BEGIN
        PRINT 'ERROR: Type must be BONUS, OVERTIME, DEDUCTION, or LATENESS';
        RETURN;
    END
    
  
    INSERT INTO PayrollPolicy (effective_date, type, description)
    VALUES (GETDATE(), @Type, @Description);
    
    SET @NewPolicyID = SCOPE_IDENTITY();
    
   
    IF @Type = 'BONUS'
    BEGIN
        INSERT INTO BonusPolicy (policy_id, bonus_type, eligibility_criteria)
        VALUES (@NewPolicyID, 'Standard', @Description);
    END
    ELSE IF @Type = 'OVERTIME'
    BEGIN
        INSERT INTO OvertimePolicy (policy_id, weekday_rate_multiplier, weekend_rate_multiplier, max_hours_per_month)
        VALUES (@NewPolicyID, 1.5, 2.0, @Duration);
    END
    ELSE IF @Type = 'DEDUCTION'
    BEGIN
        INSERT INTO DeductionPolicy (policy_id, deduction_reason, calculation_mode)
        VALUES (@NewPolicyID, @Description, 'Fixed');
    END
    ELSE IF @Type = 'LATENESS'
    BEGIN
        INSERT INTO LatenessPolicy (policy_id, grace_period_mins, deduction_rate)
        VALUES (@NewPolicyID, @Duration, 'Per minute');
    END
    
   
    INSERT INTO PayrollPolicy_ID (payroll_id, policy_id)
    VALUES (@PayrollID, @NewPolicyID);
    
    PRINT 'Policy applied successfully: Type=' + @Type + ', Duration=' + CAST(@Duration AS VARCHAR(10)) + ' mins, Description=' + @Description;
END;
GO
-- 5  Retrieve payroll summary for a given month --
GO
CREATE PROC GetMonthlyPayrollSummary
 @Month INT,@Year INT
AS
BEGIN
    SELECT SUM(net_salary) AS TotalSalaryExpenditure
    FROM Payroll
    WHERE MONTH(payment_date) = @Month
      AND YEAR(payment_date) = @Year;
END;

-- 7 Retrieve payroll history for a specific employee --

GO
CREATE PROC GetEmployeePayrollHistory
    @EmployeeID INT
AS
BEGIN   
    SELECT 
        payroll_id,
        period_start,
        period_end,
        base_amount,
        adjustments,
        contributions,
        actual_pay,
        net_salary,
        payment_date
    FROM Payroll
    WHERE employee_id = @EmployeeID
    ORDER BY period_start ASC;
END;
-- 8  Get list of employees eligible for bonuses --
GO
CREATE PROC GetBonusEligibleEmployees
    @Eligibility_criteria VARCHAR(255)
AS
BEGIN
 SELECT DISTINCT
        E.employee_id,
        E.full_name,
        E.email,
        E.department_id,
        E.position_id,
        BP.bonus_type,
        BP.eligibility_criteria
    FROM Employee E
    CROSS JOIN BonusPolicy BP
    INNER JOIN PayrollPolicy PP
        ON PP.policy_id = BP.policy_id
    WHERE E.is_active = 1
      AND BP.eligibility_criteria = @Eligibility_criteria;
END;

-- 9  Update salary type for an employee --
GO
CREATE PROC UpdateSalaryType
    @EmployeeID INT,
    @SalaryTypeID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        PRINT 'Employee not found.';
        RETURN;
    END

    
    IF NOT EXISTS (SELECT 1 FROM SalaryType WHERE salary_type_id = @SalaryTypeID)
    BEGIN
        PRINT 'Salary type not found.';
        RETURN;
    END

    
    UPDATE Employee
    SET salary_type_id = @SalaryTypeID
    WHERE employee_id = @EmployeeID;

    PRINT 'Salary type updated successfully.';
END;
-- 10 Retrieve payroll summary for a specific department --
GO
CREATE PROC GetPayrollByDepartment
@DepartmentID INT, @Month INT, @Year INT
AS
BEGIN
    SELECT 
        d.department_id,
        d.department_name,
        SUM(p.base_amount) AS TotalBaseAmount,
        SUM(p.adjustments) AS TotalAdjustments,
        SUM(p.contributions) AS TotalContributions,
        SUM(p.net_salary) AS TotalNetSalary

    FROM Payroll p

    INNER JOIN Employee e ON p.employee_id = e.employee_id
    INNER JOIN Department d ON e.department_id = d.department_id

    WHERE e.department_id = @DepartmentID
      AND MONTH(p.payment_date) = @Month
      AND YEAR(p.payment_date) = @Year

    GROUP BY d.department_id, d.department_name;
END;
   

-- 11  Block payroll processing if missed punches remain unresolved so that salary calculations are accurate -- 
GO
CREATE PROC ValidateAttendanceBeforePayroll
@PayrollPeriodID int
AS
BEGIN
    SELECT DISTINCT
        e.employee_id,
        e.full_name,
        acr.date AS punch_date,
        acr.status AS correction_status
    FROM PayrollPeriod pp
    INNER JOIN Payroll p ON p.payroll_id = pp.payroll_id
    INNER JOIN Employee e ON e.employee_id = p.employee_id
    INNER JOIN AttendanceCorrectionRequest acr
        ON acr.employee_id = e.employee_id
    INNER JOIN Attendance a
        ON a.employee_id = e.employee_id
        AND CAST(a.entry_time AS DATE) = acr.date
    WHERE pp.payroll_period_id = @PayrollPeriodID
        AND acr.status NOT IN ('Approved', 'Resolved')
        AND a.entry_time BETWEEN pp.start_date AND pp.end_date;
END;


-- 12  Sync attendance records daily to payroll and benefits so that all systems remain aligned --
GO
CREATE PROC SyncAttendanceToPayroll
@SyncDate date
AS
BEGIN
    UPDATE P
    SET P.adjustments = P.adjustments  
    FROM Payroll P
    INNER JOIN Attendance A
        ON P.employee_id = A.employee_id
    WHERE CAST(A.entry_time AS DATE) = @SyncDate
      AND @SyncDate BETWEEN P.period_start AND P.period_end;

    PRINT 'Attendance synced to payroll successfully.';
END;


-- 13 Ensure only accepted permissions affect payroll so that calculations remain accurate --
GO
CREATE PROC SyncApprovedPermissionsToPayroll
@PayrollPeriodID int
AS
BEGIN

    IF NOT EXISTS (
        SELECT 1 
        FROM PayrollPeriod
        WHERE payroll_period_id = @PayrollPeriodID
          AND status = 'Approved'
    )
    BEGIN
        PRINT 'Payroll period is not approved. No changes applied.';
        RETURN;
    END

    UPDATE P
    SET P.adjustments = P.adjustments 
    FROM Payroll P
    INNER JOIN PayrollPeriod PP
        ON P.payroll_id = PP.payroll_id
    WHERE PP.payroll_period_id = @PayrollPeriodID;

    PRINT 'Approved permissions synced to payroll successfully.';
END;

-- 14  Configure pay grades and salary bands -- 
GO
CREATE PROC  ConfigurePayGrades
@GradeName varchar(50), @MinSalary decimal(10,2), @MaxSalary decimal(10,2)
AS
BEGIN
   
    IF EXISTS (SELECT 1 FROM PayGrade WHERE grade_name = @GradeName)
    BEGIN
      
        UPDATE PayGrade
        SET min_salary = @MinSalary,
            max_salary = @MaxSalary
        WHERE grade_name = @GradeName;

        PRINT 'Pay grade updated successfully.';
    END
    ELSE
    BEGIN
        INSERT INTO PayGrade (grade_name, min_salary, max_salary)
        VALUES (@GradeName, @MinSalary, @MaxSalary);

        PRINT 'Pay grade created successfully.';
    END
END;


-- 15 Configure shift differentials and special allowances --
GO
CREATE PROC ConfigureShiftAllowances
@ShiftType varchar(50), @AllowanceName varchar(50), @Amount decimal(10,2)
AS
BEGIN

INSERT INTO ShiftSchedule(type) VALUES (@ShiftType);
INSERT INTO AllowanceDeduction(type,amount) VALUES (@AllowanceName,@Amount);
    
END;


-- 16  Enable multi-currency payroll for international employees --
GO
CREATE PROC EnableMultiCurrencyPayroll
@CurrencyCode varchar(10), @ExchangeRate decimal(10,4)
AS
BEGIN
    
   
    IF EXISTS (SELECT 1 FROM Currency WHERE currency_code = @CurrencyCode)
    BEGIN
        
        UPDATE Currency
        SET exchange_rate = @ExchangeRate
        WHERE currency_code = @CurrencyCode;
        PRINT 'Currency exchange rate updated successfully.';
    END
    ELSE
    BEGIN
        
        INSERT INTO Currency (currency_code, exchange_rate)
        VALUES (@CurrencyCode, @ExchangeRate);
        PRINT 'New currency added successfully.';
    END
END;


-- 17  Define and update tax rules for payroll compliance --
GO
CREATE PROC ManageTaxRules
@TaxRuleName varchar(50), @CountryCode varchar(10), @Rate decimal(5,2), @Exemption decimal(10,2)
AS
BEGIN
   

    IF EXISTS (SELECT 1 
               FROM TaxForm 
               WHERE jurisdiction = @CountryCode 
                 AND form_content LIKE '%' + @TaxRuleName + '%')
    BEGIN
        
        UPDATE TaxForm
        SET form_content = 'Rule: ' + @TaxRuleName 
                         + ', Rate: ' + CAST(@Rate AS VARCHAR(10)) 
                         + ', Exemption: ' + CAST(@Exemption AS VARCHAR(10)),
            validity_period = GETDATE() 
        WHERE jurisdiction = @CountryCode
          AND form_content LIKE '%' + @TaxRuleName + '%';

        SELECT 'Tax rule updated successfully.' AS Message;
    END
    ELSE
    BEGIN
        INSERT INTO TaxForm (jurisdiction, validity_period, form_content)
        VALUES (@CountryCode, GETDATE(), 
                'Rule: ' + @TaxRuleName 
                + ', Rate: ' + CAST(@Rate AS VARCHAR(10)) 
                + ', Exemption: ' + CAST(@Exemption AS VARCHAR(10)));

        SELECT 'Tax rule inserted successfully.' AS Message;
    END
END;
-- 18  Approve payroll configuration changes to prevent unauthorized adjustments --
GO
CREATE PROC ApprovePayrollConfigChanges
@ConfigID int, @ApproverID int, @Status varchar(20)
AS
BEGIN
    

    
    UPDATE ApprovalWorkflowStep
    SET action_required = @Status
    WHERE workflow_id = @ConfigID
      AND role_id = (SELECT role_id 
                     FROM EmployeeRole 
                     WHERE employee_id = @ApproverID);

    
    IF NOT EXISTS (
        SELECT 1
        FROM ApprovalWorkflowStep
        WHERE workflow_id = @ConfigID
          AND action_required <> 'Approved'
    )
    BEGIN
        UPDATE ApprovalWorkflow
        SET status = 'Approved'
        WHERE workflow_id = @ConfigID;
    END

    
    SELECT CONCAT('Payroll configuration ', @ConfigID, ' has been ', @Status, ' by approver ', @ApproverID) AS ConfirmationMessage;
END;


-- 19 Configure signing bonuses for new hires --
GO
CREATE PROC ConfigureSigningBonus
@EmployeeID int, @BonusAmount decimal(10,2), @EffectiveDate date
AS
BEGIN

    
    DECLARE @PolicyID INT;

    
    SELECT TOP 1 @PolicyID = bp.policy_id
    FROM BonusPolicy bp
    JOIN PayrollPolicy pp ON bp.policy_id = pp.policy_id
    WHERE pp.effective_date = @EffectiveDate;

    IF @PolicyID IS NULL
    BEGIN
        SELECT 'No active bonus policy found for the given date.' AS ConfirmationMessage;
        RETURN;
    END

    INSERT INTO AllowanceDeduction (
        employee_id,
        type,
        amount
    )
    VALUES (
        @EmployeeID,
        'Signing Bonus',
        @BonusAmount
    );

   
    SELECT CONCAT(
        'Signing bonus of ', @BonusAmount, 
        ' configured for employee ID ', @EmployeeID, 
        ' effective ', CONVERT(VARCHAR(10), @EffectiveDate, 120)
    ) AS ConfirmationMessage;
END;

-- 20  Configure termination and resignation compensations --
GO
CREATE PROCEDURE ConfigureTerminationBenefits
    @EmployeeID INT,
    @CompensationAmount DECIMAL(10,2),
    @EffectiveDate DATE,
    @Reason VARCHAR(50)
AS
BEGIN
  

    DECLARE @ContractID INT;

   
    SELECT @ContractID = contract_id
    FROM Employee
    WHERE employee_id = @EmployeeID;

    IF @ContractID IS NULL
    BEGIN
        PRINT 'Error: Employee does not have an associated contract.';
        RETURN;
    END;

   INSERT INTO Termination (date, reason, contract_id)
   VALUES (@EffectiveDate, @Reason, @ContractID);

    UPDATE Contract
    SET end_date = @EffectiveDate,
        current_state = 'Terminated'
    WHERE contract_id = @ContractID;

  
    UPDATE Employee
    SET employment_status = 'Terminated',
        is_active = 0,
        employment_progress = 'Finalized'
    WHERE employee_id = @EmployeeID;

   
    UPDATE Payroll
    SET net_salary = net_salary + @CompensationAmount
    WHERE employee_id = @EmployeeID
      AND period_start <= @EffectiveDate
      AND period_end >= @EffectiveDate;

    PRINT 'Termination benefits configured successfully.';
END;
GO

-- 21  Configure insurance brackets with contribution percentages --

CREATE PROCEDURE ConfigureInsuranceBrackets
    @InsuranceType VARCHAR(50),
    @MinSalary DECIMAL(10,2),
    @MaxSalary DECIMAL(10,2),
    @EmployeeContribution DECIMAL(5,2),
    @EmployerContribution DECIMAL(5,2)
AS
        BEGIN
               IF @EmployeeContribution IS NULL AND @EmployerContribution IS NOT NULL
        BEGIN
            INSERT INTO Insurance (type, contribution_rate)
            VALUES (@InsuranceType, @EmployerContribution);
        END
        ELSE IF @EmployerContribution IS NULL AND @EmployeeContribution IS NOT NULL
        BEGIN
            INSERT INTO Insurance (type, contribution_rate)
            VALUES (@InsuranceType, @EmployeeContribution);
        END
        ELSE
        BEGIN
            INSERT INTO Insurance (type, contribution_rate)
            VALUES (@InsuranceType, @EmployeeContribution + @EmployerContribution);
        END
    
        INSERT INTO PayGrade (min_salary, max_salary)
        VALUES (@MinSalary, @MaxSalary);
        
        SELECT 'Insurance bracket configured successfully' AS Message;
END;
GO

-- 22 Update existing insurance brackets when policies change --
GO
CREATE PROC UpdateInsuranceBrackets
    @BracketID INT,
    @NewMinSalary DECIMAL(10,2),
    @NewMaxSalary DECIMAL(10,2),
    @NewEmployeeContribution DECIMAL(5,2),
    @NewEmployerContribution DECIMAL(5,2)
   
AS
BEGIN
    

    IF NOT EXISTS (SELECT 1 FROM Insurance WHERE insurance_id = @BracketID)
    BEGIN
        SELECT 'Error: Insurance bracket not found.' AS NotificationMessage;
        RETURN;
    END

   
    UPDATE PayGrade
    SET 
        min_salary = @NewMinSalary,
        max_salary = @NewMaxSalary

   
    UPDATE Insurance
    SET 
        contribution_rate = @NewEmployeeContribution,
        coverage = CONCAT('MinSalary: ', @NewMinSalary, 
                        ', MaxSalary: ', @NewMaxSalary,
                        ', EmployerContribution: ', @NewEmployerContribution)
    WHERE insurance_id = @BracketID;

    
    PRINT 'Insurance bracket updated successfully by Employee ID: ';

END;
-- 23 Configure payroll rules and structure (salary types, deductions, bonuses, etc.)
GO
CREATE PROCEDURE ConfigurePayrollPolicies
    @PolicyType VARCHAR(50),
    @PolicyDetails NVARCHAR(MAX),
    @EffectiveDate DATE
AS
BEGIN
    
   INSERT INTO PayrollPolicy (effective_date, type, description)
    VALUES (@EffectiveDate, @PolicyType, @PolicyDetails);

    PRINT 'Payroll policy updated successfully.' ;
END;

-- 24  Define and manage pay grades, salary bands, and compensation limits to ensure consistency and fairness -- 
GO
CREATE PROC DefinePayGrades
@GradeName varchar(50), @MinSalary decimal(10,2), @MaxSalary decimal(10,2), @CreatedBy int
AS
BEGIN
    

    
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @CreatedBy)
    BEGIN
        RAISERROR('Invalid CreatedBy: Employee does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO PayGrade (grade_name, min_salary, max_salary)
    VALUES (@GradeName, @MinSalary, @MaxSalary);

   
    SELECT 'Pay grade defined successfully.' + @CreatedBy AS Result;
END;

-- 25 Configure escalation workflows for deductions or overpayments requiring higher-level approvalS --
GO
CREATE PROC ConfigureEscalationWorkflow
@ThresholdAmount decimal(10,2), @ApproverRole varchar(50), @CreatedBy int
AS
BEGIN
    

   
    INSERT INTO ApprovalWorkflow (workflow_type, threshold_amount, approver_role, created_by)
    VALUES ('Escalation', @ThresholdAmount, @ApproverRole, @CreatedBy);

    SELECT 'Escalation workflow configured successfully.' AS Result;
END;

-- 26  Define employee pay types (hourly, daily, monthly, etc.) for correct salary calculations -- 
GO
CREATE PROC DefinePayType
@EmployeeID INT,
@PayType VARCHAR(50),
@EffectiveDate DATE
AS
BEGIN
 

    DECLARE @SalaryTypeID INT;
    
    SELECT @SalaryTypeID = salary_type_id FROM SalaryType WHERE type = @PayType;

   UPDATE Employee SET salary_type_id = @SalaryTypeID WHERE employee_id = @EmployeeID;

   SELECT CONCAT('Pay type for Employee #', @EmployeeID, 
                  ' set to ', @PayType, 
                  ' effective ', CONVERT(VARCHAR(10), @EffectiveDate, 120), '.') 
           AS ConfirmationMessage;

    

END;

-- 27 Configure overtime rules (e.g., rate multipliers) to ensure fair compensation --
GO
CREATE PROC ConfigureOvertimeRules
    @DayType VARCHAR(20),
    @Multiplier DECIMAL(3,2),
    @hourspermonth INT
AS
BEGIN
    
    
    DECLARE @WeekdayRate DECIMAL(3,2) = NULL;
    DECLARE @WeekendRate DECIMAL(3,2) = NULL;
    DECLARE @NewPolicyID INT;
    
 
    IF @DayType = 'WEEKDAY'
        SET @WeekdayRate = @Multiplier;
    ELSE IF @DayType = 'WEEKEND'
        SET @WeekendRate = @Multiplier;
    ELSE
    BEGIN
        SELECT 'Invalid DayType. Must be WEEKDAY or WEEKEND.' AS Message;
        RETURN;
    END
    
 
    INSERT INTO PayrollPolicy (effective_date, type, description)
    VALUES (GETDATE(), 'Overtime', CONCAT(@DayType, 'overtime policy'));
    
    SET @NewPolicyID = SCOPE_IDENTITY();
   
    INSERT INTO OvertimePolicy (policy_id, weekday_rate_multiplier, weekend_rate_multiplier, max_hours_per_month)
    VALUES (@NewPolicyID, @WeekdayRate, @WeekendRate, @hourspermonth);
   
    SELECT CONCAT('Overtime policy configured successfully for ', @DayType, '.') AS ConfirmationMessage;
END;
GO




--28  Set shift differentials and special condition allowances (e.g., night shift, hazard pay) --
GO
CREATE PROC ConfigureShiftAllowance
    @ShiftType VARCHAR(20),
    @AllowanceAmount DECIMAL(10,2),
    @CreatedBy INT
AS
BEGIN
    

  
    IF @ShiftType IS NULL 
    BEGIN
        PRINT 'ERROR: ShiftType cannot be empty.';
        RETURN;
    END

    IF @AllowanceAmount <= 0
    BEGIN
        PRINT 'ERROR: AllowanceAmount must be greater than zero.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @CreatedBy)
    BEGIN
        PRINT 'ERROR: CreatedBy employee does not exist.';
        RETURN;
    END

   
    INSERT INTO AllowanceDeduction (
        type,
        amount
    )
    VALUES (
       
        @ShiftType,
        @AllowanceAmount   
    );

    PRINT 'Shift allowance configured successfully.';
END;
GO


-- 30  Configure policies for signing bonuses and payroll initiation for new hires --
GO
CREATE PROC ConfigureSigningBonusPolicy
@BonusType varchar(50), @Amount decimal(10,2), @EligibilityCriteria nvarchar(max)
AS
BEGIN
    DECLARE @NewPolicyID INT

  
    INSERT INTO PayrollPolicy (effective_date, type, description)
    VALUES (GETDATE(), 'Signing Bonus', 
            'Signing Bonus - Type: ' + @BonusType + 
            ', Amount: ' + CAST(@Amount AS VARCHAR(20)))

    
    SET @NewPolicyID = SCOPE_IDENTITY()

    
    INSERT INTO BonusPolicy (policy_id, bonus_type, eligibility_criteria)
    VALUES (@NewPolicyID, @BonusType, @EligibilityCriteria)

    SET @Message = 'Signing Bonus Policy created successfully with ID ' + CAST(@NewPolicyID AS VARCHAR(10))
END;



-- 32  Generate tax statements for employees annually --
GO
CREATE PROC GenerateTaxStatement
@EmployeeID int, @TaxYear int
AS
BEGIN
    IF @EmployeeID IS NULL OR @TaxYear IS NULL
    BEGIN
        PRINT 'Inputs cannot be NULL';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_id = @EmployeeID)
    BEGIN
        PRINT 'Employee does not exist';
        RETURN;
    END;

    SELECT 
        taxes,
        period_start,
        period_end
    FROM Payroll
    WHERE employee_id = @EmployeeID
      AND YEAR(period_end) = @TaxYear
    ORDER BY period_end;

END;


GO
-- 33 Approve configuration changes made by Payroll Specialists before they take effect --
CREATE PROC ApprovePayrollConfiguration
@ConfigID int, @ApprovedBy int
AS
BEGIN

IF EXISTS (
        SELECT 1 
        FROM PayrollSpecialist PS
        WHERE PS.employee_id = @ApprovedBy
    )
    PRINT 'Payroll configuration approved successfully.';

END;

-- 34 Modify or correct payroll entries when authorized --
GO
CREATE PROC ModifyPastPayroll
@PayrollRunID int, @EmployeeID int, @FieldName varchar(50), @NewValue decimal(10,2),
 @ModifiedBy int
AS
BEGIN
    IF NOT EXISTS (
    SELECT 1 FROM PayrollSpecialist PS
    WHERE PS.employee_id = @ModifiedBy
    )
    BEGIN
        PRINT 'Error: Only Payroll Specialists can modify past payroll.';
        RETURN;
    END;

 IF @FieldName = 'base_amount'
    UPDATE Payroll
    SET base_amount = @NewValue
    WHERE payroll_id = @PayrollRunID AND employee_id = @EmployeeID;

ELSE IF @FieldName = 'taxes'
    UPDATE Payroll
    SET taxes = @NewValue
    WHERE payroll_id = @PayrollRunID AND employee_id = @EmployeeID;

ELSE IF @FieldName = 'adjustments'
    UPDATE Payroll
    SET adjustments = @NewValue
    WHERE payroll_id = @PayrollRunID AND employee_id = @EmployeeID;

ELSE IF @FieldName = 'contributions'
    UPDATE Payroll
    SET contributions = @NewValue
    WHERE payroll_id = @PayrollRunID AND employee_id = @EmployeeID;

ELSE IF @FieldName = 'actual_pay'
    UPDATE Payroll
    SET actual_pay = @NewValue
    WHERE payroll_id = @PayrollRunID AND employee_id = @EmployeeID;

ELSE IF @FieldName = 'net_salary'
    UPDATE Payroll
    SET net_salary = @NewValue
    WHERE payroll_id = @PayrollRunID AND employee_id = @EmployeeID;
    PRINT 'Payroll entry modified successfully.';
    END;
    


-- END OF PAYROLL OFFICER --

-- START OF LINE MANAGER --
--1
GO
CREATE PROC ReviewLeaveRequest
    @LeaveRequestID INT,
    @ManagerID INT,
    @Decision VARCHAR(20)
AS
BEGIN
   

    IF @LeaveRequestID IS NULL OR @ManagerID IS NULL OR @Decision IS NULL
    BEGIN
        RAISERROR('Inputs cannot be NULL.', 16, 1);
        RETURN;
    END

    UPDATE LeaveRequest
    SET status = @Decision,
        approval_timing = GETDATE()
    WHERE request_id = @LeaveRequestID;

    
    SELECT 
        @LeaveRequestID AS LeaveRequestID,
        @ManagerID AS ManagerID,
        @Decision AS Decision;
END;
------
--2
GO 
CREATE PROC AssignShift
@EmployeeID int ,@ShiftID int
AS
BEGIN
  
    IF @EmployeeID IS NULL
    BEGIN
        PRINT 'Error: EmployeeID cannot be NULL.';
        RETURN;
    END

  
    IF @ShiftID IS NULL
    BEGIN
        PRINT 'Error: ShiftID cannot be NULL.';
        RETURN;
    END

    INSERT INTO ShiftAssignment(employee_id ,shift_id )
    VALUES(@EmployeeID,@ShiftID)
    PRINT 'Shift assigned successfully.';
END;
------
--3
GO
CREATE PROC ViewTeamAttendance
    @ManagerID INT,
    @DateRangeStart DATE,
    @DateRangeEnd DATE
AS
BEGIN
   
    IF @ManagerID IS NULL OR @DateRangeStart IS NULL OR @DateRangeEnd IS NULL
    BEGIN
        PRINT 'Error: ManagerID or DateRange cannot be NULL.';
        RETURN;
    END

    SELECT
        A.attendance_id,
        A.employee_id,
        E.full_name,
        A.shift_id,
        A.entry_time,
        A.exit_time,
        A.duration,
        A.login_method,
        A.logout_method,
        A.exception_id
    FROM Attendance A
    JOIN Employee E ON A.employee_id = E.employee_id
    WHERE E.manager_id = @ManagerID
      AND A.entry_time = @DateRangeStart AND A.exit_time=@DateRangeEnd
    ORDER BY A.entry_time;
END;

GO
CREATE PROC SendTeamNotification
    @ManagerID INT,
    @MessageContent VARCHAR(255),
    @UrgencyLevel VARCHAR(50)
AS
BEGIN
    IF @ManagerID IS NULL OR @MessageContent IS NULL OR @UrgencyLevel IS NULL
    BEGIN
        RAISERROR('Inputs cannot be NULL.', 16, 1);
        RETURN;
    END;
    
    IF NOT EXISTS (SELECT 1 FROM LineManager WHERE employee_id = @ManagerID)
    BEGIN
        RAISERROR('Unauthorized manager.', 16, 1);
        RETURN;
    END;
    
    DECLARE @NotificationID INT;
    
    INSERT INTO Notification (message_content, timestamp, urgency, notification_type)
    VALUES (@MessageContent, GETDATE(), @UrgencyLevel, 'Team');
    
    SET @NotificationID = SCOPE_IDENTITY();
    
    INSERT INTO Employee_Notification (employee_id, notification_id, delivery_status, delivered_at)
    SELECT employee_id, @NotificationID, 'Delivered', GETDATE()
    FROM Employee
    WHERE manager_id = @ManagerID;
    
    SELECT 'Notification sent successfully.' AS ConfirmationMessage;
END;

GO
CREATE PROC ApproveMissionCompletion
    @MissionID INT,
    @ManagerID INT,
    @Remarks VARCHAR(200)
AS
BEGIN
    IF @MissionID IS NULL OR @ManagerID IS NULL OR @Remarks IS NULL
    BEGIN
        RAISERROR('Inputs cannot be NULL.', 16, 1);
        RETURN;
    END

    UPDATE Mission
    SET status = 'Completed'
    WHERE mission_id = @MissionID
      AND manager_id = @ManagerID;

    PRINT 'Mission completion approved successfully.';
END;
GO

CREATE PROC RequestReplacement
    @EmployeeID INT,
    @Reason VARCHAR(150)
AS
BEGIN
    IF @EmployeeID IS NULL OR @Reason IS NULL
    BEGIN
        RAISERROR('Inputs cannot be NULL.', 16, 1);
        RETURN;
    END

    PRINT 'Replacement request submitted successfully.';
    -- No such table for replacements, so just return confirmation message.
END;
GO

CREATE PROC ViewDepartmentSummary
    @DepartmentID INT
AS
BEGIN
    -- NO such table or attribute for Projects  

    IF @DepartmentID IS NULL
    BEGIN
        RAISERROR('DepartmentID cannot be NULL.' ,16,1);
        RETURN;
    END

    SELECT 
        d.department_name,
        d.purpose,
        COUNT(e.employee_id) AS employee_count
    FROM Department d
    LEFT JOIN Employee e
        ON e.department_id = d.department_id
    WHERE d.department_id = @DepartmentID
    GROUP BY 
        d.department_name,
        d.purpose
END;

GO
CREATE PROC ReassignShift
    @EmployeeID INT,
    @OldShiftID INT,
    @NewShiftID INT
AS
BEGIN
    UPDATE ShiftAssignment
    SET shift_id = @NewShiftID
    WHERE employee_id = @EmployeeID
      AND shift_id = @OldShiftID;

    SELECT 'Shift reassigned successfully.' AS ConfirmationMessage;
END;

GO
CREATE PROC GetPendingLeaveRequests
    @ManagerID INT
AS
BEGIN
    SELECT lr.request_id,
           e.full_name AS EmployeeName,
           l.leave_type,
           lr.justification,
           lr.duration,
           lr.status,
           lr.approval_timing
    FROM LeaveRequest lr
    INNER JOIN Employee e ON lr.employee_id = e.employee_id
    INNER JOIN Leave l ON lr.leave_id = l.leave_id
    WHERE e.manager_id = @ManagerID
      AND lr.status = 'Pending';
END;

GO
CREATE PROCEDURE GetTeamStatistics
    @ManagerID INT
AS
BEGIN
   

    SELECT 
        lm.team_size,
        AVG(e.salary) AS average_salary,
        lm.approval_limit AS span_of_control
    FROM LineManager lm
    INNER JOIN Employee e ON e.manager_id = lm.employee_id
    WHERE lm.employee_id = @ManagerID
    GROUP BY lm.team_size, lm.approval_limit;
END;

GO
CREATE PROC ViewTeamProfiles
    @ManagerID INT
AS
BEGIN
    

    SELECT
        e.full_name,
        e.country_of_birth,
        e.phone,
        e.email,
        e.employment_status,
        e.is_active,
        e.profile_completion
    FROM Employee e
    INNER JOIN LineManager lm
        ON lm.employee_id = @ManagerID
        AND e.manager_id = lm.employee_id
    WHERE e.employee_id <> @ManagerID; 
END;

GO
CREATE PROC GetTeamSummary
    @ManagerID INT
AS
BEGIN
  
    
   
    IF NOT EXISTS (SELECT 1 FROM LineManager WHERE employee_id = @ManagerID)
    BEGIN
        SELECT 'Error: Invalid manager ID.' AS ErrorMessage;
        RETURN;
    END;
    
    SELECT
        e.position_id,
        e.department_id,
        COUNT(e.employee_id) AS role_count,
        AVG(DATEDIFF(YEAR, e.hire_date, GETDATE())) AS avg_tenure_years
    FROM Employee e
    WHERE e.manager_id = @ManagerID
    GROUP BY e.position_id, e.department_id
    ORDER BY e.department_id, e.position_id;
END;

GO
CREATE PROCEDURE FilterTeamProfiles
    @ManagerID INT,
    @Skill VARCHAR(50),
    @RoleID INT
AS
BEGIN
    SELECT e.employee_id, e.first_name, e.last_name, e.full_name
    FROM Employee e
    LEFT JOIN Employee_Skill es ON e.employee_id = es.employee_id
    LEFT JOIN EmployeeRole er ON e.employee_id = er.employee_id
    WHERE e.manager_id = @ManagerID
      AND (es.skill_id IN (SELECT skill_id FROM Skill WHERE skill_name = @Skill) OR @Skill IS NULL)
      AND (er.role_id = @RoleID OR @RoleID IS NULL);
END;

GO
CREATE PROC ViewTeamCertifications
    @ManagerID INT
AS
BEGIN
    SELECT e.employee_id, e.full_name, s.skill_name, v.verification_type, v.issuer
    FROM Employee e
    LEFT JOIN Employee_Skill es ON e.employee_id = es.employee_id
    LEFT JOIN Skill s ON es.skill_id = s.skill_id
    LEFT JOIN Employee_Verification ev ON e.employee_id = ev.employee_id
    LEFT JOIN Verification v ON ev.verification_id = v.verification_id
    WHERE e.manager_id = @ManagerID;
END;

GO
CREATE PROC AddManagerNotes
    @EmployeeID INT,
    @ManagerID INT,
    @Note VARCHAR(500)
AS
BEGIN
  
    IF NOT EXISTS (
        SELECT 1 
        FROM Employee 
        WHERE employee_id = @EmployeeID 
        AND manager_id = @ManagerID
    )
    BEGIN
        SELECT 'Error: Unauthorized.' AS ConfirmationMessage;
        RETURN;
    END;
    
    INSERT INTO ManagerNotes(employee_id, manager_id, note_content, created_at)
    VALUES (@EmployeeID, @ManagerID, @Note, GETDATE());
    
    SELECT 'Note added successfully.' AS ConfirmationMessage;
END;

GO
CREATE PROCEDURE RecordManualAttendance
    @EmployeeID INT,
    @Date DATE,
    @ClockIn TIME,
    @ClockOut TIME,
    @Reason VARCHAR(200),
    @RecordedBy INT
AS
BEGIN
    

    DECLARE @AttendanceID INT;
    DECLARE @LogID INT;

    
    INSERT INTO Attendance (employee_id, entry_time, exit_time)
    VALUES (@EmployeeID, @ClockIn, @ClockOut);

    SET @AttendanceID = SCOPE_IDENTITY();

    
    SELECT @LogID = ISNULL(MAX(attendance_log_id), 0) + 1
    FROM AttendanceLog;

    
    INSERT INTO AttendanceLog (attendance_log_id, attendance_id, actor, timestamp, reason)
    VALUES (@LogID, @AttendanceID, @RecordedBy, GETDATE(), @Reason);

    SELECT 'Attendance recorded successfully.' AS ConfirmationMessage;
END;

GO
CREATE PROC ReviewMissedPunches
    @ManagerID INT,
    @Date DATE
AS
BEGIN
    SELECT 
        a.attendance_id, 
        e.full_name, 
        a.entry_time, 
        a.exit_time
    FROM Attendance a
    JOIN Employee e ON a.employee_id = e.employee_id
    WHERE 
        e.manager_id = @ManagerID
        AND (a.entry_time IS NULL OR a.exit_time IS NULL)
        AND (
              CAST(a.entry_time AS DATE) = @Date
              OR CAST(a.exit_time AS DATE) = @Date
            );
END;
GO
CREATE PROC ApproveTimeRequest
    @RequestID INT,
    @ManagerID INT,
    @Decision VARCHAR(20),
    @Comments VARCHAR(200)
AS
BEGIN
    
    IF @Decision NOT IN ('Approved', 'Rejected')
    BEGIN
        SELECT 'Error: Invalid decision.' AS ConfirmationMessage;
        RETURN;
    END;
    
    
    IF NOT EXISTS (
        SELECT 1 
        FROM AttendanceCorrectionRequest acr
        JOIN Employee e ON acr.employee_id = e.employee_id
        WHERE acr.request_id = @RequestID 
        AND e.manager_id = @ManagerID
    )
    BEGIN
        SELECT 'Error: Unauthorized.' AS ConfirmationMessage;
        RETURN;
    END;
    
    UPDATE AttendanceCorrectionRequest
    SET status = @Decision,
        recorded_by = @ManagerID,
        reason = @Comments
    WHERE request_id = @RequestID;
    
    SELECT 'Confirmation: Request processed.' AS ConfirmationMessage;
END;
GO
CREATE PROC ViewLeaveRequest
    @LeaveRequestID INT,
    @ManagerID INT
AS
BEGIN
    SELECT 
        lr.request_id, 
        lr.employee_id, 
        e.full_name, 
        lr.leave_id, 
        l.leave_type, 
        lr.justification, 
        lr.duration, 
        lr.status
    FROM LeaveRequest lr
    JOIN Employee e ON lr.employee_id = e.employee_id
    JOIN Leave l ON lr.leave_id = l.leave_id
    WHERE lr.request_id = @LeaveRequestID
      AND e.manager_id = @ManagerID;
END;

GO
CREATE PROC ApproveLeaveRequest
    @LeaveRequestID INT,
    @ManagerID INT
AS
BEGIN
    UPDATE lr
    SET status = 'Approved'
    FROM LeaveRequest lr
    JOIN Employee e ON lr.employee_id = e.employee_id
    JOIN LineManager lm ON lm.employee_id = @ManagerID
    WHERE lr.request_id = @LeaveRequestID
      AND lm.employee_id = @ManagerID
      AND e.manager_id = lm.employee_id;

    SELECT 'Leave request approved successfully' AS ConfirmationMessage;
END;
GO


GO
CREATE PROC ApproveLeaveRequest
    @LeaveRequestID INT,
    @ManagerID INT
AS
BEGIN
    UPDATE lr
    SET status = 'Rejected'
    FROM LeaveRequest lr
    JOIN Employee e ON lr.employee_id = e.employee_id
    JOIN LineManager lm ON lm.employee_id = @ManagerID
    WHERE lr.request_id = @LeaveRequestID
      AND lm.employee_id = @ManagerID
      AND e.manager_id = lm.employee_id;

    SELECT 'Leave request approved successfully' AS ConfirmationMessage;
END;
GO

CREATE PROC DelegateLeaveApproval
    @ManagerID INT,
    @DelegateID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    
    INSERT INTO LeaveRequest (employee_id, leave_id, duration)
    VALUES (@ManagerID, @DelegateID, DATEDIFF(DAY, @StartDate, @EndDate));
    
    
    SELECT 'Leave approval authority delegated successfully.' AS Message;
END;
GO

CREATE PROC FlagIrregularLeave
    @EmployeeID INT,
    @ManagerID INT,
    @PatternDescription VARCHAR(200)
AS
BEGIN
  
    
   
    INSERT INTO LeaveRequest (employee_id, leave_id, justification)
    VALUES (@EmployeeID, @ManagerID, @PatternDescription);
    
    SELECT 'Irregular leave pattern flagged successfully.' AS Message;
END;

GO
CREATE PROC NotifyNewLeaveRequest
    @ManagerID INT,
    @RequestID INT
AS
BEGIN
    DECLARE @NotifID INT;

    INSERT INTO Notification (message_content, timestamp, notification_type)
    VALUES (
        (SELECT 'New leave request from ' + e.full_name
         FROM LeaveRequest lr
         JOIN Employee e ON lr.employee_id = e.employee_id
         WHERE lr.request_id = @RequestID),
        GETDATE(), 'LeaveRequest'
    );

    SET @NotifID = SCOPE_IDENTITY();

    INSERT INTO Employee_Notification (employee_id, notification_id, delivered_at)
    VALUES (@ManagerID, @NotifID, GETDATE());

    SELECT 'Notification sent successfully.' AS NotificationMessage;
END;
GO
 -- END OF LINE MANAGER --

 
-- START OF EMPLOYEE --
--1. Submit a leave request

GO
CREATE PROC SubmitLeaveRequest
    @EmployeeID INT,
    @LeaveTypeID INT,
    @StartDate DATE,
    @EndDate DATE,
    @Reason VARCHAR(100)
AS
BEGIN
    DECLARE @Duration INT;
    SET @Duration = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
    
    INSERT INTO LeaveRequest (employee_id, leave_id, justification, duration)
    VALUES (@EmployeeID, @LeaveTypeID, @Reason, @Duration);
    
    SELECT 'Leave request submitted successfully.' AS Message;
END;
GO

-- 2. Check leave balance -- entitlement in real life means all leave days not remaining days
CREATE PROC GetLeaveBalance
    @EmployeeID INT
AS
BEGIN
    SELECT 
       /* e.employee_id,
        e.first_name + ' ' + e.last_name AS employee_name,
        l.leave_type,*/
        le.entitlement AS remaining_leave_days
    FROM Employee e
    JOIN LeaveEntitlement le ON e.employee_id = le.employee_id
    JOIN Leave l ON le.leave_type_id = l.leave_id
    WHERE e.employee_id = @EmployeeID;
END;
GO

-- 3. Record attendance for a workday
CREATE PROC RecordAttendance
    @EmployeeID INT,
    @ShiftID INT,
    @EntryTime TIME,
    @ExitTime TIME
AS
BEGIN
    /*DECLARE @Duration VARCHAR(20);
    SET @Duration = CAST(DATEDIFF(MINUTE, @EntryTime, @ExitTime) AS VARCHAR(20)) + ' minutes';*/ 
    
    INSERT INTO Attendance (employee_id, shift_id, entry_time, exit_time/*, duration*/)
    VALUES (@EmployeeID, @ShiftID, @EntryTime, @ExitTime/*,@Duration*/);
    
    SELECT 'Attendance recorded successfully.' AS Message;
END;
GO

-- 4. Submit a reimbursement request
CREATE PROC SubmitReimbursement
    @EmployeeID INT,
    @ExpenseType VARCHAR(50),
    @Amount DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Reimbursement (employee_id,claim_type,amount)
    VALUES (@EmployeeID, @ExpenseType, @Amount); 
    
    SELECT 'Reimbursement request submitted successfully.' AS Message;
END;
GO

-- 5. Add a personal skill
CREATE PROC AddEmployeeSkill
    @EmployeeID INT,
    @SkillName VARCHAR(50)
AS
BEGIN
    DECLARE @SkillID INT;
    
    SELECT @SkillID = skill_id FROM Skill WHERE skill_name = @SkillName;
    
    IF @SkillID IS NULL
    BEGIN
        INSERT INTO Skill (skill_name)
        VALUES (@SkillName);
        
        SET @SkillID = SCOPE_IDENTITY();
    END
    
    INSERT INTO Employee_Skill (employee_id, skill_id)
    VALUES (@EmployeeID, @SkillID);
    
    SELECT 'Skill added successfully.' AS Message;
END;
GO

-- 6. View assigned shifts
CREATE PROC ViewAssignedShifts
    @EmployeeID INT
AS
BEGIN
    SELECT 
        /*sa.assignment_id,*/
        ss.shift_date,
        ss.start_time,
        ss.end_time,
        /*ss.name AS shift_name,*/
        /*ss.type AS shift_type,*/
        sa.start_date AS assignment_start,
        sa.end_date AS assignment_end, 
        sa.status
    FROM ShiftAssignment sa
    JOIN ShiftSchedule ss ON sa.shift_id = ss.shift_id
    WHERE sa.employee_id = @EmployeeID;
    
    SELECT d.department_name AS LOCATION
    FROM Employee e
    JOIN Department d ON e.department_id = d.department_id
    WHERE E.employee_id = @EmployeeID;
END;
GO

-- 7. View all contracts
CREATE PROC ViewMyContracts
    @EmployeeID INT
AS
BEGIN
    SELECT 
        c.contract_id,
        c.type AS contract_type,
        c.start_date,
        c.end_date,
        c.current_state
    FROM Employee e
    JOIN Contract c ON e.contract_id = c.contract_id
    WHERE e.employee_id = @EmployeeID;
END;
GO

-- 8. View payroll history
CREATE PROC ViewMyPayroll
    @EmployeeID INT
AS
BEGIN
    SELECT 
        payroll_id,
        period_start,
        period_end,
        base_amount,
        adjustments,
        taxes,
        contributions,
        actual_pay,
        net_salary,
        payment_date
    FROM Payroll
    WHERE employee_id = @EmployeeID
    ORDER BY period_start DESC;
END;
GO

-- 9. Update personal contact details
CREATE PROC UpdatePersonalDetails
    @EmployeeID INT,
    @Phone VARCHAR(20),
    @Address VARCHAR(150)
AS
BEGIN
    UPDATE Employee
    SET phone = @Phone,
        address = @Address
    WHERE employee_id = @EmployeeID;
    
    SELECT 'Contact details updated successfully.' AS Message;
END;
GO

-- 10. View assigned missions
CREATE PROC ViewMyMissions
    @EmployeeID INT
AS
BEGIN
    SELECT 
        mission_id,
        destination,
        start_date,
        end_date,
        status,
        manager_id
    FROM Mission
    WHERE employee_id = @EmployeeID
    ORDER BY start_date DESC;
END;
GO

-- 11. View full employee profile
CREATE PROC ViewEmployeeProfile
    @EmployeeID INT
AS
BEGIN
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.full_name,
        e.national_id,
        e.date_of_birth,
        e.country_of_birth,
        e.phone,
        e.email,
        e.address,
        e.emergency_contact_name,
        e.emergency_contact_phone,
        e.relationship,
        e.hire_date,
        e.employment_status,
        e.account_status,
        p.position_title,
        d.department_name,
        e.manager_id,
        e.is_active
    FROM Employee e
    LEFT JOIN Position p ON e.position_id = p.position_id
    LEFT JOIN Department d ON e.department_id = d.department_id
    WHERE e.employee_id = @EmployeeID;
END;
GO

-- 12. Update contact information by type
CREATE PROC UpdateContactInformation
    @EmployeeID INT,
    @RequestType VARCHAR(50),
    @NewValue VARCHAR(100)
AS
BEGIN
    IF @RequestType = 'Phone'
    BEGIN
        UPDATE Employee
        SET phone = @NewValue
        WHERE employee_id = @EmployeeID;
    END
    ELSE IF @RequestType = 'Address'
    BEGIN
        UPDATE Employee
        SET address = @NewValue
        WHERE employee_id = @EmployeeID;
    END
    
    SELECT 'Contact information updated successfully.' AS Message;
END;
GO

-- 13. View employment timeline
CREATE PROC ViewEmploymentTimeline
    @EmployeeID INT
AS
BEGIN
    SELECT 
        e.employee_id,
        e.hire_date,
        e.employment_status,
        p.position_title,
        d.department_name,
        c.start_date AS contract_start,
        c.end_date AS contract_end,
        c.type AS contract_type
    FROM Employee e
    LEFT JOIN Position p ON e.position_id = p.position_id
    LEFT JOIN Department d ON e.department_id = d.department_id
    LEFT JOIN Contract c ON e.contract_id = c.contract_id
    WHERE e.employee_id = @EmployeeID;
END;
GO

-- 14. Update emergency contact details
CREATE PROC UpdateEmergencyContact
    @EmployeeID INT,
    @ContactName VARCHAR(100),
    @Relation VARCHAR(50),
    @Phone VARCHAR(20)
AS
BEGIN
    UPDATE Employee
    SET emergency_contact_name = @ContactName,
        relationship = @Relation,
        emergency_contact_phone = @Phone
    WHERE employee_id = @EmployeeID;
    
    SELECT 'Emergency contact updated successfully.' AS Message;
END;
GO

-- 15. Request HR document
CREATE PROC RequestHRDocument
    @EmployeeID INT,
    @DocumentType VARCHAR(50)
AS
BEGIN
    DECLARE @NotificationID INT;
    
    INSERT INTO Notification (message_content, timestamp, notification_type)
    VALUES ('HR Document Request: ' + @DocumentType, GETDATE(),  'Document Request');
    
    SET @NotificationID = SCOPE_IDENTITY();
    
    INSERT INTO Employee_Notification (employee_id, notification_id, delivery_status, delivered_at)
    VALUES (@EmployeeID, @NotificationID, 'Delivered', GETDATE());
    
    SELECT 'HR document request submitted successfully.' AS Message;
END;
GO

-- 16. Notify profile update
CREATE PROC NotifyProfileUpdate
    @EmployeeID INT,
    @NotificationType VARCHAR(50)
AS
BEGIN
    DECLARE @NotificationID INT;
    
    INSERT INTO Notification (message_content, timestamp ,notification_type)
    VALUES ('Profile Update: ' + @NotificationType, GETDATE(),@NotificationType);
    
    SET @NotificationID = SCOPE_IDENTITY();
    
    INSERT INTO Employee_Notification (employee_id, notification_id ,delivered_at)
    VALUES (@EmployeeID, @NotificationID, GETDATE());
    
    SELECT 'Notification sent successfully.' AS Message;
END;
GO

-- 17. Log flexible attendance
CREATE PROC LogFlexibleAttendance
    @EmployeeID INT,
    @Date DATE,
    @CheckIn TIME,
    @CheckOut TIME
AS
BEGIN
    DECLARE @TotalHours DECIMAL(5,2);
    SET @TotalHours = DATEDIFF(MINUTE, @CheckIn, @CheckOut) / 60.0;
    
    DECLARE @Duration VARCHAR(20);
    SET @Duration = CAST(@TotalHours AS VARCHAR(20)) + ' hours';
    
    INSERT INTO Attendance (employee_id, entry_time, exit_time, duration)
    VALUES (@EmployeeID, @CheckIn, @CheckOut, @Duration);
    
    SELECT 'Flexible attendance logged successfully. Total working hours: ' + 
           CAST(@TotalHours AS VARCHAR(10)) + ' hours.' AS Message;
END;
GO

-- 18. Notify missed punch
CREATE PROC NotifyMissedPunch
    @EmployeeID INT,
    @Date DATE
AS
BEGIN
    DECLARE @NotificationID INT;
    
    INSERT INTO Notification (message_content, timestamp, notification_type)
    VALUES ('Missed Punch Alert: You missed a punch on ' + CAST(@Date AS DATETIME) + '. Please submit a correction request.', 
            GETDATE(),  'Missed Punch');
    
    SET @NotificationID = SCOPE_IDENTITY();
    
    INSERT INTO Employee_Notification (employee_id, notification_id, delivery_status, delivered_at)
    VALUES (@EmployeeID, @NotificationID, 'Delivered', GETDATE());
    
    SELECT 'Missed punch notification sent successfully.' AS Message;
END;
GO

-- 19. Record multiple punches for breaks and split shifts
CREATE PROC RecordMultiplePunches
    @EmployeeID INT,
    @ClockInOutTime DATETIME,
    @Type VARCHAR(10)
AS
BEGIN
    IF @Type = 'In'
    BEGIN
        INSERT INTO Attendance (employee_id, entry_time)
        VALUES (@EmployeeID, @ClockInOutTime);
    END
    ELSE IF @Type = 'Out'
    BEGIN
        UPDATE Attendance
        SET exit_time = @ClockInOutTime,
            duration = CAST(DATEDIFF(MINUTE, entry_time, @ClockInOutTime) AS VARCHAR(20)) + ' minutes'
        WHERE employee_id = @EmployeeID
        AND exit_time IS NULL
        AND attendance_id = (SELECT MAX(attendance_id) FROM Attendance WHERE employee_id = @EmployeeID AND exit_time IS NULL);
    END
    
    SELECT 'Clock ' + @Type + ' recorded successfully at ' + CAST(@ClockInOutTime AS VARCHAR(30)) + '.' AS Message;
END;
GO

-- 20. Submit correction request
CREATE PROC SubmitCorrectionRequest
    @EmployeeID INT,
    @Date DATE,
    @CorrectionType VARCHAR(50),
    @Reason VARCHAR(200)
AS
BEGIN
    INSERT INTO AttendanceCorrectionRequest (employee_id, date, correction_type, reason)
    VALUES (@EmployeeID, @Date, @CorrectionType, @Reason);
    
    SELECT 'Correction request submitted successfully.' AS Message;
END;
GO

-- 21. View request status
CREATE PROC ViewRequestStatus
    @EmployeeID INT
AS
BEGIN
    SELECT 
        request_id,
        date,
        correction_type,
        reason,
        status
    FROM AttendanceCorrectionRequest
    WHERE employee_id = @EmployeeID
    ORDER BY date DESC;
END;
GO

-- 23. Attach documents to leave request
CREATE PROC AttachLeaveDocuments
    @LeaveRequestID INT,
    @FilePath VARCHAR(200)
AS
BEGIN
    INSERT INTO LeaveDocument (leave_request_id, file_path, uploaded_at)
    VALUES (@LeaveRequestID, @FilePath, GETDATE());
    
    SELECT 'Document attached successfully.' AS Message;
END;
GO

-- 24. Modify existing leave request
CREATE PROC ModifyLeaveRequest
    @LeaveRequestID INT,
    @StartDate DATE,
    @EndDate DATE,
    @Reason VARCHAR(100)
AS
BEGIN
    DECLARE @Duration INT;
    SET @Duration = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
    
    UPDATE LeaveRequest
    SET justification = @Reason,
        duration = @Duration
    WHERE request_id = @LeaveRequestID;
    
    SELECT 'Leave request modified successfully.' AS Message;
END;
GO

-- 25. Cancel leave request
CREATE PROC CancelLeaveRequest
    @LeaveRequestID INT
AS
BEGIN
    UPDATE LeaveRequest
    SET status = 'Cancelled'
    WHERE request_id = @LeaveRequestID;
    
    SELECT 'Leave request cancelled successfully.' AS Message;
END;
GO
-- 26. View current leave balance
CREATE PROC ViewLeaveBalance
    @EmployeeID INT
    AS
    BEGIN
    SELECT 
     l.leave_type,
     le.entitlement AS remaining_leave_days
        FROM LeaveEntitlement le
        JOIN Leave l ON le.leave_type_id = l.leave_id
        WHERE le.employee_id = @EmployeeID;
    END;
    GO

-- 27. View leave history
CREATE PROC ViewLeaveHistory
    @EmployeeID INT
AS
BEGIN
    SELECT 
        lr.request_id,
        l.leave_type,
        lr.justification,
        lr.duration,
        lr.approval_timing,
        lr.status
    FROM LeaveRequest lr
    JOIN Leave l ON lr.leave_id = l.leave_id
    WHERE lr.employee_id = @EmployeeID
    ORDER BY lr.request_id DESC;
END;
GO

-- 28. Submit leave after absence (retroactive)
CREATE PROC SubmitLeaveAfterAbsence
    @EmployeeID INT,
    @LeaveTypeID INT,
    @StartDate DATE,
    @EndDate DATE,
    @Reason VARCHAR(100)
AS
BEGIN
    DECLARE @Duration INT;
    SET @Duration = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
    
    INSERT INTO LeaveRequest (employee_id, leave_id, justification, duration, status)
    VALUES (@EmployeeID, @LeaveTypeID, @Reason, @Duration, 'Retroactive');
    
    SELECT 'Retroactive leave request submitted successfully.' AS Message;
END;
GO

-- 29. Notify leave status change
CREATE PROCEDURE NotifyLeaveStatusChange
    @EmployeeID INT,
    @RequestID INT,
    @Status VARCHAR(20)
AS
BEGIN
 
    
    DECLARE @NotificationID INT;
    DECLARE @MessageContent VARCHAR(255);
    DECLARE @NotificationType VARCHAR(50);
    DECLARE @Urgency VARCHAR(20);
    
  IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE request_id = @RequestID AND employee_id = @EmployeeID)
  BEGIN
   RAISERROR('Leave request not found for the given employee.', 16, 1);
      RETURN;
      END
   
    IF @Status = 'approved'
    BEGIN
        SET @MessageContent = 'Leave request #' + CAST(@RequestID AS VARCHAR) + ' has been approved.';
        SET @NotificationType = 'Leave Approval';
        SET @Urgency = 'Medium';
    END
    ELSE IF @Status = 'rejected'
    BEGIN
        SET @MessageContent = 'Leave request #' + CAST(@RequestID AS VARCHAR) + ' has been rejected.';
        SET @NotificationType = 'Leave Rejection';
        SET @Urgency = 'High';
    END
    ELSE IF @Status = 'returned'
    BEGIN
        SET @MessageContent = 'Leave request #' + CAST(@RequestID AS VARCHAR) + ' has been returned for correction.';
        SET @NotificationType = 'Leave Correction Required';
        SET @Urgency = 'High';
    END
    ELSE IF @Status = 'modified'
    BEGIN
        SET @MessageContent = 'Leave request #' + CAST(@RequestID AS VARCHAR) + ' has been modified.';
        SET @NotificationType = 'Leave Modification';
        SET @Urgency = 'Medium';
    END
    ELSE
    BEGIN
        SET @MessageContent = 'Leave request #' + CAST(@RequestID AS VARCHAR) + ' status updated to: ' + @Status;
        SET @NotificationType = 'Leave Status Update';
        SET @Urgency = 'Low';
    END
    
  
    INSERT INTO Notification (message_content, timestamp, urgency, read_status, notification_type)
    VALUES (@MessageContent, GETDATE(), @Urgency, 'Unread', @NotificationType);
    
  
    SET @NotificationID = SCOPE_IDENTITY();
    
    INSERT INTO Employee_Notification (employee_id, notification_id, delivery_status, delivered_at)
    VALUES (@EmployeeID, @NotificationID, 'Delivered', GETDATE());
    
    UPDATE LeaveRequest
    SET status = @Status
    WHERE request_id = @RequestID;
    
    SELECT @MessageContent AS NotificationMessage, 
           @NotificationID AS NotificationID,
           'Success' AS Status;
END;
-- END OF EMPLOYEE -- 
-- END OF PROCEDURES --
