library(shiny)
library(tidyverse)
library(plotly)


# Load data
players <- read_delim("./data/players.txt", delim = ",")
teams <- read_delim("./data/teams.txt", delim = ",")
goalie_stats <- read_delim("./data/goalie_stats.txt", delim = ",")
player_stats <- read_delim("./data/skaters_stats.txt", delim = ",") %>% 
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
ui <- fluidPage(
   
   # Application title
   titlePanel("Fantasy Hockey Player Analysis"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput("forwardPlayers",
                     label = "Forwards",
                     choices = forwards_list,
                     multiple = TRUE)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotlyOutput("forward_pts_plot")
      )
   )
)

# Define server logic required to draw plots
server <- function(input, output) {
  
   selected_players <- reactive(
     player_stats %>% 
       filter(fullName %in% input$forwardPlayers)
   )
   
   output$forward_pts_plot <- renderPlotly(
     ggplotly(ggplot(data = selected_players(), aes(x=season, y=points, group = playerID, color = fullName)) +
                geom_point(stat = 'summary', fun.y = sum) +
                stat_summary(fun.y = sum, geom = "line") +
                ggtitle("Season Point Totals") +
                xlab("Season") + 
                ylab("Points") + 
                scale_color_brewer("Player", palette = "Spectral") +
                theme_bw() +
                theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45)), 
              tooltip = c("y", "colour"))
   )
}

# Run the application 
shinyApp(ui = ui, server = server)

