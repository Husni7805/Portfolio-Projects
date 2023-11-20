SELECT*
FROM Portfolio..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


--LOOKING AT TOTAL_CASES V TOTAL_DEATHS
--SHOW LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date,total_cases,total_deaths,(CONVERT(FLOAT,total_deaths)/NULLIF(CONVERT(FLOAT,total_cases),0))*100 AS DEATHPERCENTAGE
FROM Portfolio..CovidDeaths
WHERE location LIKE '%LANK%'
order by 1,2

--SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DEATHPERCENTAGE
--FROM Portfolio..CovidDeaths
--WHERE location LIKE '%LANK%'
--and continent is not null 
--order by 1,2


--LOOKING AT TOTAL CASES VS POPULATION
-- SHOW WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date,total_cases,population,(CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT,POPULATION),0))*100 AS COVIDAFFACTPERCENTAGE
FROM Portfolio..CovidDeaths
WHERE location LIKE '%LANK%'
order by 1,2


SELECT location, date,total_cases,population,(total_cases/population)*100 AS COVIDAFFACTPERCENTAGE
FROM Portfolio..CovidDeaths
WHERE location LIKE '%LANK%'and continent is not null 
order by 1,2

SELECT location, date,total_cases,population,(total_cases/population)*100 AS COVIDAFFACTPERCENTAGE
FROM Portfolio..CovidDeaths
--WHERE location LIKE '%LANK%' and continent is not null 
order by 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location,population, MAX(total_cases) AS HIGHESTINFECTIONCOUNT, MAX((total_cases/population))*100 AS PERCENTAGEPOPULATIONINFECTED
FROM Portfolio..CovidDeaths
--WHERE location LIKE '%LANK%'and continent is not null
GROUP BY location,population 
order by PERCENTAGEPOPULATIONINFECTED DESC

-- SHOWING COUNTRIES WITH HIGHES DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS INT)) AS TOTALDEATHS
FROM Portfolio..CovidDeaths
WHERE continent is not null 
--location LIKE '%LANK%'and continent is not null
GROUP BY location
order by TOTALDEATHS DESC

--BY CONTINENT

SELECT location, MAX(CAST(total_deaths AS INT)) AS TOTALDEATHS
FROM Portfolio..CovidDeaths
WHERE continent is null 
--location LIKE '%LANK%'and continent is not null
GROUP BY location
order by TOTALDEATHS DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TOTAL_CASES, SUM(new_deaths) AS TOTAL_DEATHS, SUM(new_deaths)/SUM(new_cases)*100 AS DEATHPERCENTAGE
FROM Portfolio..CovidDeaths
WHERE continent is NOT null
--location LIKE '%LANK%'
--GROUP BY date
order by 1,2


--COVID VACCINATION


SELECT*
FROM Portfolio..CovidVaccinations

--LOOKING TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS ROLLINGPEOPLEVACCINATION
FROM Portfolio..CovidDeaths AS DEA
JOIN Portfolio..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is NOT null 
ORDER BY 2,3


--CTE

WITH POPVSVAC (CONTINENT,LOCATION,DATE,POPULATION,new_vaccinations,ROLLINGPEOPLEVACCINATION) AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS ROLLINGPEOPLEVACCINATION
FROM Portfolio..CovidDeaths AS DEA
JOIN Portfolio..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is NOT null 
--ORDER BY 2,3
)
SELECT*, (ROLLINGPEOPLEVACCINATION/POPULATION)*100
FROM POPVSVAC

--TEMP TABLE

DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED

(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATION NUMERIC,
ROLLINGPEOPLEVACCINATED  NUMERIC
)
INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS ROLLINGPEOPLEVACCINATED
FROM Portfolio..CovidDeaths AS DEA
JOIN Portfolio..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is NOT null 
--ORDER BY 2,3

SELECT*, (ROLLINGPEOPLEVACCINATED/POPULATION)*100
FROM #PERCENTPOPULATIONVACCINATED

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PERCENTPOPULATIONVACCINATED AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS ROLLINGPEOPLEVACCINATED
FROM Portfolio..CovidDeaths AS DEA
JOIN Portfolio..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is NOT null 
--ORDER BY 2,3

SELECT *
FROM PERCENTPOPULATIONVACCINATED