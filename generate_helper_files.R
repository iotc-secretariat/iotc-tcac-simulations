# Libraries
library(rmarkdown)

# ReadMe ####
render("ReadMe.md", output_file = "www/readme.html", quiet = TRUE)

# Disclaimer
render("Disclaimer.md", output_file = "www/disclaimer.html", quiet = TRUE)

# User Manual
render("UserManualWithTOC.Rmd", output_file = "www/usermanual.html", quiet = TRUE)

