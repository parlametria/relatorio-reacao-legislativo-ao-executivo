cria_paleta <- function(domain, from = "#ffe4cc", to = "#ff9500") {
  function(x) {
    normalized = (x - min(domain)) / (max(domain) - min(domain))
    rgb(colorRamp(c(from, to))(normalized), maxColorValue = 255)
  }
}

detalhes_autorias = function(data) {
  data %>%
    filter(!is.na(nome)) %>%
    mutate(proposicao = str_glue("{sigla_tipo} {numero}")) %>%
    group_by(id_leggo, proposicao) %>%
    mutate(autores = n()) %>%
    ungroup() %>%
    select(nome, partido, uf, casa, proposicao, autores) %>%
    mutate(
      assinadas = 1,
      autorias_ponderadas = 1 / autores,
      coautores = autores - 1
    )
}

resume_autorias = function(data){
  data %>% 
    detalhes_autorias() %>% 
    group_by(nome, partido, uf, casa) %>% 
    summarise(assinadas = sum(assinadas), 
              autorias_ponderadas = sum(autorias_ponderadas), 
              .groups = "drop")
}

tbl_autorias_resumida = function(data) {
  escala_assinadas = cria_paleta(data$assinadas)
  escala_ponderadas = cria_paleta(data$autorias_ponderadas)
  
  data %>%
    reactable(
      defaultPageSize = 15,
      compact = TRUE,
      searchable = T,
      defaultSorted = "assinadas",
      columns = list(
        nome = colDef(name = "Parlamentar", minWidth = 150),
        partido = colDef(name = "Partido", minWidth = 75),
        uf = colDef(name = "UF", minWidth = 50),
        casa = colDef(name = "Casa", minWidth = 50),
        assinadas = colDef(
          name = "Prop. assinadas",
          minWidth = 70,
          defaultSortOrder = "desc",
          style = function(value) {
            list(background = escala_assinadas(value))
          }
        ),
        autorias_ponderadas = colDef(
          name = "Autorias ponderadas",
          minWidth = 70,
          format = colFormat(digits = 1),
          style = function(value) {
            list(background = escala_ponderadas(value))
          }
        )
      )
    )
}

tbl_detalhes_autorias = function(data) {
  data %>%
    select(-autores) %>%
    reactable(
      defaultPageSize = 10,
      compact = TRUE,
      searchable = T,
      striped = FALSE,
      groupBy = c("nome"),
      defaultSorted = "assinadas",
      columns = list(
        nome = colDef(name = "Parlamentar", minWidth = 150),
        partido = colDef(
          name = "Partido",
          minWidth = 75,
          aggregate = "unique"
        ),
        uf = colDef(
          name = "UF",
          minWidth = 50,
          aggregate = "unique"
        ),
        casa = colDef(
          name = "Casa",
          minWidth = 50,
          aggregate = "unique"
        ),
        proposicao = colDef(
          name = "Proposições",
          minWidth = 100,
          aggregate = "unique"
        ),
        assinadas = colDef(
          name = "Prop. assinadas",
          minWidth = 70,
          defaultSortOrder = "desc",
          aggregate = "sum"
        ),
        autorias_ponderadas = colDef(
          name = "Autorias ponderadas",
          minWidth = 70,
          aggregate = "sum",
          format = colFormat(digits = 2)
        ),
        coautores = colDef(name = "Coautores")
      )
    )
}