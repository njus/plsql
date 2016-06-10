/* перераспределение памяти внутри sga за сутки по часам*/
select to_char(START_TIME, 'hh24') "hour", count(*) cnt, floor(60/count(*)) "how often",
       round(sum(case
                   when s.OPER_TYPE = 'GROW' and s.PARAMETER = 'db_cache_size' then
                    s.TARGET_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             1) as "buffer_cache+",
       round(sum(case
                   when s.OPER_TYPE = 'SHRINK' and s.PARAMETER = 'db_cache_size' then
                    s.TARGET_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             1) as "buffer_cache-",
       round(sum(case
                   when s.OPER_TYPE = 'GROW' and s.PARAMETER = 'shared_pool_size' then
                    s.TARGET_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             1) as "shared_pool+",
       round(sum(case
                   when s.OPER_TYPE = 'SHRINK' and s.PARAMETER = 'shared_pool_size' then
                    s.TARGET_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             1) as "shared_pool-"
  from v$sga_resize_ops s
 where trunc(s.START_TIME) = trunc(sysdate)
 group by to_char(START_TIME, 'hh24')
 order by to_char(START_TIME, 'hh24') desc;
