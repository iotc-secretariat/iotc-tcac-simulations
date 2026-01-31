
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
library(flextable)
library(iotc.data.reference.codelists)

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

#joins reference data
c_names = names(ALL_CATCH_DATA)
#join with entities
ALL_CATCH_DATA = ALL_CATCH_DATA %>% dplyr::left_join(iotc.data.reference.codelists::ENTITIES, by = dplyr::join_by(ENTITY_CODE == CODE))
t_c_names = c("YEAR","ENTITY_CODE","NAME_EN")
ALL_CATCH_DATA = ALL_CATCH_DATA[,.SD,.SDcols = c(t_c_names, setdiff(c_names, t_c_names))] %>% dplyr::rename(ENTITY_NAME = NAME_EN)
#join with fishery types
ALL_CATCH_DATA = ALL_CATCH_DATA %>% dplyr::left_join(iotc.data.reference.codelists::LEGACY_FISHERY_TYPES, by = dplyr::join_by(FISHERY_TYPE_CODE == CODE))
t_c_names = c("YEAR","ENTITY_CODE","ENTITY_NAME", "FISHERY_TYPE_CODE", "NAME_EN")
ALL_CATCH_DATA = ALL_CATCH_DATA[,.SD,.SDcols = c(t_c_names, setdiff(c_names, t_c_names))] %>% dplyr::rename(FISHERY_TYPE_NAME = NAME_EN)
#join with gears
ALL_CATCH_DATA = ALL_CATCH_DATA %>% dplyr::left_join(iotc.data.reference.codelists::LEGACY_GEARS, by = dplyr::join_by(GEAR_CODE == CODE))
t_c_names = c("YEAR","ENTITY_CODE","ENTITY_NAME", "FISHERY_TYPE_CODE", "FISHERY_TYPE_NAME", "GEAR_CODE", "NAME_EN")
ALL_CATCH_DATA = ALL_CATCH_DATA[,.SD,.SDcols = c(t_c_names, setdiff(c_names, t_c_names))] %>% dplyr::rename(GEAR_NAME = NAME_EN)
#join with school type
ALL_CATCH_DATA = ALL_CATCH_DATA %>% dplyr::left_join(iotc.data.reference.codelists::LEGACY_SCHOOL_TYPES, by = dplyr::join_by(SCHOOL_TYPE_CODE == CODE))
t_c_names = c("YEAR","ENTITY_CODE","ENTITY_NAME", "FISHERY_TYPE_CODE", "FISHERY_TYPE_NAME", "GEAR_CODE", "GEAR_NAME", "SCHOOL_TYPE_CODE", "NAME_EN")
ALL_CATCH_DATA = ALL_CATCH_DATA[,.SD,.SDcols = c(t_c_names, setdiff(c_names, t_c_names))] %>% dplyr::rename(SCHOOL_TYPE_NAME = NAME_EN)
#join with school type
ALL_CATCH_DATA = ALL_CATCH_DATA %>% dplyr::left_join(iotc.data.reference.codelists::LEGACY_SPECIES, by = dplyr::join_by(SPECIES_CODE == CODE))
t_c_names = c("YEAR","ENTITY_CODE","ENTITY_NAME", "FISHERY_TYPE_CODE", "FISHERY_TYPE_NAME", "GEAR_CODE", "GEAR_NAME", "SCHOOL_TYPE_CODE", "SCHOOL_TYPE_NAME", "SPECIES_CODE", "NAME_EN")
ALL_CATCH_DATA = ALL_CATCH_DATA[,.SD,.SDcols = c(t_c_names, setdiff(c_names, t_c_names))] %>% dplyr::rename(SPECIES_NAME = NAME_EN)
#process Assigned area
ALL_CATCH_DATA[, ISO := sub("^NJA_", "", ASSIGNED_AREA)]
ALL_CATCH_DATA[iotc.data.reference.codelists::ENTITIES, 
   ASSIGNED_AREA_NAME := paste("NJA", NAME_EN),
   on = .(ISO = CODE)
]
ALL_CATCH_DATA[, ISO := NULL]

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