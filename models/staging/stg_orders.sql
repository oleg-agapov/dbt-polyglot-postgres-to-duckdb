select
    order_id::bigint as order_id,
    user_id::bigint as user_id,
    ordered_at::timestamp as ordered_at,
    status::text as status,
    amount::numeric(12, 2) as amount,
    date_trunc('month', ordered_at::timestamp)::date as order_month
from {{ ref('orders') }}
