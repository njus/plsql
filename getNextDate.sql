create /*or replace*/ function tst111_extractNextDate2(txt   varchar2,
                                                   ddate date) return date is

  i int;
  --предполога€ что вх. данные отсортированы по возрастанию дл€ каждого временного интервала
  type xarray is table of integer;

  months      xarray := xarray();
  dayofmonths xarray := xarray();
  dayofweek   xarray := xarray();
  hours       xarray := xarray();
  minutes     xarray := xarray();

  xmonths      int;
  xdayofmonths int;
  xhours       int;
  xminutes     int;
  xyear        int;
  result       date;
  xstr         varchar2(256);

begin

  result := ddate + interval '1' minute;
  --months
  xstr := ',' ||
          substr(txt,
                 instr(txt, ';', 1, 4) + 1,
                 instr(txt, ';', 1, 5) - instr(txt, ';', 1, 4) - 1) || ',';
  i    := 0;
  while i < length(xstr) - length(replace(xstr, ',', '')) - 1 loop
    i := i + 1;
    months. extend();
    months(months. count) := substr(xstr,
                                    instr(xstr, ',', 1, i) + 1,
                                    instr(xstr, ',', 1, i + 1) -
                                    instr(xstr, ',', 1, i) - 1);
  
  end loop;
  i := 0;

  --dayofmonths
  xstr := ',' ||
          substr(txt,
                 instr(txt, ';', 1, 3) + 1,
                 instr(txt, ';', 1, 4) - instr(txt, ';', 1, 3) - 1) || ',';
  i    := 0;
  while i < length(xstr) - length(replace(xstr, ',', '')) - 1 loop
    i := i + 1;
    dayofmonths. extend();
    dayofmonths(dayofmonths. count) := substr(xstr,
                                              instr(xstr, ',', 1, i) + 1,
                                              instr(xstr, ',', 1, i + 1) -
                                              instr(xstr, ',', 1, i) - 1);
  end loop;
  i := 0;

  --dayofweek
  xstr := ',' ||
          substr(txt,
                 instr(txt, ';', 1, 2) + 1,
                 instr(txt, ';', 1, 3) - instr(txt, ';', 1, 2) - 1) || ',';
  i    := 0;
  while i < length(xstr) - length(replace(xstr, ',', '')) - 1 loop
    i := i + 1;
    dayofweek. extend;
    dayofweek(dayofweek. count) := (substr(xstr,
                                           instr(xstr, ',', 1, i) + 1,
                                           instr(xstr, ',', 1, i + 1) -
                                           instr(xstr, ',', 1, i) - 1));
  end loop;
  i    := 0;
  xstr := ',' ||
          substr(txt,
                 instr(txt, ';', 1, 1) + 1,
                 instr(txt, ';', 1, 2) - instr(txt, ';', 1, 1) - 1) || ',';
  i    := 0;
  while i < length(xstr) - length(replace(xstr, ',', '')) - 1 loop
    i := i + 1;
    hours. extend;
    hours(hours. count) := (substr(xstr,
                                   instr(xstr, ',', 1, i) + 1,
                                   instr(xstr, ',', 1, i + 1) -
                                   instr(xstr, ',', 1, i) - 1));
  end loop;
  i    := 0;
  xstr := ',' || substr(txt, 1, instr(txt, ';', 1, 1) - 1) || ',';
  i    := 0;
  while i < length(xstr) - length(replace(xstr, ',', '')) - 1 loop
    i := i + 1;
    minutes. extend;
    minutes(minutes. count) := (substr(xstr,
                                       instr(xstr, ',', 1, i) + 1,
                                       instr(xstr, ',', 1, i + 1) -
                                       instr(xstr, ',', 1, i) - 1));
  end loop;
  i := 0;

  xmonths      := to_char(result, 'mm');
  xdayofmonths := to_char(result, 'dd');
  xhours       := to_char(result, 'hh24');
  xminutes     := to_char(result, 'mi');
  xyear        := extract(year from result);

  for years in extract(year from result) .. extract(year from result) + 3 loop
    if years >= xyear then
      if years > xyear then
        xyear        := xyear + 1;
        xmonths      := months(months. first);
        xdayofmonths := dayofmonths(dayofmonths. first);
        xhours       := hours(hours. first);
        xminutes     := minutes(minutes. first);
      end if;
    
      for ii in months. first .. months. last loop
        if months(ii) >= xmonths then
          if months(ii) > xmonths then
            xdayofmonths := dayofmonths(dayofmonths. first);
            xhours       := hours(hours. first);
            xminutes     := minutes(minutes. first);
          end if;
          xmonths := months(ii);
          for j in dayofmonths. first .. dayofmonths. last loop
            if dayofmonths(j) >= xdayofmonths and to_char(last_day(to_date(xdayofmonths || '.' || xmonths || '.' ||
                                      xyear,
                                      'dd.mm.yyyy')),'dd') >= dayofmonths(j)
             
              then
              if dayofmonths(j) > xdayofmonths then
                xhours   := hours(hours. first);
                xminutes := minutes(minutes. first);
              end if;
              xdayofmonths := dayofmonths(j);
              for k in dayofweek. first .. dayofweek. last loop
                if case to_char(to_date(xdayofmonths || '.' || xmonths || '.' ||
                                    xyear,
                                    'dd.mm.yyyy'),
                            'd')
                     when to_char(7) then
                      1
                     else
                      to_char(to_date(xdayofmonths || '.' || xmonths || '.' ||
                                      xyear,
                                      'dd.mm.yyyy'),
                              'd') + 1
                   end = dayofweek(k) then
                
                  for h in hours. first .. hours. last loop
                    if hours(h) >= xhours then
                      if hours(h) > xhours then
                        xminutes := minutes(minutes. first);
                      end if;
                      xhours := hours(h);
                      for m in minutes. first .. minutes. last loop
                        if minutes(m) >= xminutes then
                          xminutes := minutes(m);
                        
                          return to_date(xdayofmonths || '.' || xmonths || '.' ||
                                         xyear || ' ' || xhours || ':' ||
                                         xminutes,
                                         'dd.mm.yyyy hh24:mi');
                        end if;
                      end loop;
                    
                    end if;
                  end loop;
                
                end if;
              end loop;
            end if;
          
          end loop;
        end if;
      end loop;
    end if;
  end loop;
  return to_date(null);
end;
