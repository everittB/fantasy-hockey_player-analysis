# Functions used to help run the Shiny App

# Create points per season plot
create_pts_plot <- function(players){
  pts_plot <- ggplotly(ggplot(data = players, aes(x=season, y=points, group = playerID, color = fullName)) +
                         geom_point(stat = 'summary', fun.y = sum) +
                         stat_summary(fun.y = sum, geom = "line") +
                         ggtitle(label = "", subtitle = "Season Point Totals") +
                         xlab("Season") +
                         ylab("Points") +
                         scale_color_discrete("Players") +
                         scale_y_continuous(limits = c(0, NA)) +
                         theme_bw() +
                         theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
              tooltip = c("y", "colour"))
  
  pts_plot <- pts_plot %>% layout(dragmode = FALSE)
                       
  return(pts_plot)
}

# Create games played per season plot  
create_gms_plot <- function(players){
  gms_plot <- ggplotly(ggplot(data = players, aes(x=season, y=games, group = playerID, color = fullName)) +
                         geom_point(stat = 'summary', fun.y = sum) +
                         stat_summary(fun.y = sum, geom = "line") +
                         ylab("# of Games Played") + 
                         xlab("Season") +
                         scale_color_discrete("Players") +
                         scale_y_continuous(limits = c(0, NA)) +
                         theme_bw() +
                         theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                       tooltip = c("colour", "y"))
  
  gms_plot <- gms_plot %>% layout(dragmode = FALSE)
  
  return(gms_plot)
}

# Create shooting percentage plot 
create_shot_perc_plot <- function(players){
  shot_perc_plot <- ggplotly(players %>%  
                               ggplot(aes(x=season, y=shooting_perc, group = playerID, color = fullName)) +
                               geom_point(stat = 'summary', fun.y = sum) +
                               stat_summary(fun.y = sum, geom = "line") +
                               ylab("Shooting Percentage(%)") + 
                               xlab("Season") +
                               scale_color_discrete("Players") +
                               scale_y_continuous(limits = c(0, NA)) +
                               theme_bw() +
                               theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                             tooltip = c("colour", "y"))
  
  shot_perc_plot <- shot_perc_plot %>% layout(dragmode = FALSE)
  
  return(shot_perc_plot)
}

# Create average TOI plot  
create_avg_TOI_plot <- function(players){
  avg_TOI_plot <- ggplotly(players %>% 
                             ggplot(aes(x=season, y=avg_timeOnIce, group = playerID, color = fullName)) +
                             geom_point(stat = 'summary', fun.y = sum) +
                             stat_summary(fun.y = sum, geom = "line") +
                             ylab("Average TOI (minutes)") + 
                             xlab("Season") +
                             scale_color_discrete("Players") +
                             scale_y_continuous(limits = c(0, NA)) +
                             theme_bw() +
                             theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                           tooltip = c("colour", "y"))
  
  avg_TOI_plot <- avg_TOI_plot %>% layout(dragmode = FALSE)
  
  return(avg_TOI_plot)
}

# Create wins plot  
create_wins_plot <- function(players){
  wins_plot <- ggplotly(players %>% 
                          ggplot(aes(x=season, y=wins, group = playerID, color = fullName)) +
                          geom_point(stat = 'summary', fun.y = sum) +
                          stat_summary(fun.y = sum, geom = "line") +
                          ylab("# of Wins") + 
                          xlab("Season") +
                          scale_color_discrete("Players") +
                          scale_y_continuous(limits = c(0, NA)) +
                          theme_bw() +
                          theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                        tooltip = c("colour", "y"))
  
  wins_plot <- wins_plot %>% layout(dragmode = FALSE)
  
  return(wins_plot)
  
}

# Create overtime losses plot  
create_ot_losses_plot <- function(players){
  ot_losses_plot <- ggplotly(players %>% 
                               ggplot(aes(x=season, y=ot_losses, group = playerID, color = fullName)) +
                               geom_point(stat = 'summary', fun.y = sum) +
                               stat_summary(fun.y = sum, geom = "line") +
                               ylab("# of Overtime Losses") + 
                               xlab("Season") +
                               scale_color_discrete("Players") +
                               scale_y_continuous(limits = c(0, NA)) +
                               theme_bw() +
                               theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                             tooltip = c("colour", "y"))
  
  ot_losses_plot <- ot_losses_plot %>% layout(dragmode = FALSE)
  
  return(ot_losses_plot)
}

# Create shutouts plot  
create_shutouts_plot <- function(players){
  shutouts_plot <- ggplotly(players %>% 
                              ggplot(aes(x=season, y=shutouts, group = playerID, color = fullName)) +
                              geom_point(stat = 'summary', fun.y = sum) +
                              stat_summary(fun.y = sum, geom = "line") +
                              ylab("# of Overtime Losses") + 
                              xlab("Season") +
                              scale_color_discrete("Players") +
                              scale_y_continuous(limits = c(0, NA)) +
                              theme_bw() +
                              theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                            tooltip = c("colour", "y"))
  
  shutouts_plot <- shutouts_plot %>% layout(dragmode = FALSE) 
  
  return(shutouts_plot)
} 

create_player_comparison_plot <- function(players){
  comparison_plot <- ggplotly(players %>%
                                ggplot(aes(x=total_games, y = pts_per_games, label = fullName)) +
                                geom_point(alpha = 0.5) +
                                ylab("Points per Game") +
                                xlab("Total Games Played") +
                                theme_bw() +
                                theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                              tooltip = "label",
                              source = "brushed")
  
  comparison_plot <- comparison_plot %>% layout(dragmode = "select")
  
  return(comparison_plot)
}
  
create_goalie_comparison_plot <- function(players){
  comparison_plot <- ggplotly(players %>%
                                ggplot(aes(x=total_games, y = winning_perc, label = fullName)) +
                                geom_point(alpha = 0.5) +
                                ylab("Winning Percentage") +
                                xlab("Total Games Played") +
                                theme_bw() +
                                theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                              tooltip = "label",
                              dynamicTicks = TRUE,
                              source = "brushed")
  
  comparison_plot <- comparison_plot %>% layout(dragmode = FALSE)
  
  return(comparison_plot)
}