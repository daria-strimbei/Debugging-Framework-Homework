---------------------------------------------------
--Execution script

BEGIN
    debug_utils.enable_debug;
    adjust_salaries_by_commission;
    debug_utils.disable_debug;
END;
/

-- Check for compilation errors in object
SELECT name, type, line, position, text
FROM user_errors
WHERE name IN (
    'DEBUG_UTIL',
    'DEBUG_UTILS',
    'ADJUST_SALARIES_BY_COMISSION'
)
ORDER BY name, sequence;
---------------------------------------------------
--View logs

SELECT log_id,
       log_time,
       module_name,
       line_no,
       log_level,
       log_message,
       session_id
FROM debug_log
ORDER BY log_id;

---------------------------------------------------
--Verify data

SELECT employee_id,
       salary,
       commission_pct
FROM employees
ORDER BY employee_id;


---------------------------------------------------
--Cleanup if wanted

--DROP PROCEDURE adjust_salaries_by_comission;
--DROP PACKAGE debug_util;
--DROP TABLE debug_log;