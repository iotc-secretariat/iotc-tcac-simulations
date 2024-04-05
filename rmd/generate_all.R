# Source the scripts for loading and plotting the data
setwd("../initialisation/")
source("./00_CORE.R")
setwd("..")

# CONFIGURE ONE SCENARIO ####
BASELINE_WEIGHT      = 0.05
COASTAL_STATE_WEIGHT = 0.05
CATCH_BASED_WEIGHT   = 1 - (BASELINE_WEIGHT + COASTAL_STATE_WEIGHT)

# COASTAL STATE COMPONENT (species-independent)
CS_EQUAL_WEIGHT          = 0.35
CS_SOCIO_ECONOMIC_WEIGHT = 0.475
  SE_HDI_WEIGHT = 0.3
  SE_GNI_WEIGHT = 0.3
  SE_SID_WEIGHT = 0.4
CS_NJA_WEIGHT            = 1 - (CS_EQUAL_WEIGHT + CS_SOCIO_ECONOMIC_WEIGHT) 
    
# CATCH-BASED COMPONENT
SPECIES_SELECTED      = "YFT"
TAC_VALUE             = 300000
REFERENCE_YEARS       = 2000:2016
REFERENCE_METHOD      = period_average_catch_data    # or best_years_average_catch_data
ALLOCATION_TRANSITION = seq(.1, 1, .1)               # vector of length 10 of increasing cumulative re-attribution of the NJA catch to the coastal states

# Source the R allocation scripts
setwd("../initialisation/")
source("./SCENARIO_ALLOCATION_COMPUTATION.R")
setwd("..")

# DOCX
render("rmd/00_DOCX_HTML.Rmd", 
       output_dir = "outputs/", 
       output_file = paste0(REPORT_OUTPUT_NAME, ".docx"))

