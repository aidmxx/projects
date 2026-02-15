# Main Shiny app entry point
# This file allows you to run the app with: shiny::runApp()

library(shiny)

# Source the main app components
source("src/global.R")
source("src/ui.R") 
source("src/server.R")

# Run the app
shinyApp(ui = ui, server = server)

