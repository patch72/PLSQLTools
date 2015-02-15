CREATE OR REPLACE PACKAGE timer AS
  -----------------------------------------------------------------------------
  --
  -- Author:  Adrian Billington (www.oracle-developer.net)
  --          Patrick Barel     (blog.bar-solutions.com)
  --
  -- Package: TIMER
  --
  --
  -- Purpose: Timing package for testing durations of alternative coding
  --          approaches. Based on Steven Feuerstein's original timer package
  --          but simplified and modified. Works for Oracle versions 8i and
  --          above.
  --
  -- 20140205 | Patrick Barel | Added overloading for show procedure to support
  --          |               | multiple timers
  -- 20111130 | Patrick Barel | Added support for multiple timers
  -- 20111129 | Patrick Barel | Added retrieve function
  --          |               | Some refactoring
  -----------------------------------------------------------------------------

  hsecs CONSTANT PLS_INTEGER := 0;
  secs  CONSTANT PLS_INTEGER := 1;
  mins  CONSTANT PLS_INTEGER := 2;
  hrs   CONSTANT PLS_INTEGER := 3;
  days  CONSTANT PLS_INTEGER := 4;
  --
  -- Procedure to start the global timer
  -- %param show_stack_in Show the callstack when snapped.
  -- %author Adrian Billington
  -- %version 1.0
  PROCEDURE snap(show_stack_in IN BOOLEAN DEFAULT FALSE);
  -- Procedure to start a named timer
  -- %param timername_in The name of this timer
  -- %author Patrick Barel
  -- %version 1.0
  PROCEDURE snap(timername_in IN VARCHAR2);
  --
  -- Procedure to show the global timer
  -- %param prefix_in An optional prefix when displaying the timer
  -- %param format_in The format in which to display the timer
  --                {*} timer.secs (Default)
  --                {*} timer.mins
  --                {*} timer.hrs
  --                {*} timer.days
  -- %author Adrian Billington
  -- %version 1.0
  PROCEDURE show(prefix_in IN VARCHAR2 DEFAULT NULL
                ,format_in IN PLS_INTEGER DEFAULT timer.secs);
  -- Procedure to show a named timer
  -- %param format_in The format in which to display the timer
  --                {*} timer.secs (Default)
  --                {*} timer.mins
  --                {*} timer.hrs
  --                {*} timer.days
  -- %param reset_in Reset the timer (remove it) after showing its value
  --                {*} True (Default)
  --                {*} False
  -- %param timername_in The name of the timer to be shown
  -- %author Patrick Barel
  -- %version 1.0
  PROCEDURE show(timername_in IN VARCHAR2
                ,reset_in     IN BOOLEAN
                ,format_in    IN PLS_INTEGER DEFAULT timer.secs);
  --
  -- Function to retrieve the current value of a named timer
  -- %param format_in The format in which to display the timer
  --                {*} timer.secs (Default)
  --                {*} timer.mins
  --                {*} timer.hrs
  --                {*} timer.days
  -- %param reset_in Reset the timer (remove it) after retrieving its value
  --                {*} True (Default)
  --                {*} False
  -- %param timername_in The name of the timer to be retrieved
  -- %author Patrick Barel
  -- %version 1.0
  FUNCTION retrieve(format_in    IN PLS_INTEGER DEFAULT timer.secs
                   ,reset_in     IN BOOLEAN DEFAULT TRUE
                   ,timername_in IN VARCHAR2 DEFAULT NULL) RETURN PLS_INTEGER;

END timer;
/
