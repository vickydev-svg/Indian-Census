select * from PROJECT.dbo.Data1;
select * from PROJECT.dbo.Data2;

--dataset for jharkhand and bihar
select * from PROJECT..Data1 where state in ('Jharkhand', 'Bihar');
select * from PROJECT..Data2 where state in ('Jharkhand', 'Bihar');

--AGGREGATE FUNCTION:
--number of rows in dataset
select count(*) from PROJECT..Data1;
select count(*) from PROJECT..Data2;

--total population of India in database 2
select SUM(Population) from PROJECT..Data2;

--total sex ratio in data base1
select SUM(Sex_Ratio) from PROJECT..Data1;

--maximum population
select State, Population from PROJECT..Data2 where Population=(select MAX(Population)  from PROJECT..Data2);
--max sex ratio
select State, Sex_Ratio from PROJECT..Data1 where Sex_Ratio=(select round(MAX(Sex_Ratio),0)  from PROJECT..Data1);

--minimum population
select State, Population from PROJECT..Data2 where Population=(select MIN(Population)  from PROJECT..Data2);
--minimum sex ratio
select State, Sex_Ratio from PROJECT..Data1 where Sex_Ratio=(select round(MIN(Sex_Ratio),0)  from PROJECT..Data1);

--average population
select AVG(Population)  from PROJECT..Data2;
--average growth
select AVG(Growth)*100 as averageGrowth from PROJECT..Data1;

--average growth of each state using group by and order by
select State,AVG(Growth)*100 as averageGrowth from PROJECT..Data1 group by State order by averageGrowth desc;

--average literacy rate of state of having literacy rate more than 80 using group by and order by
select State, round(AVG(Literacy),0) as averageLiteracyRatio from PROJECT..Data1 group by State having round(AVG(Literacy),0)>80 order by 2 desc;

--top three states showing highest growth ratio
select top 3 state, AVG(Growth)*100 as averageGrowth from PROJECT..Data1 group by state order by 2 desc;
select state, AVG(Growth)*100 as averageGrowth from PROJECT..Data1 group by state order by 2 desc limit 3;

--bottom three states showing lowest sex ratio ratio
select top 3 state, AVG(Sex_Ratio) as avg_sex_ratio from PROJECT..Data1 group by state order by 2;

--union
select distinct state, Literacy from PROJECT..Data1 
union
select distinct state, Population from PROJECT..Data2;

-- top and bottom 3 states in literacy state
drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union opertor
select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


-- states starting with letter a
select distinct state from project..data1 where lower(state) like '[a b]%[h r]';
-- state with letter a
select distinct state from project..data1 where lower(state) like '_a%'; 


-- joining both table
--total males and females
select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project..data1 a inner join project..data2 b on a.district=b.district ) c) d
group by d.state;

-- total literacy rate
select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from project..data1 a 
inner join project..data2 b on a.district=b.district) d) c
group by c.state

-- population in previous census
select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..data1 a inner join project..data2 b on a.district=b.district) d) e
group by e.state)m


-- population vs area
select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..data1 a inner join project..data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (select '1' as keyy,z.* from (
select sum(area_km2) total_area from project..data2)z) r on q.keyy=r.keyy)g

--window 
output top 3 districts from each state with highest literacy rate
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..data1) a
where a.rnk in (1,2,3) order by state;