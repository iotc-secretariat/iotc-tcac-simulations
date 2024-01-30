source("../scripts/01.configure_and_preprocess.R")

CONFIG = read_configuration("../cfg/CPC_CONFIGURATIONS.xlsx")

ALL_CATCH_DATA = read_catch_data("../cfg/HISTORICAL_CATCH_ESTIMATES.csv", CPC_data = CONFIG$CPC_CONFIG)[CATCH_MT > 0]

AVAILABLE_YEARS = list(MIN = min(ALL_CATCH_DATA$YEAR), 
                       MAX = max(ALL_CATCH_DATA$YEAR))

AVAILABLE_SPECIES = list(`ALB - Albacore tuna`  = "ALB",
                         `BET - Bigeye tuna`    = "BET",
                         `SKJ - Skipjack tuna`  = "SKJ",
                         `YFT - Yellowfin tuna` = "YFT",
                         `SWO - Swordfish`      = "SWO")

AVAILABLE_HISTORICAL_CATCH_AVERAGE_PERIODS = list(`Selected period`  = "PE", 
                                                  `Best "n" years` = "BY")


AVAILABLE_SOCIO_ECONOMIC_OPTIONS = list(`Option #1 - Vulnerability + Priority sectors + Disproportionate burden` = "O1", 
                                        `Option #2 - HDI + GNI + SIDS` = "O2")

AVAILABLE_OUTPUT_TYPES = list(`Quota (%)`   = "quota",
                              `Catches (t)` = "catches")

AVAILABLE_HEATMAP_STYLES = list(`Color` = "color",
                                `Bar`   = "bar")

AVAILABLE_HEATMAP_TYPES = list(`Global`    = "global",
                               `By column` = "by_column")

CPC_DATA   = CONFIG$CPC_CONFIG
CS_SE_DATA = CONFIG$CS_SE_CONFIG