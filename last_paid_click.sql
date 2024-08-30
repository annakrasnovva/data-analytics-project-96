select
  s.visitor_id,
  max (s.visit_date) as visit_date,
  s.source as utm_source,
  s.medium as utm_medium,
  s.campaign as utm_campaign,
  l.lead_id,
  l.created_at,
  l.amount,
  l.closing_reason,
  l.status_id
from sessions s
left join leads l
  using (visitor_id)
left join vk_ads vk
  on s.source = vk.utm_source and s.medium = vk.utm_medium and
s.campaign = vk.utm_campaign and s.content = vk.utm_content
left join ya_ads ya
  on s.source = ya.utm_source and s.medium = ya.utm_medium and
s.campaign = ya.utm_campaign and s.content = ya.utm_content
where s.medium <> 'organic'
group by 1, 3, 4, 5, 6, 7, 8, 9, 10
order by amount desc nulls last, visit_date, s.source, s.medium, s.campaign
limit 10;