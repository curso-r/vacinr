barras <- function(da, var) {
  da %>%
    dplyr::group_by(data) %>%
    dplyr::summarise(total = sum(.data[[var]])) %>%
    ggplot2::ggplot() +
    ggplot2::aes(data, total) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal(12)
}

barras_hc <- function(da, var) {
  da %>%
    dplyr::group_by(dia = data) %>%
    dplyr::summarise(total = sum(.data[[var]])) %>%
    highcharter::hchart(
      "column",
      highcharter::hcaes(x = dia, y = total)
    )
  # highcharter::highchart() %>%
  #   highcharter::hc_chart(type = "column") %>%
  #   highcharter::hc_title(text = "Gráfico de barras") %>%
  #   highcharter::hc_series(tab)
}

tabela <- function(da) {

  da %>%
    dplyr::group_by(regiao_nm, uf_nm) %>%
    dplyr::summarise(
      total = sum(n),
      total_80 = sum(n_80),
      .groups = "drop"
    ) %>%
    reactable::reactable(
      groupBy = "regiao_nm",
      columns = list(
        regiao_nm = reactable::colDef("Regi\u00e3o"),
        uf_nm = reactable::colDef("UF"),
        total = reactable::colDef(
          "Total",
          aggregate = "sum"
        ),
        total_80 = reactable::colDef(
          "Total > 80",
          aggregate = "sum"
        )
      )
    )

}

#' Monta mapinha
#'
#' @param da dados
#' @param var variavel
#' @param tipo "circle" ou "heatmap"
#'
#' @export
mapa <- function(da, var, tipo = "circle") {
  m <- da %>%
    dplyr::group_by(muni_id, muni_nm) %>%
    dplyr::summarise(
      dplyr::across(c(lat, lon), dplyr::first),
      n = sum(.data[[var]]),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      lab = paste0(muni_nm, ": ", n)
    ) %>%
    leaflet::leaflet() %>%
    leaflet::addTiles()

  if (tipo == "circle") {
    m_final <- m %>%
      leaflet::addCircles(
        lat = ~lat,
        lng = ~lon,
        radius = ~n,
        weight = 1,
        color = "purple",
        popup = ~lab
      )
  } else {
    m_final <- m %>%
      leaflet.extras::addHeatmap(
        lat = ~lat,
        lng = ~lon,
        intensity = ~n,
        radius = 10
      )
  }
  m_final
}
