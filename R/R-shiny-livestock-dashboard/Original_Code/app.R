#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(magrittr)
library(janitor)
library(readxl)
library(plotly)
library(rsconnect)


#setwd("//research-data.shared.sydney.edu.au/fae/PRJ-BeefModel/Windows in Mac copy to network drive/Sydney/shiny-quickstart-1/ByrneValley_App")
#getwd()

#rsconnect::setAccountInfo(name='sydneylivestock',
#                          token='E267AF00A76198A13C3671E55A6DABFD',
#                          secret='ZdzrwnlW/aUpnUgJX1CtXDvs/lipLXGYxPbrcgGS')

WoW <- read_excel("wowByrne.xlsx")
WoW$Date <- as.Date(WoW$Date, format = "%d/%m/%Y")
                                      # this must be the date format to work
WoW <- arrange(WoW,desc(EID))
str(WoW)
summary(WoW)

# Define UI for application that draws a histogram
ui <- 
  fluidPage(
    titlePanel(title=div("Byrne Valley WoW data", img(src="USYD_SIA.jpg", height=100, width=200))),

    br(),
    
    fluidRow(
      
#      column(2,sidebarLayout(
        sidebarPanel(
        selectInput("EID", "Choose animal group or ID", (choices = unique(WoW$EID) %>% sort), selected = "ALL")
        )
    ),

      mainPanel(

        fluidRow(
          column(6,
               h3("Live weight, kg/hd", plotlyOutput("LiveWeight"))),
          column(6,
               h3("Growth rate, kg/d", plotlyOutput("GrowthRate"))
#        verbatimTextOutput('Stats')
              )),
br(),


        fluidRow(
  
          column(6, h3("# of Animals or Datapoints, #/d", plotlyOutput("NroObsDay")))
            ),
br(),

        fluidRow(

          column(6, h3("Animal value, $/hd", plotlyOutput("AnimalValue"))),

          column(6, h3("Animal Production, $/hd/d", plotlyOutput("AnimalProd")))
                ),
br(),
        fluidRow(
  
          column(6, h3("Feed Intake, kg/d", plotlyOutput("FeedIntake"))),
  
          column(6, h3("Methane, g/d", plotlyOutput("Methane")))
                )
    )
  )



# Define server logic required to draw graphs
server <- function(input, output) {

  EIDreac = reactive({ WoW %>%
      filter(EID %in% input$EID)
  })
  
  output$LiveWeight <- renderPlotly({
      ggplotly(ggplot(data = EIDreac(),aes(x = Date, y = FinalPweight)) +
              geom_line(color="blue", lwd=1)
#             + geom_point(aes(x = Date, y = Weight, size = 0.1, alpha=0.5))
#    plot_ly(source = "source") %>% 
#      add_lines(data = EIDreac, x = ~Date, y = ~FinalPweight, mode = "lines", line = list(width = 3))
#           +   scale_x_date(date_breaks = "3 month", date_labels = format("%m")))
    )})
  output$GrowthRate <- renderPlotly({
    ggplotly(ggplot(data = EIDreac(),aes(x = Date, y = FinalGrowthPBS), title="Growth rate") +
               geom_line(color="blue", lwd=1))
  })
  
  output$NroObsDay <- renderPlotly({
    ggplotly(ggplot(data = EIDreac(),aes(x = Date, y = NroObs), title="Number of datapoints") +
               geom_line(color="blue", lwd=1))
  })
  
  output$AnimalValue <- renderPlotly({
    ggplotly(ggplot(data = EIDreac(),aes(x = Date, y = AnimalValue, title="Animal value, $/hd")) +
               geom_line(color="green", lwd=1))
  })
  
  output$AnimalProd <- renderPlotly({
    ggplotly(ggplot(data = EIDreac(),aes(x = Date, y = AnimalProd), title="Animal Production, $/d") +
               geom_line(color="red", lwd=1))
  })
  
  output$FeedIntake <- renderPlotly({
    ggplotly(ggplot(data = EIDreac(),aes(x = Date, y = FeedIntakeKgd)) +
               geom_line(color="green", lwd=1))
  })

  output$Methane <- renderPlotly({
    ggplotly(ggplot(data = EIDreac(),aes(x = Date, y = Methane), title="Methane") +
               geom_line(color="red", lwd=1))
  })
  
  output$Stats <- renderPrint({
    summary(EIDreac$FinalPweight)
    })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

