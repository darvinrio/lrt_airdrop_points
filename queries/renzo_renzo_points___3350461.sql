-- part of a query repo
-- query name: renzo_renzo_points
-- query link: https://dune.com/queries/3350461


-- lets say time periods as - TO, T3, T2, T1 -> 1x, 3x, 2x, 1x
-- T0 - before 2024-01-03 09:20:47
-- T3 - 2024-01-03 09:20:47 to 2024-01-09 04:20:23
-- T2 - 2024-01-09 04:20:23 to 2024-01-16 10:36:11
-- T1 - after 2024-01-16 10:36:11 
with 
kelp_multipliers as (
    select * from ( values
        -- ezETH
        (0xbf5495efe5db9ce00f80364c8b423567e58d2110, 1.00, timestamp'2023-12-05 00:00:00', timestamp'2024-01-03 09:20:47'),
        (0xbf5495efe5db9ce00f80364c8b423567e58d2110, 3.00, timestamp'2024-01-03 09:20:47', timestamp'2024-01-09 04:20:23'),
        (0xbf5495efe5db9ce00f80364c8b423567e58d2110, 2.00, timestamp'2024-01-09 04:20:23', timestamp'2024-01-16 10:36:11'),
        (0xbf5495efe5db9ce00f80364c8b423567e58d2110, 1.00, timestamp'2024-01-16 10:36:11', current_timestamp),
        -- bal pool
        (0x596192bb6e41802428ac943d2f1476c1af25cc0e, 2.00, timestamp'2024-01-13 06:36:11', current_timestamp),
        -- bal gauge
        (0xa8b309a75f0d64ed632d45a003c68a30e59a1d8b, 2.00, timestamp'2024-01-13 06:36:11', current_timestamp),
        -- uni pool
        (0xBE80225f09645f172B079394312220637C440A63, 1.00, timestamp'2024-01-24 05:06:40', current_timestamp),
        -- tri lrt bal pool
        (0x848a5564158d84b8a8fb68ab5d004fae11619a54, 2.00, timestamp'2024-02-08 04:38:30', current_timestamp),
        -- tri lrt bal gauge
        (0x253ed65fff980aee7e94a0dc57be304426048b35, 2.00, timestamp'2024-02-08 04:38:30', current_timestamp),
        -- tri lrt aura vault
        (0xce98eb8b2fb98049b3f2db0a212ba7ca3efd63b0, 2.00, timestamp'2024-02-08 04:38:30', current_timestamp),
        -- pendle yt
        (0x256fb830945141f7927785c06b65dabc3744213c, 2.00, timestamp'2024-01-28 01:38:40', current_timestamp),
        -- pendle lp
        (0xde715330043799d7a80249660d1e6b61eb3713b3, 0.5, timestamp'2024-01-28 01:38:40', current_timestamp),
        -- curve lp
        (0x85de3add465a219ee25e04d22c39ab027cf5c12e, 1.0, timestamp'2024-01-30 00:00:00', current_timestamp),
        -- zircuit staking
        (0xF047ab4c75cebf0eB9ed34Ae2c186f3611aEAfa6, 1.0, timestamp'2024-02-16 01:38:00', current_timestamp),
        -- pendle arb yt
        (0x05735b65686635f5c87aa9d2dae494fb2e838f38, 2.00, timestamp'2024-01-28 01:38:40', current_timestamp),
        -- pendle arb lp
        (0x5e03c94fc5fb2e21882000a96df0b63d2c4312e2, 0.50, timestamp'2024-01-28 01:38:40', current_timestamp),
        -- pendle arb yt
        (0x98601e27d41ccff643da9d981dc708cf9ef1f150, 1.00, timestamp'2024-01-28 01:38:40', current_timestamp),
        -- pendle arb lp
        (0xd7e0809998693fd87e81d51de1619fd0ee658031, 1.00, timestamp'2024-01-28 01:38:40', current_timestamp)
    ) as miles(token, multiplier, start_time, end_time)
),
balances as (
    select * from query_3462283
    -- where wallet in (
    --     0x94cf7b6eb35de00c3aeb3ec49a625ec4e39f5630
    -- )
),
multiplier_join as (
    select 
        b.token,
        b.symbol,
        -- b.wallet,
        b.amt,
        b.evt_block_time,
        b.evt_index,
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
            case when action_rank=1 then amt_cumulative else null end
        ),3) as balance,
        sum(amt_cumulative*earning_seconds*multiplier/(60*60)) as renzo_points,
        sum(
            sum(amt_cumulative*earning_seconds*multiplier/(60*60))
        ) over(
            partition by token
            order by date_trunc('week', evt_block_time)
        ) as token_renzo_points,
        sum(
            sum(amt_cumulative*earning_seconds*multiplier/(60*60))
        ) over(order by date_trunc('week', evt_block_time)) as total_renzo_points
    from math 
    group by 1,2,3
)



select * from aggregated
order by 1 desc
-- order by evt_block_time desc, evt_index desc
