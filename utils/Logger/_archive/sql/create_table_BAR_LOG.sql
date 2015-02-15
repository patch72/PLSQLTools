-- Drop table
drop table BAR_LOG purge;
-- Create table
create table BAR_LOG
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
alter table BAR_LOG
  add constraint pk_log_id primary key (LOG_ID);
-- Add comments to the table 
comment on table BAR_LOG
  is 'Table to hold all kinds of logging information';
-- Add comments to the columns 
comment on column BAR_LOG.log_id
  is 'The primary key column for this table. Can be easily used for sorting';
comment on column BAR_LOG.log_user
  is 'The schemaname of the user that issued this message';
comment on column BAR_LOG.log_date
  is 'The Date and Time of this log message';
comment on column BAR_LOG.log_message
  is 'The log message';
comment on column BAR_LOG.log_value_date
  is 'A date value for this message, can be empty';
comment on column BAR_LOG.log_value_number
  is 'A number value for this message, can be empty';
comment on column BAR_LOG.log_value_varchar2
  is 'A character value for this message, can be empty';
-- Drop sequence
drop sequence BAR_log_seq;
-- Create sequence 
create sequence BAR_log_seq start with 138 nocache;
-- Create trigger
create or replace trigger tr_BAR_log_briu
  before insert or update on BAR_log  
  for each row
declare
  -- local variables here
begin
  if :new.log_id is null then select BAR_log_seq.nextval into :new.log_id from dual; end if;
end tr_BAR_log_briu;
/
drop public synonym BARLog;
create public synonym BARlog for BARlog;
revoke execute on BARlog from public;
grant execute on BARlog to public;
