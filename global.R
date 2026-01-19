
#packages
library(openxlsx)
library(stringr)
library(dplyr)
library(scales)
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(bs4Dash)
library(data.table)
library(DT)
library(officer)
library(officedown)
library(kableExtra)
library(knitr)
library(rmarkdown)
library(fdi4R)
library(leaflet)
library(dplyr)
library(tidyr)
library(plotly)

#options
options(scipen = 9999)

#scripts
source("./initialisation/00_CORE.R")

#users
library(config)
conn_args = config::get("dataconnection")
user_base <- dplyr::tibble(
  user = conn_args$user,
  password = conn_args$password
)

#scenarios
SCENARIO_PARAMETERS = fread("./inputs/IOTC-2024-TCAC13-REF03_Rev1_-_INPUT_PARAMETERS.csv")

#variables
ENTITIES = read_entities()
ALL_CATCH_DATA = read_catch_data("./inputs/data/HISTORICAL_CATCH_ESTIMATES.csv", CPC_data = ENTITIES)[CATCH_MT > 0]

AVAILABLE_YEARS = list(MIN = min(ALL_CATCH_DATA$YEAR), 
                       MAX = max(ALL_CATCH_DATA$YEAR))

AVAILABLE_SPECIES = list(`ALB - Albacore`  = "ALB",
                         `BET - Bigeye tuna`    = "BET",
                         `SKJ - Skipjack tuna`  = "SKJ",
                         `YFT - Yellowfin tuna` = "YFT",
                         `SWO - Swordfish`      = "SWO")

SPECIES_TABLE = data.table(SPECIES_CODE = c("ALB", "BET", "SKJ", "SWO", "YFT"), 
                           SPECIES = c("Albacore", "Bigeye tuna", "Skipjack tuna", "Swordfish", "Yellowfin tuna"), 
                           SPECIES_SCIENTIFIC = c("Thunnus alalunga", "Thunnus obesus", "Katsuwonus pelamis", "Xiphias gladius", "Thunnus albacares")
)

AVAILABLE_HISTORICAL_CATCH_AVERAGE_PERIODS = list(`Selected period` = "period", 
                                                  `Best "n" years`  = "best")


AVAILABLE_SOCIO_ECONOMIC_OPTIONS = list(`Option #1 - Vulnerability + Priority sectors + Disproportionate burden` = "O1", 
                                        `Option #2 - HDI + GNI + SIDS` = "O2")

AVAILABLE_OUTPUT_UNITS = list(`Quota (%)`   = "quota",
                              `Catches (t)` = "catches")

AVAILABLE_HEATMAP_STYLES = list(`Background color` = "color",
                                `Bar`              = "bar")

AVAILABLE_HEATMAP_TYPES = list(`Global`  = "global",
                               `By year` = "by_year")

CPC_DATA   = ENTITIES

#shiny scripts
print(list.files())
source("./server.R")
source("./ui.R")