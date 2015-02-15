/* Formatted on 2009/02/24 12:48 (Formatter Plus v4.7.0) */
CREATE OR REPLACE PACKAGE semaphores IS
  -- Author  : PATRICK BAREL
  -- Purpose : Semaphores to turn things on and off

  -- Public type declarations
  -- The actual semaphoretype
  SUBTYPE semaphore_t IS PLS_INTEGER;

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations
  FUNCTION issemaphoreset(semaphorename_in IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;

  PROCEDURE setsemaphore(semaphorename_in IN VARCHAR2 DEFAULT NULL);

  PROCEDURE clrsemaphore(semaphorename_in IN VARCHAR2 DEFAULT NULL);
END semaphores;
/
