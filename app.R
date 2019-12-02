library(maps)
library(readr)
library(readxl)
library(geojsonio)
library(broom)
library(rgeos)
library(ggraph)
library(networkD3)
library(plotly)
library(readr)
library(oce)
library(rmarkdown)
library(maps)
library(viridis)
library(RColorBrewer)
library(markdown)
library(rgdal)
library(janitor)
library(viridis)
library(networkD3)
library(ggraph)
library(readr)
library(treemapify)
library(shiny)
library(tidyverse)


## - - - read data needed for the app - - ## 
state_data <- read_xlsx("By_state_data.xlsx") %>% clean_names()
spdf <- geojson_read("us_states_hexgrid.geojson",  what = "sp")
network_sample <- read_csv("network_sample")
# Qualify to only higher cash balances. 
network_sample %>% filter(current_cash_balance > 1000)

## - - -  create UI - - - ###
ui <- navbarPage("Shiny Maps!",
                 tabPanel("Intro to Unclaimed Property",
                          
                                    align = "center",
                                    includeMarkdown("About_unclaimed.md"),
                                    plotOutput("plot2", width = "50%", height = "500px")

                          
                 ),
                 
                 tabPanel("Unclaimed Property in California", 
                          align="center",
                          includeMarkdown("state_context.md"),
                          simpleNetworkOutput("network_plot", width = "100%", height = "500px")

                 ),
                 
                 tabPanel("Digging in",
                          
                          
                            # Define the sidebar with one input for state info
                            sidebarPanel(
                              selectInput("state", "State",
                                          c("AZ" = "AZ",
                                            "CA" = "CA",
                                            "CT" = "CT",
                                            "DE" = "DE",
                                            "NH" = "NH", 
                                            "NY" = "NY",
                                            "MA" = "MA"))                    
                            ),
                          mainPanel(
                              
                            align="center",
                            includeMarkdown("state_context.md"),
                            #tags$video(id="video2", type = "video/mov",src = "network_mov.mov", controls = "controls"),
                            plotOutput("tree_plot"),
                            includeMarkdown("state_context2.md"),
                            plotOutput("value_plot")
                          )
                  ),
                 
                 tabPanel("About",
                          fluidRow(
                            column(6,
                                   includeMarkdown("About.md")
                            )
                          )
                 )
)


# Define server logic required to build all charts
server <- function(input, output, session) {
  
  output$plot2 <- renderPlot({
    
    # Prepare data for state by aggregate state analysis
    # Prepare a color scale coming from the viridis color palette
    my_palette <- rev(magma(8))[c(-1,-8)]
    # Load this file. (Note: I stored in a folder called DATA)
    # Bit of reformating
    spdf@data = spdf@data %>% mutate(google_name = gsub(" \\(United States\\)", "", google_name))
    
    spdf@data = spdf@data %>% mutate(google_name = gsub(" \\(United States\\)", "", google_name))
    spdf_fortified <- tidy(spdf, region = "google_name")
    centers <- cbind.data.frame(data.frame(gCentroid(spdf, byid=TRUE), id=spdf@data$iso3166_2))
    
    spdf_fortified <- spdf_fortified %>%
      left_join(. , state_data, by=c("id"="state")) 
    
    spdf_fortified <- spdf_fortified %>%
      left_join(state_data, by=c("id"="state")) 
    
    # Make a first chloropleth map
    spdf_fortified %>% ggplot() +
      geom_polygon(aes(fill = per_capita.x, x = long, y = lat, group = group), colour= "#9A1B00", size=.1, alpha=0.9) +
      geom_text(data = centers, aes(x=x, y=y, label=id), color="white", size=6, alpha=0.6) +
      scale_fill_gradient(low = "#FFD8D0", high = "#9A1B00") +
      #scale_fill_gradient(trans = "log") +
      theme_void() +
      ggtitle( "Unclaimed Property per Capita by State" ) +
      theme(
        text = element_text(color = "#22211d"),
        # plot.background = element_rect(fill = , color = NA), 
        #  panel.background = element_rect(fill = "#f5f5f2", color = NA), 
        #  legend.background = element_rect(fill = "#f5f5f2", color = NA),
        plot.title = element_text(size= 12, hjust=0.5, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
        legend.position = c(0.9, 0.2)
      )        
    
    
  })
  
  # Build out network diagram for sample of data from CA unclaimed data
  output$network_plot <- renderSimpleNetwork({
    simpleNetwork(network_sample,
           charge = -1)
                  
})
  # Build out treemap based on input of owner_state diagram for sample of data from CA unclaimed data
  
  output$tree_plot <- renderPlot({
    state_value <- input$state
    network_sample_state <- network_sample %>% filter(holder_state == state_value) %>% count(holder_name)
    ggplot(network_sample_state, 
           aes(area = n, fill = n, label = holder_name) ) +
      geom_treemap(show.legend = FALSE) +
      labs (title = "Companies who hold UP for CA residents ",
            subtitle = "Note: Company location determined site of relationship") +
      theme(plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5)) +
      geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
                        grow = TRUE, show.legend = FALSE) 
  })
  
  output$value_plot <- renderPlot({
    state_value <- input$state
    network_sample_value <- network_sample %>% filter(holder_state == state_value)
    ggplot(network_sample_value,
           aes(x = reorder(property_type, -current_cash_balance), y = current_cash_balance, fill = property_type)) +
      geom_col(show.legend = FALSE) +
      labs (title = "Type of property owed") +
      coord_flip() 
      
  })

  
}

# Run the application 
shinyApp(ui = ui, server = server)
