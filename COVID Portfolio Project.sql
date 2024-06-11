



-- Looking at TOTAL CASES VS TOTAL DEATHS
--Show likelihood of dying if you contract covid in tour country

Select Location, date, total_cases, total_deaths, Round((CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100,2) as DeathPercentage
from portfolioProject.dbo.cd
where location like 'Afr%'
order by 1,2

--Look at TOTAL CASES VS POPULATION
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, Round((CONVERT(float, total_cases) / CONVERT(float, population))*100,2) as 'Population Percent'
from portfolioProject.dbo.cd
where location like 'Afr%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as 'Highest Infection Rate', max( Round((CONVERT(float, total_cases) / CONVERT(float, population))*100,2)) as 'Population Percent'
from portfolioProject.dbo.cd
group by location,population
order by [Population Percent] desc

-- Showing countries with Highest Death Count per Population

select location, max(convert(int,total_deaths)) as td
from portfolioProject.dbo.cd
where continent is not null
group by location
order by td desc

--LETS BREAK THINGS DOWN BY CONTINENT



--Showing continents with the highers death count per population

select continent, max(convert(int,total_deaths)) as td
from portfolioProject.dbo.cd
where continent is not null
group by continent
order by td desc

--GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as Death_Percent
from portfolioProject.dbo.cd
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select x.continent,x.location,x.date,x.population
,y.new_vaccinations,sum(cast(y.new_vaccinations as bigint)) over (partition by
x.location order by x.location,x.date) as rollingPeopleVaccinated
from portfolioProject..cd x
join portfolioProject..cv y
on x.location=y.location
and x.date=y.date
where x.continent is not null
order by 1,2,3


-- Use CTE

with PopvsVac(continent,location,date,population,new_vaccinations,rollingPeopleVaccinated)
as(
select x.continent,x.location,x.date,x.population
,y.new_vaccinations,sum(cast(y.new_vaccinations as bigint)) over (partition by
x.location order by x.location,x.date) as rollingPeopleVaccinated
from portfolioProject..cd x
join portfolioProject..cv y
on x.location=y.location
and x.date=y.date
where x.continent is not null
--order by 1,2,3
)

select *,(rollingPeopleVaccinated/population)*100 from PopvsVac

-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric)


insert into #PercentPopulationVaccinated

select x.continent,x.location,x.date,x.population
,y.new_vaccinations,sum(cast(y.new_vaccinations as bigint)) over (partition by
x.location order by x.location,x.date) as rollingPeopleVaccinated
from portfolioProject..cd x
join portfolioProject..cv y
on x.location=y.location
and x.date=y.date
where x.continent is not null
--order by 1,2,3

select *,(rollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
select x.continent,x.location,x.date,x.population
,y.new_vaccinations,sum(cast(y.new_vaccinations as bigint)) over (partition by
x.location order by x.location,x.date) as rollingPeopleVaccinated
from portfolioProject..cd x
join portfolioProject..cv y
on x.location=y.location
and x.date=y.date
where x.continent is not null
--order by 1,2,3

select * from PercentPopulationVaccinated

