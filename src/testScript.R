library(tidyverse)
library(lubridate)
library(plotly)


# Load data
players <- read_delim("./hockey_analysis_app/data/players.txt", delim = ",", trim_ws = TRUE)
teams <- read_delim("./hockey_analysis_app/data/teams.txt", delim = ",", trim_ws = TRUE)

# Data wrangling for goalies who played on multiple teams in a single year
goalie_stats <- read_delim("./hockey_analysis_app/data/goalie_stats.txt", delim = ",", trim_ws = TRUE)%>% 
  mutate(season = as.character(season)) %>% 
  mutate(season = as.character(str_replace(season, 
                                           str_sub(season, start = 5, end = 8), 
                                           paste("/", str_sub(season, start = 7, end = 8), sep = "")
  )
  )
  ) %>% 
  mutate(ot_losses = as.numeric(ot_losses)) %>% 
  group_by(playerID, season) %>% 
  summarise(games = sum(games), wins = sum(wins), losses = sum(losses),
            ot_losses = sum(ot_losses, na.rm = TRUE), shutouts = sum(shutouts))

# Data wrangling for players who played on multiple teams in a single year, dealing with TOI 
player_stats <- read_delim("./hockey_analysis_app/data/skaters_stats.txt", delim = ",", trim_ws = TRUE) %>% 
  mutate(season = as.character(season)) %>% 
  mutate(season = as.character(str_replace(season, 
                                           str_sub(season, start = 5, end = 8), 
                                           paste("/", str_sub(season, start = 7, end = 8), sep = "")
  )
  )
  ) %>% 
  mutate(timeOnIce = ms(timeOnIce)) %>% 
  mutate(secs = (minute(timeOnIce) * 60) + second(timeOnIce)) %>% 
  group_by(playerID, season) %>% 
  summarise(games = sum(games), secs = sum(secs), points = sum(points),
            goals = sum(goals), assists = sum(assists), shots = sum(shots)) %>% 
  mutate(mins = secs / 60) %>% 
  mutate(timeOnIce = floor(mins) + ((mins %% 1) * 0.6))%>% 
  mutate(avg_timeOnIce = mins/games) %>% 
  mutate(avg_timeOnIce = round(floor(avg_timeOnIce) + ((avg_timeOnIce %% 1) * 0.6),2)) %>% 
  mutate(shooting_perc = round(goals/shots,2)*100) %>% 
  select(-mins, -secs)

# Join players and their season statistics
player_stats <- players %>% 
  filter(posType != "Goalie") %>% 
  left_join(player_stats, by = c("playerID" = "playerID")) %>% 
  mutate(playerID = as.factor(playerID))

# Join goalies and their season statistics
goalie_stats <- players %>% 
  filter(posType == "Goalie") %>% 
  left_join(goalie_stats, by = c("playerID" = "playerID")) %>% 
  mutate(playerID = as.factor(playerID))  

# Player comparison wrangling 
player_comparison <- player_stats %>% 
  filter(games > 10) %>% 
  group_by(fullName, playerID, posType) %>% 
  summarise(pts_per_games = sum(points)/sum(games),
            total_games = sum(games))  

# Goalie comparison wrangling 
goalie_comparison <- goalie_stats %>% 
  filter(games > 10) %>% 
  group_by(fullName, playerID) %>% 
  summarise(winning_perc = sum(wins)/sum(games),
            total_games = sum(games))


comparison_plot <- ggplotly(player_comparison %>%
                              ggplot(aes(x=total_games, y = pts_per_games, label = fullName)) +
                              geom_point(alpha = 0.5) +
                              ylab("Points per Game") +
                              xlab("Total Games Played") +
                              theme_bw() +
                              theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                            tooltip = "label",
                            dynamicTicks = TRUE)
comparison_plot
highlight(comparison_plot, on = "plotly_selected", selectize = TRUE)

  
tmp
tmp
