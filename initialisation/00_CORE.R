# Clears the environment
rm(list = ls())

# Source the functions
source("./scripts/00.core.R")

# Includes defaults and helper functions
source("./initialisation/93_FUNCTIONS.R")
source("./initialisation/94_TABLEFORMAT_FUNCTION.R")

# Extract the data
CPC_data   = read_entities()
catch_data = read_catch_data(CPC_data = CPC_data)

# Species table
SPECIES_TABLE = data.table(SPECIES_CODE = c("ALB", "BET", "SKJ", "SWO", "YFT"), 
                           SPECIES = c("Albacore", "Bigeye tuna", "Skipjack tuna", "Swordfish", "Yellowfin tuna"), 
                           SPECIES_SCIENTIFIC = c("Thunnus alalunga", "Thunnus obesus", "Katsuwonus pelamis", "Xiphias gladius", "Thunnus albacares")
)

# Source the scripts for data description (once)
#source("01_HISTORICAL_CATCH_ESTIMATES.R")
#source("02_SOCIO_ECONOMIC_INDICATORS.R")