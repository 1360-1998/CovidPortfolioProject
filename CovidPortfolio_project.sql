
--Viewing all data in the dateset

SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  Where continent is Not Null
  Order by 3, 4


--Showing countries, their population,total and new cases of Covid-19

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
Where continent is Not Null
Order By 1, 2

--Death Rate calculation in different countries

SELECT Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM CovidDeaths
WHERE location = 'Ghana' --this can be any country of your choice
Order By 1, 2

--Total cases vs total population
--% of population infected by covid

SELECT Location, population,total_cases,total_deaths, (total_cases/population)*100 as PercentofPopulationInfected
FROM CovidDeaths
WHERE location = 'Ghana'
Order By 1, 2

--Countries with highest infected rate compared to their population

SELECT Location, population,Max(total_cases)as maximum_cases, Max((total_cases/population))*100 as PercentofPopulationInfected
FROM CovidDeaths
Group by location, population
Order By PercentofPopulationInfected desc


--Countries with highest death rate compared to their population

SELECT Location, population,Max(cast(total_deaths as int))as maximum_deaths, Max((total_deaths/population))*100 as PercentofPopulationWhoDied
FROM CovidDeaths
Where continent is Not Null
Group by location, population
Order By maximum_deaths desc

--Breaking them down into continents

SELECT  continent,Max(cast(total_deaths as int))as maximum_deaths
FROM CovidDeaths
Where continent is not Null
Group by continent
Order By maximum_deaths desc

--Global Numbers(daily cases)

SELECT date,
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by date
Order by 1,2

--Global Numbers(total cases)

SELECT
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--Group by date
Order by 1,2


--Joining CovidDeaths and CovidVaccination tables together

 Select * 
 From CovidDeaths dea
 Join CovidVaccinations vac
	on dea.location = vac. location
	and dea.date = vac.date


--Looking at Total Population vs Total Vaccination(Rolling Count)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



 --Percentage of people vaccinated as compared to the population of the country(Not rolling)

SELECT
    location,
    total_population,
    total_vaccination,
    CAST(total_vaccination AS FLOAT) / CAST(total_population AS FLOAT) AS VaccinationPercentage
FROM (
    SELECT
        dea.location,
        SUM(population) AS total_population,
        SUM(CAST(total_vaccinations AS BIGINT)) AS total_vaccination
    FROM
        CovidDeaths dea
        JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    GROUP BY
        dea.location
) AS subquery
ORDER BY
    VaccinationPercentage DESC;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 