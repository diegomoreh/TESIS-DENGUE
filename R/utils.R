#' Obtener los meses con mayor número de casos
#'
#' Función que obtiene los meses con el mayor número de casos
#' @param data_event Un `data.frame` con los datos de la enfermedad
#' o vento
#' @param col_fechas Un `array` (arreglo) de `character` (cadena de caracteres)
#' con los nombres de columna de los datos de la enfermedad o evento
#' que contienen las fechas
#' @param col_casos Un `character` (cadena de caracteres) con el nombre de la
#' columna de los datos de la enfermedad o evento que contiene el número
#' de casos; su valor por defecto es `"casos"`
#' @param top Un `numeric` (numerico) que contiene la cantidad máxima
#' de meses a retornar; su valor por defecto es `3`
#' @param concat_vals Un `boolean` (TRUE/FALSE) que indica si se requiere
#' concatenar los meses como una cadena; su valor por defecto es `TRUE`
#' @return Un `data.frame` que contiene los meses con mayor número de casos
#' @examples
#' data(dengue2020)
#' data_limpia <- limpiar_data_sivigila(dengue2020)
#' casos_inisintomas <- agrupar_fecha_inisintomas(data_limpia)
#' obtener_meses_mas_casos(data_event= casos_inisintomas,
#'                         col_fechas = "ini_sin",
#'                         col_casos = "casos",
#'                         top = 3,
#'                         concat_vals = TRUE)
#' @export
obtener_meses_mas_casos <- function(data_event,
                                    col_fechas,
                                    col_casos = "casos",
                                    top = 1,
                                    concat_vals = TRUE) {
  stopifnot("El parametro data_event es obligatorio" =
              !missing(data_event),
            "El parametro data_event debe ser un data.frame" =
              is.data.frame(data_event),
            "El parametro data_agrupada no debe estar vacio" =
              nrow(data_event) > 0,
            "El parametro col_fechas es obligatorio"
            = !missing(col_fechas),
            "El parametro col_fechas debe ser un cadena de caracteres"
            = is.character(col_fechas),
            "El parametro col_casos debe ser un cadena de caracteres"
            = is.character(col_casos),
            "El parametro top debe ser numerico"
            = is.numeric(top))
  data_mas_casos <-
    data_event[order(eval(parse(text = paste0("data_event$", col_casos))),
                     decreasing = TRUE), ]
  if (nrow(data_mas_casos) < top) {
    top <- nrow(data_mas_casos)
  }
  data_mas_casos <- data_mas_casos[1:top, ]
  data_mas_casos$Meses <- months(data_mas_casos[[col_fechas]],
                                 abbreviate = TRUE)
  if (concat_vals && length(data_mas_casos$Meses) >= 2) {
    months_concat <-
      concatenar_vals_token(as.character(data_mas_casos$Meses)[1:top])
    return(months_concat)
  }
  return(data_mas_casos)
}

#' Obtener nombres de departamentos
#'
#' Función que obtiene los nombres de los departamentos
#' @param data_event Un `data.frame` que contiene los datos de
#' la enfermedad o evento
#' @return Un `data.frame` con los nombres de los departamentos
#' @examples
#' data(dengue2020)
#' @export
obtener_nombres_dptos <- function(data_event) {
  stopifnot("El parametro data_event es obligatorio" =
              !missing(data_event),
            "El parametro data_event debe ser un data.frame" =
              is.data.frame(data_event),
            "El parametro data_agrupada no debe estar vacio" =
              nrow(data_event) > 0)
  data_event_dptos <- data_event
  data_event_dptos$codigo <- data_event$id
  geo_country_data <- import_geo_cods()
  deptos_data <- data.frame(
    id = geo_country_data$c_digo_departamento,
    nombre = geo_country_data$nombre_departamento
  )
  i <- 1
  for (code in deptos_data$id) {
    data_event_dptos$id[data_event_dptos$id == code] <-
      deptos_data$nombre[i]
    i <- i + 1
  }
  colnames(data_event_dptos)[colnames(data_event_dptos) == "id"] <-
    "nombre"
  data_event_dptos <- data_event_dptos[order(data_event_dptos$nombre,
                                             decreasing = FALSE), ]
  data_event_dptos <- data_event_dptos[5:nrow(data_event_dptos), ]
  return(data_event_dptos)
}

