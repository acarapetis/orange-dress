select map.name, IF((sniper='pox' and winner='SNIPER') or (spy='pox' and winner='SPY'), 'win', 'lose') as res, count(*) 
from game inner join map on game.map = map.hash 
where sniper='pox' or spy='pox' 
group by map,res order by map;
