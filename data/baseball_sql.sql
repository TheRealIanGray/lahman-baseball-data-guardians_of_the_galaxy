/*Question 1- What range of years for baseball games played does the provided database cover?*/
/*select min(yearid) as min, max(yearid) as max
from batting*/
--1817-2016



/*Question 2- Find the name and height of the shortest player in the database. 
			How many games did he play in? 
			What is the name of the team for which he played?*/

/*select distinct p.playerid, namegiven, namefirst, namelast, height, t.name as teamname
from people as p
left join batting as b
on p.playerid = b.playerid
left join teams as t
on t.teamid=b.teamid
where p.playerid='gaedeed01'
order by height asc*/



/*Question 3- Find all players in the database who played at Vanderbilt University. 
				Create a list showing each player’s first and last names as well as the total salary 
				they earned in the major leagues. Sort this list in descending order by the total salary earned. 
				Which Vanderbilt player earned the most money in the majors?*/

/*with vandy_players as 
			(select distinct playerid
			from collegeplaying
			where schoolid = 'vandy'),
	sal as 
			(select sum(salary) as salaryx, playerid
			from salaries
			group by playerid)
select p.namelast, p.namefirst, sal.salaryx
from vandy_players
inner join sal
on vandy_players.playerid = sal.playerid
inner join people as p
on vandy_players.playerid = p.playerid
order by sal.salaryx desc*/



/*Question 4- Using the fielding table, group players into three groups based on their position: 
				label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
				and those with position "P" or "C" as "Battery". 
				Determine the number of putouts made by each of these three groups in 2016.*/
				
/*select sum(PO), case when pos = 'OF' then 'Outfield'
						when pos in ('SS', '1B', '2B', '3B') then 'Infield'
						when pos = 'P' then 'Battery' 
						when pos = 'C' then 'Battery' else 'na' end as Position
from fielding
where yearid = '2016'
group by Position
order by Position*/
		
		

/*Question 5- Find the average number of strikeouts per game by decade since 1920. 
				Round the numbers you report to 2 decimal places. 
				Do the same for home runs per game. 
				Do you see any trends?*/

/*select round((sum(cast(so as decimal)))/sum(cast(g as decimal)/2), 2) as avg_strikout_by_game, 
				round(sum(cast(hr as decimal)) / sum(cast(g as decimal)/2), 2) as avg_homerun_by_game,
				left(cast(yearid as varchar(4)), 3) || '0s' as decade
from teams as t
group by decade
order by decade*/


	
/*Question 6- Find the player who had the most success stealing bases in 2016, 
				where success is measured as the percentage of stolen base attempts which are successful. 
				(A stolen base attempt results either in a stolen base or being caught stealing.) 
				Consider only players who attempted at least 20 stolen bases.*/
				
/*select playerid, round((cast(sb as decimal)/(cast(sb as decimal) + cast(cs as decimal))),2) as stolen
from batting
where yearid = '2016'
		and (sb + cs) > 19
order by stolen desc*/

				
				
/*Question 7- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?*/
				
/*select teamid, yearid, w, WSWin, name
from teams
where yearid > 1969
and wswin = 'N'
order by w desc
limit 1*/

/*What is the smallest number of wins for a team that did win the world series?*/

/*select teamid, yearid, w, WSWin
from teams
where yearid > 1969
and wswin = 'Y'
order by w asc
limit 1*/

/*Doing this will probably result in an unusually small number of wins for a world series champion 
				– determine why this is the case.*/

/*select max(w), min(w), yearid, WSWin
from teams
group by yearid, wswin
order by yearid desc*/

/*Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that 
				a team with the most wins also won the world series? What percentage of the time?*/

/*with w as (select yearid, max(w) as ww, WSWin
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
on w.yearid = l.yearid*/

/*where (SELECT max(w) as max_wins, wswin, yearid
FROM teams
WHERE yearid >='1970' AND yearid<>'1981'
GROUP BY yearid,  wswin
ORDER BY yearid)*/
	
	
	
