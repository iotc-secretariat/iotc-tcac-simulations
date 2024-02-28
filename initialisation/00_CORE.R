# Clears the environment
rm(list = ls())

# Prevents formatting of numbers using scientific notation (e.g., in heatmap legends)
options(scipen = 99999)

# Includes defaults and helper functions
source("91_LIBS_EXTERNAL.R")
source("92_LIBS_IOTC.R")
source("93_FUNCTIONS.R")

# Source the scripts
source("../scripts/01.configure_and_preprocess.R")
source("01_HISTORICAL_CATCH_ESTIMATES.R")
source("02_SOCIO_ECONOMIC_INDICATORS.R")
#source("03_CPC_FEATURES_MAPS.R")
#source("04_NATIONAL_JURISDICTION_MAPS.R")