clear screen
set serveroutput on size unlimited

declare

begin
  -- turn logging on (if it is not on anyway)
  logger.TurnLogOn;
  -- Adding log messages has been overloaded
  logger.ADD(message_in => 'Just the message');
  logger.ADD(date_in => '29-Dec-1972', message_in => 'Date and message');
  logger.ADD(message_in => 'Message and a date value', value_date_in => '29-Dec-1972');
  logger.ADD(date_in => '29-Dec-1972', message_in => 'Date and Message and a date value', value_date_in => '29-Dec-1972');
  logger.ADD(message_in => 'Message and a number value', value_number_in => 40);
  logger.ADD(date_in => '29-Dec-1972', message_in => 'Date and Message and a number value', value_number_in => 40);
  logger.ADD(message_in => 'Message and a varchar2 value', value_varchar2_in => 'Patrick');
  logger.ADD(date_in => '29-Dec-1972', message_in => 'Date and Message and a varchar2 value', value_varchar2_in => 'Patrick');
  logger.ADD(message_in => 'Message and a boolean value', value_boolean_in => True);
  logger.ADD(date_in => '29-Dec-1972', message_in => 'Date and Message and a boolean value', value_boolean_in => False);
  --  turn logging off
  logger.TurnLogOff;
end;
/
prompt Query to put the log values in one column
set echo on
SELECT   t.log_id
       , t.log_user
       , t.log_date
       , t.log_message
       , COALESCE( TO_CHAR( t.log_value_date, 'YYYYMMDD')
                 , t.log_value_varchar2
                 , TO_CHAR( t.log_value_number )
                 ) log_value
    FROM LOGGER_LOG t
   where 1=1
ORDER BY t.log_id DESC NULLS LAST
/


