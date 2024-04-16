/*
Problem Statements
1. For Each State which district is having highest confirmed cases.
2. For the Month with highest cases what was “Cured to Confirmed Ratio” of state with 
highest deaths. 
3. List top 5 districts in which least number of deaths occurred (greater than zero).
4. Which state had highest percentage of deceased cases?
5. Which Month shows highest number of New Cases (Represent month as Jan, feb not 
as 1, 2)?
6. For Each State in which month ratio of cured to confirmed was least (greater than 
0)?
7. For each State which District had min Confirmed Delta Cases
8. How Many Deaths Occurred for State codes [“AR”, “CT”,” BR “, “DL”, “KA”,” MH”, 
“UP”] in the month of May.
9. Find out top 20 Districts with best recovery rate for Delta Cases
10. For the state of Maharashtra, Gujarat and Goa List down top 2 districts with highest 
overall recovery rate (Normal + Delta)
*/

-- 1. For Each State which district is having highest confirmed cases.

use covidanalysis;

select * from detailed_numbers;

select state,district,confirmed,rank() over (partition by state order by confirmed desc) from detailed_numbers n;

select * from (
select state,district,confirmed,rank() over (partition by state order by confirmed desc) as Ranker from detailed_numbers n
) as RankerTable
where Ranker=1;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 2. For the Month with highest cases what was “Cured to Confirmed Ratio” of state with 
-- highest deaths. 

-- finding state with highest deaths. :- Maharashtra
select state,sum(death)
from daily_cases
group by state
order by sum(death) desc
limit 1;

-- Post running the above query we know that state with highest deaths. is in state of :- Maharashtra

-- finding Month with highest cases

select *,MONTH(STR_TO_DATE(date, '%d-%m-%Y')) AS Month
from daily_cases;                                                       -- ignore this,its for understanding purpose only

SELECT MONTH('2020-01-30') AS Month;     -- ignore this,its for understanding purpose only

select Month,sum(total_confirmed_cases) from
(select *,MONTH(STR_TO_DATE(date, '%d-%m-%Y')) AS Month
from daily_cases) as MonthExtractionTable
group by Month
order by sum(total_confirmed_cases) desc
limit 1
;
--  Post running the above query we get 7 as month with highest confirmed cases


-- Did Maharashtra record the highest cases in 7th month? or was it someone else? 
select state,sum(death) from
(
select State,Month,death from
(select state,death, MONTH(STR_TO_DATE(date, '%d-%m-%Y')) AS Month 
 from daily_cases) as Table1
 where month = 7
 ) as Table2
 group by state
 order by sum(death) desc
 ;
-- Post running the above query we can say :- Yes,Maharashtra had highest deaths in 7th month


 
-- For the Month with highest cases what was “Cured to Confirmed Ratio” of state with highest deaths.  

select * from daily_cases;                                              -- ignore this,its for understanding purpose only
 
 select state,sum(cured),sum(confirmed),sum(cured)/sum(confirmed) as 'Cured to Confirmed Ratio'  from
 (select state,`Cured/Discharged/Migrated` as 'Cured',`Total_Confirmed_cases` as 'Confirmed', MONTH(STR_TO_DATE(date, '%d-%m-%Y')) AS Month 
 from daily_cases) as Table1
 where Month=7 and state='Maharashtra'
 group by state
 ;

-- Final Answer From Above Query:- Maharashtra	4593201	8191488	0.5607

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------------

-- 3. List top 5 districts in which least number of deaths occurred (greater than zero).

select district from detailed_numbers;

select distinct(district) from detailed_numbers;


select district ,deceased
from detailed_numbers
where deceased<>0
order by deceased
limit 5;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 4. Which state had highest percentage of deceased cases?

select state,((sum(deceased)/sum(confirmed))*100) as 'Percentage of deceased cases'
from detailed_numbers
group by state
order by ((sum(deceased)/sum(confirmed))*100) desc
limit 1;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Which Month shows highest number of New Cases (Represent month as Jan, feb not as 1, 2)?

select Monthh,sum(`New cases`) from
(select *,substr(monthname(str_to_date(date,'%d-%m-%y')),1,3) as `Monthh` from daily_cases) as Table1
group by Monthh
order by sum(`New cases`) desc
limit 1
;


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 6. For Each State in which month ratio of cured to confirmed was least (greater than 0)?



select state,
        Month,
        `Ratio of Cured/Confirmed` from
