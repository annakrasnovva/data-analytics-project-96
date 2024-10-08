with last_visits as (
    select
        s.visitor_id,
        max(s.visit_date) as max_visit_date
    from sessions as s
    where s.medium != 'organic'
    group by 1
)

select
    lv.visitor_id,
    lv.max_visit_date as visit_date,
    s.source as utm_source,
    s.medium as utm_medium,
    s.campaign as utm_campaign,
    l.lead_id,
    l.created_at,
    l.amount,
    l.closing_reason,
    l.status_id
from last_visits as lv
left join sessions as s
    on lv.visitor_id = s.visitor_id and lv.max_visit_date = s.visit_date
left join leads as l
    on lv.visitor_id = l.visitor_id
where s.medium != 'organic'
order by 8 desc nulls last, 2 asc, 3 asc, 4 asc, 5 asc;
