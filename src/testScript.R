library(tidyverse)
library(plotly)
library(lubridate)

# Load data
players <- read_delim("./hockey_analysis_app/data/players.txt", delim = ",", trim_ws = TRUE)

teams <- read_delim("./hockey_analysis_app/data/teams.txt", delim = ",", trim_ws = TRUE)

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
  select(-mins, -secs)
 
  
  
goalie_stats <- players %>% 
  filter(posType == "Goalie") %>% 
  left_join(goalie_stats, by = c("playerID" = "playerID")) %>% 
  mutate(playerID = as.factor(playerID))


player_stats <- players %>% 
  filter(posType != "Goalie") %>% 
  left_join(player_stats, by = c("playerID" = "playerID")) %>% 
  mutate(playerID = as.factor(playerID))

play_plot <- player_stats %>%  
  head(50) %>% 
  ggplot(aes(x=season, y=points, group = playerID, color = fullName)) +
    geom_point(stat = 'summary', fun.y = sum) +
    stat_summary(fun.y = sum, geom = "line") +
    ggtitle("Season Point Totals") +
    xlab("Season") + 
    ylab("Points") + 
    scale_color_brewer(palette = "Spectral") +
    theme_bw() +
    theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45))

ggplotly(play_plot, tooltip = c("colour", "y"))

ggplotly(player_stats %>% 
  head(50) %>% 
  mutate(shooting_perc = round(goals/shots,2)*100) %>% 
  ggplot(aes(x=season, y=shooting_perc, group = playerID, color = fullName)) +
    geom_point(stat = 'summary', fun.y = sum) +
    stat_summary(fun.y = sum, geom = "line") +
    ylab("Shooting Percentage(%)") + 
    xlab("Season") +
    scale_color_discrete("Players") +
    theme_bw() +
    theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
  tooltip = c("colour", "y")
)

ggplotly(player_stats %>% 
           head(50) %>%
           ggplot(aes(x=season, y=games, group = playerID, color = fullName)) +
           geom_point(stat = 'summary', fun.y = sum) +
           stat_summary(fun.y = sum, geom = "line") +
           ylab("# of Games Played") + 
           xlab("Season") +
           scale_color_discrete("Players") +
           theme_bw() +
           theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
         tooltip = c("colour", "y")
)

ggplotly(player_stats %>% 
           head(50) %>%
           ggplot(aes(x=season, y=avg_timeOnIce, group = playerID, color = fullName)) +
           geom_point(stat = 'summary', fun.y = sum) +
           stat_summary(fun.y = sum, geom = "line") +
           ylab("Average TOI (minutes)") + 
           xlab("Season") +
           scale_color_discrete("Players") +
           theme_bw() +
           theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
         tooltip = c("colour", "y")
)


  
  
  
  