## Fantasy Hockey Player Analysis  

Creating an application that pulls NHL stats and creates an interactive visualization to analysis player statistics.

![screenshot](./imgs/app_screenshot.JPG)

## Usage  

### Shiny Server  
The hosted Shiny Application can be found [here](https://everittb.shinyapps.io/hockey_analysis_app/).  

### Local Machine

#### Pre-requisites  
**R version 3.5.0**  

| Packages | Version |
|:--------:|:-------:|  
| DT | 0.6 |
| plotly | 4.9.0 |
| lubridate | 1.7.4 |
| forcats | 0.4.0 |
| stringr | 1.4.0 |
| dplyr | 0.8.1 |
| purr | 0.3.2 |
| readr | 1.3.1 |
| tidyr | 0.8.3 |
| tibble | 2.1.1 |
| ggplot2 | 3.1.1 |
| tidyverse | 1.2.1 |
| shiny | 1.3.2 |  

**Python version 3.6.5**  

#### Setup Instructions  
1. Clone this repository  
2. Open a terminal window
3. Navigate to `fantasy-hockey_player-analysis/`
4. *Optionally run:* `python src/get_stats.py` *in the terminal window*  
  - Updates player statistics   
6. Run ` Rscript src/launch_app.R` in the terminal window  
