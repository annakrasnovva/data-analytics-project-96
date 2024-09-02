select
    date(s.visit_date),
    s.source as utm_source,
    s.medium as utm_medium,
    s.campaign as utm_campaign,
    count(s.visitor_id) as visitors_count,
    sum(coalesce(vk.daily_spent, 0))
    + sum(coalesce(ya.daily_spent, 0)) as total_cost,
    count(lead_id) as leads_count,
    count(status_id) as purchases_count,
    sum(amount) as revenue
from sessions as s
left join leads as l
    on s.visitor_id = l.visitor_id
left join vk_ads as vk
    on
        s.source = vk.utm_source and s.medium = vk.utm_medium
        and s.campaign = vk.utm_campaign and s.content = vk.utm_content
left join ya_ads as ya
    on
        s.source = ya.utm_source and s.medium = ya.utm_medium
        and s.campaign = ya.utm_campaign and s.content = ya.utm_content
where s.medium <> 'organic' and status_id = 142
group by 1, 2, 3, 4
order by 9 desc nulls last, 1, 5 desc, 2, 3, 4;