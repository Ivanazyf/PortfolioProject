-- select data that we are going to be using
use DataProject;

select continent, location, date1, total_cases, new_cases, total_deaths, population 
from CovidDeath
where continent != ''
order by 1,2;

-- looking at total cases VS total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date1, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from CovidDeath
where location like '%states%'
and continent != ''
order by 1,2;

-- looking at total cases VS population
-- shows what percentage of population got covid
select location, date1, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeath
where location like '%states%'
and continent != ''
order by 1,2;

-- looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeath
where continent != ''
group by 1,2
order by PercentPopulationInfected desc;

-- showing countries with Highest Death Count per population
select location, max(total_deaths) as TotalDeathCount from CovidDeath
where continent != ''
group by 1
order by TotalDeathCount desc;

-- showing countries with total Death Count per population
select location, sum(new_deaths) as TotalDeathCount from CovidDeath
where continent = '' and location not in ('World','European Union','International') and location not like '%income'
group by 1
order by TotalDeathCount desc;

-- let's break things down by continent
-- showing continents with the highest death count per population
select continent, max(total_deaths) as TotalDeathCount 
from CovidDeath
where continent != '' 
group by 1
order by TotalDeathCount desc;

-- Global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercent
from CovidDeath
where continent != ''
-- group by date1
order by 1,2;


-- looking at total population VS vaccinations

-- Use CTE (Common Table Expression)
   --  a one-time result set, meaning a temporary table that only exists for the duration of the query.
With popVSvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date1, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location Order by dea.location,dea.date1)
as RollingPeopleVaccinated  -- partition by: similar to group by, order by: add number up one by one
from CovidDeath dea
join CovidVaccination vac
     on dea.location = vac.location and dea.date1 = vac.date1
where dea.continent != ''
)
select *, (RollingPeopleVaccinated/Population)*100
from popVSvac

-- Creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date1, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location Order by dea.location,dea.date1)
as RollingPeopleVaccinated  -- partition by: similar to group by, order by: add number up one by one
from CovidDeath dea
join CovidVaccination vac
     on dea.location = vac.location and dea.date1 = vac.date1
where dea.continent != ''

-- For Tableau Visualization
-- 3.
-- looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeath
where continent != ''
group by 1,2
order by PercentPopulationInfected desc;

-- 4.
select location, population, date1, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeath
group by 1,2,3
order by PercentPopulationInfected desc;

select location from CovidDeath
where location = 'China';



