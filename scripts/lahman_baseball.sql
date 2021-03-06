Select DISTINCT(yearid)
FROM appearances
ORDER BY yearid;

-- 1. the database covers the years 1871 to 2016 -- 

SELECT namefirst, namelast, height, playerid
FROM people
ORDER BY height;

SELECT *
FROM appearances
WHERE playerid = 'gaedeed01';

SELECT DISTINCT(name)
FROM teams
WHERE teamid = 'SLA';

-- 2. Eddie Gaedel was the shortest player at 43 inches, he played for the St. Louis Browns and only played in one game in 1951.

SELECT *
FROM schools
WHERE schoolname = 'Vanderbilt University';

SELECT COUNT(DISTINCT playerid)
FROM collegeplaying 
WHERE schoolid = 'vandy';

SELECT DISTINCT namefirst, namelast 
FROM collegeplaying AS cp
INNER JOIN people AS p
ON cp.playerid = p.playerid
WHERE schoolid = 'vandy';




