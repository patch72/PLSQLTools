clear screen
set serveroutput on size unlimited

-- Drop table
drop table AMIS_LOG purge;
-- Create table
create table AMIS_LOG
(
  log_id             number,
  log_user           varchar2(30),
  log_date           date default sysdate not null,
  log_message        varchar2(4000) not null,
  log_value_date     date,
  log_value_number   number,
  log_value_varchar2 varchar2(4000)
)
;
-- Create/Recreate primary, unique and foreign key constraints 
alter table AMIS_LOG
  add constraint pk_log_id primary key (LOG_ID);
-- Add comments to the table 
comment on table AMIS_LOG
  is 'Table to hold all kinds of logging information';
-- Add comments to the columns 
comment on column AMIS_LOG.log_id
  is 'The primary key column for this table. Can be easily used for sorting';
comment on column AMIS_LOG.log_user
  is 'The schemaname of the user that issued this message';
comment on column AMIS_LOG.log_date
  is 'The Date and Time of this log message';
comment on column AMIS_LOG.log_message
  is 'The log message';
comment on column AMIS_LOG.log_value_date
  is 'A date value for this message, can be empty';
comment on column AMIS_LOG.log_value_number
  is 'A number value for this message, can be empty';
comment on column AMIS_LOG.log_value_varchar2
  is 'A character value for this message, can be empty';
-- Drop sequence
drop sequence amis_log_seq;
-- Create sequence 
create sequence amis_log_seq start with 1 nocache;
-- Create trigger
create or replace trigger tr_amis_log_briu
  before insert or update on amis_log  
  for each row
declare
  -- local variables here
begin
  if :new.log_id is null then select amis_log_seq.nextval into :new.log_id from dual; end if;
end tr_amis_log_briu;
/
--create public synonym amislog for amislog;
--grant execute on amislog to public;
-- Drop table
drop table AMIS_LOG_SETTINGS purge;
-- Create table
create table AMIS_LOG_SETTINGS
(
  set_on             number default 0
)
;
-- Add comments to the table 
comment on table AMIS_LOG_SETTINGS
  is 'Table to the settings for logging';
-- Add comments to the columns 
comment on column AMIS_LOG_SETTINGS.set_on
  is 'Turn logging on and off using a database value';
-- Insert a single row
insert into AMIS_LOG_SETTINGS(set_on) values (default);
-- commit the action
commit;
-- Create trigger
create or replace trigger tr_amis_log_settings_brid
  before insert or delete on amis_log_settings  
  for each row
declare
  -- local variables here
begin
  -- prevent the insert or delete from happening
  if inserting then
    raise_application_error(-20000, 'You are not allowed to add rows to this table.');
  else
    raise_application_error(-20000, 'You are not allowed to remove rows from this table.');
  end if;
end tr_amis_log_settings_brid;
/
--create public synonym amislog for amislog;
--grant execute on amislog to public;
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
/* Formatted on 2008/07/25 09:55 (Formatter Plus v4.7.0) */
CREATE OR REPLACE PACKAGE BODY amislog
IS
  -- Private type declarations
--  type <TypeName> is <Datatype>;
 subtype log_id_t is amis_log.log_id%type;  
 subtype log_user_t is amis_log.log_user%type;
 subtype log_date_t is amis_log.log_date%type;    
 subtype log_message_t is amis_log.log_message%type;   
 subtype log_value_date_t is amis_log.log_value_date%type;   
 subtype log_value_number_t is amis_log.log_value_number%type;    
 subtype log_value_varchar2_t is amis_log.log_value_varchar2%type;  
 
 type log_id_cc is table of log_id_t index by binary_integer;
 type log_user_cc is table of log_user_t index by binary_integer;
 type log_date_cc is table of log_date_t index by binary_integer; 
 type log_message_cc is table of log_message_t index by binary_integer;
 type log_value_date_cc is table of log_value_date_t index by binary_integer;
 type log_value_number_cc is table of log_value_number_t index by binary_integer; 
 type log_value_varchar2_cc is table of log_value_varchar2_t index by binary_integer;
  -- Private constant declarations
