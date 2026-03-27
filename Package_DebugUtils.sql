-- Has:
--  - Part 1 required procedures (enable/disable, log_msg, log_variable, log_error)
--  - Part 2 required core log(p_module_name, p_line, p_message)
-- Adds:
--  - Optional logging levels + enable flags
--  - Overloaded log_msg/log_variable that accept (module, line) for accurate caller info


CREATE OR REPLACE PACKAGE debug_utils AS

  ---------------------------------------------------
  --  Enables debug mode (turns logging ON)
  g_debug_mode BOOLEAN := FALSE;

  ---------------------------------------------------
  --  Enables debug mode (turns logging ON)
  
  g_enable_debug BOOLEAN := TRUE;
  g_enable_info  BOOLEAN := TRUE;
  g_enable_warn  BOOLEAN := TRUE;
  g_enable_error BOOLEAN := TRUE;

  ---------------------------------------------------
  -- Enable / Disable debug mode

  PROCEDURE enable_debug;
  PROCEDURE disable_debug;

  ---------------------------------------------------
  -- Core logging procedure 

  PROCEDURE log
  (
    p_module_name IN VARCHAR2,
    p_line        IN NUMBER,
    p_message     IN VARCHAR2,
    p_level       IN VARCHAR2 DEFAULT 'DEBUG'
  );

  ---------------------------------------------------
  -- Part 1 required procedures (simple signatures)
 
  PROCEDURE log_msg(p_message IN VARCHAR2);
  PROCEDURE log_variable(p_name IN VARCHAR2, p_value IN VARCHAR2);
  
  -- Logs error messages
  PROCEDURE log_error(p_proc IN VARCHAR2, p_err IN VARCHAR2);

  ---------------------------------------------------
  -- Overloads that capture real caller info
  
  PROCEDURE log_msg(p_module_name IN VARCHAR2, p_line IN NUMBER, p_message IN VARCHAR2);
  PROCEDURE log_variable(p_module_name IN VARCHAR2, p_line IN NUMBER, p_name IN VARCHAR2, p_value IN VARCHAR2);

  ---------------------------------------------------
  -- Convenience wrappers 

  PROCEDURE log_info(p_module IN VARCHAR2, p_line IN NUMBER, p_message IN VARCHAR2);
  PROCEDURE log_debug(p_module IN VARCHAR2, p_line IN NUMBER, p_name IN VARCHAR2, p_value IN VARCHAR2);

  -- Optional runtime toggles 
  PROCEDURE set_level_enabled(p_level IN VARCHAR2, p_enabled IN BOOLEAN);

END debug_utils;
/