#' Obtener fila con mayor número de casos
#'
#' Función que obtiene la fila con el mayor número de casos
#' @param data_event Un `data.frame` que contiene los datos de la
#' enfermedad o evento
#' @param nomb_col Un `character` (cadena de caracteres) con el
#' nombre de la columna de los datos de la enfermedad o evento que
#' contiene el número de casos
#' @param porcentaje Un `boolean` (TRUE/FALSE) que indica si se
#' requiere agregar un porcentaje de casos como columna
#' @return Un `data.frame` que contiene la fila con mayor número de casos
#' @examples
#' data(dengue2020)
#' data_limpia <- limpiar_data_sivigila(dengue2020)
#' casos_sex <- agrupar_sex(data_event = data_limpia,
#'                          porcentaje = TRUE)
#' obtener_fila_mas_casos(data_event = casos_sex,
#'                        nomb_col = "casos",
#'                        porcentaje = TRUE)
#' @export
obtener_fila_mas_casos <- function(data_event,
                                   nomb_col = "casos",
                                   porcentaje = TRUE) {
  stopifnot("El parametro data_event es obligatorio" =
              !missing(data_event),
            "El parametro data_event debe ser un data.frame" =
              is.data.frame(data_event),
            "El parametro data_agrupada no debe estar vacio" =
              nrow(data_event) > 0,
            "El parametro nomb_col debe ser un cadena de caracteres"
            = is.character(nomb_col),
            "El parametro porcentaje debe ser booleano"
            = is.logical(porcentaje))
  data_mas_casos <- data_event[order(eval(parse(text =
                                                  paste0("data_event$",
                                                         nomb_col))),
                                     decreasing = TRUE), ]
  data_mas_casos <- data_mas_casos[1, ]
  if (porcentaje) {
    value_per <-
      data_mas_casos$casos[1] / sum(eval(parse(text =
                                                 paste0("data_event$",
                                                        nomb_col))))
    data_mas_casos$porcentaje <- round(value_per * 100, 2)
  }
  return(data_mas_casos)
}

#' Concatenar valores con separador o token
#'
#' Función que concatena valores con un separador o token específico
#' @param vals Un `array` (arreglo) de character (cadena de caracteres)
#' que contiene los valores que se desean concatenar
#' @param longitud Un `numeric` (numerico) que contiene la longitud de
#' los valores que se desean concatenar; su valor por defecto es `3`
#' @param princ_token Un `character` (cadena de caracteres) que contiene el
#' separador o token principal; su valor por defecto es `", "`
#' @param final_token Un `character` (cadena de caracteres) que contien el
#' separador o token final; su valor por defecto es `"y "`
#' @return Un `character` (cadena de caracteres) con el valor final concatenado
#' @examples
#' concatenar_vals_token(vals = c("enero", "febrero", "marzo"),
#'                       longitud = 3,
#'                       princ_token = ", ",
#'                       final_token = "y ")
#' @export
concatenar_vals_token <- function(vals,
                                  longitud = 3,
                                  princ_token = ", ",
                                  final_token = "y ") {
  stopifnot("El parametro vals es obligatorio" =
              !missing(vals),
            "El parametro vals debe ser una cadena de caracteres o
            un arreglo de cadenas de caracteres"
            = is.character(vals),
            "El parametro princ_token debe ser un cadena de caracteres"
            = is.character(princ_token),
            "El parametro final_token debe ser un cadena de caracteres"
            = is.character(final_token))
  final_val <- ""
  i <- 1
  for (value in vals) {
    if (i != longitud) {
      final_val <- paste0(final_val, value, princ_token)
    } else {
      final_val <- paste0(final_val, final_token, value)
    }
    i <- i + 1
  }
  return(final_val)
}

