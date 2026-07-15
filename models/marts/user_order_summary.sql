select
    users.user_id,
    users.display_name,
    users.email,
    count(orders.order_id) filter (
        where orders.status = 'completed'
    )::bigint as completed_order_count,
    coalesce(
        sum(orders.amount) filter (where orders.status = 'completed'),
        0
    )::numeric(12, 2) as completed_order_amount,
    max(orders.ordered_at)::date as latest_order_date
from {{ ref('stg_users') }} as users
left join {{ ref('stg_orders') }} as orders
    on users.user_id = orders.user_id
group by
    users.user_id,
    users.display_name,
    users.email
