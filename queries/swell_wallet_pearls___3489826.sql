-- part of a query repo
-- query name: swell_wallet_pearls
-- query link: https://dune.com/queries/3489826


with
kelp_multipliers as (
    select * from ( values
        (0xf951E335afb289353dc249e82926178EaC7DEd78, 1.00, date'2023-04-12', current_date), -- 'sweth'
    
        (0xd33dAd974b938744dAC81fE00ac67cb5AA13958E, 1.00, date'2023-08-10', date'2023-09-19'), -- 'somm vault'
        (0xd33dAd974b938744dAC81fE00ac67cb5AA13958E, 2.00, date'2023-09-19', date'2023-09-23'), -- 'somm vault'
        (0xd33dAd974b938744dAC81fE00ac67cb5AA13958E, 1.00, date'2023-09-23', date'2023-10-06'), -- 'somm vault'
        (0xd33dAd974b938744dAC81fE00ac67cb5AA13958E, 2.00, date'2023-10-06', date'2023-12-06'), -- 'somm vault'
        (0xd33dAd974b938744dAC81fE00ac67cb5AA13958E, 1.00, date'2023-12-06', current_date), -- 'somm vault'
        
        (0xE7e2c68d3b13d905BBb636709cF4DfD21076b9D2, 2.00, date'2023-08-18', date'2023-09-06'), -- 'bal'
        (0xE7e2c68d3b13d905BBb636709cF4DfD21076b9D2, 1.00, date'2023-09-06', current_date), -- 'bal'
        (0xf8f18dc9E192A9Bf9347DA0E2107d05D5B67F38e, 2.00, date'2023-08-18', date'2023-09-06'), -- 'aura'
        (0xf8f18dc9E192A9Bf9347DA0E2107d05D5B67F38e, 1.00, date'2023-09-06', current_date), -- 'aura'
        
        -- approx 1 lp -> 2 sweth
        (0x0e1c5509b503358ea1dac119c1d413e28cc4b303, 2.00, date'2023-04-12', date'2023-09-19'), -- 'pendle lp'
        (0x0e1c5509b503358ea1dac119c1d413e28cc4b303, 4.00, date'2023-09-19', date'2023-10-02'), -- 'pendle lp'
        (0x0e1c5509b503358ea1dac119c1d413e28cc4b303, 2.00, date'2023-10-02', current_date), -- 'pendle lp'
        -- probably 1.5 ( site says 6)
        (0x32bd822d615A3658A68b6fDD30c2fcb2C996D678, 1.5, date'2023-04-12', current_date), -- 'eigenpie'
        
        (0xD48a0484730D867F551e6FcAC4926f88F27AF4FD, 1.00, date'2023-04-12', date'2023-07-27'), -- 'aura dep'
        (0xD48a0484730D867F551e6FcAC4926f88F27AF4FD, 2.00, date'2023-07-27', date'2023-08-22'), -- 'aura dep'
        (0x02d928e68d8f10c0358566152677db51e1e2dc8c, 1.00, date'2023-04-12', date'2023-07-27'), -- 'bal dep'
        (0x02d928e68d8f10c0358566152677db51e1e2dc8c, 2.00, date'2023-07-27', date'2023-08-22'), -- 'bal dep'
        (0xae8535c23afedda9304b03c68a3563b75fc8f92b, 1.00, date'2023-04-12', date'2023-07-27'), -- 'bal dep'
        (0xae8535c23afedda9304b03c68a3563b75fc8f92b, 2.00, date'2023-07-27', date'2023-08-22'), -- 'bal dep'
        (0xcf756c00a755172bdc073787ea83817603da42ef, 2.00, date'2023-04-12', date'2023-07-27'), -- 'pendle lp dep'
        (0xcf756c00a755172bdc073787ea83817603da42ef, 4.00, date'2023-07-27', date'2023-08-22'), -- 'pendle lp dep'
        
        (0x858646372cc42e1a627fce94aa7a7033e7cf075a, 1.00, date'2023-04-12', current_date), -- 'eigen'
        
        (0xFAe103DC9cf190eD75350761e95403b7b8aFa6c0, 1.00, date'2023-04-12', current_date), -- 'rsweth'
        
        (0xce98eb8b2fb98049b3f2db0a212ba7ca3efd63b0, 1.00, date'2023-04-12', date'2024-02-13'), -- 'tri lrt aura'
        (0xce98eb8b2fb98049b3f2db0a212ba7ca3efd63b0, 2.00, date'2024-02-13', date'2024-03-10'), -- 'tri lrt aura'
        (0xce98eb8b2fb98049b3f2db0a212ba7ca3efd63b0, 1.00, date'2024-03-10', current_date), -- 'tri lrt aura'
        (0x253ed65fff980aee7e94a0dc57be304426048b35, 1.00, date'2023-04-12', date'2024-02-13'), -- 'tri lrt gauge'
        (0x253ed65fff980aee7e94a0dc57be304426048b35, 2.00, date'2024-02-13', date'2024-03-10'), -- 'tri lrt gauge'
        (0x253ed65fff980aee7e94a0dc57be304426048b35, 1.00, date'2024-03-10', current_date), -- 'tri lrt gauge'
        (0x848a5564158d84b8a8fb68ab5d004fae11619a54, 1.00, date'2023-04-12', date'2024-02-13'), -- 'tri pool'
        (0x848a5564158d84b8a8fb68ab5d004fae11619a54, 2.00, date'2024-02-13', date'2024-03-10'), -- 'tri pool'
        (0x848a5564158d84b8a8fb68ab5d004fae11619a54, 1.00, date'2024-03-10', current_date), -- 'tri pool'
        
        (0x4afdb1b0f9a56922e398d29239453e6a06148ed0, 1.00, date'2023-04-12', current_date), -- 'rsweth pendle yt'
        (0x1729981345aa5cacdc19ea9eeffea90cf1c6e28b, 3.00, date'2023-04-12', current_date), -- 'rsweth pendle lp'
        
        (0x278cfb6f06b1efc09d34fc7127d6060c61d629db, 2.00, date'2023-04-12', date'2024-03-02'), -- 'crv weeth'
        (0x0bfb387b87e8bf173a10a7dcf786b0b7875f6771, 1.00, date'2024-03-02', current_date),  -- 'crv weeth gauge'
        (0x278cfb6f06b1efc09d34fc7127d6060c61d629db, 2.00, date'2023-04-12', date'2024-03-02'), -- 'crv weeth'
        (0x0bfb387b87e8bf173a10a7dcf786b0b7875f6771, 1.00, date'2024-03-02', current_date),  -- 'crv weeth gauge'
        
        (0xA2306Ce8e7B747BdaB363E0e954fcaaCc6A8Cc15, 1.00, date'2023-09-18', date'2023-09-19'), -- mav 42'
        (0xA2306Ce8e7B747BdaB363E0e954fcaaCc6A8Cc15, 2.00, date'2023-09-19', date'2023-10-02'), -- mav 42'
        (0xA2306Ce8e7B747BdaB363E0e954fcaaCc6A8Cc15, 1.00, date'2023-10-02', date'2023-12-31'), -- mav 42'
        (0x328344c5ba9256c4f87e1d2118109cc469591294, 1.00, date'2023-04-12', date'2023-10-30'), -- mav 74'
        (0x328344c5ba9256c4f87e1d2118109cc469591294, 2.00, date'2023-10-30', date'2023-12-31'), -- mav 74'
        (0x328344c5ba9256c4f87e1d2118109cc469591294, 1.00, date'2023-12-31', current_date), -- mav 74'
        (0x8fdaeae0b2e9d8b437c1f3b3ece97c92e883acaf, 1.00, date'2023-04-12', date'2024-01-30'), -- mav 89'
        (0x8fdaeae0b2e9d8b437c1f3b3ece97c92e883acaf, 2.00, date'2024-01-30', date'2024-02-29'), -- mav 89'
        (0x8fdaeae0b2e9d8b437c1f3b3ece97c92e883acaf, 1.00, date'2024-02-29', current_date), -- mav 89'
        (0x3b55d7d1bf24d8f1f370018d59c5deac5b06d330, 1.00, date'2023-04-12', current_date), -- mav 88'
        (0x4650c64a8136f7bc2616a524cb44cfb240e33a40, 1.00, date'2023-04-12', date'2024-02-13'), -- mav 92'
        (0x4650c64a8136f7bc2616a524cb44cfb240e33a40, 2.00, date'2024-02-13', date'2024-03-14'), -- mav 92'
        (0x4650c64a8136f7bc2616a524cb44cfb240e33a40, 1.00, date'2024-03-14', current_date), -- mav 92'
        
        (0x30ea22c879628514f1494d4bbfef79d21a6b49a2, 1.00, date'2023-04-28', date'2023-09-29'), -- uni sweth
        
        (0x846a4566802c27eac8f72d594f4ca195fe41c07a, 1.00, date'2023-04-28', current_date), -- bunni sweth
        (0x05058071e3e799f0c6341f44843636e7c441c1fb, 1.00, date'2024-01-01', date'2024-02-13'), -- bunni rsweth
        (0x05058071e3e799f0c6341f44843636e7c441c1fb, 2.00, date'2024-02-13', date'2024-03-16'), -- bunni rsweth
        (0x05058071e3e799f0c6341f44843636e7c441c1fb, 1.00, date'2024-10-02', current_date) -- bunni rsweth
    ) as miles(token, multiplier, start_time, end_time)
),
balances as (
    select * from query_3489828
    -- where wallet in (
    --     0x364F7Fd945B8c76C3C77d6ac253f1fEa3B65E00d
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
        wallet,
        sum(amt_cumulative*earning_seconds*multiplier*4/(24*60*60)) as total_pearl_points,
        sum(amt*mint_flag*40) as mint_pearl_points,
        sum(amt_cumulative*earning_seconds*multiplier*4/(24*60*60))+sum(amt*mint_flag*40) as all_pearls,
        min(evt_block_time) as first_interaction
    from math 
    group by 1
)

select
    rank() over(order by all_pearls desc) as pearl_rank,
    * 
from aggregated 
order by all_pearls desc


-- select * from math
