# Source the R codes
setwd("initialization")
source("00_CORE.R")
setwd("..")

WP_IDENTIFIER = "IOTC-2024-TCAC-WG"
PAPER_NUMBER_VERSION = "01"

### PPTX
render("./00_PPTX.Rmd", 
       output_format = powerpoint_presentation(reference_doc = "../../templates/ppt_template.potx", slide_level = 2),
       output_dir    = "outputs/ppt/", 
       output_file   = paste0(TITLE, ".pptx")
)

