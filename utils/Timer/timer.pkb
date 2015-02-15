CREATE OR REPLACE PACKAGE BODY timer IS

  /* Package types... */
  TYPE typ_rec_elapsed IS RECORD(
     hsecs PLS_INTEGER
    ,secs  PLS_INTEGER
    ,mins  PLS_INTEGER
    ,hrs   PLS_INTEGER
    ,days  PLS_INTEGER);
  -- Type to hold multiple timers
  TYPE timers_tt IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(255);
  /* Package (global) variables... */
  g_last_timing PLS_INTEGER := NULL;
  g_show_stack  BOOLEAN := FALSE;
  -- Associative Array to hold the different timers
  g_timers timers_tt;

  /******************* FUNCTION caller *********************/
  FUNCTION caller RETURN VARCHAR2 IS
    v_stk VARCHAR2(4000) := dbms_utility.format_call_stack;
    v_dpt PLS_INTEGER := 6;
    v_pos PLS_INTEGER := 21;
    v_dlm VARCHAR2(1) := chr(10);
  BEGIN
    RETURN nvl(substr(substr(v_stk
                            ,instr(v_stk, v_dlm, 1, (v_dpt - 1)) + 1
                            ,instr(v_stk, v_dlm, 1, v_dpt) - (instr(v_stk, v_dlm, 1, (v_dpt - 1))) - 1)
                     ,v_pos)
              ,'[unknown]');
  END caller;

  /******************* PROCEDURE snap *********************/
  PROCEDURE snap(show_stack_in IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    g_last_timing := dbms_utility.get_time;
    IF show_stack_in THEN
      g_show_stack := show_stack_in;
      dbms_output.put_line('[started ' || caller() || ']');
    END IF;
  END snap;
  /******************* PROCEDURE snap *********************/
  PROCEDURE snap(timername_in IN VARCHAR2) IS
  BEGIN
    g_timers(timername_in) := dbms_utility.get_time;
  END snap;

  /******************* FUNCTION elapsed *********************/
  FUNCTION elapsed(timername_in IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    IF timername_in IS NULL THEN
      RETURN dbms_utility.get_time - g_last_timing;
    ELSE
      BEGIN
        RETURN dbms_utility.get_time - g_timers(timername_in);
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END;
    END IF;
  END elapsed;

  /******************* FUNCTION reformat *********************/
  FUNCTION reformat(input_in  IN NUMBER
                   ,format_in IN VARCHAR2 DEFAULT 9999900) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(to_char(input_in, format_in));
  END reformat;

  /******************* FUNCTION remainder *********************/
  FUNCTION remainder(input_in   IN PLS_INTEGER
                    ,modulus_in IN PLS_INTEGER
                    ,format_in  IN VARCHAR2 DEFAULT '900') RETURN VARCHAR2 IS
  BEGIN
    RETURN reformat(MOD(input_in, modulus_in), format_in);
  END remainder;

  /**************** FUNCTION retrieve_timing ******************/
  FUNCTION retrieve_timing(timername_in IN VARCHAR2 DEFAULT NULL) RETURN typ_rec_elapsed IS
    l_returnvalue typ_rec_elapsed;
  BEGIN
    /* Capture the elapsed time and format it into the "set timing on" format of SQL*Plus... */
    l_returnvalue.hsecs := elapsed(timername_in);
    l_returnvalue.secs  := trunc(l_returnvalue.hsecs / 100);
    l_returnvalue.mins  := trunc(l_returnvalue.hsecs / 6000);
    l_returnvalue.hrs   := trunc(l_returnvalue.hsecs / 360000);
    l_returnvalue.days  := trunc(l_returnvalue.hsecs / 8640000);
    RETURN l_returnvalue;
  END retrieve_timing;

  /******************* PROCEDURE show *********************/
  PROCEDURE show(prefix_in IN VARCHAR2 DEFAULT NULL
                ,format_in IN PLS_INTEGER DEFAULT timer.secs) IS
    /*
    * Construct message for display of elapsed time. Programmer can
    * include a prefix to the message and also ask that the last
    * timing variable be reset/updated to save calling snap again.
    */
    rec_elapsed      typ_rec_elapsed;
    v_elapsed_string VARCHAR2(128);
    v_message        VARCHAR2(512);
    v_label          VARCHAR2(128);
  
  BEGIN
  
    IF g_last_timing IS NULL THEN
      dbms_output.put_line('Timer not started.');
    ELSE
      /* Capture the elapsed time and format it into the "set timing on" format of SQL*Plus... */
      rec_elapsed := retrieve_timing;
    
      IF format_in = timer.hsecs THEN
        v_elapsed_string := reformat(rec_elapsed.hsecs, '99999990.00') || ' hseconds';
      ELSIF format_in = timer.secs THEN
        v_elapsed_string := reformat(rec_elapsed.hsecs / 100, '99999990.00') || ' seconds';
      ELSIF format_in = timer.mins THEN
        v_elapsed_string := reformat(rec_elapsed.mins) || ' minutes ' ||
                            remainder(rec_elapsed.secs, 60) || ' seconds';
      ELSIF format_in = timer.hrs THEN
        v_elapsed_string := reformat(rec_elapsed.hrs) || ' hours ' ||
                            remainder(rec_elapsed.mins, 60) || ' minutes';
      ELSE
        v_elapsed_string := reformat(rec_elapsed.days) || ' days ' ||
                            remainder(rec_elapsed.hrs, 24) || ' hours';
      END IF;
    
      /* Build the message string... */
      v_label   := nvl(prefix_in, 'elapsed');
      v_message := '[' || v_label || '] ' || v_elapsed_string;
    
      /* Output... */
      IF g_show_stack THEN
        dbms_output.put_line('[stopped ' || caller() || ']');
      END IF;
      dbms_output.put_line(v_message);
    
      /* Reset... */
      g_last_timing := NULL;
      g_show_stack  := FALSE;
    END IF;
  
  END show;

  /******************* PROCEDURE show *********************/
  PROCEDURE show(timername_in IN VARCHAR2
                ,reset_in     IN BOOLEAN
                ,format_in    IN PLS_INTEGER DEFAULT timer.secs) IS
    /*
    * Construct message for display of elapsed time. Programmer can
    * include a prefix to the message and also ask that the last
    * timing variable be reset/updated to save calling snap again.
    */
    rec_elapsed      typ_rec_elapsed;
    v_elapsed_string VARCHAR2(128);
    v_message        VARCHAR2(512);
    v_label          VARCHAR2(128);
  
  BEGIN
  
    IF (timername_in IS NULL)
       AND (g_last_timing IS NULL) THEN
      dbms_output.put_line('Timer not started.');
    ELSE
      /* Capture the elapsed time and format it into the "set timing on" format of SQL*Plus... */
      rec_elapsed := retrieve_timing(timername_in);
    
      IF format_in = timer.hsecs THEN
        v_elapsed_string := reformat(rec_elapsed.hsecs, '99999990.00') || ' hseconds';
      ELSIF format_in = timer.secs THEN
        v_elapsed_string := reformat(rec_elapsed.hsecs / 100, '99999990.00') || ' seconds';
      ELSIF format_in = timer.mins THEN
        v_elapsed_string := reformat(rec_elapsed.mins) || ' minutes ' ||
                            remainder(rec_elapsed.secs, 60) || ' seconds';
      ELSIF format_in = timer.hrs THEN
        v_elapsed_string := reformat(rec_elapsed.hrs) || ' hours ' ||
                            remainder(rec_elapsed.mins, 60) || ' minutes';
      ELSE
        v_elapsed_string := reformat(rec_elapsed.days) || ' days ' ||
                            remainder(rec_elapsed.hrs, 24) || ' hours';
      END IF;
    
      /* Build the message string... */
      v_label   := nvl(timername_in, 'elapsed');
      v_message := '[' || v_label || '] ' || v_elapsed_string;
    
      /* Output... */
      IF g_show_stack THEN
        dbms_output.put_line('[stopped ' || caller() || ']');
      END IF;
      dbms_output.put_line(v_message);
    
      /*      \* Reset... *\
            g_last_timing := NULL;
            g_show_stack  := FALSE;
      */
      IF reset_in THEN
        /* Reset... */
        IF timername_in IS NULL THEN
          g_last_timing := NULL;
        ELSE
          g_timers(timername_in) := NULL;
        END IF;
      
        g_show_stack := FALSE;
      END IF;
    
    END IF;
  
  END show;
  /****************** FUNCTION retrieve *******************/
  FUNCTION retrieve(format_in    IN PLS_INTEGER DEFAULT timer.secs
                   ,reset_in     IN BOOLEAN DEFAULT TRUE
                   ,timername_in IN VARCHAR2 DEFAULT NULL) RETURN PLS_INTEGER IS
    l_returnvalue PLS_INTEGER;
    rec_elapsed   typ_rec_elapsed;
  BEGIN
    IF (timername_in IS NULL)
       AND (g_last_timing IS NULL) THEN
      dbms_output.put_line('Timer not started.');
      l_returnvalue := NULL;
    ELSE
      rec_elapsed := retrieve_timing(timername_in);
      --
      IF format_in = timer.hsecs THEN
        l_returnvalue := rec_elapsed.hsecs;
      ELSIF format_in = timer.secs THEN
        l_returnvalue := rec_elapsed.secs;
      ELSIF format_in = timer.mins THEN
        l_returnvalue := rec_elapsed.mins;
      ELSIF format_in = timer.hrs THEN
        l_returnvalue := rec_elapsed.hrs;
      ELSE
        l_returnvalue := rec_elapsed.days;
      END IF;
      --
      IF reset_in THEN
        /* Reset... */
        IF timername_in IS NULL THEN
          g_last_timing := NULL;
        ELSE
          g_timers(timername_in) := NULL;
        END IF;
      
        g_show_stack := FALSE;
      END IF;
    END IF;
    RETURN l_returnvalue;
  END retrieve;
END timer;
/
