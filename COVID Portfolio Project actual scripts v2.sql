Select * From [porfolio project].dbo.coviddeath
order by 3,4


--Select * From [porfolio project].dbo.covidvacination
--order by 3,4

--Select Data that we are going to be using
Select 
Location, date, population, total_cases, new_cases, total_deaths
From [porfolio project].dbo.coviddeath
order by 1,2

-- Looking at Total Cases vs Total Death
--Shows the likehood of dying if you contract covid in your country

Select 
Location, date, population, total_cases, total_deaths, (CONVERT(float, total_deaths)/ NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage
From [porfolio project].dbo.coviddeath
Where location like '%states%'
order by 1,2


-- Looking at the Total Cases Vs Population
--shows what percentage of the population got covid

Select 
Location, date, population, total_cases, (total_cases/Population) * 100 as PercentagePopulationInfected
From [porfolio project].dbo.coviddeath
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population


 
Select 
Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as DeathPercentage
From [porfolio project].dbo.coviddeath
Where location like '%states%'
Group by Location, Population
order by 1,2

--LET'S BREAK THINGS BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [porfolio project].dbo.coviddeath
--Where location like %states%'
Where continent is null
Group by location
order by TotalDeathCount

--Showing contintents with the highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [porfolio project].dbo.coviddeath
--Where location like %states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
  (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [porfolio project].dbo.coviddeath
--Where location like '%states%'
Where continent is not null



--looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated

from [porfolio project].dbo.coviddeath dea
Join [porfolio project].dbo.covidvacination vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

	 --USE CTE

With PopvsVac (continent, Location, Date, Population, new_vaccination, RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [porfolio project].dbo.coviddeath dea
Join [porfolio project].dbo.covidvacination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccintions numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [porfolio project].dbo.coviddeath dea
Join [porfolio project].dbo.covidvacination vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- creating view to store data for later visualizations


create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [porfolio project].dbo.coviddeath dea
Join [porfolio project].dbo.covidvacination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated