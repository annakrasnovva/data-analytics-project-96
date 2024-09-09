with last_visits as (
    select
        max(date(visit_date)) as visit_date,
        visitor_id
    from sessions
    group by 2
),

leads as (
    select
        lv.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        count(distinct lv.visitor_id) as visitors_count,
        count(l.lead_id) as leads_count,
        count(
            case
                when l.status_id = 142 then lv.visitor_id
            end
        ) as purchases_count,
        sum(amount) as revenue
    from last_visits as lv
    inner join sessions as s
        on lv.visitor_id = s.visitor_id
    left join leads as l
        on s.visitor_id = l.visitor_id
    where s.medium <> 'organic'
    group by 1, 2, 3, 4
),

ads as (
    select
        date(campaign_date) as campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as total_cost
    from vk_ads
    group by 1, 2, 3, 4
    union all
    select
        date(campaign_date) as campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as total_cost
    from ya_ads
    group by 1, 2, 3, 4
)

select
    l.visit_date,
    l.utm_source,
    l.utm_medium,
    l.utm_campaign,
    l.visitors_count,
    a.total_cost,
    l.leads_count,
    l.purchases_count,
    l.revenue
from leads as l
left join ads as a
    on
        l.visit_date = a.campaign_date
        and l.utm_source = a.utm_source
        and l.utm_medium = a.utm_medium
        and l.utm_campaign = a.utm_campaign
order by 9 desc nulls last, 1 asc, 5 desc, 2, 3, 4;
