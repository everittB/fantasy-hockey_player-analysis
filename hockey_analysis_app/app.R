library(shiny)
library(tidyverse)
library(lubridate)
library(plotly)


# Load data
players <- read_delim("./data/players.txt", delim = ",", trim_ws = TRUE)
teams <- read_delim("./data/teams.txt", delim = ",", trim_ws = TRUE)
goalie_stats <- read_delim("./data/goalie_stats.txt", delim = ",", trim_ws = TRUE)

# Data wrangling for players who played on multiple teams in a single year, dealing with TOI 
player_stats <- read_delim("./data/skaters_stats.txt", delim = ",", trim_ws = TRUE) %>% 
  mutate(season = as.character(season)) %>% 
  mutate(season = as.character(str_replace(season, 
                                           str_sub(season, start = 5, end = 8), 
                                           paste("/", str_sub(season, start = 7, end = 8), sep = "")
                                           )
                              )
        )%>% 
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


# Get forwards player list  
forwards_list <-  players %>% 
  filter(posType == "Forward" ) %>% 
  arrange(fullName) %>% 
  pull(fullName) %>% 
  as.list()

# Get defence player list  
defense_list <-  players %>% 
  filter(posType == "Defenseman" ) %>% 
  arrange(fullName) %>%
  pull(fullName) %>% 
  as.list()

# Get goalies list  
goalie_list <-  players %>% 
  filter(posType == "Goalie" ) %>% 
  arrange(fullName) %>%
  pull(fullName) %>% 
  as.list()

# Define UI for application
ui <- navbarPage("Fantasy Hockey Analysis", id="pages",
                 
  # Create forwards page
  tabPanel("Forwards", value = "Forward",
           
    fluidPage(title = "Forwards",
              
      fluidRow(selectInput("forwardPlayers",
                           label = "Forwards",
                           choices = forwards_list,
                           multiple = TRUE,
                           width = "100%")
              ),
      
      h4("Points"),
      plotlyOutput("pts_plot_fwds"),
      h4("Games"),
      plotlyOutput("gms_plot_fwds"),
      h4("Shooting Percentage"),
      plotlyOutput("shot_perc_plot")
    )
  ),
  
  # Create defense page
  tabPanel("Defense", value = "Defenseman", 
           
    fluidPage(title = "Defense",
    
      fluidRow(selectInput("defenseman",
                           label = "Defenseman",
                           choices = defense_list,
                           multiple = TRUE,
                           width = "100%")
              ),
      
      h4("Points"),
      plotlyOutput("pts_plot_def"),
      h4("Games"),
      plotlyOutput("gms_plot_def"),
      h4("Time on Ice"),
      plotlyOutput("avg_TOI_plot")
    )
  ),
  
  # Create goalies page
  tabPanel("Goalies", value = "Goalie", 
    
    fluidPage(title = "Goalies",
              
      fluidRow(selectInput("goalies",
                           label = "Goalies",
                           choices = goalie_list,
                           multiple = TRUE,
                           width = "100%")
      ),
              
      plotlyOutput("pts_plot3")
    )
  )
)


# Define server logic required to make pages
server <- function(input, output) {
  
  
  # Select the players based off the current tab
  select_players <- function(cur_page){
    if (cur_page == "Forward"){
      selected_players <- player_stats %>%
        filter(fullName %in% input$forwardPlayers)
    } else if (cur_page == "Defenseman"){
      selected_players <- player_stats %>%
        filter(fullName %in% input$defenseman)
    } else{
      selected_players <- goalie_stats %>%
        filter(fullName %in% input$goalies)
    }
    return(selected_players)
  }
  
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
  
  
  # Watch for page and selected players 
  selected_players <- reactive(select_players(input$pages))
  
  output$pts_plot_fwds <- output$pts_plot_def <-renderPlotly({
    create_pts_plot(selected_players())
  })
  
  output$gms_plot_fwds <- output$gms_plot_def <- renderPlotly({
    create_gms_plot(selected_players())
  })
  
  output$shot_perc_plot <- renderPlotly({
    create_shot_perc_plot(selected_players())
  })
  
  output$avg_TOI_plot <- renderPlotly({
    create_avg_TOI_plot(selected_players())
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