--  <ConstantName> constant <Datatype> := <Value>;
  c_maxrows constant pls_integer := 5; -- preserve memory by not making this number too big

  -- Private variable declarations
--  <VariableName> <Datatype>;
--  fDoLog boolean;
  fDoLog pls_integer;
  function getlogvaluefromtable return pls_integer
  $if dbms_db_version.ver_le_10_2
   $then 
   $else result_cache relies_on (amis_log_settings)
   $end
  is
    l_returnvalue pls_integer;
  begin
    begin
      select set_on
        into l_returnvalue
        from amis_log_settings;
    exception
      when no_data_found then l_returnvalue := null;
      when too_many_rows then l_returnvalue := null;
    end;
    RETURN l_returnvalue;
  end getlogvaluefromtable;
  
  function ifelse( boolean_in     in boolean
                 , value_true_in  in varchar2
                 , value_false_in in varchar2) return varchar2
  is
  begin
    if boolean_in then
      return value_true_in;
    else
      return value_false_in;
    end if;
  end;
  
  procedure inc(value_inout in out pls_integer)
  is
  begin
    if value_inout is null then
      value_inout := 0;
    end if;
    value_inout := value_inout + 1;
  end inc;
  
  procedure dec(value_inout in out pls_integer)
  is
  begin
    value_inout := value_inout -1;
    if (value_inout is null) or (value_inout < 0) then
      value_inout := 0;
    end if;
  end dec;
  
  -- Function and procedure implementations
  procedure TurnLogOn
  is
  begin
--    fDoLog := true;
    inc(fDoLog);
  end TurnLogOn;
  
  procedure TurnLogOff
  is
  begin
--    fDoLog := false;
    dec(fDoLog);
  end TurnLogOff;
  
  PROCEDURE initialization
  IS
  BEGIN
--    TurnLogOff;
    TurnLogOn;
  END initialization;

  function dolog return boolean
  is
  begin
--    return fDoLog;
    return ((fDoLog > 0) or (getlogvaluefromtable > 0));
  end dolog;
  
  PROCEDURE DO_ADD(
    date_in                        IN      DATE/* DEFAULT SYSDATE*/
  , user_in                        in      VARCHAR2
  , message_in                     IN      VARCHAR2
  , value_date_in                  IN      DATE/* DEFAULT NULL*/
  , value_number_in                IN      NUMBER/* DEFAULT NULL*/
  , value_varchar2_in              IN      VARCHAR2/* DEFAULT NULL*/ )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    luser amis_log.log_user%type := user_in;
  BEGIN
    if dolog then
      if (luser is null) then
        luser := user;
      end if;
      INSERT INTO amis_log
                  ( log_date, log_user, log_message, log_value_date, log_value_number, log_value_varchar2 )
           VALUES ( date_in, luser, message_in, value_date_in, value_number_in, value_varchar2_in );
    end if;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(to_char(sqlcode));
      DBMS_OUTPUT.PUT_LINE(sqlerrm);
      ROLLBACK;
  END DO_ADD;
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2 )
  is
  begin
    DO_ADD(date_in => sysdate
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => null
       , value_varchar2_in => null);
  end add;
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2 )
  is
  begin
    DO_ADD(date_in => date_in
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => null
       , value_varchar2_in => null);
  end add;
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_date_in                  IN      DATE )
  is
  begin
    DO_ADD(date_in => sysdate
       , user_in => user
       , message_in => message_in
       , value_date_in => value_date_in
       , value_number_in => null
       , value_varchar2_in => null);
  end add;
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_date_in                  IN      DATE )
  is
  begin
    DO_ADD(date_in => date_in
       , user_in => user
       , message_in => message_in
       , value_date_in => value_date_in
       , value_number_in => null
       , value_varchar2_in => null);
  end add;
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_number_in                IN      NUMBER )
  is
  begin
    DO_ADD(date_in => sysdate
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => value_number_in
       , value_varchar2_in => null);
  end add;
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_number_in                IN      NUMBER )
  is
  begin
    DO_ADD(date_in => date_in
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => value_number_in
       , value_varchar2_in => null);
  end add;
  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_varchar2_in              IN      VARCHAR2 )
  is
  begin
    DO_ADD(date_in => sysdate
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => null
       , value_varchar2_in => value_varchar2_in);
  end add;
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_varchar2_in              IN      VARCHAR2 )
  is
  begin
    DO_ADD(date_in => date_in
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => null
       , value_varchar2_in => value_varchar2_in);
  end add;

  PROCEDURE ADD(
    message_in                     IN      VARCHAR2
  , value_boolean_in               IN      BOOLEAN )
  is
  begin
    DO_ADD(date_in => sysdate
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => null
       , value_varchar2_in => ifelse(value_boolean_in, 'TRUE', ifelse(value_boolean_in = false, 'FALSE', 'NULL')));
  end add;
  PROCEDURE ADD(
    date_in                        IN      DATE
  , message_in                     IN      VARCHAR2
  , value_boolean_in               IN      BOOLEAN )
  is
  begin
    DO_ADD(date_in => date_in
       , user_in => user
       , message_in => message_in
       , value_date_in => null
       , value_number_in => null
       , value_varchar2_in => ifelse(value_boolean_in, 'TRUE',ifelse(value_boolean_in = false, 'FALSE', 'NULL')));
  end add;
  
  procedure show
  is
    cursor logmessages_cur is
    select log_id
         , log_user
         , log_date
         , log_message
         , log_value_date
         , log_value_number
         , log_value_varchar2
      from amis_log
     where 1=1
         ;    
 l_log_id log_id_cc;
 l_log_user log_user_cc;
 l_log_date log_date_cc;
 l_log_message log_message_cc;
 l_log_value_date log_value_date_cc;
 l_log_value_number log_value_number_cc;
 l_log_value_varchar2 log_value_varchar2_cc;


    
  begin
