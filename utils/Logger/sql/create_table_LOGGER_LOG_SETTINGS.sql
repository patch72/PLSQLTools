-- Drop table
drop table LOGGER_LOG_SETTINGS purge;
-- Create table
create table LOGGER_LOG_SETTINGS
(
  set_on             number default 0
, log_level          number default 0
)
;
-- Create/Recreate check constraints 
alter table LOGGER_LOG_SETTINGS
  add constraint CK_SET_ON
  check (SET_ON in (0,1));
alter table LOGGER_LOG_SETTINGS
  add constraint CK_LOG_LEVEL
  check (LOG_LEVEL between 0 and 10);
-- Add comments to the table 
comment on table LOGGER_LOG_SETTINGS
  is 'Table to the settings for logging';
-- Add comments to the columns 
comment on column LOGGER_LOG_SETTINGS.set_on
  is 'Turn logging on and off using a database value';
comment on column LOGGER_LOG_SETTINGS.log_level
  is 'The minimum level the message must have to do logging';
-- Insert a single row
insert into LOGGER_LOG_SETTINGS(set_on, log_level) values (default, default);
-- commit the action
commit;
-- Create trigger
create or replace trigger tr_logger_log_settings_brid
  before insert or delete on logger_log_settings  
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
end tr_logger_log_settings_brid;
/
