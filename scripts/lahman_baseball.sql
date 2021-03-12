/* Q1 - What range of years for baseball games played does the provided database cover?*/


Select DISTINCT(yearid)
FROM appearances
ORDER BY yearid;

/*Q2 - Find the name and height of the shortest player in the database. 
			How many games did he play in? 
			What is the name of the team for which he played?
Eddie Gaedel was the shortest player at 43 inches, he played for the St. Louis Browns */ 

SELECT namefirst, namelast, height, playerid
FROM people
ORDER BY height;

SELECT *
FROM appearances
WHERE playerid = 'gaedeed01';

SELECT DISTINCT(name)
FROM teams
WHERE teamid = 'SLA';

/* Q3 - Find all players in the database who played at Vanderbilt University. */
--Subquery for Vanderbilt
-- Identify school id
-- David Price earned the highest salary at $30,000,000 -- 

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

SELECT *
FROM salaries AS s
WHERE s.playerid IN
	(SELECT DISTINCT p.playerid 
	FROM collegeplaying AS cp
INNER JOIN people AS p 
ON cp.playerid = p.playerid
WHERE cp.schoolid = 'vandy')
ORDER BY salary DESC;

SELECT DISTINCT namefirst, namelast
FROM people
WHERE playerid = 'priceda01';

/* Q4 - Using the fielding table, group players into three groups based on their position:
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.
*/
-- infield putouts: 58934, battery putouts: 41424, outfield putouts: 29560 --

SELECT *
FROM fielding;

SELECT yearid, SUM(po) AS putouts,
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	END AS field_group
FROM fielding
WHERE yearid = 2016
GROUP BY yearid, field_group
ORDER BY putouts DESC;

/* Q5 - Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places.
Do the same for home runs per game. Do you see any trends? */

SELECT * 
FROM batting
WHERE yearid >= '1920';

SELECT * 
FROM battingpost; 

SELECT yearid AS decade, ROUND(AVG(so),2) AS avg_strikeouts, 
	ROUND(AVG(hr),2) AS avg_homeruns
FROM batting
WHERE yearid >= '1920'
GROUP BY decade
ORDER BY decade;

-- 5. Both average strikeouts and average homeruns generally trend higher each decade --

/*SELECT * 
FROM batting
WHERE yearid >= '1920';

SELECT * 
FROM battingpost;*/  

SELECT TRUNC(yearid, -1) AS decade, ROUND((SUM(CAST(so AS decimal))) / SUM(CAST(g AS decimal)/2), 2) AS avg_strikeouts, 
	ROUND(SUM(CAST(hr AS decimal)) / SUM(CAST(g AS decimal)/2),2) AS avg_homeruns
FROM teams
WHERE TRUNC(yearid, -1) >= '1920'
GROUP BY decade
ORDER BY decade;

/* Q6 - Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases. */

SELECT playerid, ROUND((CAST(sb AS decimal)/(CAST(sb AS decimal) + CAST(cs AS decimal))),2) AS stolen
FROM batting
WHERE yearid = '2016'
AND (sb + cs) > 19
ORDER BY stolen DESC;



/* Q7 - From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
What is the smallest number of wins for a team that did win the world series?
Doing this will probably result in an unusually small number of wins for a world series champion
	– determine why this is the case.*/

SELEct * 
FROM teams;

SELECT teamid, yearid, w, wswin, g
FROM teams
WHERE yearid > 1969
AND wswin = 'N'
ORDER BY w DESC;

SELECT teamid, yearid, w, wswin
FROM teams
WHERE yearid > 1969
AND wswin = 'Y'
ORDER BY w ASC;

-- players were on strike 1981 -- 

SELECT MAX(w), MIN(w), yearid, wswin
FROM teams
GROUP BY yearid, wswin
ORDER BY yearid DESC;


with w AS (SELECT yearid, MAX(w) AS ww, wswin
		FROM teams
		WHERE yearid > 1969
		AND yearid <> 1981
		AND wswin = 'Y'
		GROUP BY yearid, wswin
		ORDER BY yearid DESC),
	l AS (SELECT yearid, MAX(w) AS lw, wswin
		FROM teams
		WHERE yearid > 1969
		AND yearid <> 1981
		AND wswin = 'N'
		GROUP BY yearid, wswin
		ORDER BY yearid DESC)
SELECT ROUND(SUM(CASE WHEN ww > lw THEN CAST('1.0' AS decimal)
			WHEN ww <= lw THEN CAST('0.0' AS decimal) END)/
			COUNT(DISTINCT w.yearid), 2)
