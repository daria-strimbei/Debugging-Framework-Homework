CREATE OR REPLACE PROCEDURE adjust_salaries_by_commission AS

-- Cursor to select employees and lock rows for update

CURSOR c_emp IS
    SELECT employee_id,
           salary,
           commission_pct
    FROM hr.employees
    FOR UPDATE OF salary;

-- Variable to store new salary
v_new_salary    hr.employees.salary%TYPE;

-- Variable to store increase percentage
v_increase_pct  NUMBER;

BEGIN
    debug_utils.log_info($$PLSQL_UNIT, $$PLSQL_LINE, 'Start processing');

    -- Loop through each employee
    FOR r_emp IN c_emp LOOP
        -- Log employee ID
        debug_utils.log_info(
            $$PLSQL_UNIT,
            $$PLSQL_LINE,
            'Employee ID: ' || r_emp.employee_id
        );
        
        debug_utils.log_debug(
            $$PLSQL_UNIT,
            $$PLSQL_LINE,
            'Old Salary',
            TO_CHAR(r_emp.salary)
        );
        
        -- Determine increase percentage:
        -- if commission exists → use it
        -- otherwise → default to 2%
        v_increase_pct := NVL(r_emp.commission_pct, 0.02);

        debug_utils.log_debug(
            $$PLSQL_UNIT,
            $$PLSQL_LINE,
            'Increase %',
            TO_CHAR(v_increase_pct)
        );
        
         -- Calculate new salary
        v_new_salary := r_emp.salary * (1 + v_increase_pct);

        debug_utils.log_debug(
            $$PLSQL_UNIT,
            $$PLSQL_LINE,
            'New Salary',
            TO_CHAR(v_new_salary)
        );

        -- Update the current row using cursor reference
        UPDATE hr.employees
        SET salary = v_new_salary
        WHERE CURRENT OF c_emp;

        -- Log number of rows updated
        debug_utils.log_debug(
            $$PLSQL_UNIT,
            $$PLSQL_LINE,
            'Rows updated',
            TO_CHAR(SQL%ROWCOUNT)
        );
    END LOOP;

    -- Log successful completion
    debug_utils.log_info(
        $$PLSQL_UNIT,
        $$PLSQL_LINE,
        'Completed successfully'
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- Log error message and stack trace
        debug_utils.log_error(
            $$PLSQL_UNIT,
            'Failure: ' || SQLERRM || ' | ' || DBMS_UTILITY.format_error_backtrace
        );
        RAISE;
END adjust_salaries_by_commission;
/