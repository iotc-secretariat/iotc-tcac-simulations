# Libraries
library(rmarkdown)

# ReadMe ####
render("ReadMe.md", output_file = "www/ReadMe.html", quiet = TRUE)

# Disclaimer
render("Disclaimer.md", output_file = "www/Disclaimer.html", quiet = TRUE)

# User Manual
render("UserManual.md", output_file = "www/UserManual.html", quiet = TRUE)

