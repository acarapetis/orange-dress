CREATE VIEW game_view AS
SELECT *, 
    IF(winner='SPY', spy, sniper) AS winner_name,
    IF(winner='SPY', sniper, spy) AS loser_name
FROM game WHERE result != 'IN_PROGRESS';
