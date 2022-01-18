
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
select location, continent, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1, 2

-- looking at total cases vs Total deaths 
-- shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
from coviddeaths
where location = 'United States'
order by 1, 2


--looking at total cases vs population
-- shows what percentage of population got covid through time

select location, date, population, total_cases, (total_cases/population)*100 as casepercent
from coviddeaths
where location = 'United States'
order by 1, 2

--lookin at countries with highest infecton rate compared to population
select location, population, max(total_cases) as highestinfectionct, max((total_cases/population))*100 as percentpopinfected
from coviddeaths
group by population, location
order by percentpopinfected desc

--showing countries with highest death count per population 
select location, population, max(cast(total_deaths as int)) as totaldeathct
from coviddeaths
where continent is not null
group by location, population
order by totaldeathct desc

-- Showing continets with the highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathct
from coviddeaths
where continent is not null
group by location
order by totaldeathct desc

--global numbers
select sum(new_cases) as total_cases_worldwide, sum(cast(new_deaths as int)) as total_deaths_worldwide, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent_worldwide
from coviddeaths
where continent is not null
--group by date
order by 1, 2

--looking at total population vs vaccinations ( rolling % of population vaccinated)

select cd.continent, cd.location, cd.date, cd.population, vac.people_fully_vaccinated, (people_fully_vaccinated/population)*100 as percent_of_pop_vaccinated
from coviddeaths as cd join covidvaccinations vac
	on cd.location = vac.location and cd.date = vac.date
where cd.continent is not null --and cd.location 
order by 2, 3


-- Using CTE to look for Countries with the highest % of population Vaccinated against Covid-19. Order Highest to lowest.
with popvacc 
as (
select cd.continent, cd.location, cd.date, cd.population, vac.people_fully_vaccinated, (cast(vac.people_fully_vaccinated as int)/cd.population)*100 as [%_of_pop_vaxxxed], rn = row_number()
	OVER (Partition by cd.Location Order by (vac.people_fully_vaccinated/cd.population)*100 desc, cd.Date) 
from coviddeaths as cd join covidvaccinations vac
	on cd.location = vac.location and cd.date = vac.date
where cd.continent is not null)
select *
from popvacc 
where rn = 1
order by [%_of_pop_vaxxxed] desc

--Temp Table, included Drop Table incase of future alterations
Drop Table if exists  #PercentofUnitedStatesPopulationVaccinated
create table #PercentofUnitedStatesPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
people_fully_vaccinated numeric
)

insert into #PercentofUnitedStatesPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, vac.people_fully_vaccinated
from coviddeaths as cd join covidvaccinations vac
	on cd.location = vac.location and cd.date = vac.date
where cd.continent is not null and cd.location = 'United States'

select *, (people_fully_vaccinated/population)*100
from #PercentofUnitedStatesPopulationVaccinated

--Creating View to store data for later visualizations

create view PercentofUnitedStatesPopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, vac.people_fully_vaccinated, (cast(vac.people_fully_vaccinated as int)/cd.population)*100 as [%_of_pop_vaxxxed], rn = row_number()
	OVER (Partition by cd.Location Order by (vac.people_fully_vaccinated/cd.population)*100 desc, cd.Date) 
from coviddeaths as cd join covidvaccinations vac
	on cd.location = vac.location and cd.date = vac.date
where cd.continent is not null

Select*
from PercentofUnitedStatesPopulationVaccinated