#' Obtener columnas de ocurrencia geográfica de los datos de la
#' enfermedad o evento
#'
#' Función que obtiene las columnas de ocurrencia geográfica de los
#' datos de la enfermedad o evento
#' @param cod_event Un `numeric` (numerico) o `character`
#' (cadena de caracteres) que contiene el código de la
#' enfermedad o evento
#' @param nombre_event Un `character` (cadena de caracteres) con el nombre de
#' la enfermedad o evento
#' @return Un `data.frame` con las columnas de ocurrencia geográfica de los
#' datos de la enfermedad
#' @examples
#' obtener_tip_ocurren_geo(cod_event = 210)
#' @export
obtener_tip_ocurren_geo <- function(cod_event = NULL, nombre_event = NULL) {
  geo_occurren <- config::get(file =
                                system.file("extdata",
                                            "config.yml",
                                            package = "sivirep"),
                              "occurrence_geo_diseases")
  col_ocurren <- c("cod_dpto_o", "cod_mun_o", "ocurrencia")
  param_busqueda <- NULL
  if (!is.null(cod_event)) {
      param_busqueda <- cod_event
      stopifnot("El parametro cod_event es obligatorio" =
              !missing(cod_event),
            "El parametro cod_event debe ser una cadena de caracteres o
            numerico" =
              (is.numeric(cod_event) && !is.character(cod_event)) ||
              (!is.numeric(cod_event) && is.character(cod_event)))
  }
  if (!is.null(nombre_event)) {
    stopifnot("El parametro nombre_event debe ser un cadena de caracteres"
            = is.character(nombre_event))
    param_busqueda <- nombre_event
  }
  if (length(grep(param_busqueda, geo_occurren$cod_dpto_n)) == 1
      && grep(param_busqueda, geo_occurren$cod_dpto_n) > 0) {
    col_ocurren <- c("cod_dpto_n", "cod_mun_n", "notificacion")
  } else if (length(grep(param_busqueda, geo_occurren$cod_dpto_r)) == 1
             && grep(param_busqueda, geo_occurren$cod_dpto_r) > 0) {
    col_ocurren <- c("cod_dpto_r", "cod_mun_r", "residencia")
  } else {
    col_ocurren <- c("cod_dpto_o", "cod_mun_o", "ocurrencia")
  }
  return(col_ocurren)
}

#' Obtener información geográfica de los datos de la enfermedad o evento
#'
#' Función que obtiene la información geográfica de los datos de la enfermedad
#' o evento
#' @param dpto Un `character` (cadena de caracteres) que contiene el nombre
#' del departamento; su valor por defecto es `NULL`
#' @param mpio Un `character` (cadena de caracteres) que contiene los datos del
#' municipio; su valor por defecto es `NULL`
#' @return Un `data.frame` con la información geográfica de los datos de
#' la enfermedad o evento
#' @examples
#' obtener_info_depts(dpto = "ANTIOQUIA")
#' @export
obtener_info_depts <- function(dpto = NULL, mpio = NULL) {
  stopifnot("El parametro dpto es obligatorio" =
              !missing(dpto),
            "El parametro dpto debe ser una cadena de caracteres" =
              is.character(dpto))
  data_geo <- import_geo_cods()
  list_dptos <- unique(data_geo$nombre_departamento)
  list_specific <-
    list_dptos[stringr::str_detect(list_dptos,
                                   toupper(dpto))]
  data_dpto <- dplyr::filter(data_geo, .data$nombre_departamento %in%
                               list_specific)
  if (!is.null(mpio)) {
    stopifnot("El parametro mpio debe ser una cadena de caracteres"
              = is.character(mpio))
    list_municipalities <- unique(data_geo$nombre_municipio)
    list_specific <-
      list_municipalities[stringr::str_detect(list_municipalities,
                                              toupper(mpio))]
    data_dpto <- dplyr::filter(data_geo, .data$nombre_municipio %in%
                                 list_specific)
  }
  return(data_dpto)
}

