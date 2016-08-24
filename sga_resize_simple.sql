--SGA resize init final and the differense
select s.END_TIME,
       s.component,
       s.OPER_TYPE,
       s.STATUS,
       round(s.INITIAL_SIZE / 1024 / 1024 / 1024, 2) init_gb,
       round(s.FINAL_SIZE / 1024 / 1024 / 1024, 2) Final_GB,
       round(s.TARGET_SIZE / 1024 / 1024 / 1024, 2) target_gb,
       round((s.INITIAL_SIZE - FINAL_SIZE) / 1024 / 1024) diff_MB
  from v$sga_resize_ops s
-- where trunc(s.START_TIME) = trunc(sysdate)
 order by s.END_TIME desc
