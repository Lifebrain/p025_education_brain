library(rmarkdown)

render("LB_hippo_analyses_GAMM.Rmd","pdf_document")
render("LB_hippo_analyses_GAMM.Rmd","rmarkdown::github_document")