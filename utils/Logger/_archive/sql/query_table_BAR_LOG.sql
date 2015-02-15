select t.*, rowid from bar_log t
order by t.log_id desc nulls last;
--truncate table bar_log;
