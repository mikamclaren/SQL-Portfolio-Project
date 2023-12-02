select *
from Projects..CovidDeaths
where continent is not null
order by 3,4


--select *
--from Projects..CovidVaccinations
--order by 3,4

-- Select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Projects..CovidDeaths
order by 1,2

--Looking at the total cases vs total deaths
--Shows the likelihoood of dying if you contract Covid in your country
select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from Projects..CovidDeaths
where continent is not null
where location like '%states%'
order by 1,2


--Looking at the total cases vs the population
--Shows what percentage of population got Covid
select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
from Projects..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2


--countries with the highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from Projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--Showing the countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Projects..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


--Showing the continents with the highest death cont per population
--This will  group by continent, but the numbers will not be as accurate as in the above
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
--if you remove date from the first line below and comment out "group by date" you will get the world total stats

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
from Projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--Looking at total population vs vaccinations
Select *
from Projects..CovidDeaths dea
join Projects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date


--this casts an error due to the third line below because you cannot use a newly created column to do calculations on. See 'Create CTE' below
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
join Projects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3



--Create CTE (order by clause cannot be in the CTE, so it has been commented out)
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
join Projects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac





--Temp Table

Drop table if exists #PercentPopulationVaccinated -- add drop table if exists so you can continually make updates to the table without creating an already exists error
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
join Projects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations (cannot use order by clause in views either)

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
join Projects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


Select *
from PercentPopulationVaccinated


