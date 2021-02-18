devtools::load_all()

library(shiny)

ui <- fluidPage(
  fluidRow(
    column(
      width = 12,
      tags$h2("Aplicativo top")
    )
  ),
  fluidRow(
    column(
      width = 4,
      radioButtons("tipo_mapa", "Tipo de mapa",
                   c("Círculo" = "circle",
                     "Heatmap" = "heatmap"),
                   selected = "heatmap"),
      radioButtons("variavel", "Variável",
                   c("N" = "n",
                     "N > 80" = "n_80")),
      sliderInput(
        "data",
        label = "Selecione o período",
        min = min(da_vacinacao_municipio$data, na.rm = TRUE),
        max = max(da_vacinacao_municipio$data, na.rm = TRUE),
        value = as.Date("2021-01-01"),
        animate = TRUE
      )
    )
  ),
  fluidRow(
    column(
      width = 6,
      leaflet::leafletOutput("mapa")
    ),
    column(
      width = 6,
      reactable::reactableOutput("tabela"),
      plotOutput("grafico")
    )
  )
)

server <- function(input, output, session) {

  tabela_filtrada <- reactive({
    da_vacinacao_municipio  %>%
      dplyr::mutate(
        lab = paste0(muni_nm, ": ", n)
      )
  })

  output$mapa <- leaflet::renderLeaflet({
    mapa(
      da_vacinacao_municipio %>% dplyr::filter(data == "2021-01-20"),
      input$variavel
    )
  })

  observe({
    mapa_proxy <- leaflet::leafletProxy(
      "mapa",
      data = tabela_filtrada()%>%
        dplyr::filter(
          data == input$data
        ))
    if (input$tipo_mapa == "circle") {
      mapa_proxy %>%
        leaflet::clearShapes() %>%
        leaflet::addCircles(
          "mapa",
          lat = ~lat,
          lng = ~lon,
          radius = ~n,
          weight = 1,
          color = "purple",
          popup = ~lab
        )
    } else {
      mapa_proxy  %>%
        leaflet.extras::clearHeatmap() %>%
        leaflet.extras::addHeatmap(
          lat = ~lat,
          lng = ~lon,
          intensity = ~n,
          radius = 10
        )
    }
  })

  output$tabela <- reactable::renderReactable({
    tabela(tabela_filtrada()%>%
             dplyr::filter(
               data <= input$data
             ))
  })

  output$grafico <- renderPlot({
    barras(tabela_filtrada()%>%
             dplyr::filter(
               data <= input$data
             ), input$variavel)
  })
}

shinyApp(ui, server)
