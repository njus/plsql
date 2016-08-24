function getSvarMatOnKK(idvkk number) return TvvvSvarMatOnKKtbl
  pipelined is
begin
  for lv in (select grps,
                    trim(sxk_list(mark || ': ' || qtymark || ' ')) qtymark,
                    max(total) prar,
                    round(sum(val) * 7 / 198, 2) el,
                  case when trim(max(nocalk)) is not null then  'Не рассчитались операции: '||trim(sxk_list(mark || ': ' || nocalk ||chr(13))) end nocalk --не посчиталась свварка по опр.
                   ,null as ktpnumbs,
                    sum(val) val --контрольное знач
             from (select --подселект чтобы узнать к-во марок на группу
                      grps,
                      mark,
                      count(1) qtymark,
                      sum(val) val,
                      max(total) total,
                      max(case
                            when trim(nocalk) is not null then
                             nocalk || ' ' || scaption
                            else
                             ''
                          end) nocalk,
                      max(idktpver) idktpver
                       from (select *
                               from (select
                                       rn,
                                       max(mark) mark,
                                       max(smnemocode) smnemocode,
                                       max(scaption) scaption,
                                       max(qtyinkk) qtyinkk,
                                       max(qty) qty,
                                       max(idktpver) idktpver,
                                       round(sum(prar * metri * qty), 2) val,
                                       trim(sxk_list(case
                                                       when ppo.id is null or spr.id is null then
                                                        ppo.smnemocode
                                                       else
                                                        ''
                                                     end || ' ')) nocalk
                                        from (select x.*,
                                                     1 qty,
                                                     (select /*+ index(a5 FK_ccc_REFATTRITEMVALUE_REFITE) index(a6 FK_ccc_REFATTRITEMVALUE_REFITE)*/
                                                       nvl(a5.fFloat + a6.fFloat,
                                                           0)
                                                        from ccc_RefAttrItemValue a5,
                                                             ccc_RefAttrItemValue a6
                                                       where a5.idRefItem(+) =
                                                             idkompl
                                                         and a5.idRefAttr =
                                                             2384001
                                                         and a6.idRefItem =
                                                             idkompl
                                                         and a6.idRefAttr =
                                                             2385001) qtyinkk,
                                                     rownum rn
                                                from (select /*+ cardinality(50) ordered index_(raiv FK_ccc_REFATTRITEMVALUE_REFITE) index(raiv FK_ccc_REFATTRITEMVALUE_REFATT) use_nl(raiv p_i) index(a4 FK_ccc_REFATTRITEMVALUE_REFITE)
                                                      index(pr PK_mmm_PROCESSRESOURCE)*/
                                                       p_i.id idkompl,
                                                       ccc_refitemapi.GetMnemocode(max(a4.idRefItemValue)) mark,
                                                       vvv_mmm_ktp.getktpverbymark(max(ccc_refitemapi.GetOriginal(a4.idRefItemValue))) idktpver
                                                        from ccc_RefAttrItemValue raiv,
                                                             ccc_RefItem          p_i,
                                                             ccc_RefAttrItemValue a4
                                                       where raiv.idRefItem =
                                                             idvkk
                                                         and raiv.idRefAttr =
                                                             2390001
                                                         and p_i.id =
                                                             raiv.IdRefItemValue
                                                         and a4.idRefItem = p_I.id
                                                         and a4.idRefAttr =
                                                             2382001
                                                       group by raiv.idRefItem,
                                                                p_i.id
                                                      having exists ( --исключим нулевые элементы компл карты
                                                                    select /*+ index(a5 FK_ccc_REFATTRITEMVALUE_REFITE) index(a6 FK_ccc_REFATTRITEMVALUE_REFITE)*/
                                                                     nvl(a5.fFloat +
                                                                          a6.fFloat,
                                                                          0)
                                                                      from ccc_RefAttrItemValue a5,
                                                                            ccc_RefAttrItemValue a6
                                                                     where a5.idRefItem =
                                                                           p_i.id
                                                                       and a5.idRefAttr =
                                                                           2384001
                                                                       and a6.idRefItem =
                                                                           p_i.id
                                                                       and a6.idRefAttr =
                                                                           2385001
                                                                       and nvl(a5.fFloat +
                                                                               a6.fFloat,
                                                                               0) > 0)) x
                                              connect by prior --размножим элем. к.к. 1 строка - 1 штука марки
                                                          idkompl = idkompl --не убирать это
                                                     and level <=
                                                         (select /*+ index(a5 FK_ccc_REFATTRITEMVALUE_REFITE) index(a6 FK_ccc_REFATTRITEMVALUE_REFITE)*/
                                                           nvl(a5.fFloat +
                                                               a6.fFloat,
                                                               0)
                                                            from ccc_RefAttrItemValue a5,
                                                                 ccc_RefAttrItemValue a6
                                                           where a5.idRefItem =
                                                                 idkompl
                                                             and a5.idRefAttr =
                                                                 2384001
                                                             and a6.idRefItem =
                                                                 idkompl
                                                             and a6.idRefAttr =
                                                                 2385001)
                                                     and prior
                                                          dbms_random.value is not null --не убирать это
                                              ) kk_tuk
                                        left join (select /*+ leading(pov po) index(pov FK_mmm_PROCESSOPERATIONVER_VER) */
                                                   pov.idprocesscardversion,
                                                   pov.id,
                                                   (select /*+ index(agi FK_ccc_ATTRIBUTEGROUPITEM_GR) index(oas FK_ccc_OBJECTATTRIBUTESET_TBL) 
                                                                            index(oav FK_ccc_OBJECTATTRIBUTEVALUE_S) */
                                                     oav.fvalue
                                                      from ccc_attributegroupitem   agi,
                                                           ccc_objectattributeset   oas,
                                                           ccc_objectattributevalue oav
                                                     where agi.sname =
                                                           'vvv_LegSeam'
                                                       and 524001 =
                                                           agi.idattributegroup
                                                       and oas.idobjtable = 20390
                                                       and 18516 =
                                                           oas.idattrsourceobjtable
                                                       and agi.idattribute = 2001
                                                       and oav.idobjectattributeset =
                                                           oas.id
                                                       and oav.idattributegroupitem =
                                                           agi.id
                                                       and pov.id =
                                                           oas.idoriginal) katet,
                                                   (select /*+ index(agi FK_ccc_ATTRIBUTEGROUPITEM_GR) index(oas FK_ccc_OBJECTATTRIBUTESET_TBL) 
                                                                            index(oav FK_ccc_OBJECTATTRIBUTEVALUE_S) */
                                                     oav.fvalue
                                                      from ccc_attributegroupitem   agi,
                                                           ccc_objectattributeset   oas,
                                                           ccc_objectattributevalue oav
                                                     where agi.sname =
                                                           'vvv_Thick1'
                                                       and 243001 =
                                                           agi.idattributegroup
                                                       and oas.idobjtable = 20390
                                                       and 18516 =
                                                           oas.idattrsourceobjtable
                                                       and agi.idattribute = 6001
                                                       and oav.idobjectattributeset =
                                                           oas.id
                                                       and oav.idattributegroupitem =
                                                           agi.id
                                                       and pov.id =
                                                           oas.idoriginal) thckns, --толщина листов,           
                                                   (select oav.fvalue
                                                      from ccc_objectattributeset   oas,
                                                           ccc_attributegroupitem   agi,
                                                           ccc_objectattributevalue oav
                                                     where agi.sname =
                                                           'vvv_norm_105'
                                                       and 983001 =
                                                           agi.idattributegroup
                                                       and oas.idoriginal =
                                                           pov.id
                                                       and oas.idobjtable = 20390
                                                       and 18516 =
                                                           oas.idattrsourceobjtable
                                                       and agi.idattribute =
                                                           863001
                                                       and oav.idobjectattributeset =
                                                           oas.id
                                                       and oav.idattributegroupitem =
                                                           agi.id
                                                       and pov.id =
                                                           oas.idoriginal) metri,
                                                   po.smnemocode,
                                                   po.scaption,
                                                   (select vvv_varchar2_256(replace(max(s.smnemocode || '; '),
                                                                                    'ГОСТ 14771-76 ',
                                                                                    ''),
                                                                            regexp_substr((trim(replace(max(upper(s.smnemocode)),
                                                                                                        'ГОСТ 14771-76',
                                                                                                        ''))),
                                                                                          '^[[:alpha:]][[:digit:]]{1,2}'))
                                                      from mmm_stdoperation s
                                                     where s.idworknormitem =
                                                           pov.idworknormitem
                                                       and s.idoperationtype =
                                                           po.idoperationtype
                                                       and Upper(s.sMnemocode) like
                                                           Upper('ГОСТ 14771-76%')
                                                     escape '(') GOST_TYPE
                                                    from mmm_processoperation    po,
                                                         mmm_processoperationver pov
                                                  --к-во метров
                                                   where pov.idprocessoperation =
                                                         po.id
                                                     and po.idoperationtype in --п/автомат сварка тип операции
                                                         (select distinct x.idoperationtype --, x.smnemocode, x.scaption
                                                            from mmm_StdOperation x
                                                           where Upper(x.sMnemocode) like
                                                                 Upper('ГОСТ 14771-76%'))
                                                     and pov.idworknormitem in --сварка норма
                                                         (select w.id --, w.smnemocode, w.scaption
                                                            from mmm_worknorm   w,
                                                                 ccc_FolderItem fi
                                                           where fi.idFolder in
                                                                 (select id
                                                                    from ccc_Folder
                                                                   start with id =
                                                                              6287001
                                                                  connect by idParent = prior id)
                                                             and w.id =
                                                                 fi.idOrigin
                                                             and fi.idType =
                                                                 4848001
                                                                and w.id!=376001--перестановка полуавтомата 
                                                                 )                                                                 
                                                                 ) ppo
                                          on kk_tuk.idktpver =
                                             ppo.idprocesscardversion
                                        left join (select /*+ ordered use_nl(p_i a1) use_nl(p_i a2) use_nl(p_i a3) use_nl(p_i a4) use_nl(p_i a5) use_nl(p_i a6) use_nl(p_i a7) index(p_i FK_ccc_REFITEM_REF) index(a1 FK_ccc_REFATTRITEMVALUE_REFATT) index(a1 FK_ccc_REFATTRITEMVALUE_REFATT) index(a2 FK_ccc_REFATTRITEMVALUE_REFATT)
                                                               index(a3 FK_ccc_REFATTRITEMVALUE_REFATT)*/
                                                   p_i.id,
                                                   a1.sstring thc,
                                                   a2.sstring gost,
                                                   replace(a2.sstring,
                                                           'ГОСТ 14771-76',
                                                           '') stype,
                                                   a4.fFloat el,
                                                   a5.fFloat pr,
                                                   a6.fFloat fl,
                                                   a7.fFloat prAr
                                                    from ccc_RefItem          p_i,
                                                         ccc_RefAttrItemValue a1,
                                                         ccc_RefAttrItemValue a2,
                                                         ccc_RefAttrItemValue a4,
                                                         ccc_RefAttrItemValue a5,
                                                         ccc_RefAttrItemValue a6,
                                                         ccc_RefAttrItemValue a7
                                                   where p_i.idRef =
                                                         ccc_refapi.FindByName('vvv_norm_svarka')
                                                     and a1.idRefItem = p_I.id
                                                     and a1.idRefAttr =
                                                         ccc_refattrapi.FindByMnemocode(p_i.idRef,
                                                                                        'thickness')
                                                     and a2.idRefItem = p_I.id
                                                     and a2.idRefAttr =
                                                         ccc_refattrapi.FindByMnemocode(p_i.idRef,
                                                                                        'gost')
                                                     and a4.idRefItem = p_I.id
                                                     and a4.idRefAttr =
                                                         ccc_refattrapi.FindByMnemocode(p_i.idRef,
                                                                                        'elektrodi')
                                                     and a5.idRefItem = p_I.id
                                                     and a5.idRefAttr =
                                                         ccc_refattrapi.FindByMnemocode(p_i.idRef,
                                                                                        'provolkaAf')
                                                     and a6.idRefItem = p_I.id
                                                     and a6.idRefAttr =
                                                         ccc_refattrapi.FindByMnemocode(p_i.idRef,
                                                                                        'flus')
                                                     and a7.idRefItem = p_I.id
                                                     and a7.idRefAttr =
                                                         ccc_refattrapi.FindByMnemocode(p_i.idRef,
                                                                                        'provolkaAr')
                                                     and exists
                                                   (select 1
                                                            from ccc_RefAttrItemValue a
                                                           where a.idRefItem =
                                                                 p_I.id
                                                             and 'vvv_norm_svarka' =
                                                                 ccc_refapi.GetName(a.idref)
                                                             and a.idRefAttr =
                                                                 ccc_refattrapi.FindByMnemocode(p_i.idRef,
                                                                                                'gost')
                                                             and instr(a.sstring,
                                                                       'ГОСТ 14771-76') > 0)) spr
                                          on instr(spr.stype, ppo.GOST_TYPE.n2) > 0
                                         and spr.thc =
                                             nvl(trim(ppo.thckns), trim(katet))
                                       group by kk_tuk.rn --строка=марка в количестве 1
                                      ) yyy 
                                      model --модел нужен для разбиения по группм не превышающим 6 барабанов(198 кг)
                                     dimension by(row_number() over(order by case when val is null then 1 else 0 end, val asc,mark, rn)  rn1) 
                                     measures(mark, smnemocode,/*rn10,*/rn, scaption, qtyinkk, qty, idktpver, nocalk, val, val total, 0 mmax, 0 as grps, 0 cntMInGr, 0 cntM) 
                                     rules(
                                     total [ rn1 > 1 ] order by rn1 = --вспомог. кол
                                    case
                                      when nvl(total [ cv() - 1 ], 0) + val [ cv() ] <= 198 then
                                       nvl(total [ cv() - 1 ], 0) + total [ cv() ]
                                      else
                                       total [ cv() ]
                                    end, 
                                    mmax [ rn1 > 0 ] order by rn1 = --вспомог кол.
                                    case
                                       when nvl(total[cv()],0)=0 then -1
                                      when nvl(total [ cv()],0) + val [ cv()+1 ] <= 198 and  total [ cv() ]>0 then
                                      null
                                      else
                                        rn[cv()] 
                                    end, 
                                    grps [ rn1 > 0 ] order by rn1 desc = --группы до 198 кг проволоки(до 6 мотков)
                                    case
                                      when mmax [ cv() ] is null then
                                       grps [ cv() + 1 ]
                                      else
                                       mmax [ cv() ]
                                    end)) zzz
                      group by grps, mark)
              group by grps
              order by grps             
             ) loop
    pipe row(TvvvSvarMatOnKK(lv.grps,
                             lv.qtymark,
                             lv.prar,
                             lv.el,
                             lv.nocalk,
                             lv.ktpnumbs,
                             lv.val));
  end loop;
end;
