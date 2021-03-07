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
-----------------------------------------------------------
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
----------------------------------------------------------
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
WITH salary as (SELECT sum (COALESCE(salary,0))AS total_salary, playerid
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
--Other to see
/*SELECT DISTINCT c.playerid, SUM(s.salary),p.namelast, p.namefirst, c.schoolid
FROM collegeplaying as c
JOIN people as p
ON p.playerid = c.playerid
JOIN salaries as s
ON p.playerid = s.playerid
WHERE c.schoolid LIKE '%vand%'
GROUP BY c.playerid,p.namelast,p.namefirst,c.schoolid
ORDER BY SUM(s.salary) DESC

SELECT p.namefirst,
		p.namelast,
		SUM(COALESCE(s.salary,0)) AS total_salary
FROM people AS p
LEFT JOIN collegeplaying AS cp
USING (playerid)
LEFT JOIN schools AS sch
USING (schoolid)
LEFT JOIN salaries AS s
USING (playerid)
WHERE sch.schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC;
*/

/*Which Vanderbilt player earned the most money in the majors? */
-- Based on above Query David Price earned the highest salary of 82,851,296

-------------------------------------------------------
/* Q4 Using the fielding table, group players into three groups based on their position:
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.
*/

-- Create the POS Groups with the info
WITH fielding_group AS (SELECT playerid, 
						yearid, 
						pos,
						CASE WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
							 WHEN pos ='OF' THEN 'Outfield'
							 WHEN pos ='P' OR pos='C' THEN 'Battery'
							 END AS pos_groups,
						po
						FROM fielding
					   )
-- SUM the PO  to each POS_group received from CTE					
SELECT fielding_group.pos_groups, sum(po)
FROM fielding_group
WHERE yearid = 2016
GROUP BY fielding_group.pos_groups

-- Battery 41424
-- Infield 58934
-- Outfield 29560
----------------------------------------------------
/* Q5. Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places.
Do the same for home runs per game. Do you see any trends?
*/

WITH pitching_groups AS (SELECT yearid,
						CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
							 WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
						 	 WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
						 	 WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
						 	 WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
						 	 WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
						 	 WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
						 	 WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
						 	 WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
						 	 WHEN yearid >= 2010 THEN '2010s'
						END AS decades,
						 so,
						 hr
						FROM pitching
						) 
SELECT pitching_groups.decades,
	   ROUND(AVG(so),2) AS avg_strikeouts,
	   ROUND(AVG(hr),2) AS avg_homeruns
FROM pitching_groups
WHERE yearid >= 1920
GROUP BY pitching_groups.decades
ORDER BY pitching_groups.decades

-- Both Strikeouts and Homeruns peak in 60's before tapering off as decades progress
/* Q6
Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.
*/


-- Use of Batting table (SB&CS) & Pitching table(SB&CS) SB=Stolen Bases, CS= Caught Stolen
-- Use of teams table where (SB&CS)
-- Use of Batting Post and Fielding Post ()
SELECT yearid,
	   CS,
	   SB
	   playerid
FROM teams
ORDER BY playerid
	   
