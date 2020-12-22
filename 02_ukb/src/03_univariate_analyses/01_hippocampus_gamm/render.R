library(rmarkdown)

render("UKB_hippo_analyses_GAMM.Rmd","pdf_document")
render("UKB_hippo_analyses_GAMM.Rmd","rmarkdown::github_document")