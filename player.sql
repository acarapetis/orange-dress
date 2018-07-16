DROP VIEW IF EXISTS player_percentages;
DROP VIEW IF EXISTS player_stats;
DROP VIEW IF EXISTS players;

CREATE VIEW players AS
SELECT spy as name FROM game GROUP BY spy
UNION DISTINCT
SELECT sniper as name FROM game GROUP BY sniper;

CREATE VIEW player_stats AS
SELECT name, 
    (SELECT COUNT(*) FROM game WHERE spy=name OR sniper=name) AS total_games,
    (SELECT COUNT(*) FROM game WHERE sniper=name) AS sniper_games, 
    (SELECT COUNT(*) FROM game WHERE spy=name) AS spy_games,
    (SELECT COUNT(*) FROM game_view WHERE winner_name=name) AS wins,
    (SELECT COUNT(*) FROM game WHERE spy=name AND result='MISSIONS_WIN') AS spy_completions,
    (SELECT COUNT(*) FROM game WHERE spy=name AND result='SPY_TIMEOUT') AS spy_timeouts,
    (SELECT COUNT(*) FROM game WHERE spy=name AND result='SPY_SHOT') AS spy_deaths,
    (SELECT COUNT(*) FROM game WHERE spy=name AND result='CIVILIAN_SHOT') AS spy_frames,
    (SELECT COUNT(*) FROM game WHERE sniper=name AND result='MISSIONS_WIN') AS sniper_completions,
    (SELECT COUNT(*) FROM game WHERE sniper=name AND result='SPY_TIMEOUT') AS sniper_timeouts,
    (SELECT COUNT(*) FROM game WHERE sniper=name AND result='SPY_SHOT') AS sniper_hits,
    (SELECT COUNT(*) FROM game WHERE sniper=name AND result='CIVILIAN_SHOT') AS sniper_misses
FROM players;

CREATE VIEW player_percentages AS
SELECT
    name,
    total_games as total_games,
    sniper_games/total_games as sniper,
    spy_games/total_games as spy,
    wins/total_games as wins,
    spy_completions/spy_games as spy_completions,
    spy_timeouts/spy_games as spy_timeouts,
    spy_deaths/spy_games as spy_deaths,
    spy_frames/spy_games as spy_frames,
    sniper_completions/sniper_games as sniper_completions,
    sniper_timeouts/sniper_games as sniper_timeouts,
    sniper_hits/sniper_games as sniper_hits,
    sniper_misses/sniper_games as sniper_misses
FROM player_stats;
