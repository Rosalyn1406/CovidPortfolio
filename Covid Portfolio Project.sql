/*
Notes: 
a) when the continent is null, it's location is in the entire continent
*/

select *
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4

-- Select Data
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths: 
-- Likelihood of dying if you contract covid 
select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as "DeathPercentage"
from PortfolioProject..CovidDeaths
where location like 'canada'
and continent is not null
order by 1,2

-- Total Cases vs Population:
-- Shows what percentage of population contracted covid
select location, date, total_cases, population, (total_cases/population)*100 as "Percentage Population Infected"
from PortfolioProject..CovidDeaths
--where location like 'canada'
order by 1,2

-- Countries with HIGHEST infection rate compared to population
select location, population, max(total_cases) as "Highest Infection Count", max((total_cases/population))*100 as "Percentage Population Infected"
from PortfolioProject..CovidDeaths
--where location like 'canada'
group by location, population
order by [Percentage Population Infected] desc

-- Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as "Total Death Count"
from PortfolioProject..CovidDeaths
--where location like 'canada'
where continent is not null
group by location
order by [Total Death Count] desc

/* Notes:
a) total_deaths is in varchar, must convert to int
b) (group by location) groups them in continent
c) Where continent is not null, they are in their own country location
*/

-- Countries/Location with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as "Total Death Count"
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by [Total Death Count] desc

-- Continent with Highest Death Count per Population
select continent, max(cast(total_deaths as int)) as "Total Death Count"
from PortfolioProject..CovidDeaths
--where location like 'canada'
where continent is not null
group by continent
order by [Total Death Count] desc

-- Global Numbers 
-- Across the world
select date, sum(new_cases) as "Total Cases", sum(cast(new_deaths as int)) as "Total Death", sum(cast(new_deaths as int))/sum(new_cases)*100 as "Death Percentage"
from PortfolioProject..CovidDeaths
-- where location like 'canada'
where continent is not null
-- group by (date)
order by 1,2 

-- Global Numbers II 
-- Total Cases across the world
select sum(new_cases) as "Total Cases", sum(cast(new_deaths as int)) as "Total Death", sum(cast(new_deaths as int))/sum(new_cases)*100 as "Death Percentage"
from PortfolioProject..CovidDeaths
-- where location like 'canada'
where continent is not null
-- group by (date)
order by 1,2 

-- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as "Rolling People Vaccinated"
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, [Rolling People Vaccinated])
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as "Rolling People Vaccinated"
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, ([Rolling People Vaccinated]/population) *100 as "Percentage of People Vaccinated In Country"
from PopVsVac

--Temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacccinations numeric,
[Rolling People Vaccinated] numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as "Rolling People Vaccinated"
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *, ([Rolling People Vaccinated]/population) *100 as "Percentage of People Vaccinated In Country"
from #PercentPopulationVaccinated

-- Maximum Percentage of People Vaccinated in Country
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as "Rolling People Vaccinated"
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE
with PopVsVac (location,population, [Rolling People Vaccinated]) 
as (
select dea.location, dea.population 
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as "Rolling People Vaccinated"
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select location, max([Rolling People Vaccinated]/population) *100 as "Maximum Percentage of People Vaccinated in Country"
from PopVsVac
group by (location)

/*
Notes:
a) Partition by location (eg: sum through Canada, when it reach another country, it will start a new sum)
b) Order by location and date to keep it organize
b) !! sum(cast(new_vaccinations as int)) -> sum(convert(int, new_vaccinations)) !!
c) Total amount of vaccination by Albania is 347702 (row 863)
d) Ratio of  maximum "Rolling People Vaccinated" to Population: How many people in that country are vaccinated 
e) Can't use column created ("Rolling People Vaccinated") to do calculation -> use CTE/Temp_table
f) Number of columns in CTE must match number of columns in select query
*/

-- Creating View to store date for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as "Rolling People Vaccinated"
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated