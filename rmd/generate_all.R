# Define date range for charts
START_DATE = as.Date("2023-01-01")
END_DATE   = as.Date("2023-12-31")

# Define CPC of interest (code)
CPC_SELECTED = "KOR"
if(CPC_SELECTED == "EU"){FLEETS_SELECTED = c("EUESP", "EUFRA", "EUITA")} else {FLEETS_SELECTED = CPC_SELECTED}

# Source the R codes
setwd("initialisation")
source("00_CORE.R")
setwd("..")

# CPC names
CPC_LIST = data.table(CPC_CODE = c("EU", "JPN", "KOR", "MUS", "OMN", "SYC", "TZA"), CPC = c("European Union", "Japan", "Korea", "Mauritius", "Oman", "Seychelles", "Tanzania"))

REPORT_OUTPUT_NAME = paste0(CPC_SELECTED, "_3BU_", START_DATE, "_", END_DATE)

# DOCX
render("rmd/00_DOCX_HTML.Rmd", output_dir = "outputs/cpc_submission_factsheets/", output_file = paste0(REPORT_OUTPUT_NAME, ".docx"))

