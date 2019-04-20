library(tidyverse)
library(plotly)

# Load data
players <- read_delim("./hockey_analysis_app/data/players.txt", delim = ",")
teams <- read_delim("./hockey_analysis_app/data/teams.txt", delim = ",")
goalie_stats <- read_delim("./hockey_analysis_app/data/goalie_stats.txt", delim = ",")
player_stats <- read_delim("./hockey_analysis_app/data/skaters_stats.txt", delim = ",") %>% 
  mutate(season = as.character(season)) %>% 
  mutate(season = as.character(str_replace(season, 
                                        str_sub(season, start = 5, end = 8), 
                                        paste("/", str_sub(season, start = 7, end = 8), sep = "")
                                        )
                            )
         )
  


play_plot <- players %>% 
  left_join(player_stats, by = c("playerID" = "playerID")) %>% 
  mutate(playerID = as.factor(playerID)) %>% 
  head(100) %>% 
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


goalie_stats <- players %>% 
  filter(posType == "Goalie") %>% 
  left_join(goalie_stats, by = c("playerID" = "playerID")) %>% 
  mutate(playerID = as.factor(playerID))
