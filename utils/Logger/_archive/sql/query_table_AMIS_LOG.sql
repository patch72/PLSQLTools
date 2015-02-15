select t.*, rowid from amis_log t
order by t.log_id desc nulls last;
SELECT   t.log_id
       , t.log_date
       , t.log_message
       , COALESCE( TO_CHAR( t.log_value_date, 'YYYYMMDD')
                 , t.log_value_varchar2
                 , TO_CHAR( t.log_value_number )
                 ) log_value
       , ROWID
    FROM amis_log t
ORDER BY t.log_id DESC NULLS LAST;
--truncate table amis_log;
--delete from amis_log;