#' Establecer códigos geográficos de los datos de la enfermedad o evento
#'
#' Función que establece los códigos geográficos de los datos de la enfermedad
#' o evento
#' @param cod_dpto Un `numeric` (numerico) que contiene el código del
#' departamento
#' @param cod_mpio Un `numeric` (numerico) que contiene el código del municipio
#' @return Un `data.frame` con los códigos geográficos
#' @examples
#' modficar_cod_mun(cod_dpto = 01, cod_mpio = "001")
#' @export
modficar_cod_mun <- function(cod_dpto, cod_mpio) {
  cod_mpio <- as.character(cod_mpio)
  cod_dpto <- as.character(cod_dpto)
  if (startsWith(cod_dpto, "0")) {
    cod_dpto <- substr(cod_dpto, 2, 2)
    cod_mpio <- gsub(cod_dpto, "", cod_mpio)
  }
  return(cod_mpio)
}

#' Obtener departamentos de Colombia
#'
#' Función que obtiene los departamentos de Colombia
#' @return Un `data.frame` con los departamentos de Colombia
#' @examples
#' obtener_dptos()
#' @export
obtener_dptos <- function() {
  dptos <- config::get(file =
                         system.file("extdata", "config.yml",
                                     package = "sivirep"),
                       "departments")
  return(dptos)
}

#' Obtener nombre del municipio en Colombia
#'
#' Función que obtiene el nombre del municipio
#' @param data_geo Un `data.frame` que contiene los códigos
#' geográficos (departamentos y municipios de Colombia)
#' @param cod_dpto Un `numeric` (numerico) o `character`
#' (cadena de caracteres) que contiene el código
#' del departamento
#' @param cod_mpio Un `numeric` (numerico) o `character`
#' (cadena de caracteres) que contiene el código
#' del municipio
#' @return Un `character` (cadena de caracteres) con el nombre del municipio
#' @examples
#' data_geo <- import_geo_cods()
#' obtener_nombres_mpios(data_geo,
#'                       cod_dpto = "05",
#'                       cod_mpio = "001")
#' @export
obtener_nombres_mpios <- function(data_geo, cod_dpto, cod_mpio) {
  stopifnot("El parametro data_geo es obligatorio" =
              !missing(data_geo),
            "El parametro data_geo debe ser un data.frame" =
              is.data.frame(data_geo),
            "El parametro data_geo no debe estar vacio" =
              nrow(data_geo) > 0,
            "El parametro cod_dpto es obligatorio" =
              !missing(cod_dpto),
            "El parametro cod_dpto debe ser una cadena de caracteres
            o numerico" =
            (is.numeric(cod_dpto) && !is.character(cod_dpto)) ||
            (!is.numeric(cod_dpto) && is.character(cod_dpto)),
            "El parametro cod_mpio es obligatorio" =
              !missing(cod_mpio),
            "El parametro cod_mpio debe ser una cadena de caracteres
            o numerico" =
            (is.numeric(cod_mpio) && !is.character(cod_mpio)) ||
            (!is.numeric(cod_mpio) && is.character(cod_mpio)))
  cod_dpto <- as.character(cod_dpto)
  if (startsWith(cod_dpto, "0")) {
    cod_dpto <- substr(cod_dpto, 2, 2)
    cod_mpio <- paste0(cod_dpto, cod_mpio)
  } else {
    cod_mpio <- paste0(cod_dpto, cod_mpio)
  }
  data_mpio <- dplyr::filter(data_geo,
                            .data$codigo_municipio %in% as.integer(cod_mpio))
  data_mpio <- data_mpio[1, ]
  return(data_mpio$nombre_municipio)
}
