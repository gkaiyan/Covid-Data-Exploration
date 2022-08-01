
--looking at the tables
SELECT * FROM covid_deaths
SELECT * FROM covidvaccinations

SELECT 
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM covid_deaths
ORDER BY 1,2 

--total cases Vs total deaths
--shows likelihood of dying if one contracted Covid in Singapore
SELECT 
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  total_deaths/total_cases *100 AS death_percentage
FROM covid_deaths
WHERE location LIKE '%Sing%'
ORDER BY 1,2 

--total cases Vs population
--percentage of population that got Covid in Singapore
SELECT 
  location,
  date,
  total_cases,
  population,
  total_cases/population *100 AS percentage_positive
FROM covid_deaths
WHERE location LIKE '%Sing%'
AND continent IS NOT NULL
ORDER BY 1,2 

--looking at countries with highest infection rate compared to population
SELECT 
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  MAX(total_cases)/population *100 AS infection_percentage
FROM covid_deaths
GROUP BY 
  location, 
  population
ORDER by infection_percentage DESC

--showing the countries with the highest death count in population
SELECT 
  location,
  population,
  MAX(CAST(total_deaths AS int)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- BREAKING THINGS DOWN BY CONTINENT

--continents with highest death count in population
SELECT 
  continent,
  population,
  MAX(CAST(total_deaths AS int)) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
GROUP BY continent
ORDER BY total_death_count DESC

--GLOBAL NUMBERS

--total number of cases, total number of deaths and percentage of population that contracted Covid 
SELECT 
  SUM(new_cases) AS total_cases,
  SUM(CAST(total_deaths AS int)) AS total_deaths,
  SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
--WHERE location LIKE '%Sing%'
WHERE continent IS NOT NULL 
ORDER BY 
  total_cases,
  total_deaths

--total population vs vaccinations
-- percentage of people who had one covid vaccination
SELECT 
  covid_deaths.continent,
  covid_deaths.location,
  covid_deaths.date,
  covid_deaths.population,
  covid_vac.new_vaccinations
  SUM(CAST(covid_vac.new_vaccinations AS BIGINT)) OVER (
    PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date
  ) AS rolling_total_vaccinations
FROM covid_deaths AS covid_deaths
JOIN covidvaccinations AS covid_vac
  ON covid_deaths.location = covid_vac.location
 AND covid_deaths.date = covid_vac.date
WHERE covid_deaths.continent IS NOT NULL
ORDER BY 
  coviddeaths.location,
  coviddeaths.date

--using CTE to perform calculation on partition by 
WITH pop_vs_vacc AS (
  SELECT 
    covid_deaths.continent,
    covid_deaths.location,
    covid_deaths.date,
    covid_deaths.population,
    covid_vac.new_vaccinations
    SUM(CAST(covid_vac.new_vaccinations AS BIGINT)) OVER (
      PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date
    ) AS rolling_total_vaccinations
  FROM covid_deaths AS covid_deaths
  JOIN covidvaccinations AS covid_vac
    ON covid_deaths.location = covid_vac.location
   AND covid_deaths.date = covid_vac.date
  WHERE covid_deaths.continent IS NOT NULL
)

SELECT 
* ,
rolling_total_vaccinations/population * 100 AS percent_pop_vaccinated
FROM pop_vs_vacc

--CREATING TEMP TABLE 

--create temp temp to perform calculation on partition by 
DROP TABLE IF EXIST percent_pop_vacc
CREATE TABLE percent_pop_vacc (
  continent VARCHAR(255),
  location VARCHAR(255),
  date DATETIME,
  population NUMERIC,
  new_vaccinations NUMERIC,
  rolling_total_vaccinations NUMERIC
)

INSERT INTO percent_pop_vacc 
  SELECT 
	covid_deaths.continent,
	covid_deaths.location,
	covid_deaths.date,
	covid_deaths.population,
	covid_vac.new_vaccinations,
	SUM(CAST(covid_vac.new_vaccinations AS INT)) OVER (
	  PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date
	 ) AS rolling_total_vaccinations
  FROM covid_deaths AS covid_deaths
  JOIN covidvaccinations AS covid_vac
    ON covid_deaths.location = covid_vac.location
   AND covid_deaths.date = covid_vac.date
  WHERE covid_deaths.continent IS NOT NULL

SELECT 
* ,
rolling_total_vaccinations/population * 100 AS percent_pop_vaccinated
FROM percent_pop_vacc 
