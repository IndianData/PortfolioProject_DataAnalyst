--FROM PortfolioProject..CovidDeaths
--FROM PortfolioProject..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

SELECT location, MAX(total_cases) as HighestInfectionCount ,population, MAX((total_deaths/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

----GLOBAL NUMBERS

--SELECT date as Date, SUM(new_cases)as Sum_new_cases, SUM(cast(new_deaths as int)) as Sum_new_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--Where continent is not null
--Group by date
--Order by 1,2

--GLOBAL NUMBERS (Total deaths, cases and DeathPercentage)

SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

--JOINING Deaths and Vaccinations on location and date.


SELECT *
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date as Date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---WITH CTE


With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 As RollingPeopleVaccinatedPercentage
From PopvsVac

---TEMP Table
---Create Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations in Tableau
Drop view if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated