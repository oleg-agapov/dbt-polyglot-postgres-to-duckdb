select
    user_id::bigint as user_id,
    lower(email)::varchar(255) as email,
    display_name::text as display_name,
    created_at::timestamp as created_at,
    status::text as status
from {{ ref('users') }}
