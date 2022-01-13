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
-- shows what percentage of population got covid

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

-- deaths by continent
select location, max(cast(total_deaths as int)) as totaldeathct
from coviddeaths
where continent is null
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

with popvacc (continent, location, date, population, people_fully_vaccinated, percent_of_pop_vaccinated)
as (
select cd.continent, cd.location, cd.date, cd.population, vac.people_fully_vaccinated, (people_fully_vaccinated/population)*100 as percent_of_pop_vaccinated
from coviddeaths as cd join covidvaccinations vac
	on cd.location = vac.location and cd.date = vac.date
where cd.continent is not null)
--use CTE to determine most vaxxed countries against pop
select continent, location, max(percent_of_pop_vaccinated) as top_percent
from popvacc
group by continent, location, date
order by max(percent_of_pop_vaccinated) desc

select *
from coviddeaths
where location = 'United States'