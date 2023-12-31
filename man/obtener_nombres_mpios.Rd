% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{obtener_nombres_mpios}
\alias{obtener_nombres_mpios}
\title{Obtener nombre del municipio en Colombia}
\usage{
obtener_nombres_mpios(data_geo, cod_dpto, cod_mpio)
}
\arguments{
\item{data_geo}{Un `data.frame` que contiene los códigos
geográficos (departamentos y municipios de Colombia)}

\item{cod_dpto}{Un `numeric` (numerico) o `character`
(cadena de caracteres) que contiene el código
del departamento}

\item{cod_mpio}{Un `numeric` (numerico) o `character`
(cadena de caracteres) que contiene el código
del municipio}
}
\value{
Un `character` (cadena de caracteres) con el nombre del municipio
}
\description{
Función que obtiene el nombre del municipio
}
\examples{
data_geo <- import_geo_cods()
obtener_nombres_mpios(data_geo,
                      cod_dpto = "05",
                      cod_mpio = "001")
}
