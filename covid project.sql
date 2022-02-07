SELECT * FROM Coviddata.covidvaccination order by 3,4;
SELECT * FROM Coviddata.covid_death  order by 3,4;

SELECT 
    location,date,total_cases,new_cases,total_deaths,population
FROM
    Coviddata.covid_death
ORDER BY 1,2;

-- looking at total cases vs total deaths (death rate)
-- Looking at the death rate of Japan in 2021
SELECT 
    location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,3) as percentage_death
FROM
    Coviddata.covid_death
where location like "Japan" and year(date) = '2021' 
ORDER BY date desc;

-- looking at Total cases vs Population
-- showing percentage of population infected 
SELECT 
    location,date,total_cases,population,round((total_cases/population)*100,3) as percentage_death
FROM
    Coviddata.covid_death
where continent <>''
ORDER BY date ;

-- looking at top 3 countries have highest infection rate compare with population

SELECT 
    location,population,max(total_cases) as highest_infection,round((max(total_cases)/population)*100,3) as percentage_death
FROM
    Coviddata.covid_death
group by location,population
ORDER BY  percentage_death desc
limit 3;

-- showing continents have total death count 

SELECT 
    location,max(cast(total_deaths as signed integer)) as total_death
FROM
    Coviddata.covid_death
where continent =''
group by location
ORDER BY  total_death;


-- showing countries have total death count per population

SELECT 
    location,max(cast(total_deaths as signed integer)) as total_death
FROM
    Coviddata.covid_death
where continent <>''
group by location
ORDER BY  total_death desc;

-- showing daily death percentage

SELECT 
    date,sum(new_cases) total_newcases,
    sum(cast(new_deaths as signed integer)) as total_newdeaths,
    sum(cast(new_deaths as signed integer))/sum(new_cases)*100 as death_percentage
FROM
    Coviddata.covid_death
where continent <>''
group by date
ORDER BY 1,2;

-- way 1: Total population vs Vaccination


select de.continent,
    de.location,
    de.date,
    de.population,
	va.new_vaccinations,
    (t1.addup_totalvaccinated/de.population) as vaccin_per_population
FROM (SELECT 
    v.new_vaccinations,
    sum(cast(v.new_vaccinations as signed int)) over (partition by d.location order by d.location,d.date) as addup_totalvaccinated
    -- (addup_totalvaccinated/d.population) as vaccin_per_population
FROM
    Coviddata.covidvaccination v
        JOIN
    Coviddata.covid_death d ON d.location = v.location
        AND d.date = v.date
where d.continent <>'' and v.new_vaccinations <>''
order by 1,2) T1
join  Coviddata.covidvaccination va on va.new_vaccinations=t1.new_vaccinations 
join  Coviddata.covid_death de ON  de.location=va.location
order by 1,2,3;

-- create temporary table 
-- way 2:Total population vs Vaccination

use Coviddata;

create temporary table percentVaccinatedPopulation
(continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
addup_totalvaccinated numeric);

insert into percentVaccinatedPopulation
SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    sum(cast(v.new_vaccinations as signed int)) over (partition by d.location order by d.location,d.date) as addup_totalvaccinated
    -- (addup_totalvaccinated/d.population) as vaccin_per_population
FROM
    Coviddata.covidvaccination v
        JOIN
    Coviddata.covid_death d ON d.location = v.location
        AND d.date = v.date
where d.continent <>'' and v.new_vaccinations <>'';

select *,(addup_totalvaccinated/population)*100 as vaccin_per_population
from percentVaccinatedPopulation;

-- creating view for 2022-01-02 total deaths of each countries

create view TotalDeaths as 
select location,date,total_deaths
from Coviddata.covid_death
where continent <>'' and date = '2022-01-02'
order by 1,2;



