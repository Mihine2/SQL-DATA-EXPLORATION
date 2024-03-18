--Covid 19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Portfolio..CovidDeaths
Where continent is not null
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not null
order by 1,2

--Looking at total cases and total deads
--Shows likelihood of dying if we contract covid in Viet Nam
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM Portfolio..CovidDeaths
WHERE Location LIKE '%Viet%' AND continent is not null
ORDER BY 1,2

--Looking at total cases and total population
--Percentage of population infected
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Percentage_Population_Infected
FROM Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at country with highest infection case per population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as Percentage_Population_Infected
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

--Looking at country with highest total death per population
SELECT location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population)*100) as Deaths_Percentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

--Breaking down by continent
--Looking at continent with highest infection case per population
SELECT continent, MAX(total_cases) as HighestInfectionCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--GLOBAL NUMBER
SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases) as Death_percentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY [date]
ORDER BY [date]

-- JOIN STATEMENT
SELECT *
FROM Portfolio..CovidDeaths dea
JOIN  Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 

---- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN  Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN  Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent VARCHAR(50),
Location VARCHAR(50),
Date DATETIME,
Population FLOAT,
New_Vaccinations FLOAT,
RollingPeopleVaccinated FLOAT)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN  Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN  Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null 



