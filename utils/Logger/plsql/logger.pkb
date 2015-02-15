CREATE OR REPLACE PACKAGE BODY logger IS
  -- {%skip} Private type declarations

  -- Subtype to hold the maximum size of a varchar2 variable in PL/SQL
  SUBTYPE maxvarchar IS VARCHAR2(32767);
  -- Subtype based on the log_id column of the table
  SUBTYPE log_id_t IS logger_log.log_id%TYPE;
  -- Subtype based on the log_user column of the table
  SUBTYPE log_user_t IS logger_log.log_user%TYPE;
  -- Subtype based on the log_date column of the table
  SUBTYPE log_date_t IS logger_log.log_date%TYPE;
  -- Subtype based on the log_message column of the table
  SUBTYPE log_message_t IS logger_log.log_message%TYPE;
  -- Subtype based on the log_value_date of the table
  SUBTYPE log_value_date_t IS logger_log.log_value_date%TYPE;
  -- Subtype based on the log_value_number of the table
  SUBTYPE log_value_number_t IS logger_log.log_value_number%TYPE;
  -- Subtype based on the log_value_varchar2 of the table
  SUBTYPE log_value_varchar2_t IS logger_log.log_value_varchar2%TYPE;

  -- Type to hold a REF CURSOR
  TYPE refcursor IS REF CURSOR;
  -- Type to hold an associative array of log_ids
  TYPE log_id_cc IS TABLE OF log_id_t INDEX BY BINARY_INTEGER;
  -- Type to hold an associative array of log_users
  TYPE log_user_cc IS TABLE OF log_user_t INDEX BY BINARY_INTEGER;
  -- Type to hold an associative array of log_dates
  TYPE log_date_cc IS TABLE OF log_date_t INDEX BY BINARY_INTEGER;
  -- Type to hold an associative array of log_messages
  TYPE log_message_cc IS TABLE OF log_message_t INDEX BY BINARY_INTEGER;
  -- Type to hold an associative array of log_value_dates
  TYPE log_value_date_cc IS TABLE OF log_value_date_t INDEX BY BINARY_INTEGER;
  -- Type to hold an associative array of log_value_numbers
  TYPE log_value_number_cc IS TABLE OF log_value_number_t INDEX BY BINARY_INTEGER;
  -- Type to hold an associative array of log_value_varchar2s
  TYPE log_value_varchar2_cc IS TABLE OF log_value_varchar2_t INDEX BY BINARY_INTEGER;
  -- Type to hold an associative array of log records
  TYPE logger_log_cc IS TABLE OF logger_log%ROWTYPE INDEX BY BINARY_INTEGER;
  -- {%skip} Private constant declarations

  -- maximum number of rows to be retrieved in a single roundtrip.
  -- preserve memory by not making this number too big
  c_maxrows CONSTANT PLS_INTEGER := 50;
  -- default level of the logging
  c_default_level CONSTANT PLS_INTEGER := 1;

  -- {%skip} Private variable declarations

  -- Variable to hold the state of the logging. Turned on or off.
  fdolog PLS_INTEGER;
  -- Variable to hold the loglevel. min = 0 (logging off) max = 10
  floglevel PLS_INTEGER;
  -- Variable to hold the caller.
  flogcaller logger_log.log_caller%TYPE;
  -- {%skip} Private function and procedure implementations

  -- Set logger
  PROCEDURE setlogger(logger_in IN VARCHAR2) IS
  BEGIN
    flogcaller := logger_in;
  END setlogger;
  -- Get logger
  FUNCTION getlogger RETURN VARCHAR2 IS
  BEGIN
    RETURN flogcaller;
  END getlogger;

  FUNCTION whologgedthis RETURN VARCHAR2 IS
    l_callstack   VARCHAR2(2000);
    l_returnvalue VARCHAR2(100);
  BEGIN
    <<code>>
  -- Get the current callstack
    l_callstack := dbms_utility.format_call_stack;
    --    dbms_output.put_line(l_callstack);
    -- The line of interest is the fourth line.
    l_returnvalue := substr(l_callstack
                           ,instr(l_callstack, chr(10), 1, 6) + 1
                           ,(instr(l_callstack, chr(10), 1, 7) - instr(l_callstack, chr(10), 1, 6)));
    --    dbms_output.put_line(l_returnvalue);
    -- All we are interested in is the type and the name of the program.
    l_returnvalue := TRIM(substr(l_returnvalue, instr(l_returnvalue, ' ', 1)));
    --    dbms_output.put_line(l_returnvalue);
    l_returnvalue := TRIM(substr(l_returnvalue, instr(l_returnvalue, ' ', 1)));
    --    dbms_output.put_line(l_returnvalue);
    RETURN l_returnvalue;
  END whologgedthis;

  -- This value is not cached in the package. If we are at 11Gr1 or higher then
  -- it is cached using the result cache.
  FUNCTION getlevelfromtable RETURN PLS_INTEGER
  $if dbms_db_version.ver_le_10_2
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  $then
    $else
  result_cache relies_on(log_settings)
  $end
   IS
    l_returnvalue PLS_INTEGER;
  BEGIN
    BEGIN
      SELECT log_level
        INTO l_returnvalue
        FROM logger_log_settings;
    EXCEPTION
      WHEN no_data_found THEN
        l_returnvalue := NULL;
      WHEN too_many_rows THEN
        l_returnvalue := NULL;
    END;
    RETURN l_returnvalue;
  END getlevelfromtable;
  -- This value is not cached in the package. If we are at 11Gr1 or higher then
  -- it is cached using the result_cache.
  FUNCTION getlogvaluefromtable RETURN PLS_INTEGER
  $if dbms_db_version.ver_le_10_2
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                $then
    $else
  result_cache relies_on(log_settings)
  $end
   IS
    l_returnvalue PLS_INTEGER;
  BEGIN
    BEGIN
      SELECT set_on
        INTO l_returnvalue
        FROM logger_log_settings;
    EXCEPTION
      WHEN no_data_found THEN
        l_returnvalue := NULL;
      WHEN too_many_rows THEN
        l_returnvalue := NULL;
    END;
    RETURN l_returnvalue;
  END getlogvaluefromtable;

  PROCEDURE inc(value_inout IN OUT PLS_INTEGER) IS
  BEGIN
    IF value_inout IS NULL THEN
      value_inout := 0;
    END IF;
    value_inout := value_inout + 1;
  END inc;

  PROCEDURE DEC(value_inout IN OUT PLS_INTEGER) IS
  BEGIN
    value_inout := value_inout - 1;
    IF (value_inout IS NULL)
       OR (value_inout < 0) THEN
      value_inout := 0;
    END IF;
  END DEC;

  FUNCTION RANGE(value_in  IN PLS_INTEGER
                ,limit1_in IN PLS_INTEGER
                ,limit2_in IN PLS_INTEGER) RETURN PLS_INTEGER IS
    l_min         PLS_INTEGER;
    l_max         PLS_INTEGER;
    l_returnvalue PLS_INTEGER;
  BEGIN
    l_min := least(limit1_in, limit2_in);
    l_max := greatest(limit1_in, limit2_in);
    -- l_returnvalue cannot be greater than l_max
    l_returnvalue := least(value_in, l_max);
    -- l_returnvalue cannot be less than l_min
    l_returnvalue := greatest(l_returnvalue, l_min);
    RETURN l_returnvalue;
  END RANGE;
  -- Function and procedure implementations
  PROCEDURE turnlogon IS
  BEGIN
    inc(fdolog);
  END turnlogon;
  --
  PROCEDURE turnlogoff IS
  BEGIN
    DEC(fdolog);
  END turnlogoff;
  --
  PROCEDURE setloglevel(level_in IN PLS_INTEGER) IS
  BEGIN
    floglevel := RANGE(level_in, 0, 10);
  END setloglevel;
  --
  PROCEDURE initialization IS
  BEGIN
    turnlogoff;
    --    turnlogon;
    setloglevel(0);
    --    setloglevel(1);
    -- clear the log until 7 days before today
    remove_until(date_in => (SYSDATE - 7));
  END initialization;

  FUNCTION dolog(level_in IN PLS_INTEGER) RETURN BOOLEAN IS
    l_tablelevel PLS_INTEGER;
    l_tablelog   PLS_INTEGER;
  BEGIN
    l_tablelevel := getlevelfromtable;
    l_tablelog   := getlogvaluefromtable;
    -- The higher the level, the less should be logged
    RETURN(((fdolog > 0) OR (l_tablelog > 0)) AND
           --           (((level_in >= floglevel) AND (floglevel > 0)) OR
           (((level_in <= floglevel) AND (floglevel > 0)) OR
           --           ((level_in >= l_tablelevel) AND (l_tablelevel > 0))));
           ((level_in <= l_tablelevel) AND (l_tablelevel > 0))));
  END dolog;

  PROCEDURE do_add(level_in          IN PLS_INTEGER
                  ,date_in           IN DATE
                  ,user_in           IN VARCHAR2
                  ,message_in        IN VARCHAR2
                  ,value_date_in     IN DATE
                  ,value_number_in   IN NUMBER
                  ,value_varchar2_in IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_user   logger_log.log_user%TYPE := user_in;
    l_caller logger_log.log_caller%TYPE;
  BEGIN
    IF dolog(level_in => level_in) THEN
      IF (user_in IS NULL) THEN
        l_user := USER;
      ELSE
        l_user := user_in;
      END IF;
      l_caller := nvl(getlogger, whologgedthis);
      INSERT INTO logger_log
        (log_level
        ,log_date
        ,log_user
        ,log_message
        ,log_value_date
        ,log_value_number
        ,log_value_varchar2
        ,log_session_id
        ,log_caller)
      VALUES
        (level_in
        ,date_in
        ,l_user
        ,message_in
        ,value_date_in
        ,value_number_in
        ,value_varchar2_in
        ,sys_context('USERENV', 'SESSIONID')
         --        ,dms_utils.getsessionid
        ,l_caller);
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(to_char(SQLCODE));
      dbms_output.put_line(SQLERRM);
      ROLLBACK;
  END do_add;
  PROCEDURE add(message_in IN VARCHAR2) IS
  BEGIN
    add(level_in => c_default_level, message_in => message_in);
    --    do_add(date_in           => SYSDATE
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(date_in    IN DATE
               ,message_in IN VARCHAR2) IS
  BEGIN
    add(level_in => c_default_level, date_in => date_in, message_in => message_in);
    --    do_add(date_in           => date_in
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(message_in    IN VARCHAR2
               ,value_date_in IN DATE) IS
  BEGIN
    add(level_in => c_default_level, message_in => message_in, value_date_in => value_date_in);
    --    do_add(date_in           => SYSDATE
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => value_date_in
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(date_in       IN DATE
               ,message_in    IN VARCHAR2
               ,value_date_in IN DATE) IS
  BEGIN
    add(level_in      => c_default_level
       ,date_in       => date_in
       ,message_in    => message_in
       ,value_date_in => value_date_in);
    --    do_add(date_in           => date_in
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => value_date_in
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(message_in      IN VARCHAR2
               ,value_number_in IN NUMBER) IS
  BEGIN
    add(level_in => c_default_level, message_in => message_in, value_number_in => value_number_in);
    --    do_add(date_in           => SYSDATE
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => value_number_in
    --          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(date_in         IN DATE
               ,message_in      IN VARCHAR2
               ,value_number_in IN NUMBER) IS
  BEGIN
    add(level_in        => c_default_level
       ,date_in         => date_in
       ,message_in      => message_in
       ,value_number_in => value_number_in);
    --    do_add(date_in           => date_in
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => value_number_in
    --          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2) IS
  BEGIN
    add(level_in          => c_default_level
       ,message_in        => message_in
       ,value_varchar2_in => value_varchar2_in);
    --    do_add(date_in           => SYSDATE
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => value_varchar2_in);
  END add;
  PROCEDURE add(date_in           IN DATE
               ,message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2) IS
  BEGIN
    add(level_in          => c_default_level
       ,date_in           => date_in
       ,message_in        => message_in
       ,value_varchar2_in => value_varchar2_in);
    --    do_add(date_in           => date_in
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => value_varchar2_in);
  END add;

  PROCEDURE add(message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN) IS
  BEGIN
    add(level_in         => c_default_level
       ,message_in       => message_in
       ,value_boolean_in => value_boolean_in);
    --    do_add(date_in           => SYSDATE
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => CASE value_boolean_in
    --                                  WHEN TRUE THEN
    --                                   'TRUE'
    --                                  WHEN FALSE THEN
    --                                   'FALSE'
    --                                  ELSE
    --                                   'NULL'
    --                                END);
  END add;
  PROCEDURE add(date_in          IN DATE
               ,message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN) IS
  BEGIN
    add(level_in         => c_default_level
       ,date_in          => date_in
       ,message_in       => message_in
       ,value_boolean_in => value_boolean_in);
    --    do_add(date_in           => date_in
    --          ,user_in           => USER
    --          ,message_in        => message_in
    --          ,value_date_in     => NULL
    --          ,value_number_in   => NULL
    --          ,value_varchar2_in => CASE value_boolean_in
    --                                  WHEN TRUE THEN
    --                                   'TRUE'
    --                                  WHEN FALSE THEN
    --                                   'FALSE'
    --                                  ELSE
    --                                   'NULL'
    --                                END);
  END add;

  PROCEDURE add(level_in   IN PLS_INTEGER
               ,message_in IN VARCHAR2) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => SYSDATE
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => NULL
          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(level_in   IN PLS_INTEGER
               ,date_in    IN DATE
               ,message_in IN VARCHAR2) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => date_in
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => NULL
          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(level_in      IN PLS_INTEGER
               ,message_in    IN VARCHAR2
               ,value_date_in IN DATE) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => SYSDATE
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => value_date_in
          ,value_number_in   => NULL
          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(level_in      IN PLS_INTEGER
               ,date_in       IN DATE
               ,message_in    IN VARCHAR2
               ,value_date_in IN DATE) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => date_in
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => value_date_in
          ,value_number_in   => NULL
          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(level_in        IN PLS_INTEGER
               ,message_in      IN VARCHAR2
               ,value_number_in IN NUMBER) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => SYSDATE
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => value_number_in
          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(level_in        IN PLS_INTEGER
               ,date_in         IN DATE
               ,message_in      IN VARCHAR2
               ,value_number_in IN NUMBER) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => date_in
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => value_number_in
          ,value_varchar2_in => NULL);
  END add;
  PROCEDURE add(level_in          IN PLS_INTEGER
               ,message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => SYSDATE
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => NULL
          ,value_varchar2_in => value_varchar2_in);
  END add;
  PROCEDURE add(level_in          IN PLS_INTEGER
               ,date_in           IN DATE
               ,message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => date_in
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => NULL
          ,value_varchar2_in => value_varchar2_in);
  END add;

  PROCEDURE add(level_in         IN PLS_INTEGER
               ,message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => SYSDATE
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => NULL
          ,value_varchar2_in => CASE value_boolean_in
                                  WHEN TRUE THEN
                                   'TRUE'
                                  WHEN FALSE THEN
                                   'FALSE'
                                  ELSE
                                   'NULL'
                                END);
  END add;
  PROCEDURE add(level_in         IN PLS_INTEGER
               ,date_in          IN DATE
               ,message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN) IS
  BEGIN
    do_add(level_in          => level_in
          ,date_in           => date_in
          ,user_in           => USER
          ,message_in        => message_in
          ,value_date_in     => NULL
          ,value_number_in   => NULL
          ,value_varchar2_in => CASE value_boolean_in
                                  WHEN TRUE THEN
                                   'TRUE'
                                  WHEN FALSE THEN
                                   'FALSE'
                                  ELSE
                                   'NULL'
                                END);
  END add;

  PROCEDURE show IS
    CURSOR logmessages_cur IS
      SELECT log_id
            ,log_user
            ,log_date
            ,log_message
            ,log_value_date
            ,log_value_number
            ,log_value_varchar2
        FROM logger_log
       WHERE 1 = 1;
    l_log_id             log_id_cc;
    l_log_user           log_user_cc;
    l_log_date           log_date_cc;
    l_log_message        log_message_cc;
    l_log_value_date     log_value_date_cc;
    l_log_value_number   log_value_number_cc;
    l_log_value_varchar2 log_value_varchar2_cc;
  
  BEGIN
    -- open the cursor
    OPEN logmessages_cur;
    LOOP
      -- fetch data into collections using bulk operations
      FETCH logmessages_cur BULK COLLECT
        INTO l_log_id
            ,l_log_user
            ,l_log_date
            ,l_log_message
            ,l_log_value_date
            ,l_log_value_number
            ,l_log_value_varchar2 LIMIT c_maxrows;
      IF l_log_id.count > 0 THEN
        FOR idx IN l_log_id.first .. l_log_id.last LOOP
          dbms_output.put_line('log_id             : ' || l_log_id(idx));
          dbms_output.put_line('log_user           : ' || l_log_user(idx));
          dbms_output.put_line('log_date           : ' || l_log_date(idx));
          dbms_output.put_line('log_message        : ' || l_log_message(idx));
          dbms_output.put_line('log_value_date     : ' || l_log_value_date(idx));
          dbms_output.put_line('log_value_number   : ' || l_log_value_number(idx));
          dbms_output.put_line('log_value_varchar2 : ' || l_log_value_varchar2(idx));
        END LOOP;
      END IF;
      -- Notfound flag will be set if we retrieve less rows than the limit
      EXIT WHEN logmessages_cur%NOTFOUND;
    END LOOP;
    CLOSE logmessages_cur;
  END show;

  PROCEDURE show(last_rows_in IN NUMBER) IS
    l_sql       maxvarchar;
    l_refcursor refcursor;
    l_log       logger_log_cc;
  BEGIN
    l_sql := q'{SELECT log_id
                      ,log_user
                      ,log_date
                      ,log_message
                      ,log_value_date
                      ,log_value_number
                      ,log_value_varchar2
                  FROM (SELECT log_id
                              ,log_user
                              ,log_date
                              ,log_message
                              ,log_value_date
                              ,log_value_number
                              ,log_value_varchar2
                          FROM logger_log
                         ORDER BY log_id DESC)
                 WHERE rownum <= }' || to_char(last_rows_in);
    -- open the cursor
    OPEN l_refcursor FOR l_sql;
    LOOP
      -- fetch data into collections using bulk operations
      FETCH l_refcursor BULK COLLECT
        INTO l_log LIMIT c_maxrows;
      IF l_log.count > 0 THEN
        FOR idx IN l_log.first .. l_log.last LOOP
          dbms_output.put_line('log_id             : ' || l_log(idx).log_id);
          dbms_output.put_line('log_user           : ' || l_log(idx).log_user);
          dbms_output.put_line('log_date           : ' || l_log(idx).log_date);
          dbms_output.put_line('log_message        : ' || l_log(idx).log_message);
          dbms_output.put_line('log_value_date     : ' || l_log(idx).log_value_date);
          dbms_output.put_line('log_value_number   : ' || l_log(idx).log_value_number);
          dbms_output.put_line('log_value_varchar2 : ' || l_log(idx).log_value_varchar2);
        END LOOP;
      END IF;
      -- Notfound flag will be set if we retrieve less rows than the limit
      EXIT WHEN l_refcursor%NOTFOUND;
    END LOOP;
    CLOSE l_refcursor;
  END show;
  --
  PROCEDURE turnlogon_fixed IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE logger_log_settings
       SET set_on = 1;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END turnlogon_fixed;
  --
  PROCEDURE turnlogoff_fixed IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE logger_log_settings
       SET set_on = 0;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END turnlogoff_fixed;
  --
  PROCEDURE setloglevel_fixed(level_in IN PLS_INTEGER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_log_level PLS_INTEGER;
  BEGIN
    l_log_level := RANGE(level_in, 0, 10);
    UPDATE logger_log_settings
       SET log_level = l_log_level;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END setloglevel_fixed;

  PROCEDURE clear_log IS
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE LOGGER_LOG';
  END clear_log;

  PROCEDURE remove_until(date_in IN DATE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF date_in IS NOT NULL THEN
      DELETE FROM logger_log t
       WHERE t.log_date < date_in;
    ELSE
      clear_log;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END remove_until;
  --
BEGIN
  initialization;
END logger;
/
