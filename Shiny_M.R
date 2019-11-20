library(shiny)

  
  ui <- fluidPage(
    "Plot goes here:",
    plotOutput(outputId = "my_plot" )
)

  
# Input you read outputs from
# Outputs you read to.
server <- function(input, output){
  
  
  
}

shinyApp(ui = ui, server = server)