# Install/load pacman
if(!require(pacman)){
  install.packages("pacman")
  suppressPackageStartupMessages(library(pacman,quietly = TRUE))
}

# Install/load libraries required for analysis
pacman::p_load(
  "bookdown",
  "flextable",   # Use old version: 0.6.9
  "ggpubr", 
  "ggsci", 
  "knitr", 
  "officer", 
  "openxlsx",  
  "rmarkdown", 
  "scales", 
  "tidyverse", 
  "rnaturalearth", 
  "rnaturalearthdata", 
  "sf", 
  "RDCOMClient", 
  "data.table", 
  "DT", 
  "kableExtra"
)

theme_set(theme_bw())
