use Portfolio_project;
SELECT*
From Portfolio_project.dbo.Covid_deaths
where continent is not null
order by 3,4;

--SELECT*
--From Portfolio_project.dbo.Covid_Vaccination
--order by 3,4

--Select data we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project.dbo.Covid_deaths
order by 1,2; 
--ALTER TABLE Covid_Deaths
--ALTER COLUMN total_deaths float
--ALTER TABLE Covid_Deaths
--ALTER COLUMN total_cases float

--Looking at total cases VS total deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project.dbo.Covid_deaths
WHERE Location like '%ndia'
order by 1,2;

--Looking at the total cases VS Population
--Shows that what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Infectedpercentage
FROM Portfolio_Project.dbo.Covid_deaths
--WHERE Location like '%ndia'
order by 1,2 ;


--Looking at the countries with highest infection as compared to the population

SELECT Location, MAX(total_cases) AS HighestInfesctionCount, population, MAX((total_cases/population))*100 as Infectedpopulationpercentage
FROM Portfolio_Project.dbo.Covid_deaths
--WHERE Location like '%ndia'
Group by Population, Location
order by Infectedpopulationpercentage DESC;

--Showing countries with the highest death count

SELECT Location, MAX(total_deaths) AS TotaldeathCount, population
FROM Portfolio_Project.dbo.Covid_deaths
--WHERE Location like '%ndia'
where continent is not null
Group by Population, Location
order by TotaldeathCount desc;

--Breaking the above query by continent
SELECT continent, MAX(total_deaths) AS TotaldeathCount
FROM Portfolio_Project.dbo.Covid_deaths
--WHERE Location like '%ndia'
where continent is not null
Group by continent
order by TotaldeathCount desc;

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)* 100 
as DeathPercentage--, 
FROM Portfolio_Project.dbo.Covid_deaths
where continent is not null
--Group by date
order by 1,2;


--Looking at total population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100 ( we cannnot take the alias name we just created
--instead of that we will use CTEs or temp table)

FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
ON dea.location= vac.location and dea.date = vac.date
--where dea.continent is not null
order by 2,3;



-- Creating CTEs
With PopVSVac( Continent, Location, date, population, New_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
-- ( we cannnot take the alias name we just created
--instead of that we will use CTEs or temp table)

FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
ON dea.location= vac.location and dea.date = vac.date
where dea.continent is not null
)
SELECT* , (RollingPeopleVaccinated/population)*100
FROM PopVSVac

--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
-- ( we cannnot take the alias name we just created
--instead of that we will use CTEs or temp table)

FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
ON dea.location= vac.location and dea.date = vac.date
--where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS Vaccinatedpercentage
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualization
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
-- ( we cannnot take the alias name we just created
--instead of that we will use CTEs or temp table)

FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
ON dea.location= vac.location and dea.date = vac.date
where dea.continent is not null


Select*
From PercentPopulationVaccinated;

