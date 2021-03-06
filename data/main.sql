--Identify the years  for baseball games played
SELECT MIN(DISTINCT yearid) as First_year, MAX(DISTINCT yearid) AS Latest_year
FROM appearances;

SELECT MIN(DISTINCT yearid) as First_year, MAX(DISTINCT yearid) AS Latest_year
FROM pitching;

SELECT MIN(DISTINCT yearid) as First_year, MAX(DISTINCT yearid) AS Latest_year
FROM batting;

SELECT MIN(DISTINCT yearid) as First_year, MAX(DISTINCT yearid) AS Latest_year
FROM fielding;

-- First Year 1871 and Last Year 2016

-- 