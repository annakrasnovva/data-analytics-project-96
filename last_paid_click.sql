with last_visits as (
select s.visitor_id,
max(s.visit_date) as visit_date
from sessions s where medium <> 'organic'
group by 1
)

select
    lv.visitor_id,
    lv.visit_date,
    s.source as utm_source,
    s.medium as utm_medium,
    s.campaign as utm_campaign,
    l.lead_id,
    l.created_at,
    l.amount,
    l.closing_reason,
    l.status_id
from last_visits lv
left join sessions s
  on lv.visitor_id = s.visitor_id
left join leads as l
    on lv.visitor_id = l.visitor_id
where s.medium <> 'organic'
order by amount desc nulls last, visit_date, utm_source, utm_medium, utm_campaign;
