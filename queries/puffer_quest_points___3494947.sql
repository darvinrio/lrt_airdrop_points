-- part of a query repo
-- query name: puffer_quest_points
-- query link: https://dune.com/queries/3494947


with 
kelp_multipliers as (
    select * from ( values
        (0xD9A442856C234a39a81a089C06451EBAa4306a72, 0.00, date'2024-01-31', date'2024-02-26'), -- 'pufeth'
        (0xD9A442856C234a39a81a089C06451EBAa4306a72, 1.00, date'2024-02-26', date'2024-03-20'), -- 'pufeth'
        (0xb3c8ce1ee157b0dcaa96897c9170aee6281706c9, 2.00, date'2024-02-26', date'2024-03-28'), -- 'crv'
        (0xb6ec26a3433d6cd11084c2094f12c4e571806d06, 2.00, date'2024-02-26', date'2024-03-28'), -- 'crv gauge'
        -- (0x17be998a578fd97687b24e83954fec86dc20c979, 2.00, date'2024-02-26', date'2024-03-28'), -- 'pendle lp'
        (0x391b570e81e354a85a496952b66adc831715f54f, 2.00, date'2024-02-26', date'2024-03-28'),  -- 'yt'
        -- (0x17be998a578fd97687b24e83954fec86dc20c979, 1.25, date'2024-03-28', current_date), -- 'pendle lp'
        (0x391b570e81e354a85a496952b66adc831715f54f, 1.25, date'2024-03-28', current_date), -- 'yt'
        (0xAd16eDCF7DEB7e90096A259c81269d811544B6B6, 1.15, date'2024-03-20', current_date), -- zknova
        (0xEEda34A377dD0ca676b9511EE1324974fA8d980D, 2.00, date'2024-03-20', current_date), -- curve v2
        (0x63e0d47a6964ad1565345da9bfa66659f4983f02, 2.00, date'2024-03-20', current_date), -- bal
        (0xD9A442856C234a39a81a089C06451EBAa4306a72, 1.00, date'2024-03-20', current_date), -- zircuit
        (0x3b95bc951ee0f553ba487327278cac44f29715e5, 1.15, date'2024-03-20', current_date)  -- manta
    ) as miles(token, multiplier, start_time, end_time)
),
balances as (
    select * from query_3494922
    -- where wallet in (
    --     
    -- )
),
multiplier_join as (
    select 
        b.token,
        b.symbol,
        b.wallet,
        b.mint_flag,
        b.amt,
        b.evt_block_time,
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
        date_trunc('day', evt_block_time) as date,
        token,
        symbol,
        round(avg(
            case when action_rank=1 then amt_cumulative else null end
        ),3) as balance,
        sum(amt_cumulative*earning_seconds*multiplier*30/(60*60)) as pearl_points,
        sum(
            case when evt_block_time < timestamp'2024-02-26 04:00:00'
                then 
                amt*mint_flag*10000
                else amt*mint_flag*1000
            end
        ) as mint_pearl_points,        
        sum(
            sum(amt_cumulative*earning_seconds*multiplier*30/(60*60))
        ) over(
            partition by token
            order by date_trunc('day', evt_block_time)
        ) as token_pearl_points,
        sum(
            sum(amt_cumulative*earning_seconds*multiplier*30/(60*60))
        ) over(order by date_trunc('day', evt_block_time)) as total_pearl_points,
        sum(sum(
            case when evt_block_time < timestamp'2024-02-26 04:00:00'
                then amt*mint_flag*10000
                else amt*mint_flag*1000
            end
        )) over(order by date_trunc('day', evt_block_time)) as total_mint_pearl_points
    from math 
    group by 1,2,3
)


select *,
    total_pearl_points+total_mint_pearl_points as total_pearls
from aggregated
order by 1 desc
-- order by evt_block_time desc, evt_index desc

-- select * from math