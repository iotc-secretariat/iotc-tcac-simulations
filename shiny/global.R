
#packages
library(stringr)
library(dplyr)
library(scales)
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(data.table)
library(DT)
library(officer)
library(officedown)
#library(RDCOMClient)
library(kableExtra)
library(knitr)
library(rmarkdown)

#scripts
source("../initialisation/00_CORE.R")

#variables
CONFIG = read_configuration("../cfg/CPC_CONFIGURATIONS.xlsx")

ALL_CATCH_DATA = read_catch_data("../cfg/HISTORICAL_CATCH_ESTIMATES.csv", CPC_data = CONFIG$CPC_CONFIG)[CATCH_MT > 0]

AVAILABLE_YEARS = list(MIN = min(ALL_CATCH_DATA$YEAR), 
                       MAX = max(ALL_CATCH_DATA$YEAR))

AVAILABLE_SPECIES = list(`ALB - Albacore tuna`  = "ALB",
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

CPC_DATA   = CONFIG$CPC_CONFIG
CS_SE_DATA = CONFIG$CS_SE_CONFIG


#shiny scripts
print(list.files())
source("./server.R")
source("./UI.R")