/* distribution inside sga by hours 
*/
select to_char(START_TIME, 'dd hh24') "dd hh24",
       count(*) cnt,
       floor(60 / count(*)) "how often",
       round(sum(case
                   when s.OPER_TYPE = 'GROW' and s.PARAMETER = 'db_cache_size' then
                    FINAL_SIZE - s.INITIAL_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             2) as "buffer_cacheGB+",
       count(case
               when s.OPER_TYPE = 'GROW' and s.PARAMETER = 'db_cache_size' then
                1
             end) "buffer_cache+ cnt",
       round(sum(case
                   when s.OPER_TYPE = 'SHRINK' and s.PARAMETER = 'db_cache_size' then
                    s.INITIAL_SIZE - FINAL_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             2) as "buffer_cacheGB-",
       count(case
               when s.OPER_TYPE = 'SHRINK' and s.PARAMETER = 'db_cache_size' then
                1
             end) "buffer_cache- cnt" /*,
       round(sum(case
                   when s.OPER_TYPE = 'GROW' and s.PARAMETER = 'shared_pool_size' then
                      FINAL_SIZE-s.INITIAL_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             2) as "shared_poolGB+",
       count(case
               when s.OPER_TYPE = 'GROW' and s.PARAMETER = 'shared_pool_size' then
                1
             end) "shared_pool+ cnt",
       round(sum(case
                   when s.OPER_TYPE = 'SHRINK' and s.PARAMETER = 'shared_pool_size' then
                    s.INITIAL_SIZE - FINAL_SIZE
                   else
                    0
                 end) / 1024 / 1024 / 1024,
             2) as "shared_poolGB-",
       count(case
               when s.OPER_TYPE = 'SHRINK' and s.PARAMETER = 'shared_pool_size' then
                1
             end) "shared_pool- cnt"*/
  from v$sga_resize_ops s
--where trunc(s.START_TIME) = trunc(sysdate)
 group by to_char(START_TIME, 'dd hh24')
 order by max(START_TIME) desc
