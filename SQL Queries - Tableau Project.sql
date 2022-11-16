/*
Queries used for Tableau Dashboard 

Please access the link below for my Tableau COVID Dashboard:
https://public.tableau.com/views/CovidDashboard_16680895190020/Dashboard1?:language=fr-FR&:display_count=n&:origin=viz_share_link
*/



-- 1. Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject.dbo.Covid_death
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1, 2;



-- 2. Continents with Heighest New Death Count per Population 
-- excluding Worl, International and European Union, cause the last one is a part of Europe

SELECT location, SUM(new_deaths) AS Total_death_count
FROM PortfolioProject.dbo.Covid_death
WHERE continent IS NULL 
AND location NOT LIKE '%income%'
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_death_count DESC;



---- 3. Countries with Hughest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_population_infected
FROM PortfolioProject.dbo.Covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_population_infected DESC;



-- 4. Countries with Hughest Infection Rate compared to Population griuped by location, population and date

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_population_infected
FROM PortfolioProject.dbo.Covid_death
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY Percent_population_infected DESC;


