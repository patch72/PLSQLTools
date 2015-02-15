/* Formatted on 2008/07/25 09:55 (Formatter Plus v4.7.0) */
CREATE OR REPLACE PACKAGE amislog
IS
  -- Author  : PATRICK_B
  -- Created : 7/25/2008 9:47:15 AM
  -- Purpose : Logging

  -- Public type declarations
--  type <TypeName> is <Datatype>;

  -- Public constant declarations
--  <ConstantName> constant <Datatype> := <Value>;
  -- Public variable declarations
--  <VariableName> <Datatype>;

  -- Public function and procedure declarations
  procedure TurnLogOn;

  procedure TurnLogOff;
/*
  PROCEDURE ADD(
    date_in                        IN      DATE DEFAULT SYSDATE
  , message_in                     IN      VARCHAR2
  , value_date_in                  IN      DATE DEFAULT NULL
  , value_number_in                IN      NUMBER DEFAULT NULL
  , value_varchar2_in              IN      VARCHAR2 DEFAULT NULL );
*/
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2 );
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2 );
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_date_in                  IN      DATE );
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_date_in                  IN      DATE );
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_number_in                IN      NUMBER );
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_number_in                IN      NUMBER );
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_varchar2_in              IN      VARCHAR2 );
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_varchar2_in              IN      VARCHAR2 );
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_boolean_in               IN      BOOLEAN );
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_boolean_in               IN      BOOLEAN );

  procedure show;
/*
  PROCEDURE ADD(
    date_in                        IN      DATE DEFAULT SYSDATE
  , message_in                     IN      VARCHAR2
  , value_date_in                  IN      DATE DEFAULT NULL
  , value_number_in                IN      NUMBER DEFAULT NULL
  , value_varchar2_in              IN      VARCHAR2 DEFAULT NULL );
--*/
END amislog;
/
