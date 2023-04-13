SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4


-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
ORDER BY 1,2


--Looking at the total cases vs total deaths
-- shows the likelihood of dying if you contract covid in India
Select location, date, total_cases, total_deaths, 
(CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage --(total_deaths/total_cases) 
FROM PortfolioProject..CovidDeaths  
WHERE location like '%india%'
and continent is not null
ORDER BY 1,2


--looking at the total cases vs population
--shows what percentage of population has got Covid 
Select location, date, population, total_cases,
(CAST(total_deaths as float)/CAST(population as float))*100 as PercentPopulationInfected --(total_deaths/total_cases) 
FROM PortfolioProject..CovidDeaths  
WHERE location like '%india%' and 
continent is not null
ORDER BY 1,2 


--looking at contries with the highest infection rate compared to population
Select location, population, Max(total_cases) as HeigestInfectionCount,
MAX(CAST(total_deaths as float)/CAST(population as float))*100 as PercentPopulationInfected --(total_deaths/total_cases) 
FROM PortfolioProject..CovidDeaths  
--WHERE location like '%india%' and continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Showing the countries with the highest death count per population
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
--WHERE location like '%india%' 
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing the continets with the highest death counts
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
--WHERE location like '%india%' 
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS
Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths   
--WHERE location like '%india%'
WHERE continent is not null and new_cases <> 0 and new_deaths <> 0 --to avoid division by zero
--GROUP BY date
ORDER BY 1,2



--looking at totalpopulation vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations ))
	OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--partion by location and then ordering by date and location
--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USING CTE

With PopsVsVac (Continent, location, date, population, new_vaccinations ,RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations ))
	OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--partion by location and then ordering by date and location
--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopsVsVac



--USING TEMP Table

DROP Table if exists #PercentPopulationVaccinated --when edting doesn't throw an error, deletes the table and creates it again
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinaitons numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations ))
	OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--partion by location and then ordering by date and location
--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualization

USE PortfolioProject
GO
CREATE OR ALTER VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations ))
	OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--partion by location and then ordering by date and location
--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
