-- part of a query repo
-- query name: etherfi_s1_2_wallet_points
-- query link: https://dune.com/queries/3665624


with
stake_ranks as (
    select
        rank_label, 
        start_hour*(60.0*60) as start_hour, 
        end_hour*(60.0*60) as end_hour, 
        boost
    from ( values
        ( 1 ,  0, 100, 1.0),
        ( 2 ,100, 200, 1.1),
        ( 3 ,200, 300, 1.2),
        ( 4 ,300, 400, 1.3),
        ( 5 ,400, 500, 1.4),
        ( 6 ,500, 600, 1.6),
        ( 7 ,600, 700, 1.8),
        ( 8 ,700, 800000, 2.0) -- large value
    ) as ranks(rank_label, start_hour, end_hour, boost)
),
kelp_multipliers as (
    select * from ( values
        (0x35fA164735182de50811E8e2E824cFb9B6118ac2, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- eeth
        (0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- weeth
        (0xeA1A6307D9b18F8d1cbf1c3Dd6aad8416C06a221, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- liquid
        
        (0xf32e58f92e60f4b0a37a69b95d642a471365eae8, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- pendlelp eth
        (0xfb35fd0095dd1096b1ca49ad44d8c5812a201677, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- yt eth
                
        (0xe11f9786b06438456b044b3e21712228adcaa0d1, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- pendlelp arb apr25
        (0xf28db483773e3616da91fdfa7b5d4090ac40cc59, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- yt arb apr25
        (0x952083cde7aaa11ab8449057f7de23a970aa8472, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- pendlelp arb jun27
        (0xdcdc1004d5c271adc048982d7eb900cc4f472333, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- yt arb jun27
                
        (0xb9dEbDDF1d894c79D2B2d09f819FF9B856FCa552, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- bal weth pool
        (0x05ff47AFADa98a98982113758878F9A8B9FddA0a, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- bal reth pool
        (0xC859BF9d7B8C557bBd229565124c2C09269F3aEF, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- bal reth gauge
        (0x07A319A023859BbD49CC9C38ee891c3EA9283Cc5, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- aura reth vault
        (0xce98eb8b2fb98049b3f2db0a212ba7ca3efd63b0, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- bal tri lrt aura
        (0x253ed65fff980aee7e94a0dc57be304426048b35, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- bal tri lrt gauge
        (0x848a5564158d84b8a8fb68ab5d004fae11619a54, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- bal tri pool
                
        (0x13947303f63b363876868d070f14dc865c36463b, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- crv weth pool
        (0x1cac1a0ed47e2e0a313c712b2dcf85994021a365, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- crv weth gauge
        (0x278cfb6f06b1efc09d34fc7127d6060c61d629db, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- crv rsweth
        (0x0bfb387b87e8bf173a10a7dcf786b0b7875f6771, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- crv rsweth gauge
        
    
        (0xF047ab4c75cebf0eB9ed34Ae2c186f3611aEAfa6, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- zircuit
        (0xba3335588d9403515223f109edc4eb7269a9ab5d, 1.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- gearbox
        (0x7448c7456a97769f6cd04f1e83a4a23ccdc46abd, 2.00/10, timestamp'2023-01-01 00:00:00', timestamp'2024-03-15 00:00:00'), -- mav
        
        -- s2
        (0x35fA164735182de50811E8e2E824cFb9B6118ac2, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- eeth
        (0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- weeth
        (0xeA1A6307D9b18F8d1cbf1c3Dd6aad8416C06a221, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- liquid
        
        (0xf32e58f92e60f4b0a37a69b95d642a471365eae8, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- pendlelp eth
        (0xfb35fd0095dd1096b1ca49ad44d8c5812a201677, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- yt eth
                
        (0xe11f9786b06438456b044b3e21712228adcaa0d1, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- pendlelp arb apr25
        (0xf28db483773e3616da91fdfa7b5d4090ac40cc59, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- yt arb apr25
        (0x952083cde7aaa11ab8449057f7de23a970aa8472, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- pendlelp arb jun27
        (0xdcdc1004d5c271adc048982d7eb900cc4f472333, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- yt arb jun27
                
        (0xb9dEbDDF1d894c79D2B2d09f819FF9B856FCa552, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- bal weth pool
        (0x05ff47AFADa98a98982113758878F9A8B9FddA0a, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- bal reth pool
        (0xC859BF9d7B8C557bBd229565124c2C09269F3aEF, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- bal reth gauge
        (0x07A319A023859BbD49CC9C38ee891c3EA9283Cc5, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- aura reth vault
        (0xce98eb8b2fb98049b3f2db0a212ba7ca3efd63b0, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- bal tri lrt aura
        (0x253ed65fff980aee7e94a0dc57be304426048b35, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- bal tri lrt gauge
        (0x848a5564158d84b8a8fb68ab5d004fae11619a54, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- bal tri pool
                
        (0x13947303f63b363876868d070f14dc865c36463b, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- crv weth pool
        (0x1cac1a0ed47e2e0a313c712b2dcf85994021a365, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- crv weth gauge
        (0x278cfb6f06b1efc09d34fc7127d6060c61d629db, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- crv rsweth
        (0x0bfb387b87e8bf173a10a7dcf786b0b7875f6771, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- crv rsweth gauge
        
    
        (0xF047ab4c75cebf0eB9ed34Ae2c186f3611aEAfa6, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- zircuit
        (0xba3335588d9403515223f109edc4eb7269a9ab5d, 1.00, timestamp'2024-03-15 00:00:00', current_timestamp), -- gearbox
        (0x7448c7456a97769f6cd04f1e83a4a23ccdc46abd, 2.00, timestamp'2024-03-15 00:00:00', current_timestamp) -- mav
    ) as miles(token, multiplier, start_time, end_time)
),
balances as (
    -- 10th apr 450B
    select * from query_3614288
    -- where evt_block_time < date'2024-03-16'
    -- and wallet in (
    --     0x17d879bfe7f6992fc5ca6b2bdd089f32c8670037
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
        b.evt_index,
        b.amt_cumulative,
        b.next_update,
        k.multiplier, 
        k.start_time, 
        k.end_time,
        b.action_rank,
        -- for state rank
        b.amt_wallet_cumulative,
        b.next_wallet_update,
        case when b.evt_block_time > k.start_time then b.evt_block_time else k.start_time end as wallet_start_time,
        case when k.end_time < b.next_update then k.end_time else b.next_update end as wallet_end_time
    from balances b 
        join kelp_multipliers k 
            on b.token = k.token
            -- multipliers only if  
            -- conditions : must start before event end and must not end before start of event
            and b.evt_block_time < k.end_time
            and next_update > k.start_time
),
math as (
    select m.*,
        -- case when evt_block_time > start_time then evt_block_time else start_time end as wallet_start_time,
        -- case when end_time < next_update then end_time else next_update end as wallet_end_time,
        date_diff('second',
            case when evt_block_time > start_time then evt_block_time else start_time end,
            case when end_time < next_update then end_time else next_update end
        ) as earning_seconds,
        
            case 
                when amt_wallet_cumulative < 0.01 then 0
                when wallet_end_time <= date'2024-03-15' then 0
                when wallet_start_time < date'2024-03-15' and wallet_end_time > date'2024-03-15' 
                    then date_diff('second', date'2024-03-15', wallet_end_time)
                    -- then date_diff('second', evt_block_time, date'2024-03-15')
                else date_diff('second', wallet_start_time, wallet_end_time)
                end as delta_tim,
        sum(
            case 
                when amt_wallet_cumulative < 0.01 then 0
                when wallet_end_time <= date'2024-03-15' then 0
                when wallet_start_time < date'2024-03-15' and wallet_end_time > date'2024-03-15' 
                    then date_diff('second', date'2024-03-15', wallet_end_time)
                    -- then date_diff('second', evt_block_time, date'2024-03-15')
                else date_diff('second', wallet_start_time, wallet_end_time)
                end
        ) over(partition by wallet order by wallet_start_time, wallet_end_time) as time_in_system
    from multiplier_join m
),
add_lag as (
    select *,
        coalesce(
            lag(time_in_system) over(partition by wallet order by wallet_start_time, wallet_end_time ), 
            0 
        ) as prev_time_in_system
    from math
),
stake_rank_join as (
    select 
        m.*,
        s.*,
        if(earning_seconds=0, 0, if(time_in_system=0, boost,((
        case 
            -- start prev current end : done
            when (prev_time_in_system between start_hour and end_hour) 
                and (time_in_system between start_hour and end_hour)
            then time_in_system - prev_time_in_system
            -- prev start end current : done
            when (start_hour between prev_time_in_system and time_in_system)
                and (end_hour between prev_time_in_system and  time_in_system)
            then end_hour-start_hour
            -- start prev end current
            when (prev_time_in_system between start_hour and end_hour)
                and (end_hour between prev_time_in_system and  time_in_system)
                then end_hour -  prev_time_in_system
            -- prev start current  end 
            when (start_hour between prev_time_in_system and time_in_system)
                and (time_in_system between start_hour and  end_hour)
                then time_in_system - start_hour
        else null end)))) as eff_boost_time, -- *boost/(earning_seconds)
        -- else null end))) as eff_boost -- *boost/(earning_seconds)
        if(earning_seconds=0, 0, if(time_in_system=0, boost,((
        case 
            -- start prev current end : done
            when (prev_time_in_system between start_hour and end_hour) 
                and (time_in_system between start_hour and end_hour)
            then time_in_system - prev_time_in_system
            -- prev start end current : done
            when (start_hour between prev_time_in_system and time_in_system)
                and (end_hour between prev_time_in_system and  time_in_system)
            then end_hour-start_hour
            -- start prev end current
            when (prev_time_in_system between start_hour and end_hour)
                and (end_hour between prev_time_in_system and  time_in_system)
                then end_hour -  prev_time_in_system
            -- prev start current  end 
            when (start_hour between prev_time_in_system and time_in_system)
                and (time_in_system between start_hour and  end_hour)
                then time_in_system - start_hour
        else null end)*boost/(earning_seconds)))) as eff_boost
    from add_lag m
    join stake_ranks s 
        on m.prev_time_in_system <= s.end_hour
        and m.time_in_system >= s.start_hour
),
aggregated as (
    select 
        wallet,
        max(rank_label) as current_rank,
        sum(amt_cumulative*earning_seconds*multiplier*eff_boost*10000/(24*60*60)) as total_pearl_points,
        -- sum(amt*mint_flag*40) as mint_pearl_points,
        -- sum(amt_cumulative*earning_seconds*multiplier*eff_boost*10000/(24*60*60))+sum(amt*mint_flag*40) as all_pearls,
        min(evt_block_time) as first_interaction
    from stake_rank_join 
    group by 1
)

select
    rank() over(order by total_pearl_points desc) as pearl_rank,
    * 
from aggregated 
order by total_pearl_points desc


-- select * from math
