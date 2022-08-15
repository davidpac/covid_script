--- Selecting the table that will be used for the exploratory analysis

select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from 
	dev_david.cdeaths
order by 
	1,2

-- the chance of dying if you contract covid in each country

select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
from 
	dev_david.cdeaths
where 
	location ilike '%germany%'
order by 
	1,2
	
-- Looking at total cases vs. Population

select 
	location, 
	date, 
	total_cases, 
	population,
	max(total_cases) as highest_infection_count,
	total_deaths, 
	(total_cases /population)*100 as DeathPercentage
from 
	dev_david.cdeaths
where 
	location ilike '%germany%'
group by 
	1
order by 
	1,2

-- Looking at Countries with highest infection rate compared to population
	
select 
	location, 
	population,
	max(total_cases) as highest_infection_count,
	max((total_cases /population))*100 as population_percentage
from 
	dev_david.cdeaths
group by 
	1,2
order by
	population_percentage desc

-- Looking at Countries with Highest Death Count per Population

select 
	location, 
	max(cast(total_deaths as int)) as total_death
from 
	dev_david.cdeaths
where 
	continent is not null
group by 
	1
order by 
	total_death desc

-- Looking at Continents with Highest Death Count per Population

select 
	continent, 
	max(cast(total_deaths as int)) as total_death
from d
	ev_david.cdeaths
where 
	continent is not null
group by 
	1
order by 
	total_death desc

	
-- Global Numbers

select 
	date,
	sum(new_cases) as total_new_cases,
	sum(cast(new_deaths as int)) as total_death, 
	(sum(new_deaths)/sum(cast(new_cases as int)))*100 as death_percentage 
from 
	dev_david.cdeaths
where 
	continent is not null
group by 
	1
order by 
	1,2
	
-- Looking at Total Population vs Vaccinations
	
select 
	death.continent,
	death.location,
	death.date,
	death.population,
	vaccination.new_vaccinations,
	sum(convert(int,vaccination.new_vaccinations)) Over (Partition by death.location) as rolling_people_vaccinated
from
	dev_david.cdeaths death
join
	dev_david.cvac vaccination
on
	death.location = vaccination.location
and 
	death.date = vaccination.date
where
	death.continent is not null 
order by 
	2,3
	
--- Using CTE 

with population_vs_vaccination as (select 
	death.continent,
	death.location,
	death.date,
	death.population,
	vaccination.new_vaccinations,
	sum(convert(int,vaccination.new_vaccinations)) Over (Partition by death.location) as rolling_people_vaccinated
from
	dev_david.cdeaths death
join
	dev_david.cvac vaccination
on
	death.location = vaccination.location
and 
	death.date = vaccination.date
where
	death.continent is not null 
order by 
	2,3)
select *, (rolling_people_vaccinated/population) * 100
from population_vs_vaccination

--- Creating view

create or replace view dev_david.covid_data as(
with population_vs_vaccination as (select 
	death.continent,
	death.location,
	death.date,
	death.population,
	vaccination.new_vaccinations,
	sum(convert(int,vaccination.new_vaccinations)) Over (Partition by death.location) as rolling_people_vaccinated
from
	dev_david.cdeaths death
join
	dev_david.cvac vaccination
on
	death.location = vaccination.location
and 
	death.date = vaccination.date
where
	death.continent is not null 
order by 
	2,3)
select *, (rolling_people_vaccinated/population) * 100
from population_vs_vaccination)
