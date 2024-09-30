-- платные кол-во постетителей

with last_visits as (
    select
        visitor_id,
        max(visit_date) as max_visit_date
    from sessions
    where medium != 'organic'
    group by 2
),

leads as (
    select
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        date(lv.max_visit_date) as visit_date,
        count(distinct lv.visitor_id) as visitors_count,
        count(l.lead_id) as leads_count,
        count(
            case
                when
                    l.status_id = 142
                    or l.closing_reason = 'Успешно реализовано'
                    then lv.visitor_id
            end
        ) as purchases_count,
        sum(l.amount) as revenue
    from last_visits as lv
    inner join sessions as s
        on lv.visitor_id = s.visitor_id and lv.max_visit_date = s.visit_date
    left join leads as l
        on s.visitor_id = l.visitor_id and l.created_at >= s.visit_date
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
    l.leads_count,
    l.purchases_count,
    a.total_cost,
    l.revenue,
    coalesce(a.total_cost / l.visitors_count, 0) as cpu,
    round(
        coalesce(l.leads_count, 0)::numeric / l.visitors_count::numeric * 100, 2
    ) as leads_cr_percents,
    case
        when
            l.leads_count is null or l.leads_count = 0
            or l.purchases_count is null or l.purchases_count = 0 then 0
        else round(l.purchases_count::numeric / l.leads_count::numeric * 100, 2)
    end as purchases_cr_percents,
    case
        when
            a.total_cost is null or a.total_cost = 0 or l.leads_count = 0 then 0
        else a.total_cost / l.leads_count
    end as cpl,
    case
        when
            a.total_cost is null or a.total_cost = 0
            or l.purchases_count = 0 then 0
        else a.total_cost / l.purchases_count
    end as cppu,
    case
        when a.total_cost is null or a.total_cost = 0 then 0
        else ((l.revenue - a.total_cost) / a.total_cost) * 100
    end as roi
from leads as l
left join ads as a
    on
        l.visit_date = a.campaign_date
        and l.utm_source = a.utm_source
        and l.utm_medium = a.utm_medium
        and l.utm_campaign = a.utm_campaign
order by 11 desc nulls last, 2 asc;
