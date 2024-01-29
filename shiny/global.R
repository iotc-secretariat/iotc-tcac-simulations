source("../01.configure_and_preprocess.R")

CONFIG = read_configuration("../CPC_core_data.xlsx")

ALL_CATCH_DATA = read_catch_data("../HISTORICAL_CATCH_ESTIMATES.csv", CPC_data = CONFIG$CPC_CONFIG)

AVAILABLE_YEARS = list(MIN = min(ALL_CATCH_DATA$YEAR), 
                       MAX = max(ALL_CATCH_DATA$YEAR))

AVAILABLE_SPECIES = list(`ALB - Albacore tuna`  = "ALB",
                         `BET - Bigeye tuna`    = "BET",
                         `SKJ - Skipjack tuna`  = "SKJ",
                         `YFT - Yellowfin tuna` = "YFT",
                         `SWO - Swordfish`      = "SWO")

AVAILABLE_HISTORICAL_CATCH_AVERAGE_PERIODS = list(`Entire period`  = "PE", 
                                                  `Best 'n' years` = "BY")


CPC_DATA   = CONFIG$CPC_CONFIG
CS_SE_DATA = CONFIG$CS_SE_CONFIG