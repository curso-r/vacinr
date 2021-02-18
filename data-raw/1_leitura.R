library(magrittr)

path <- "~/Downloads/microdados_vacinacao.csv.gz"

# comparar o fread com o arrow ----

# tictoc::tic()
# da_vacinacao <- data.table::fread(path, tz = "UTC")
# tictoc::toc()

tictoc::tic()
da_vacinacao <- arrow::read_csv_arrow(path)
tictoc::toc()

dplyr::glimpse(da_vacinacao)

aux_muni <- abjData::muni %>%
  dplyr::select(
    muni_id,
    uf_nm,
    uf_sigla,
    regiao_nm,
    lon,
    lat
  )

da_vacinacao_municipio <- da_vacinacao %>%
  dplyr::filter(
    numero_dose == 1
  ) %>%
  dplyr::group_by(
    data = data_aplicacao,
    muni_id = paciente_codigo_ibge_municipio,
    muni_nm = paciente_municipio
  ) %>%
  dplyr::summarise(
    n = dplyr::n(),
    n_80 = sum(paciente_idade >= 80),
    .groups = "drop"
  ) %>%
  dplyr::mutate(muni_id = as.character(muni_id)) %>%
  dplyr::inner_join(
    aux_muni, "muni_id"
  ) %>%
  dplyr::mutate(
    dplyr::across(
      c(muni_nm, regiao_nm, uf_nm),
      abjutils::rm_accent
    )
  )

usethis::use_data(da_vacinacao_municipio,
                  overwrite = TRUE)
