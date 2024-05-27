SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
where location = 'Nigeria'
order by 1,2

SELECT location, date, total_cases, cast(total_deaths as int) , (total_deaths/total_cases)*100
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
where location = 'Nigeria'
order by 1,2

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

SELECT location, population, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null 
group by location, population
order by TotalDeathCount desc


SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

SELECT date,  sum(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths --sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- where location = 'Nigeria'
where continent is not null
group by date
order by 1,2

-- CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as rollingPeopleVaccinated
 --(rollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as death
full outer Join PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	And death.date = vac.date
where death.continent is not null
--order by 2,3
)
Select *, (rollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

insert into  #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as rollingPeopleVaccinated
 --(rollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as death
full outer Join PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	And death.date = vac.date
 --where death.continent is not null
--order by 2,3


Select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Create view for a later visualization

Create view PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as rollingPeopleVaccinated
 --(rollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as death
full outer Join PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	And death.date = vac.date
where death.continent is not null
--order by 2,3