/*Question 8- Using the attendance figures from the homegames table, find the teams and parks which had the 
				top 5 average attendance per game in 2016 
				(where average attendance is defined as total attendance divided by number of games). 
				Only consider parks where there were at least 10 games played. 
				Report the park name, team name, and average attendance. 
				Repeat for the lowest 5 average attendance.*/

/*Parks top 5 attendance*/
/*with p as (select park_name, park
			from parks)
select p.park_name, sum(attendance)/sum(games) as att_ratio
from homegames as hg
join p 
on hg.park = p.park
where year = 2016
group by p.park_name
having sum(games) > 9
order by att_ratio desc
limit 5*/

/*Teams top 5 attendance*/
/*with t as (select teamid, name
			 from teams)
select name, sum(attendance)/sum(games) as att_ratio
from homegames as hg
join t 
on hg.team = t.teamid
where year = 2016
group by name
order by att_ratio desc
limit 5*/



/*Question 9- Which managers have won the TSN Manager of the Year award in both 
				the National League (NL) and the American League (AL)? 
				Give their full name and the teams that they were managing when they won the award.*/

--had to include duplicated/reversed CTE to get distinct year values for when the two awards were won each year
--instead of just a single year, which would have meant only finding one of the teams coached at the time.


/*with nl as (select playerid, yearid
			from awardsmanagers
			where awardid = 'TSN Manager of the Year'
			and lgid = 'NL'
			and playerid in (select playerid
				from awardsmanagers
				where awardid = 'TSN Manager of the Year'
				and lgid = 'AL')),
	al as (select playerid, yearid
			from awardsmanagers
			where awardid = 'TSN Manager of the Year'
			and lgid = 'AL'
			and playerid in (select playerid
				from awardsmanagers
				where awardid = 'TSN Manager of the Year'
				and lgid = 'NL'))
select namelast||' '||namefirst, m.yearid, name
from (select *
	 from nl 
	 union all
	 select *
	 from al) as something
join people as p
on something.playerid = p.playerid
join managers as m
on m.playerid = p.playerid
and m.yearid = something.yearid
join teams as t
on m.teamid = t.teamid
and m.yearid = t.yearid
order by yearid desc*/

/*Question 10- Analyze all the colleges in the state of Tennessee. Which college has had the 
				most success in the major leagues. Use whatever metric for success you like 
				- number of players, number of games, salaries, world series wins, etc.*/
				
/*select s.schoolid, s.schoolname, count(distinct cp.playerid) as player_count
from collegeplaying as cp
join schools as s
on s.schoolid = cp.schoolid
where schoolstate = 'TN' 
group by s.schoolid
order by player_count desc*/


/*Question 11- Is there any correlation between number of wins and team salary? 
				Use data from 2000 and later to answer this question. 
				As you do this analysis, keep in mind that salaries across the 
				whole league tend to increase together, 
				so you may want to look on a year-by-year basis.*/
				
				
/*select t.teamid, t.yearid, sum(w)/count(distinct playerid) as w_sum, sum(salary) as s_sum
from salaries as s
join teams as t
on s.teamid = t.teamid and s.yearid = t.yearid
where t.yearid > '1999'
group by t.teamid, t.yearid
order by t.yearid desc, w_sum desc*/



/*Question 12- In this question, you will explore the connection between number of wins and attendance.
				Does there appear to be any correlation between attendance 
				at home games and number of wins?
				Do teams that win the world series see a boost in 
				attendance the following year? What about teams that 
				made the playoffs? Making the playoffs means either being a 
				division winner or a wild card winner.*/
				
				
/*Question 13- It is thought that since left-handed pitchers are more rare, 
				causing batters to face them less often, that they are more effective. 
				Investigate this claim and present evidence to either support or dispute this claim. 
				First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
				Are left-handed pitchers more likely to win the Cy Young Award? 
				Are they more likely to make it into the hall of fame?*/

/*select peo.namefirst||' '||peo.namelast as name, 
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
order by outs_ratio desc*/

