select * 
from CovidDeaths
where continent is not null
order by 3,4;

--select * 
--from CovidDeaths
--order by 3,4;

/* select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2; */

--1. Total Cases vs Total Deaths in India
select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,4) as Death_Percentage
from CovidDeaths
where location like('India') and continent is not null
order by 1,2;

--2. Total Cases vs Total Population
-- What Percentage of population got covid in India
select location,date,population,total_cases,round((total_cases/population)*100,2) as Covid_Percentage
from CovidDeaths
where location like('India')and  continent is not null
order by 1,2;

--3. Countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,max(round((total_cases/population)*100,2)) as Covid_Percentage
from CovidDeaths
where continent is not null
group by location,population
order by Covid_Percentage desc;



--4. Countires with highest death count 
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc;

--5. Top 5 countries with most people died
select top 10 location, sum(cast(total_deaths as int)) as Total_Deaths_In_Country
from CovidDeaths
where continent is not null
group by location 
order by Total_Deaths_In_Country desc;


--6. Top 10 countries with most Infected
select top 10 location, sum((total_cases)) as Total_Cases_In_Country
from CovidDeaths
where continent is not null
group by location 
order by Total_Cases_In_Country desc;


---BREAK THINGS BY CONTINENT

-- 1. Top Continents with most Infected

select continent, sum(total_cases)as Total_Infected_Cases_In_Continent
from CovidDeaths
where continent is not null
group by continent
order by Total_Infected_Cases_In_Continent desc;

-- 2. Top Continents with most People Died

select continent, sum(cast(total_deaths as int)) as Total_Deaths_In_Continent
from CovidDeaths
where continent is  not null
group by continent
order by Total_Deaths_In_Continent desc;


-- Breaking into global numbers
--1. Datewise percentage
select date, sum(new_cases) as total_cases, 
			sum(cast(new_deaths as int)) as total_deaths,
			sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null 
group by date
order by 1,2;

--2. Total Percentage
select  sum(new_cases) as total_cases, 
			sum(cast(new_deaths as int)) as total_deaths,
			sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null 
order by 1,2;

------       -Vaccination Table-         ------------
-- 1. Total number of people vaccinated
with PopulationvsVaccination(continent, location, date, population,new_Vaccinations, Rolling_People_Vaccinated) as
(	select d.continent, d.location,d.date, d.population, v.new_vaccinations,
	sum(convert(int, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as Rolling_People_Vaccinated
	from CovidDeaths d
	join CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
	where d.continent is not null
	--order by 2,3
)
select *, (Rolling_People_Vaccinated/population)*100 as percentage
from PopulationvsVaccination;


----Temp Table---

Drop table if exists #PercentageOfPeopleVaccinated
create table #PercentageOfPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
insert into #PercentageOfPeopleVaccinated
select d.continent, d.location,d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as Rolling_People_Vaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
select *, (Rolling_People_Vaccinated/population)*100 as percentage
from #PercentageOfPeopleVaccinated;	



----Creating Views for later visualizations---
create view PercentageOfPeopleVaccinated as
select d.continent, d.location,d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as Rolling_People_Vaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null;
--order by 2,3
select * from PercentageOfPeopleVaccinated;
