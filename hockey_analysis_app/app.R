# Define R Shiny App Server and Interface  
# Brenden Everitt  

library(shiny)
library(tidyverse)
library(lubridate)
library(plotly)
library(DT)

# Load helper functions for creating plots 
source("./src/app_functions.R")


# Load data
players <- read_delim("./data/players.txt", delim = ",", trim_ws = TRUE)
teams <- read_delim("./data/teams.txt", delim = ",", trim_ws = TRUE)

# Data wrangling for goalies who played on multiple teams in a single year
goalie_stats <- read_delim("./data/goalie_stats.txt", delim = ",", trim_ws = TRUE)%>% 
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
player_stats <- read_delim("./data/skaters_stats.txt", delim = ",", trim_ws = TRUE) %>% 
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
                 
   # C
  tabPanel("Home", value = "Home",
           
    fluidPage(title = "Player Comparison",
              
      tabsetPanel(
        tabPanel("Forwards", value = "home_fwds", 
                 plotlyOutput("fwds_comparison")),
        tabPanel("Defense", value = "home_defs", 
                 plotlyOutput("defs_comparison")),
        tabPanel("Goalies", value = "home_gols",
                 plotlyOutput("gols_comparison")),
        id = "home"
        
      )
    )
  ),  
                 
  # Create forwards page
  tabPanel("Forward Analysis", value = "Forward",
           
    fluidPage(title = "Forwards",
              
      fluidRow(selectInput("forwards",
                           label = "Forwards",
                           choices = forwards_list,
                           multiple = TRUE,
                           selected = "Connor McDavid",
                           width = "100%")
              ),
      fluidRow(
        tabsetPanel(
          tabPanel("Points", value = "fwd_pts",
                   plotlyOutput("pts_plot_fwds")
          ),
          tabPanel("Shooting Percentage", value = "fwd_sht",
                   plotlyOutput("shot_perc_plot")
          ),
          tabPanel("Games", value = "fwd_gms",
                   plotlyOutput("gms_plot_fwds")
          ),
          id = "fwds"
        )
      ),
      fluidRow(
        dataTableOutput("fwds_table") 
      )
    )
  ),
  
  # Create defense page
  tabPanel("Defense Analysis", value = "Defenseman", 
           
   fluidPage(title = "Defense",
    
      fluidRow(selectInput("defenseman",
                           label = "Defenseman",
                           choices = defense_list,
                           multiple = TRUE,
                           selected = "Brent Burns",
                           width = "100%")
              ),
      fluidRow(
        tabsetPanel(
          tabPanel("Points", value = "def_pts",
                   plotlyOutput("pts_plot_def")
          ),
          tabPanel("Time on Ice", value = "def_toi",
                   plotlyOutput("avg_TOI_plot")
          ),
          tabPanel("Games", value = "def_gms",
                   plotlyOutput("gms_plot_def")
          ),
          id = "defs"
        )
      ),
      fluidRow(
        dataTableOutput("def_table") 
      )
    )
  ),
  
  # Create goalies page
  tabPanel("Goalie Analysis", value = "Goalie", 
    
    fluidPage(title = "Goalies",
              
      fluidRow(selectInput("goalies",
                           label = "Goalies",
                           choices = goalie_list,
                           multiple = TRUE,
                           selected = "Matt Murray",
                           width = "100%")
      ),
      fluidRow(
        tabsetPanel(
          tabPanel("Wins", value = "gol_wins",
                   plotlyOutput("wins_plot")
          ),
          tabPanel("Games", value = "gol_gms",
                   plotlyOutput("gms_plot_goals")
          ),
          tabPanel("Shutouts", value = "gol_sht",
                   plotlyOutput("shutouts_plot")
          ),
          tabPanel("Overtime Losses", value = "gol_otl",
                   plotlyOutput("ot_losses_plot")
          ),
          id = "defs"
        )
      ),
      fluidRow(
        dataTableOutput("gols_table") 
      )
    )
  )
)


# Define server logic required to make pages
server <- function(input, output) {
  
  # Select the players based off the current page and tab
  selected_players <- reactive({
    if (input$pages == "Home"){
      if (input$home == "home_fwds"){
        selected_players <- player_comparison %>% 
          filter(posType == "Forward")
      }else if (input$home == "home_defs"){
        selected_players <- player_comparison %>% 
          filter(posType == "Defenseman")
      }else if (input$home == "home_gols"){
        selected_players <- goalie_comparison
      }
    } else if (input$pages == "Forward"){
      selected_players <- player_stats %>%
        filter(fullName %in% input$forwards)
    } else if (input$pages == "Defenseman"){
      selected_players <- player_stats %>%
        filter(fullName %in% input$defenseman)
    } else if (input$pages == "Goalie"){
      selected_players <- goalie_stats %>%
        filter(fullName %in% input$goalies)
    }
    return(selected_players)
  })
  
  output$fwds_comparison <- output$defs_comparison <- renderPlotly({
    create_player_comparison_plot(selected_players())
  })  
  
  output$gols_comparison <- renderPlotly({
    create_goalie_comparison_plot(selected_players())
  })

  output$pts_plot_fwds <- output$pts_plot_def <- renderPlotly({
    create_pts_plot(selected_players())
  })

  output$gms_plot_fwds <- output$gms_plot_def <- output$gms_plot_goals<- renderPlotly({
    create_gms_plot(selected_players())
  })

  output$shot_perc_plot <- renderPlotly({
    create_shot_perc_plot(selected_players())
  })

  output$avg_TOI_plot <- renderPlotly({
    create_avg_TOI_plot(selected_players())
  })

  output$wins_plot <- renderPlotly({
    create_wins_plot(selected_players())
  })

  output$ot_losses_plot <- renderPlotly({
    create_ot_losses_plot(selected_players())
  })

  output$shutouts_plot <- renderPlotly({
    create_shutouts_plot(selected_players())
  })
  
  output$fwds_table <- output$def_table <-  renderDataTable(datatable(
    player_stats %>%
      filter(posType == input$pages & 
               (fullName %in% input$forwards | fullName %in% input$defenseman)) %>% 
      select(fullName,
             season,
             games,
             points,
             timeOnIce,
             shots),
    colnames = c("Name" = "fullName",
                 "Season" = "season",
                 "Games" = "games",
                 "Points" = "points",
                 "TOI" = "timeOnIce",
                 "Shots" = "shots"
    ),
    options = list(pageLength = 10)
  )
)
  output$gols_table <- renderDataTable(datatable(
   goalie_stats %>% 
     filter(fullName %in% input$goalies) %>% 
     select(fullName,
            season,
            games,
            wins,
            losses,
            ot_losses,
            shutouts),
   colnames = c("Name" = "fullName",
                "Season" = "season",
                "Games" = "games",
                "Wins" = "wins",
                "Losses" = "losses",
                "OTL" = "ot_losses",
                "Shutouts" = "shutouts"
   ),
   options = list(pageLength = 10)
  )
)
  
}

# Run the application 
shinyApp(ui = ui, server = server)

