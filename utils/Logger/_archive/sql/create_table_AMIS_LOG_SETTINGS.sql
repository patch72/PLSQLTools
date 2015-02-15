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
