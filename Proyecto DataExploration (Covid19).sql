
--Select *
--From PortfolioProject.dbo.CovidDeaths
--Order by location, date

Select *
From PortfolioProject.dbo.CovidVaccinations
Where continent is not null                                          -- Porque hay continentes y paises en la misma columna
Order by location, date

-- Seleccionar los datos que vamos a usar

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null                                        
Order by location, date

-- Comparar total de casos vs total de muertes y obtener porcentarge de muerte por infección

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentatge
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
Order by location, date

-- Comparar total de casos vs población y obtener porcentarge de la población infectada

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentatge
From PortfolioProject.dbo.CovidDeaths
Where continent is not null                                        
--Where location like '%states%'
Order by location, date

-- Buscar países con porcentage de infección máximo más alto

Select location, population, Max(total_cases) as HighestInfecctionCount, Max((total_cases/population))*100 as InfectedPercentatge
From PortfolioProject.dbo.CovidDeaths
Where continent is not null                                          
Group by location, population
Order by InfectedPercentatge Desc

-- Buscar países con porcentarge de muerte por infección maximo más alto

Select location, Max(cast(total_deaths as int)) as TotalDeathCount   -- Cambiar tipo de carácter de nvarchar(255) a int, de letra a números
From PortfolioProject.dbo.CovidDeaths
Where continent is not null                                          -- Porque hay continentes y paises en la misma columna
Group by location
Order by TotalDeathCount Desc

-- (CAMBIAR VARIABLE LOCALIZACIÓN POR CONTIENTE, ahora se analizaran los datos teneiendo como referencia los continentes)

-- Buscar continentes con porcentarge de muerte por infección maximo más alto

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount   
From PortfolioProject.dbo.CovidDeaths
Where continent is not null                                           
Group by continent
Order by TotalDeathCount Desc

-- NÚMEROS GLOBALES

Select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentatge
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
Order by date

-- Otro ejemplo

Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentatge
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Comparar total de la población vs total de vacunados

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Inner Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

-- Para utilitzar una columna creada en la misma consulta hay que usar un CTE o temp_table (Recomendable CTE)

-- CTE Common Table Expression

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Inner Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated                    -- Para cargar la tabla una vez creada y evitar error tabla ya existe
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Inner Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Crear vista para posterior visualización (Tableau), (View) para guardar todas las tablas importantes para visualizar

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Inner Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated