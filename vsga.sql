select s.POOL,
       s.NAME,
       round(s.BYTES / 1024 / 1024 / 1024, 2) gb,
       round((s.bytes / sum(s.bytes) over()) * 100) "% " /*,
       round(((sum(case
                    when s.name = 'free memory' then
                     s.BYTES
                  end) over())/sum(s.bytes) over())*100) "% free mem"*/
  from V$sgastat s
 where s.BYTES  > 1024*1024
   and s.pool = 'shared pool'
 order by s.BYTES desc
