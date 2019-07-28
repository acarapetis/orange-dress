select date_format(time, '%Y%m') as month, count(*) as count from game where 'pox' in (spy,sniper) group by month;
