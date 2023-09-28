--COVID 19 DATA EXPLORATION

SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECTING DATA TO START WITH
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is NOT NULL
order by 1,2

--TOTAL DEATHS PER TOTAL CASES
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL and location like '%states%'
order by 1,2

--HIGHEST DEATH PERCENTAGE RECORDED IN YOUR COUNTRY
SELECT location,date,total_cases,new_cases,total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL and location like '%states%'
order by DeathPercentage desc

--TOTAL CASES PER POPULATION
--SHOWS THE PERCENTAGE OF POPULATION INFECTED WITH COVID
SELECT location,date,total_cases,population,round((total_cases/population)*100,2) as PercentPopulatonInfected
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--HIGHEST PERCENT OF INFECTED POPULATION PER COUNTRY
SELECT location,population,max(total_cases) as HighestCountofInfection,max(round((total_cases/population)*100,2)) as PercentPopulatonInfected
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population 
ORDER BY PercentPopulatonInfected desc

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,population,MAX(total_deaths) AS HighestDeathCount,MAX(total_deaths/population)*100 AS TotalDeathPerPopulation
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY TotalDeathPerPopulation desc

--BREAKING DOWN BY CONTINENTS
--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent,ROUND(MAX((total_deaths/population)*100),2) AS DeathCountPerContinent
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY DeathCountPerContinent DESC

--GLOBAL CASES
SELECT SUM(total_cases) AS TotalCases,SUM(total_deaths) AS TotalDeaths,(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--TOTALPOPULATION VS VACCINATIONS
--SHOWS PERCENTAGE OF POPULATION THAT HAS RECEIVED AT LEAST ONE VACCINE

SELECT cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY cov.location ORDER BY cov.date) AS RollingPeopelVaccinated
FROM CovidVaccinations vac
INNER JOIN CovidDeaths cov
on vac.location=cov.location and vac.date=cov.date
WHERE cov.continent is not NULL
ORDER BY 2,3

--PERFORMING CALCULATIONS
WITH DeaVac(Continent,Location,Date,Population,[New Vaccinations],RollingPeopleVaccinated)
AS
(
SELECT TOP 100 PERCENT cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY cov.location ORDER BY cov.date) AS RollingPeopelVaccinated
FROM CovidVaccinations vac
INNER JOIN CovidDeaths cov
on vac.location=cov.location and vac.date=cov.date
WHERE cov.continent is not NULL
ORDER BY 2,3	
)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentofRollingVaccinated
FROM DeaVac

--USING TEMP TABLE TO PERFORM CALCULATIONS
SELECT cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY cov.location ORDER BY cov.date) AS RollingPeopelVaccinated
INTO #PercentPopulationVaccinated --CREATING TEMP TABLE 
FROM CovidVaccinations vac
INNER JOIN CovidDeaths cov
on vac.location=cov.location and vac.date=cov.date
WHERE cov.continent is not NULL
ORDER BY 2,3

SELECT *,(RollingPeopelVaccinated/Population)*100 AS PercentofRollingVaccinated
FROM #PercentPopulationVaccinated

--CREATING A VIEW
CREATE VIEW vw_PopVac
AS
SELECT TOP 100 PERCENT cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY cov.location ORDER BY cov.date) AS RollingPeopelVaccinated
FROM CovidVaccinations vac
INNER JOIN CovidDeaths cov
on vac.location=cov.location and vac.date=cov.date
WHERE cov.continent is not NULL
ORDER BY 2,3

SELECT *
FROM vw_PopVac