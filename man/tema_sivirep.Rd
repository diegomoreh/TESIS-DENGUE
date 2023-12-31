% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/theme_sivirep.R
\name{tema_sivirep}
\alias{tema_sivirep}
\title{Tema \pkg{ggplot2} personalizado para los reportes de \pkg{sivirep}}
\usage{
tema_sivirep()
}
\value{
Un objecto tema de \pkg{ggplot2}
}
\description{
Tema \pkg{ggplot2} personalizado para los reportes de \pkg{sivirep}
}
\examples{
library(ggplot2)
ggplot(mtcars, ggplot2::aes(wt, mpg)) +
  ggplot2::geom_point() +
  ggplot2::labs(title = "La economia") +
  tema_sivirep()
}
