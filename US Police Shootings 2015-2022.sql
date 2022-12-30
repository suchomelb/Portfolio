/*
Analyzing US Police Shootings 2015-2022 (2022 data only up to August)

Skills used: Joins, CTE's, Window Functions, Aggregate Functions, CASE Function, 

*/


--Police shooting deaths by year

SELECT 
    year(date) as year,
    count(date) as deaths
FROM
    Info
GROUP BY
    year(date)
ORDER BY 
    year(date)


--Police shooting deaths by month per year

SELECT 
    DATEPART(yyyy, date) as year,
    DATEPART(mm, date) as month,
    count(date) as deaths
FROM
    Info
GROUP BY
    DATEPART(yyyy, date),
    DATEPART(mm, date)
ORDER BY 
    DATEPART(yyyy, date),
    DATEPART(mm, date)


-- Police shooting deaths totals by state

SELECT
    state,
    COUNT(state) as deaths
FROM
    Info
GROUP BY
    state
ORDER BY
    COUNT(state) DESC


--Percentage of police shootings deaths by gender

With CTE as
    (SELECT
        COUNT(*) as DeathByGender,
        gender,
        SUM(COUNT(*)) OVER () AS TotalDeaths
    FROM
        Info
    GROUP BY
        gender
    )
SELECT
    Gender,
    DeathByGender as [Death By Gender],
    CAST(((DeathbyGender * 1.0)/TotalDeaths)*100 AS NUMERIC(36,2)) as [% Of Total Deaths]
FROM
    CTE
ORDER BY
    DeathByGender DESC

/*** Other option for above
    With toplevel as
       (SELECT
            COUNT(gender) as deaths,
            gender,
            Sumofalldeaths =( SELECT max(id) FROM Info)
        FROM
            Info
        GROUP BY
            gender
        )

    SELECT
        deaths,
        gender,
        (deaths/Sumofalldeaths)*100 as percent_total

    FROM
        toplevel

    ORDER BY
        deaths DESC
***/


-- Deaths of individuals who were armed vs. unarmed

With CTE as
    (SELECT
        CAST(COUNT(*) AS FLOAT) as Total,
        (SELECT COUNT(armed) FROM Details WHERE armed <> 'unarmed') as Armed,
        (SELECT COUNT(armed) FROM Details WHERE armed = 'unarmed') as Unarmed
        
    FROM
        Details
    ) 
SELECT
    Total,
    CAST(((Armed * 1.0)/Total)*100 as numeric(36,2)) as [% Armed],
    CAST(((Unarmed * 1.0)/Total)*100 as numeric(36,2)) as [% Unarmed]       
FROM
    CTE


-- Deaths of individuals by armed/weapon type held

With CTE as
    (SELECT
        COUNT(*) CountArmed,
        armed,
        SUM(COUNT(*)) OVER () AS TotalDeaths
    FROM
        Details
    GROUP BY 
        armed
    ) 

SELECT
    Armed,
    CAST(((CountArmed * 1.0)/TotalDeaths)*100 AS NUMERIC(36,2)) as [% Of Total]      
FROM
    CTE  
ORDER BY
    [% Of Total] DESC


-- Breaking down deaths into age groups

WITH CTE AS
    (SELECT 
        age,
        CASE
            WHEN age < 11 THEN '1-10'
            WHEN age < 21 THEN '11-20'
            WHEN age < 31 THEN '21-30'
            WHEN age < 41 THEN '31-40'
            WHEN age < 51 THEN '41-50'
            WHEN age < 61 THEN '51-60'
            WHEN age < 71 THEN '61-70'
            WHEN age < 81 THEN '71-80'
            WHEN age < 91 THEN '81-90'
            WHEN age < 100 THEN '91-100'
        END as age_range
    FROM
        Info
    )
SELECT
    age_range AS [Age Group],
    COUNT(age) AS Deaths
    
FROM
    CTE
GROUP BY
    age_range
ORDER BY
    age_range


-- Join showing deaths by whether individuals showed signs of mental illness, grouped by gender

WITH CTE as
    (SELECT
        I.Gender,
        CASE
            WHEN D.signs_of_mental_illness = 1 THEN 'Yes'
            ELSE 'No'
        END AS [Signs Of Mental Illness],
        COUNT(D.signs_of_mental_illness) AS Total,
        SUM(COUNT(*)) OVER () AS Sumofalldeaths
    FROM
        Info I
    JOIN
        Details D 
        ON I.Id = D.Id
    GROUP BY
        I.Gender,
        D.signs_of_mental_illness 
    )
SELECT
    Gender,
    [Signs Of Mental Illness],
    Total,
    CAST(((Total * 1.0)/Sumofalldeaths)*100 AS NUMERIC(36,2)) AS [% Of Total Deaths]
FROM
    CTE
ORDER BY
    Total DESC,
    Gender,
    [Signs Of Mental Illness]