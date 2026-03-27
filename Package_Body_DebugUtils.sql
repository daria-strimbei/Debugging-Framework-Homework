CREATE OR REPLACE PACKAGE BODY debug_utils AS

  ---------------------------------------------------
  -- Internal: normalize level to a short uppercase token

  FUNCTION norm_level(p_level VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(UPPER(TRIM(p_level)), 1, 10);
  END norm_level;

  ---------------------------------------------------
  -- Internal: check if a level is enabled

  FUNCTION is_level_enabled(p_level VARCHAR2) RETURN BOOLEAN IS
    l_level VARCHAR2(10) := norm_level(p_level);
  BEGIN
    CASE l_level
      WHEN 'DEBUG' THEN RETURN g_enable_debug;
      WHEN 'INFO'  THEN RETURN g_enable_info;
      WHEN 'WARN'  THEN RETURN g_enable_warn;
      WHEN 'ERROR' THEN RETURN g_enable_error;
      ELSE
        RETURN TRUE; -- unknown level => allow
    END CASE;
  END is_level_enabled;

  ---------------------------------------------------
  -- Change level flags at runtime

  PROCEDURE set_level_enabled(p_level IN VARCHAR2, p_enabled IN BOOLEAN) IS
    l_level VARCHAR2(10) := norm_level(p_level);
  BEGIN
    CASE l_level
      WHEN 'DEBUG' THEN g_enable_debug := p_enabled;
      WHEN 'INFO'  THEN g_enable_info  := p_enabled;
      WHEN 'WARN'  THEN g_enable_warn  := p_enabled;
      WHEN 'ERROR' THEN g_enable_error := p_enabled;
      ELSE
        NULL; -- ignore unknown level
    END CASE;
  END set_level_enabled;

  ---------------------------------------------------
  -- Enable / Disable debug

  PROCEDURE enable_debug IS
  BEGIN
    g_debug_mode := TRUE;
  END enable_debug;

  PROCEDURE disable_debug IS
  BEGIN
    g_debug_mode := FALSE;
  END disable_debug;

  ---------------------------------------------------
  -- Core logging procedure
  -- Uses autonomous transaction so logs survive rollbacks

  PROCEDURE log
  (
    p_module_name IN VARCHAR2,
    p_line        IN NUMBER,
    p_message     IN VARCHAR2,
    p_level       IN VARCHAR2 DEFAULT 'DEBUG'
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_level VARCHAR2(10) := norm_level(p_level);
  BEGIN
    IF g_debug_mode AND is_level_enabled(l_level) THEN
      INSERT INTO debug_log (module_name, line_no, log_level, log_message)
      VALUES (
        SUBSTR(p_module_name, 1, 100),
        p_line,
        l_level,
        SUBSTR(p_message, 1, 4000)
      );

      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
  
      ROLLBACK; 
      NULL;
  END log;

  ---------------------------------------------------
  -- Part 1 required procedures
 

  PROCEDURE log_msg(p_message IN VARCHAR2) IS
  BEGIN
    log(
      p_module_name => NVL(SYS_CONTEXT('USERENV', 'MODULE'), 'UNKNOWN_MODULE'),
      p_line        => NULL,
      p_message     => p_message,
      p_level       => 'DEBUG'
    );
  END log_msg;

  PROCEDURE log_variable(p_name IN VARCHAR2, p_value IN VARCHAR2) IS
  BEGIN
    log_msg(p_name || '=' || p_value);
  END log_variable;

  PROCEDURE log_error(p_proc IN VARCHAR2, p_err IN VARCHAR2) IS
  BEGIN
    log(
      p_module_name => p_proc,
      p_line        => NULL,
      p_message     => p_err,
      p_level       => 'ERROR'
    );
  END log_error;

  ---------------------------------------------------
  -- Overloads that capture real caller info
  

  PROCEDURE log_msg(p_module_name IN VARCHAR2, p_line IN NUMBER, p_message IN VARCHAR2) IS
  BEGIN
    log(p_module_name, p_line, p_message, 'DEBUG');
  END log_msg;

  PROCEDURE log_variable(p_module_name IN VARCHAR2, p_line IN NUMBER, p_name IN VARCHAR2, p_value IN VARCHAR2) IS
  BEGIN
    log(p_module_name, p_line, p_name || '=' || p_value, 'DEBUG');
  END log_variable;

  ---------------------------------------------------
  -- Convenience wrappers 

  PROCEDURE log_info(p_module IN VARCHAR2, p_line IN NUMBER, p_message IN VARCHAR2) IS
  BEGIN
    log(p_module, p_line, p_message, 'INFO');
  END log_info;

  PROCEDURE log_debug(p_module IN VARCHAR2, p_line IN NUMBER, p_name IN VARCHAR2, p_value IN VARCHAR2) IS
  BEGIN
    log(p_module, p_line, p_name || '=' || p_value, 'DEBUG');
  END log_debug;

END debug_utils;