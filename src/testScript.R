library(tidyverse)
library(plotly)

# Load data
players <- read_delim("./hockey_analysis_app/data/players.txt", delim = ",", trim_ws = TRUE)
teams <- read_delim("./hockey_analysis_app/data/teams.txt", delim = ",", trim_ws = TRUE)
goalie_stats <- read_delim("./hockey_analysis_app/data/goalie_stats.txt", delim = ",", trim_ws = TRUE)
player_stats <- read_delim("./hockey_analysis_app/data/skaters_stats.txt", delim = ",", trim_ws = TRUE) %>% 
  mutate(season = as.character(season)) %>% 
  mutate(season = as.character(str_replace(season, 
                                        str_sub(season, start = 5, end = 8), 
                                        paste("/", str_sub(season, start = 7, end = 8), sep = "")
                                        )
                            )
         )
  
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
