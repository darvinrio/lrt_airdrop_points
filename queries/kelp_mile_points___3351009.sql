-- part of a query repo
-- query name: kelp_mile_points
-- query link: https://dune.com/queries/3351009


with 
kelp_multipliers as (
    select * from ( values
        -- rsETH
        -- (0xa1290d69c65a6fe4df752f95823fae25cb99e5a7, 1.25, timestamp'2023-12-10 00:00:00', timestamp'2024-01-01 00:00:00'), -- 1.25x multiplier 1st Jan 2024
        -- (0xa1290d69c65a6fe4df752f95823fae25cb99e5a7, 1.00, timestamp'2024-01-01 00:00:00', current_timestamp),
        (0xa1290d69c65a6fe4df752f95823fae25cb99e5a7, 1.00, timestamp'2023-12-10 00:00:00', current_timestamp),
        -- uni
        (0x64939a882c7d1b096241678b7a3a57ed19445485, 3.00, timestamp'2024-01-26 00:00:00', current_timestamp),
        -- (0x64939a882c7d1b096241678b7a3a57ed19445485, 2.00, timestamp'2024-02-26 00:00:00', timestamp'2024-06-26 00:00:00'),
        -- crv
        (0x3772ba91b46f456ae487cb0974040c861c045810, 3.00, timestamp'2024-01-26 00:00:00', current_timestamp),
        -- (0x3772ba91b46f456ae487cb0974040c861c045810, 2.00, timestamp'2024-02-26 00:00:00', timestamp'2024-06-26 00:00:00'),
        -- bal
        (0x7761b6e0daa04e70637d81f1da7d186c205c2ade, 3.00, timestamp'2024-01-26 00:00:00', current_timestamp),
        -- (0x7761b6e0daa04e70637d81f1da7d186c205c2ade, 2.00, timestamp'2024-02-26 00:00:00', timestamp'2024-06-26 00:00:00')
        -- mav
        (0xa6634fc4ed29950e85d97d48580a1a9d5c14ca7c, 2.00, timestamp'2024-01-30 00:00:00', current_timestamp),
        -- pendle LP
        (0x4f43c77872db6ba177c270986cd30c3381af37ee, 3.00, timestamp'2024-01-24 00:00:00',timestamp'2024-02-27 00:00:00'),
        (0x4f43c77872db6ba177c270986cd30c3381af37ee, 2.00, timestamp'2024-02-27 00:00:00', current_timestamp),
        (0x6f02c88650837c8dfe89f66723c4743e9cf833cd, 4.00, timestamp'2024-01-24 00:00:00', timestamp'2024-03-01 00:00:00'), -- arb
        (0x6f02c88650837c8dfe89f66723c4743e9cf833cd, 2.50, timestamp'2024-03-01 00:00:00', current_timestamp), -- arb
        -- pendle YT
        (0x28df0f193d8e45073bc1db6f2347812c031ba818, 4.00, timestamp'2024-01-24 00:00:00', timestamp'2024-03-01 00:00:00'), -- arb
        (0x28df0f193d8e45073bc1db6f2347812c031ba818, 2.50, timestamp'2024-03-01 00:00:00', current_timestamp), -- arb
        (0x0ed3a1d45dfdcf85bcc6c7bafdc0170a357b974c, 3.00, timestamp'2024-01-24 00:00:00', timestamp'2024-02-27 00:00:00'),
        (0x0ed3a1d45dfdcf85bcc6c7bafdc0170a357b974c, 2.00, timestamp'2024-02-27 00:00:00', current_timestamp)
    ) as miles(token, multiplier, start_time, end_time)
),
balances as (
    select * from query_3465811
    -- where wallet in (
    --     0x2326d4fb2737666dda96bd6314e3d4418246cfe8
    -- )
),
multiplier_join as (
    select 
        b.token,
        b.symbol,
        -- b.wallet,
        b.amt,
        b.evt_block_time,
        b.boosted_amt_cumulative,
        b.amt_cumulative,
        b.next_update,
        k.multiplier, 
        k.start_time, 
        k.end_time,
        b.action_rank
    from balances b 
        join kelp_multipliers k 
            on b.token = k.token
            -- multipliers only if  
            -- conditions : must start before event end and must not end before start of event
            and b.evt_block_time < k.end_time
            and next_update > k.start_time
),
math as (
    select *,
        case when evt_block_time > start_time then evt_block_time else start_time end as wallet_start_time,
        case when end_time < next_update then end_time else next_update end as wallet_end_time,
        date_diff('second',
            case when evt_block_time > start_time then evt_block_time else start_time end,
            case when end_time < next_update then end_time else next_update end
        ) as earning_seconds
    from multiplier_join
),

aggregated as (
    select 
        date_trunc('week', evt_block_time) as date,
        token,
        symbol,
        round(avg(
            case when action_rank=1 then boosted_amt_cumulative+amt_cumulative else null end
        ),3) as balance,
        
        sum(
            case when symbol = 'rsETH' then
                case when amt_cumulative < 0 
                    then 1.25*(boosted_amt_cumulative + amt_cumulative)*earning_seconds*multiplier*10000/(24*60*60) 
                    else (1.25*boosted_amt_cumulative + amt_cumulative)*earning_seconds*multiplier*10000/(24*60*60)
                end
                else amt_cumulative*earning_seconds*multiplier*10000/(24*60*60)
            -- else 0 
            end
        ) as kelp_miles,
        min(evt_block_time) as first_interaction
    from math 
    group by 1,2,3
)

select
    *,
    sum(
        kelp_miles
    ) over(
        partition by token
        order by date
    ) as token_kelp_miles,
    sum(
        kelp_miles
    ) over(order by date) as total_kelp_miles
from aggregated 
order by 1 desc
-- 275959

