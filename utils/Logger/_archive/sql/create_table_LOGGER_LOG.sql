-- Drop table
drop table LOGGER_LOG purge;
-- Create table
create table LOGGER_LOG
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
alter table LOGGER_LOG
  add constraint pk_log_id primary key (LOG_ID);
-- Add comments to the table 
comment on table LOGGER_LOG
  is 'Table to hold all kinds of logging information';
-- Add comments to the columns 
comment on column LOGGER_LOG.log_id
  is 'The primary key column for this table. Can be easily used for sorting';
comment on column LOGGER_LOG.log_user
  is 'The schemaname of the user that issued this message';
comment on column LOGGER_LOG.log_date
  is 'The Date and Time of this log message';
comment on column LOGGER_LOG.log_message
  is 'The log message';
comment on column LOGGER_LOG.log_value_date
  is 'A date value for this message, can be empty';
comment on column LOGGER_LOG.log_value_number
  is 'A number value for this message, can be empty';
comment on column LOGGER_LOG.log_value_varchar2
  is 'A character value for this message, can be empty';
-- Drop sequence
drop sequence logger_log_seq;
-- Create sequence 
create sequence logger_log_seq start with 1 nocache;
-- Create trigger
create or replace trigger tr_logger_log_briu
  before insert or update on logger_log  
  for each row
declare
  -- local variables here
begin
  if :new.log_id is null then select logger_log_seq.nextval into :new.log_id from dual; end if;
end tr_logger_log_briu;
/
--create public synonym amislog for amislog;
--grant execute on amislog to public;
