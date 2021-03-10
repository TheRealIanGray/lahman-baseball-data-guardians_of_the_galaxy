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

-- 3. David Price earned the highest salary at $30,000,000 -- 

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

-- 4. infield putouts: 58934, battery putouts: 41424, outfield putouts: 29560 --

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

-- 5. --


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

-- 5. Both average strikeouts and average homeruns generally trend higher each decade --

-- 7. 

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

-- players were on strike -- 

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

-- 8. --

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
ORDER BY att_ratio DESC
LIMIT 5

