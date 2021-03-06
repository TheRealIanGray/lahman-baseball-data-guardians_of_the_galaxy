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

select *
from schools

select *
from salaries

select *
from collegeplaying
