/* 
Working with SQL to answer stakeholder questions
*/
-- Unifying all tables

SELECT *
FROM dbo.[2018]
union
SELECT *
FROM dbo.[2019]
union
SELECT *
FROM dbo.[2020];

-- creating cte
-- Looking at hotel revenue growth by year

with hotels as (
SELECT *
FROM dbo.[2018]
UNION
SELECT *
FROM dbo.[2019]
UNION
SELECT *
FROM dbo.[2020])

SELECT arrival_date_year, hotel, round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2) as revenue
FROM hotels
GROUP BY arrival_date_year, hotel;

 -- Working with joins

with hotels as (
SELECT *
FROM dbo.[2018]
union
SELECT *
FROM dbo.[2019]
union
SELECT *
FROM dbo.[2020])

SELECT *
FROM hotels
LEFT JOIN MarketSegment
ON hotels.market_segment = MarketSegment.market_segment
LEFT JOIN MealCost
ON MealCost.meal = hotels.meal