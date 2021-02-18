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
                     "Heatmap" = "heatmap")),
      radioButtons("variavel", "Variável",
                   c("N" = "n",
                     "N > 80" = "n_80")),
      sliderInput(
        "data_",
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
      highcharter::highchartOutput("grafico")
    )
  )
)

server <- function(input, output, session) {

  tabela_filtrada <- reactive({
    da_vacinacao_municipio %>%
      dplyr::filter(
        data >= as.Date(input$data_)
      )
  })

  output$mapa <- leaflet::renderLeaflet({
    mapa(
      da_vacinacao_municipio,
      input$variavel,
      input$tipo_mapa
    )
  })

  output$tabela <- reactable::renderReactable({
    tabela(tabela_filtrada())
  })

  output$grafico <- highcharter::renderHighchart({
    barras_hc(tabela_filtrada(), "n")
  })
}

shinyApp(ui, server)
