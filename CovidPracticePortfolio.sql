SELECT *
FROM [Porfolio Project]..CovidDeaths
WHERE continent IS NULL
ORDER BY 3,4

--SELECT *
--FROM [Porfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Porfolio Project]..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if contracting covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM [Porfolio Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentGotCovid
FROM [Porfolio Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--looking at countries with highest infection rate compared to Population
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Porfolio Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Porfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--BROKEN DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Porfolio Project]..CovidDeaths
WHERE continent IS NOT NULL 
AND location NOT LIKE ('%Income%')
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Porfolio Project]..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT  date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM [Porfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaxCount
--, (RollingVaxCount/population)*100
FROM [Porfolio Project]..CovidDeaths DEA
JOIN [Porfolio Project]..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--USING CTE
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaxCount)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaxCount
--, (RollingVaxCount/population)*100
FROM [Porfolio Project]..CovidDeaths DEA
JOIN [Porfolio Project]..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingVaxCount/Population)*100
FROM PopVsVac


--USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaxCount numeric)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaxCount
--, (RollingVaxCount/population)*100
FROM [Porfolio Project]..CovidDeaths DEA
JOIN [Porfolio Project]..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
SELECT *, (RollingVaxCount/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaxCount
--, (RollingVaxCount/population)*100
FROM [Porfolio Project]..CovidDeaths DEA
JOIN [Porfolio Project]..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


