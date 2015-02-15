CREATE OR REPLACE PACKAGE logger IS
  -- %Author Patrick Barel
  -- %Usage Logging
  -- %Version 1.1

  -- Public type declarations
  -- Public constant declarations
  -- Public variable declarations

  -- Public function and procedure declarations
  -- remove this in production
  --  FUNCTION whologgedthis RETURN VARCHAR2;
  --
  --
  -- Set logger
  PROCEDURE setlogger(logger_in IN VARCHAR2);
  -- Get logger
  FUNCTION getlogger RETURN VARCHAR2;
  --
  -- Turn logging on
  PROCEDURE turnlogon;
  --
  -- Turn logging off
  PROCEDURE turnlogoff;
  --
  -- Set the level of logging
  PROCEDURE setloglevel(level_in IN PLS_INTEGER);
  --
  -- Add a log message to the table
  -- %param message_in The message to be added
  PROCEDURE add(message_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  PROCEDURE add(date_in    IN DATE
               ,message_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param message_in The message to be added
  -- %param value_date_in The date value to be added
  PROCEDURE add(message_in    IN VARCHAR2
               ,value_date_in IN DATE);
  --
  -- Add a log message to the table
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_date_in The date value to be added
  PROCEDURE add(date_in       IN DATE
               ,message_in    IN VARCHAR2
               ,value_date_in IN DATE);
  --
  -- Add a log message to the table
  -- %param message_in The message to be added
  -- %param value_number_in The number value to be added
  PROCEDURE add(message_in      IN VARCHAR2
               ,value_number_in IN NUMBER);
  --
  -- Add a log message to the table
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_number_in The number value to be added
  PROCEDURE add(date_in         IN DATE
               ,message_in      IN VARCHAR2
               ,value_number_in IN NUMBER);
  --
  -- Add a log message to the table
  -- %param message_in The message to be added
  -- %param value_varchar2_in The varchar2 value to be added
  PROCEDURE add(message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_varchar2_in The varchar2 value to be added
  PROCEDURE add(date_in           IN DATE
               ,message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param message_in The message to be added
  -- %param value_boolean_in The boolean value to be added (will be changed to a varchar2 representation)
  PROCEDURE add(message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN);
  --
  -- Add a log message to the table
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_boolean_in The boolean value to be added (will be changed to a varchar2 representation)
  PROCEDURE add(date_in          IN DATE
               ,message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param message_in The message to be added
  PROCEDURE add(level_in   IN PLS_INTEGER
               ,message_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  PROCEDURE add(level_in   IN PLS_INTEGER
               ,date_in    IN DATE
               ,message_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param message_in The message to be added
  -- %param value_date_in The date value to be added
  PROCEDURE add(level_in      IN PLS_INTEGER
               ,message_in    IN VARCHAR2
               ,value_date_in IN DATE);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_date_in The date value to be added
  PROCEDURE add(level_in      IN PLS_INTEGER
               ,date_in       IN DATE
               ,message_in    IN VARCHAR2
               ,value_date_in IN DATE);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param message_in The message to be added
  -- %param value_number_in The number value to be added
  PROCEDURE add(level_in        IN PLS_INTEGER
               ,message_in      IN VARCHAR2
               ,value_number_in IN NUMBER);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_number_in The number value to be added
  PROCEDURE add(level_in        IN PLS_INTEGER
               ,date_in         IN DATE
               ,message_in      IN VARCHAR2
               ,value_number_in IN NUMBER);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param message_in The message to be added
  -- %param value_varchar2_in The varchar2 value to be added
  PROCEDURE add(level_in          IN PLS_INTEGER
               ,message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_varchar2_in The varchar2 value to be added
  PROCEDURE add(level_in          IN PLS_INTEGER
               ,date_in           IN DATE
               ,message_in        IN VARCHAR2
               ,value_varchar2_in IN VARCHAR2);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param message_in The message to be added
  -- %param value_boolean_in The boolean value to be added (will be changed to a varchar2 representation)
  PROCEDURE add(level_in         IN PLS_INTEGER
               ,message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN);
  --
  -- Add a log message to the table
  -- %param level_in The level of the log record
  -- %param date_in The date to be added
  -- %param message_in The message to be added
  -- %param value_boolean_in The boolean value to be added (will be changed to a varchar2 representation)
  PROCEDURE add(level_in         IN PLS_INTEGER
               ,date_in          IN DATE
               ,message_in       IN VARCHAR2
               ,value_boolean_in IN BOOLEAN);
  --
  -- Show the contents of the log messages in the table
  PROCEDURE show;
  -- Show the contents of the log messages in the table
  -- %param last_rows_in The number of rows to be shown
  PROCEDURE show(last_rows_in IN NUMBER);
  -- Turn logging on and fix it in the table
  PROCEDURE turnlogon_fixed;
  -- Turn logging off and fix it in the table
  PROCEDURE turnlogoff_fixed;
  -- Set the loglevel and fix it in the table
  PROCEDURE setloglevel_fixed(level_in IN PLS_INTEGER);
  -- Clear the entire log. Uses a truncate so it cannot be rolled back.
  PROCEDURE clear_log;
  -- Remove all records before the given date. Autonomous, does commit if succesful
  PROCEDURE remove_until(date_in IN DATE);

END logger;
/