FROM w
JOIN l
ON w.yearid = l.yearid;

/* Q8 - Using the attendance figures from the homegames table,
find the teams and parks which had the top 5 average attendance per game in 2016
(where average attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

SELECT MAX(attendance) AS max_att
FROM homegames
LIMIT 5;

with p AS (SELECT park_name, park
			FROM parks)
SELECT p.park_name, SUM(attendance)/SUM(games) AS att_ratio
FROM homegames AS hg
JOIN p 
USING (park)
WHERE year = 2016
GROUP BY p.park_name
HAVING SUM(games) > 9
ORDER BY att_ratio DESC
LIMIT 5

with t AS (SELECT teamid, name
			FROM teams)
SELECT name, SUM(attendance)/SUM(games) AS att_ratio
FROM homegames AS hg
JOIN t 
ON hg.team = t.teamid
WHERE year = 2016
GROUP BY name
HAVING SUM(games) > 9
ORDER BY att_ratio DESC
LIMIT 5


/* Q9 - Which managers have won the TSN Manager of the Year award in both the 
National League (NL) and the American League (AL)? Give their full name and 
the teams that they were managing when they won the award.*/

SELECT *
FROM awardsmanagers;

WITH tsn AS (SELECT *
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
	AND lgid = 'AL'
	AND playerid IN (SELECT playerid
		FROM awardsmanagers
		WHERE awardid ILIKE '%TSN%'
			AND lgid = 'NL')
UNION ALL
SELECT *
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
	AND lgid = 'NL'
	AND playerid IN (SELECT playerid
		FROM awardsmanagers
		WHERE awardid ILIKE '%TSN%'
			AND lgid = 'AL'))
SELECT p.namefirst||' '|| p.namelast, tsn.lgid, tsn.yearid, t.name
FROM tsn
JOIN people AS p 
USING (playerid)
JOIN managers AS m
USING (playerid, yearid)
JOIN teams AS t
USING (teamid,yearid)

/* Q10 - Analyze all the colleges in the state of Tennessee. Which college has had the 
	most success in the major leagues. Use whatever metric for success you like 
		- number of players, number of games, salaries, world series wins, etc.*/

SELECT * 
FROM collegeplaying;

SELECT * 
FROM schools;

SELECT s.schoolname, s.schoolid, COUNT(DISTINCT(cp.playerid)) AS player_count
FROM collegeplaying AS cp
JOIN schools AS s
USING (schoolid)
WHERE schoolstate = 'TN' 
GROUP BY s.schoolid
ORDER BY player_count DESC;

/*Q11 - Is there any correlation between number of wins and team salary? 
		Use data from 2000 and later to answer this question. 
		As you do this analysis, keep in mind that salaries across the 
		whole league tend to increase together, 
		so you may want to look on a year-by-year basis.*/

SELECT * 
FROM teams;

select t.teamid, t.yearid, SUM(w)/count(distinct playerid) as w_sum, sum(salary) as s_sum
from salaries as s
join teams as t
on s.teamid = t.teamid and s.yearid = t.yearid
where t.yearid > '1999'
group by t.teamid, t.yearid, t.w
order by t.yearid desc, w_sum desc

/*Question 12- In this question, you will explore the connection between number of wins and attendance.
				Does there appear to be any correlation between attendance 
				at home games and number of wins?
				Do teams that win the world series see a boost in 
				attendance the following year? What about teams that 
				made the playoffs? Making the playoffs means either being a 
				division winner or a wild card winner.*/
				
SELECT * 
FROM 

/*Question 13- It is thought that since left-handed pitchers are more rare, 
				causing batters to face them less often, that they are more effective. 
				Investigate this claim and present evidence to either support or dispute this claim. 
				First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
				Are left-handed pitchers more likely to win the Cy Young Award? 
				Are they more likely to make it into the hall of fame?*/

select peo.namefirst||' '||peo.namelast as name, 
			sum(hbp) as hit, 
			round(sum(cast(hbp as decimal))/sum(cast(bfp as decimal))*100, 2)||'%' as beaned_ratio, 
			sum(so) as outs, 
			round(sum(cast(so as decimal))/sum(cast(bfp as decimal))*100, 2)||'%' as outs_ratio, 
			throws,
			(select round(sum(cast(case when throws = 'L' then '1' else '0' end as decimal))/count(*), 2) 
			 as lefty_ratio from people)
from pitching as pit
join people as peo
on pit.playerid = peo.playerid
where bfp >0
group by throws, peo.namefirst, peo.namelast
having sum(so) > '1000'
order by outs_ratio desc
