library(shiny)
library(tidyverse)
library(plotly)


# Load data
players <- read_delim("./data/players.txt", delim = ",", trim_ws = TRUE)
teams <- read_delim("./data/teams.txt", delim = ",", trim_ws = TRUE)
goalie_stats <- read_delim("./data/goalie_stats.txt", delim = ",", trim_ws = TRUE)
player_stats <- read_delim("./data/skaters_stats.txt", delim = ",", trim_ws = TRUE) %>% 
  mutate(season = as.character(season)) %>% 
  mutate(season = as.character(str_replace(season, 
                                           str_sub(season, start = 5, end = 8), 
                                           paste("/", str_sub(season, start = 7, end = 8), sep = "")
                                           )
                              )
        )

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
  pull(fullName) %>% 
  as.list()

# Get defence player list  
defense_list <-  players %>% 
  filter(posType == "Defenseman" ) %>% 
  pull(fullName) %>% 
  as.list()

# Get goalies list  
goalie_list <-  players %>% 
  filter(posType == "Goalie" ) %>% 
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
      
      plotlyOutput("pts_plot1")
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
      
      plotlyOutput("pts_plot2")
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
  
  create_pts_plot <- function(players){
     pts_plot <- ggplotly(ggplot(data = players, aes(x=season, y=points, group = playerID, color = fullName)) +
                geom_point(stat = 'summary', fun.y = sum) +
                stat_summary(fun.y = sum, geom = "line") +
                ggtitle("Season Point Totals") +
                xlab("Season") +
                ylab("Points") +
                scale_color_brewer("Players", palette = "Spectral") +
                theme_bw() +
                theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)),
              tooltip = c("y", "colour"))
     return(pts_plot)
  }
  
  current_page <- reactive(input$pages)
  selected_players <- reactive(select_players(current_page()))
  pts_plot <- reactive(create_pts_plot(selected_players()))
  output$pts_plot1 <- output$pts_plot2 <- renderPlotly(pts_plot())

   # observe(print(current_page()))
}

# Run the application 
shinyApp(ui = ui, server = server)

