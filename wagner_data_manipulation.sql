-- TEAM STATS --

-- How many wins/losses do we have all time when we steal more than two bases? Less than two bases?
with two_or_more as ( 
select "W/L", count(*) as two_or_moreSBs
FROM game_stats
where "SB" > 1 
group by "W/L"
), less_than_two as(
select "W/L", count(*) as less_than_twoSBs
FROM game_stats
where "SB" < 2  
group by "W/L"
)
select two_or_more."W/L", two_or_more.two_or_moreSBs, less_than_two.less_than_twoSBs
from two_or_more
left join less_than_two on two_or_more."W/L" = less_than_two."W/L"

--  Batting Average on Balls in Play (BABIP) per game and run result
select "Date",
case when (("AB" - "K" - "HR" + "SF")*1.0) = 0 THEN NULL
else (("H" - "HR")*1.0) / (("AB" - "K" - "HR" + "SF")*1.0) end as BABIP,
case when "R" >= 5 then '5 runs or more' else 'Less than 5 runs' end as Runs_scored
from game_stats
group by "Date", 2, 3 
order by "Date" desc

-- Strikeout and Walk Percentage for hitters
select EXTRACT(Year from (cast("Date" as TIMESTAMP))) as Year,
AVG((("K" * 1.0) / (("AB" + "BB" + "SF" + "IBB" + "HBP" + "SH")*1.0))) as K_percentage,
AVG(((("BB"+ "IBB") * 1.0) / (("AB" + "BB" + "SF" + "IBB" + "HBP" + "SH")*1.0))) as BB_percentage,
sum(case when "W/L" = 'W' then 1 else 0 end) Wins
from game_stats
GROUP BY 1
order by Year

-- Winning % based on K's
with less_than_six as(
select ((sum(case when "W/L" = 'W' then 1 else 0 end)*1.0)/ (count("W/L")*1.0)) as winning_percent_less6ks
from game_stats
where "K" < 6
), six_or_more AS(
select ((sum(case when "W/L" = 'W' then 1 else 0 end)*1.0)/ (count("W/L")*1.0)) as winning_percent_6ormoreks
from game_stats
where "K" > 5
)

select less_than_six.*, six_or_more.* 
from less_than_six
cross JOIN six_or_more



--INDIVIDUAL STATS --

-- Find weighted on base percentage for each player
select "Player", ((0.690 * "BB" + 0.722 * "HBP" + 0.888 * ("H" - "2B" + "3B"+ "HR") + 1.271 * "2B" + 1.616 * "3B" +
2.101 * "HR") / ("AB" + "BB" + "SF" + "HBP")) as wOBA, "AB", "Year"
from hitting_stats
group by "Player", "Year", 2, "AB"
order by "Year" desc, "AB" desc, "woba" desc
limit 135

-- Calculate Isolated Power for each Player
select "Player", ("SLG%" - "AVG") as ISO, "AB", "Year"
from hitting_stats
group by "Player", "Year", 2, "AB"
order by "Year" desc, "AB" desc, ISO desc

-- Calculate Batting Average on Balls in Play (BABIP)
select "Player", 
case when (("AB" - "SO" - "HR" + "SF")*1.0) = 0 THEN NULL
else (("H" - "HR")*1.0) / (("AB" - "SO" - "HR" + "SF")*1.0) end as BABIP, 
"AB", 
"Year"
from hitting_stats
group by "Player", "Year", 2, "AB"
order by "Year" desc, "AB" desc, BABIP desc

-- Strikeout and Walk Percentage per hitter
select 
"Player",
AVG((("SO" * 1.0) / (("AB" + "BB" + "SF" + "HBP" + "SH")*1.0))) as K_percentage,
AVG(((("BB") * 1.0) / (("AB" + "BB" + "SF" + "HBP" + "SH")*1.0))) as BB_percentage
from hitting_stats
GROUP BY 1
order by "Player", K_percentage, BB_percentage

-- Strikeout and Walk Percentage per pitcher
select 
"Player",
AVG((("SO" * 1.0) / (("AB" + "BB" + "HBP" + "SHA" + "SFA")*1.0))) as K_percentage,
AVG(((("BB") * 1.0) / (("AB" + "BB" + "HBP" + "SHA" + "SFA")*1.0))) as BB_percentage
from indi_pitch_stats
GROUP BY 1
order by "Player", K_percentage, BB_percentage