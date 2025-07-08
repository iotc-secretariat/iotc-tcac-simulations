# Libraries
library(officer)
library(officedown)
library(knitr)
library(rmarkdown)
library(openxlsx)
library(flextable)
library(dplyr)
library(data.table)

setwd("./rmd")

# General report describing data, assumptions, and results
render("06_00_Simulation_Tool_Description.Rmd", 
       output_dir = "../outputs/", 
       output_file = "IOTC-2025-TCAC15-INF02 - Simulation_tool_description.docx"
)