--    -- write the headers
--          DBMS_OUTPUT.PUT_LINE('Log_id             : '||l_log_id(idx));
--          DBMS_OUTPUT.PUT_LINE('Log_date           : '||l_log_date(idx));
--          DBMS_OUTPUT.PUT_LINE('Log_message        : '||l_log_message(idx));
--          DBMS_OUTPUT.PUT_LINE('Log_value_date     : '||l_log_value_date(idx));
--          DBMS_OUTPUT.PUT_LINE('Log_value_number   : '||l_log_value_number(idx));
--          DBMS_OUTPUT.PUT_LINE('Log_value_varchar2 : '||l_log_value_varchar2(idx));
    -- open the cursor
    open logmessages_cur;
    loop
      -- clear the collections
      l_log_id.delete;
      l_log_date.delete;
      l_log_message.delete;
      l_log_value_date.delete;
      l_log_value_number.delete;
      l_log_value_varchar2.delete;
      
      -- fetch data into collections
      fetch logmessages_cur 
       bulk collect into l_log_id
                       , l_log_user
                       , l_log_date
                       , l_log_message
                       , l_log_value_date
                       , l_log_value_number
                       , l_log_value_varchar2
      limit c_maxrows;
      if l_log_id.count > 0 then
        for idx in l_log_id.first .. l_log_id.last loop
          DBMS_OUTPUT.PUT_LINE('Log_id             : '||l_log_id(idx));
          DBMS_OUTPUT.PUT_LINE('Log_user           : '||l_log_user(idx));
          DBMS_OUTPUT.PUT_LINE('Log_date           : '||l_log_date(idx));
          DBMS_OUTPUT.PUT_LINE('Log_message        : '||l_log_message(idx));
          DBMS_OUTPUT.PUT_LINE('Log_value_date     : '||l_log_value_date(idx));
          DBMS_OUTPUT.PUT_LINE('Log_value_number   : '||l_log_value_number(idx));
          DBMS_OUTPUT.PUT_LINE('Log_value_varchar2 : '||l_log_value_varchar2(idx));
        end loop;
      end if;
      exit when l_log_id.count < c_maxrows;
    end loop;
  end show;
BEGIN
  initialization;
END amislog;
/