(select 
		*,
        dense_rank() over (partition by state order by `Ratio of Cured/Confirmed`) as 'DenseRank'
from
(select state,
        Month,
        `Ratio of Cured/Confirmed`
        from
(select 
		state,
        Month,
        sum(`Cured/Discharged/Migrated`) as 'Cured',
        sum(`Total_Confirmed_cases`) as 'Confirmed', 
        sum(`Cured/Discharged/Migrated`) * 100 / sum(`Total_Confirmed_cases`) as 'Ratio of Cured/Confirmed'
        from
				(select *,monthname(str_to_date(date,'%d-%m-%y')) as `Month` from daily_cases) as Table1
group by state,Month
order by state,sum(`Cured/Discharged/Migrated`) * 100 / sum(`Total_Confirmed_cases`)) 
as Table2
where `Ratio of Cured/Confirmed` <> 0) as Table3) as Table4
where DenseRank=1
;

 

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 7. For each State which District had min Confirmed Delta Cases

select * from
 (select 
		state,
        district,
        delta_confirmed,
        dense_rank() over(partition by state order by delta_confirmed) as DenseRanker
from detailed_numbers)
as Table1
where DenseRanker= 1;

-- if we dont consider zero deltaConfirmed districts 
select 
		state,
        district,
        delta_confirmed
from
(select 
		*,
	   dense_rank() over(partition by state order by delta_confirmed) as DenseRanker
from
(select 
		state,
        district,
        delta_confirmed
from detailed_numbers
where delta_confirmed<>0) 
as Table1)
as Table2
where DenseRanker=1
;

-- --------------------------------------------------------------------------------------------------------------------------------------------
--  8. How Many Deaths Occurred for State codes [“AR”, “CT”,” BR “, “DL”, “KA”,” MH”, “UP”] in the month of May.

select * from detailed_numbers;

-- APPROACH 1:- hardcoded way  
/*
“AR”   Arunachal Pradesh
“CT”   Chhattisgarh
”BR“   Bihar
“DL”   Delhi
“KA”   Karnataka
”MH”   Maharashtra
“UP”   Uttar Pradesh
*/

select 
       state,
       sum(death)
from 
daily_cases
where state in ('Arunachal Pradesh','Chhattisgarh','Bihar','Delhi','Karnataka','Maharashtra','Uttar Pradesh')
      and monthname(str_to_date(date,'%d-%m-%y'))='May'
group by state
;


--  APPROACH 2:- By joining tables;


-- step 1 
select * from detailed_numbers;

-- step 2
select distinct(state) from detailed_numbers dn where state_code in ('AR', 'CT', 'BR', 'DL', 'KA', 'MH', 'UP');

-- step 3
select dc.date,dc.state,death from
(select distinct(state) from detailed_numbers dn where state_code in ('AR', 'CT', 'BR', 'DL', 'KA', 'MH', 'UP')) 
as Table1
inner join
daily_cases dc
on Table1.state = dc.state
;

-- step 4

select dc.date,dc.state,death from
(select distinct(state) from detailed_numbers dn where state_code in ('AR', 'CT', 'BR', 'DL', 'KA', 'MH', 'UP')) 
as Table1
inner join
daily_cases dc
on Table1.state = dc.state
where date like '__-05-2020'
;

-- step 5
select dc.state,sum(death) as `Deaths in May` from
(select distinct(state) from detailed_numbers dn where state_code in ('AR', 'CT', 'BR', 'DL', 'KA', 'MH', 'UP')) 
as Table1
inner join
daily_cases dc
on Table1.state = dc.state
where date like '__-05-2020'
group by state
;


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 9. Find out top 20 Districts with best recovery rate for Delta Cases

select district,delta_recovered*100/delta_confirmed as `Recovery_Rate` from detailed_numbers dn WHERE Delta_Confirmed
order by Recovery_Rate desc
limit 20
;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 10. For the state of Maharashtra, Gujarat and Goa List down top 2 districts with highest overall recovery rate (Normal + Delta) 

-- step1 
select state,district,confirmed,delta_confirmed,recovered,delta_recovered,
	   (recovered+delta_recovered)*100/(confirmed+delta_confirmed) as `Overall_Recovery_Rate(Normal+Delta)`
from detailed_numbers
where state in ('Maharashtra', 'Gujarat','Goa')
;


-- step2 
select * from
(Select *,dense_rank() over(partition by state order by `Overall_Recovery_Rate(Normal+Delta)` desc ) as `DenseRanker` from
(select state,district,confirmed,delta_confirmed,recovered,delta_recovered,
	   (recovered+delta_recovered)*100/(confirmed+delta_confirmed) as `Overall_Recovery_Rate(Normal+Delta)`
from detailed_numbers where state in ('Maharashtra', 'Gujarat','Goa')) as Table1) as Table2
where DenseRanker in (1,2)
;

-- --------------------------------------------------------------------------------------------------------------------------------------------










