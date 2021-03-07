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
				
select playerid, case when pos = 'OF' then 'Outfield'
						/*when pos = ('SS', '1B', '2B', '3B') then 'Infield'*/
						when pos = 'P' then 'Battery' 
						when pos = 'C' then 'Battery' else 'na' end as 'Position',
						
		year
from fielding
order by p
				
/*Question 5- Find the average number of strikeouts per game by decade since 1920. 
				Round the numbers you report to 2 decimal places. 
				Do the same for home runs per game. 
				Do you see any trends?*/
				
select round(avg(soa), 2), left(cast(yearid as varchar(4)), 3) as decade
from teams
group by decade
order by decade

select *
from teams
				
/*Question 6- Find the player who had the most success stealing bases in 2016, 
				where success is measured as the percentage of stolen base attempts which are successful. 
				(A stolen base attempt results either in a stolen base or being caught stealing.) 
				Consider only players who attempted at least 20 stolen bases.
				
/*Question 7- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
				What is the smallest number of wins for a team that did win the world series? 
				Doing this will probably result in an unusually small number of wins for a world series champion 
				– determine why this is the case. 
				Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that 
				a team with the most wins also won the world series? What percentage of the time?*/
				
/*Question 8- Using the attendance figures from the homegames table, find the teams and parks which had the 
				top 5 average attendance per game in 2016 
				(where average attendance is defined as total attendance divided by number of games). 
				Only consider parks where there were at least 10 games played. 
				Report the park name, team name, and average attendance. 
				Repeat for the lowest 5 average attendance.
				
/*Question 9- Which managers have won the TSN Manager of the Year award in both 
				the National League (NL) and the American League (AL)? 
				Give their full name and the teams that they were managing when they won the award.
