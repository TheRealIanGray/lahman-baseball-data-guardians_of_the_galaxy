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

-- Name an Height of the Shortest player
SELECT namefirst, namelast, namegiven, height, playerid
FROM people
WHERE height = (
	SELECT min(height)
	FROM people);
	
-- Name is Eddie Gaedel with a height of 43 with playerid 'gaedeed01'

/*How many games did he play in? What is the name of the team for which he played? */

SELECT count(*), teamid
FROM appearances
WHERE playerid = 'gaedeed01'
GROUP BY teamid



-- The player Eddie Gaedel played only once for the team id SLA

-- The below Query is not correct with the teams table in terms of the count
SELECT count(a.playerid = 'gaedeed01'), a.teamid
FROM appearances AS a
LEFT JOIN teams As t
ON a.teamid=t.teamid
WHERE playerid = 'gaedeed01'
GROUP BY a.teamid

-- Query gets us the team Name based on teamid from Appearance table
SELECT DISTINCT(name),
FROM teams
WHERE teamid = 'SLA';

/* Q3  Find all players in the database who played at Vanderbilt University. */
--Subquery for Vanderbilt
-- Identify school id

SELECT schoolid
FROM schools
WHERE schoolname ilike'Vanderbilt%'

SELECT DISTINCT p.playerid, p.namefirst, p.namelast
FROM collegeplaying AS cp
JOIN people AS p
ON cp.playerid=p.playerid
WHERE cp.schoolid =(
					SELECT schoolid
					FROM schools
					WHERE schoolname ilike'Vanderbilt%')

-- There are 24 distinct players that play for Vanderbilt.




/*Create a list showing each player’s first and last names 
as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned.*/

-- CREATED a CTE to perform a total salary by player id
WITH salary as (SELECT sum(salary)AS total_salary, playerid
			    FROM salaries
			   GROUP BY playerid)

-- JOIN Salary CTE to identify the total salary by  player id
SELECT distinct p.playerid, p.namefirst, p.namelast, s.total_salary
FROM collegeplaying AS cp
JOIN people AS p
ON cp.playerid=p.playerid
JOIN salary AS s
ON p.playerid=s.playerid
WHERE cp.schoolid =(
					SELECT schoolid
					FROM schools
					WHERE schoolname ilike'Vanderbilt%')
ORDER BY s.total_salary DESC
-- This number shrinks from 24 players at vanderbilt to 15 player with salary

/*Which Vanderbilt player earned the most money in the majors? */
-- Based on above Query David Price earned the highest salary of 82,851,296


/* Q4 Using the fielding table, group players into three groups based on their position:
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.


