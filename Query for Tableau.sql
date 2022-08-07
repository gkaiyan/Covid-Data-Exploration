--Queries for Tableau 

--1. 

SELECT 
  SUM(new_cases) AS total_cases, 
  SUM(CAST(new_deaths AS int)) AS total_deaths, 
  SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--Where location like '%states%'
WHERE continent IS NOT NULL 
ORDER BY 
1,2


  --2. 

SELECT
  location, 
  SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
--Where location like '%states%'
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY 
  location
ORDER BY 
  TotalDeathCount DESC

--3. 

SELECT 
  location, 
  population,
  MAX(total_cases) AS HighestInfectionCount,  
  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
--Where location like '%states%'
GROUP BY 
  location, 
  population
ORDER BY 
  PercentPopulationInfected DESC

--4. 

SELECT 
  location, 
  population,
  date, 
  MAX(total_cases) AS HighestInfectionCount, 
  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
--Where location like '%states%'
GROUP BY 
location, 
population, 
date
ORDER BY PercentPopulationInfected DESC