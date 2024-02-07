select *
from PortfolioProject ..CovidDeaths
where continent is not null -- we did these because we want ot get rid of the countries named as the contienent at the locations columnorder by 3,4

--select *
--from PortfolioProject ..CovidVaccinations
--where continent is not null -- we did these because we want ot get rid of the countries named as the contienent at the locations column
--order by 3,4



-- First: Select the data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject ..CovidDeaths
where continent is not null -- we did these because we want ot get rid of the countries named as the contienent at the locations column
order by 1,2




-- We are looking the totalcases VS total_death
-- Showes likelihood of dying if you cotract covid in your country
select Location, date, total_cases, total_deaths , (convert(float,total_deaths)/ nullif(convert(float,total_cases),0))*100 as DeathPercrntage  -- I used this statment (Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage) to solve the problem that appered to me "the error Msg 8117, Level 16, State 1, Line 17 Operand data type nvarchar is invalid for divide operator."
from PortfolioProject ..CovidDeaths
--where location Like '%Sudan%' -- we use this if we want to the percentage in specific location)
order by 1,2




-- Looking at the total cases VS Population
-- Shows what percentage of population got Covid

select Location, date,population, total_cases, (total_cases/population)*100  as Percent_Populations_infected
from PortfolioProject ..CovidDeaths
where continent is not null -- we did these because we want ot get rid of the countries named as the contienent at the locations column--where location = 'Sudan'
order by 1,2




-- looking at Countries with highest infection rate compared to population

select Location, population, MAX(total_cases)as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Populations_infected
from PortfolioProject ..CovidDeaths
where continent is not null -- we did these because we want ot get rid of the countries named as the contienent at the locations column--where location = 'Sudan'
group by Location, population
order by 4 desc




-- This showes countries with the highest death count per population
select Location,  MAX(cast(total_deaths as int)) as Highest_Death_Count --"MAX(convert(int,total_deaths))" is another to convert the column's type
from PortfolioProject ..CovidDeaths
where continent is not null -- we did these because we want ot get rid of the countries named as the contienent at the locations column
--where location = 'Sudan'
group by Location
order by 2 desc



--Let's break things down by continent
select Location,  MAX(cast(total_deaths as int)) as Highest_Death_Count --"MAX(convert(int,total_deaths))" is another to convert the column's type
from PortfolioProject ..CovidDeaths
where continent is null -- we did these because we want ot get rid of the countries named as the contienent at the locations column
--where location = 'Sudan'
group by Location
order by Highest_Death_Count desc




-- Showing the  contiennt with the highst death count per population

select continent,  MAX(cast(total_deaths as int)) as Highest_Death_Count --"MAX(convert(int,total_deaths))" is another to convert the column's type
from PortfolioProject ..CovidDeaths
where continent is not null -- we did these because we want ot get rid of the countries named as the contienent at the locations column
--where location = 'Sudan'
group by continent
order by Highest_Death_Count desc




--Global Numbers
select  SUM( new_cases) as total_cases, SUM( cast( new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/ sum(New_cases )*100 as DeathPercrntage 
from PortfolioProject ..CovidDeaths
where continent is not null

--Group by date
order by 1,2



--looking at total population VS vaccination

Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by (dea.location) Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- To do this operaation we need to use CTE " (RollingPeopleVaccinated/population)*100" and that because we can not use new statement that we identify in the same query in same place
-- Using CTE:

With popVSvac (continent, Location, Population,new_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,
dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by (dea.location) Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
select * , (RollingPeopleVaccinated/Population)*100 
From popVSvac



-- We can use Temp table to do the same thing that we did in CTE
-- using TEMP Table:
Drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated 
( continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric ,
RollingPeopleVaccinated numeric)

Insert Into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by (dea.location) Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

select *,(RollingPeopleVaccinated/Population)*100 
from #PercentagePopulationVaccinated 



-- creating View to store data for visualizations
Create view PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by (dea.location) Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3 

select *
From PercentagePopulationVaccinated