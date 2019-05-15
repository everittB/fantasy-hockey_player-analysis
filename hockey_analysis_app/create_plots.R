# Create points per season plot
create_pts_plot <- function(players){
  pts_plot <- ggplotly(ggplot(data = players, aes(x=season, y=points, group = playerID, color = fullName)) +
                         geom_point(stat = 'summary', fun.y = sum) +
                         stat_summary(fun.y = sum, geom = "line") +
                         ggtitle(label = "", subtitle = "Season Point Totals") +
                         xlab("Season") +
                         ylab("Points") +
                         scale_color_discrete("Players") +
                         theme_bw() +
                         theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                       tooltip = c("y", "colour"))
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
                         theme_bw() +
                         theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                       tooltip = c("colour", "y"))
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
                               theme_bw() +
                               theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                             tooltip = c("colour", "y"))
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
                             theme_bw() +
                             theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                           tooltip = c("colour", "y"))
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
                          theme_bw() +
                          theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                        tooltip = c("colour", "y"))
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
                               theme_bw() +
                               theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                             tooltip = c("colour", "y"))
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
                              theme_bw() +
                              theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
                            tooltip = c("colour", "y"))
  return(shutouts_plot)
}