library(shiny)
library(shinydashboard)
library(tidyverse)


concrete <- read.csv("C:/Users/Tejashwini Saravanan/Copy of Concrete_Data.csv")
colnames(concrete) <- c("Cement", "BlastFurnaceSlag", "FlyAsh", "Water",
                        "Superplasticizer", "CoarseAggregate", "FineAggregate",
                        "Age", "CompressiveStrength")
concrete <- concrete %>% mutate(WC_Ratio = Water / Cement)


ui <- dashboardPage(
  dashboardHeader(title = "Concrete Strength Dashboard"),
  dashboardSidebar(
    sliderInput("ageFilter", "Select Age (days):", 
                min = min(concrete$Age), 
                max = max(concrete$Age), 
                value = c(min(concrete$Age), max(concrete$Age))),
    
    sliderInput("cementRange", "Select Cement Range (kg/m³):",
                min = floor(min(concrete$Cement)),
                max = ceiling(max(concrete$Cement)),
                value = c(min(concrete$Cement), max(concrete$Cement)))
  ),
  dashboardBody(
    tags$div(
      style = "padding: 10px; text-align: center;",
      tags$h2("The Concrete Dataset")
    ),
    
    fluidRow(
      valueBoxOutput("avg_strength"),
      valueBoxOutput("max_strength"),
      valueBoxOutput("num_samples")
    ),
    fluidRow(
      box(title = "Strength vs. Age", width = 6, plotOutput("plot1")),
      box(title = "Strength vs. WC Ratio", width = 6, plotOutput("plot2"))
    ),
    fluidRow(
      box(title = "Strength vs. Cement", width = 6, plotOutput("plot3")),
      box(title = "Strength vs. Fly Ash", width = 6, plotOutput("plot4"))
    ),
    fluidRow(
      box(title = "Heatmap: Age vs Cement", width = 12, plotOutput("heatmap"))
    )
  )
)


server <- function(input, output) {
  
  filtered <- reactive({
    concrete %>%
      filter(Age >= input$ageFilter[1],
             Age <= input$ageFilter[2],
             Cement >= input$cementRange[1],
             Cement <= input$cementRange[2])
  })
  
  output$avg_strength <- renderValueBox({
    avg <- round(mean(filtered()$CompressiveStrength), 2)
    valueBox(avg, "Avg Strength (MPa)", icon = icon("chart-line"), color = "light-blue")
  })
  
  output$max_strength <- renderValueBox({
    max_val <- round(max(filtered()$CompressiveStrength), 2)
    valueBox(max_val, "Max Strength (MPa)", icon = icon("trophy"), color = "green")
  })
  
  output$num_samples <- renderValueBox({
    n <- nrow(filtered())
    valueBox(n, "Filtered Mixes", icon = icon("flask"), color = "orange")
  })
  
  output$plot1 <- renderPlot({
    ggplot(filtered(), aes(x = Age, y = CompressiveStrength)) +
      geom_point(color = "#2c7fb8") +
      geom_smooth(method = "lm", se = FALSE, color = "black") +
      labs(x = "Age (days)", y = "Strength (MPa)")
  })
  
  output$plot2 <- renderPlot({
    ggplot(filtered(), aes(x = WC_Ratio, y = CompressiveStrength)) +
      geom_point(color = "#f03b20") +
      geom_smooth(method = "loess", se = FALSE, color = "black") +
      labs(x = "Water-Cement Ratio", y = "Strength (MPa)")
  })
  
  output$plot3 <- renderPlot({
    ggplot(filtered(), aes(x = Cement, y = CompressiveStrength)) +
      geom_point(color = "darkgreen") +
      geom_smooth(method = "lm", se = FALSE) +
      labs(x = "Cement Content", y = "Strength (MPa)")
  })
  
  output$plot4 <- renderPlot({
    ggplot(filtered(), aes(x = FlyAsh, y = CompressiveStrength)) +
      geom_point(color = "purple") +
      geom_smooth(method = "lm", se = FALSE) +
      labs(x = "Fly Ash (kg/m³)", y = "Strength (MPa)")
  })
  
  output$heatmap <- renderPlot({
    ggplot(filtered(), aes(x = Cement, y = Age, fill = CompressiveStrength)) +
      geom_tile() +
      scale_fill_viridis_c() +
      labs(x = "Cement", y = "Age", fill = "Strength (MPa)") +
      theme_minimal()
  })
}


shinyApp(ui, server)




