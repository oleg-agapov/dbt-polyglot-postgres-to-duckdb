select *
from {{ ref('user_order_summary') }}
where
    (user_id = 1 and completed_order_amount <> 199.75)
    or (user_id = 2 and completed_order_amount <> 310.00)
    or (user_id = 3 and completed_order_amount <> 0.00)
    or (user_id = 4 and completed_order_amount <> 42.35)
