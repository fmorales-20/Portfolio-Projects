--Looking at Covid Death table

SELECT *
FROM PortfolioProject..Covids_Deaths
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..Covids_Vacinations
--ORDER BY 3,4


-- Selecting Data that we are going to use.

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covids_Deaths
ORDER BY 1,2;


--Looking at total cases vs total deaths
--Shows likelihood of dying in the United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covids_Deaths
WHERE location like '%states%'
ORDER BY 1,2;


--Looking at total cases vs population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..Covids_Deaths
WHERE location like '%states%'
ORDER BY 1,2;


--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..Covids_Deaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;


--Showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..Covids_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


--Let's break things down by continent
--Showing continentes with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..Covids_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covids_Deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


--Looking at the Covid Vacination table

SELECT *
FROM PortfolioProject..Covids_Vacinations;


--Looking at total population vs total vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covids_Deaths dea
JOIN PortfolioProject..Covids_Vacinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


--USE CTE

With PopvsVac (Continent, location,date, population, new_vaccinations, RollingPeopleVaccinated) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..Covids_Deaths dea
 JOIN PortfolioProject..Covids_Vacinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covids_Deaths dea
JOIN PortfolioProject..Covids_Vacinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covids_Deaths dea
JOIN PortfolioProject..Covids_Vacinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;


SELECT *
FROM PercentPopulationVaccinated
