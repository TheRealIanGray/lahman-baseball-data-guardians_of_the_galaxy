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
-- Other Codes to see
/*

SELECT namefirst, namelast, namegiven, height, a.g_all, a.teamid, t.name
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
JOIN teams AS t
ON a.teamid = t.teamid
GROUP BY namefirst, namelast, namegiven, height, a.g_all, a.teamid, t.name
ORDER BY height
LIMIT 5;
*/


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
-- Based on above Query David Price earned the highest salary of 81,851,296

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
						so, -- Strike out
						hr,-- home runs,
						soa, -- Strike outs by Pitcher
						 g
						FROM teams
						) 
SELECT pitching_groups.decades,
	 ROUND((sum(CAST (so AS dec)))/(sum(CAST (g AS dec))/2),2) AS avg_strikeouts, -- Divide by 2 for each team
	ROUND(sum(CAST (hr AS dec))/(sum(CAST (g AS dec))/2),2) AS avg_homeruns

	   --avg_strikeouts,
	   --avg_homeruns
FROM pitching_groups
WHERE yearid >= 1920
GROUP BY pitching_groups.decades
ORDER BY pitching_groups.decades

-- Both Strikeouts and Homeruns peak in 60's before tapering off as decades progress

-- Other code to look
/*WITH decades as (	
				SELECT 	generate_series(1920,2010,10) as low_b,
						generate_series(1929,2019,10) as high_b)
SELECT 	low_b as decade,
		--SUM(so) as strikeouts,
		--SUM(g)/2 as games,  -- used last 2 lines to check that each step adds correctly
		ROUND(SUM(so::numeric)/(sum(g::numeric)/2),2) as SO_per_game,  -- note divide by 2, since games are played by 2 teams
		ROUND(SUM(hr::numeric)/(sum(g::numeric)/2),2) as hr_per_game
FROM decades LEFT JOIN teams
	ON yearid BETWEEN low_b AND high_b
GROUP BY decade
ORDER BY decade;

--Other way to look for decade
-- floor 1922/10 = 192.2, FLOOR rounds is DOWN to nearest year, multiply by 10 to get back to 1920.
select floor(yearid/10)*10 as decade--, yearid
from batting
where yearid >= 1920
group by decade;--, yearid;

*/
/* Q6
Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.
*/


-- Use of Batting table (SB&CS) SB=Stolen Bases, CS= Caught Stolen
-- Use of teams table where (SB&CS)
-- Use of Batting Post and Fielding Post ()
WITH batting_sum AS ( SELECT yearid,
							 playerid,
					 		 teamid,
							 cs,
							 sb,
					 		 sum(cs+sb) AS attempts
						FROM batting
					 	WHERE yearid = '2016'
					 	GROUP BY yearid, playerid, cs, sb, teamid
						ORDER BY attempts DESC)

SELECT b.playerid, 
	  	p.namefirst, p.namelast, p.namegiven, b.sb, b.cs, b.attempts,
	   cast(b.sb as float)/cast(b.attempts as float) * 100 AS success_perc
FROM batting_sum AS b
JOIN people AS p
USING(playerid)
WHERE b.sb >=20
GROUP BY  b.playerid, p.namefirst, p.namelast, p.namegiven,b.sb, b.cs, b.attempts
ORDER BY success_perc DESC

-- Chris Owings with player id owingch01 has the highest success rate in stealing bases in the year 2016


/* Q7
From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
What is the smallest number of wins for a team that did win the world series?
Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
*/

-- Total wins by team by yearid>1970 sorted by teamid, yearid
SELECT teamid, yearid, w as total_wins
FROM teams
WHERE yearid >='1970'
ORDER BY total_wins DESC

-- Refine the above query to sum wins by team only cumulatively and didn't win the World Series (Largest Wins )
SELECT teamid, name, w as total_wins
FROM teams
WHERE yearid >='1970' AND wswin='N'
ORDER BY total_wins DESC
-- ANS is SEA Seattle Mariners than won 116 games

