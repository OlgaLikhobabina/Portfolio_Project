/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT * 
FROM PortfolioProjectCovid..Covid_death
WHERE continent IS NOT NULL
ORDER BY 3, 4;


--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectCovid..Covid_death
ORDER BY 1, 2;


--Total Cases vs Total Deaths
--Shows liklehood of dying if you contract covid in France

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM PortfolioProjectCovid..Covid_death
WHERE location like '%France%'
ORDER BY 1, 2;


--Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Total_percentage
FROM PortfolioProjectCovid..Covid_death
WHERE location like '%France%'
ORDER BY 1, 2;



--Countries with Hughest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_population_infected
FROM PortfolioProjectCovid..Covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_population_infected DESC;



--Countries with Heighest Death Count per Population

SELECT location, MAX(total_deaths) AS Total_death_count
FROM PortfolioProjectCovid..Covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC;


--Continents with Heighest Death Count per Population

SELECT location, MAX(total_deaths) AS Total_death_count
FROM PortfolioProjectCovid..Covid_death
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY Total_death_count DESC;


--Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProjectCovid..Covid_death
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1, 2;


--Total cases
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProjectCovid..Covid_death
WHERE continent IS NOT NULL
ORDER BY 1, 2;


--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location 
Order by dea.location, dea.date) AS Rolling_people_vaccinated
FROM PortfolioProjectCovid..Covid_death dea
JOIN PortfolioProjectCovid..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;



---- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location 
Order by dea.location, dea.date) AS Rolling_people_vaccinated
FROM PortfolioProjectCovid..Covid_death dea
JOIN PortfolioProjectCovid..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT*, (Rolling_people_vaccinated/population)*100
FROM PopvsVac;



---- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #Percent_population_vaccinated
CREATE TABLE #Percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #Percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location 
Order by dea.location, dea.date) AS Rolling_people_vaccinated
FROM PortfolioProjectCovid..Covid_death dea
JOIN PortfolioProjectCovid..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT*, (Rolling_people_vaccinated/population)*100
FROM #Percent_population_vaccinated;



--Creating View to store data later visualizations
Create View Percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location 
Order by dea.location, dea.date) AS Rolling_people_vaccinated
FROM PortfolioProjectCovid..Covid_death dea
JOIN PortfolioProjectCovid..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;


SELECT *
FROM Percent_population_vaccinated;