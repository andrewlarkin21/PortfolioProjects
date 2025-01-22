SELECT *
FROM
  portfolio-448503.Covid.Coviddeaths
ORDER BY
  3, 4

SELECT *
FROM
  portfolio-448503.Covid.CovidVaccinations
ORDER BY
  3, 4

# Select Data we are going to be using
# Select Location, date, total_cases, new_cases, total_deaths, population

SELECT
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population,
FROM
  portfolio-448503.Covid.Coviddeaths
ORDER BY
  1, 2

# Looking at Total cases vs Total Deaths
# Shows likleyhood of dying if you contract covid in your country

SELECT
  location, 
  date, 
  total_cases,  
  total_deaths,
  (total_deaths/total_cases)*100 AS DeathPercentage
FROM
  portfolio-448503.Covid.Coviddeaths
WHERE
  location = 'United States'
ORDER BY
  1, 2

# Looking at Total_cases vs Population
# Shows what percentage of population got Covid

SELECT
  location, 
  date, 
  total_cases,  
  population,
  (total_cases/population)*100 AS PercentageAffected
FROM
  portfolio-448503.Covid.Coviddeaths
WHERE
  location = 'United States'
ORDER BY
  1, 2

# Looking at countries with highest infection rate compared to population

SELECT
  location, 
  population, 
  MAX(total_cases) AS HighestInfectionCount,   
  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM
  portfolio-448503.Covid.Coviddeaths
GROUP BY 
  location,
  population
ORDER BY
  PercentPopulationInfected DESC

# Show country with highest death count per population

SELECT
  location,
  MAX(total_deaths) AS TotalDeathCount,   
FROM
  portfolio-448503.Covid.Coviddeaths
WHERE
  continent is not null
GROUP BY 
  location
ORDER BY
  TotalDeathCount DESC

# Show continent with highest death count per population

SELECT
  location,
  MAX(total_deaths) AS TotalDeathCount,   
FROM
  portfolio-448503.Covid.Coviddeaths
WHERE
  continent is null
GROUP BY 
  location
ORDER BY
  TotalDeathCount DESC

# Global Numbers

SELECT
  date, 
  SUM(new_cases) AS total_cases,  
  SUM(cast(new_deaths as int)) AS total_deaths,
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM
  portfolio-448503.Covid.Coviddeaths
WHERE
  continent is not null
GROUP BY
  date
ORDER BY
  1, 2

SELECT 
  SUM(new_cases) AS total_cases,  
  SUM(cast(new_deaths as int)) AS total_deaths,
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM
  portfolio-448503.Covid.Coviddeaths
WHERE
  continent is not null
ORDER BY
  1, 2

# Looking at Total Population vs Vaccinations

SELECT *
FROM
  portfolio-448503.Covid.CovidVaccinations dea
  JOIN portfolio-448503.Covid.Coviddeaths vac
  ON dea.location = vac.location
  AND dea.date = vac.date

SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM
  portfolio-448503.Covid.CovidVaccinations vac
JOIN portfolio-448503.Covid.Coviddeaths dea
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent is not null
ORDER By
  2,3

# USE CTE

WITH PopvsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM
  portfolio-448503.Covid.CovidVaccinations vac
JOIN portfolio-448503.Covid.Coviddeaths dea
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM
  PopvsVacc

# Temp Table
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM
  portfolio-448503.Covid.CovidVaccinations vac
JOIN portfolio-448503.Covid.Coviddeaths dea
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent is not null
ORDER BY
  2,3

# VIEW
CREATE VIEW
  PercentPopulationVaccinated AS
  SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM
  portfolio-448503.Covid.CovidVaccinations vac
JOIN portfolio-448503.Covid.Coviddeaths dea
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent is not null