-- Refine the above query to sum wins by team only cumulatively and did win the World Series (Smallest Wins )
SELECT teamid, name, w as total_wins, wswin
FROM teams
WHERE yearid >='1970' AND wswin='Y'
ORDER BY total_wins
-- ANS is LAN -Los Angeles Dodgers than won 63 games

-- Refine the above query adding Yearid to sum wins by team only cumulatively and did win the World Series (Smallest Wins )
SELECT teamid, name, yearid, w as total_wins, wswin, g
FROM teams
WHERE yearid >='1970' AND wswin='Y'
ORDER BY yearid
-- By googling year id, the players were on strike in 1981 and hence the lower total no.of wins with 110games vs 160's games

-- Redo the above query adding Yearid skipping 1981 to sum wins by team only cumulatively and did win the World Series (Smallest Wins )
SELECT teamid, name, yearid, w as total_wins, wswin, g
FROM teams
WHERE yearid >='1970' AND yearid<>'1981' AND wswin='Y'
ORDER BY total_wins DESC
-- By googling year id, the players were on strike in 1981 and hence the lower total no.of wins with 110games vs 160's games

-- Find the Max wins that also was part of WS from 1970-2016
SELECT max(w) as max_wins, wswin, yearid
FROM teams
WHERE yearid >='1970' AND yearid<>'1981'
GROUP BY yearid,  wswin
ORDER BY yearid

--Codes to See
with w as (select yearid, max(w) as ww, WSWin
		from teams
		where yearid > 1969
		and yearid != 1981
		and wswin = 'Y'
		group by yearid, wswin
		order by yearid desc),
	l as (select yearid, max(w) as lw, WSWin
		from teams
		where yearid > 1969
		and yearid != 1981
		and wswin = 'N'
		group by yearid, wswin
		order by yearid desc)
select round(sum(case when ww > lw then cast('1.0' as decimal)
			when ww <= lw then cast('0.0' as decimal) end)/
			count(distinct w.yearid), 2)
from w
join l
on w.yearid = l.yearid

--World series win count by team
SELECT teamid, name, count(wswin) as t_ws_wins
from teams
WHERE yearid >= '1970' AND wswin ='Y'
GROUP  BY teamid, name
ORDER BY t_ws_wins DESC

--World series wins by teams and year
SELECT teamid, yearid, wswin, name
from teams
WHERE yearid >= '1970' AND wswin ='Y'
ORDER BY teamid


/*
Then redo your query, excluding the problem year.
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?
*/

WITH decades as (	
				SELECT 	generate_series(1920,2010,10) as low_b,
						generate_series(1929,2019,10) as high_b)
SELECT 	low_b as decade,
		--SUM(so) as strikeouts,
		--SUM(g)/2 as games,  -- used last 2 lines to check that each step adds correctly
		ROUND(SUM(so::numeric)/(sum(g::numeric)/2),2) as SO_per_game,  -- note divide by 2, since games are played by 2 teams
		ROUND(SUM(hr::numeric)/(sum(g::numeric)/2),2) as hr_per_game
FROM decades LEFT JOIN teams
	ON yearid BETWEEN low_b AND high_b
GROUP BY decade
ORDER BY decade;

/*Using the attendance figures from the homegames table,
find the teams and parks which had the top 5 average attendance per game in 2016
(where average attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/


-- Top Attendance by Park  
WITH p AS (
			SELECT park_name, park, city
			FROM parks)
--CTE for park info
SELECT p.park_name, sum(attendance)/sum(games) AS att_per_game, p.city
FROM homegames
JOIN p
using (park)
WHERE year='2016'
GROUP BY p.park_name, p.city
ORDER BY att_per_game DESC
LIMIT 5;

-- Top Attendance by teams 
WITH t AS (
			SELECT park_name, park, city
			FROM parks)
--CTE for park info
SELECT p.park_name, sum(attendance)/sum(games) AS att_per_game, p.city
FROM homegames
JOIN p
using (park)
WHERE year='2016'
GROUP BY p.park_name, p.city
ORDER BY att_per_game DESC
LIMIT 5;