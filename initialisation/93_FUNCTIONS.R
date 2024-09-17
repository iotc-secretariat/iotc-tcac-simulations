DEBUG_LEVELS = data.table(
  LEVEL = c(0, 1, 2, 3),
  LABEL = c("DEBUG", "INFO", "WARN", "ERROR"),
  stringsAsFactors = FALSE
)

DEBUG_LEVEL = DEBUG_LEVELS[LABEL == "INFO"]$LEVEL

set_debug_level = function(debug_level = "INFO") {
  if(is.na(debug_level)) {
    print(DEBUG_LEVELS[LEVEL == DEBUG_LEVEL])
  } else {
    DEBUG_LEVEL = DEBUG_LEVELS[LABEL == debug_level]$LEVEL
    print(DEBUG_LEVELS[LEVEL == DEBUG_LEVEL])
  }
}

debug = function(severity = "INFO", text = "Debug message", prefix = NA) {
  severity_level = DEBUG_LEVELS[LABEL == severity]$LEVEL
  
  if(DEBUG_LEVEL <= severity_level) {
    cat(paste0("[ ", date(), " ] : [ ", severity, " ] : ", fifelse(is.na(prefix), "", paste0("{ ", prefix, " } : ")), text, "\n"))
  }
  
  return(invisible())
}

d_debug = function(text = "DEBUG message", prefix = NA) {
  debug("DEBUG", text, prefix)
  
  return(invisible())
}

d_info = function(text = "INFO message", prefix = NA) {
  debug("INFO", text, prefix)
  
  return(invisible())
}

d_warn = function(text = "WARN message", prefix = NA) {
  debug("WARN", text, prefix)
  
  return(invisible())
}

d_error = function(text = "ERROR message", prefix = NA) {
  debug("ERROR", text, prefix)
  
  return(invisible())
}

d_info("Initializing common functions...")

charts_folder = function(dataset = "NC", species_code, subfolder) { 
  folder = paste0("../outputs/charts/", dataset)
  
  if(!is.na(species_code)) folder = paste0(folder, "/", species_code)
  if(!is.na(subfolder)) folder = paste0(folder, "/", subfolder)
  
  return(folder)
}

chart_file = function(dataset = "NC", species_code, subfolder, filename) {
  folder = charts_folder(dataset, species_code, subfolder)
  file   = paste0(folder, "/", filename)
  
  l_info(paste0("File path: ", file))
  
  return(file)
}

first_year = function(years) {
  return (head(sort(+years), 1))
}

last_year = function(years) {
  return (tail(sort(+years), 1))
}

last_n_years = function(years, n) {
  Y_E = last_year(years)
  Y_S = Y_E - n + 1
  
  return (Y_S:Y_E)
}

last_5_years = function(years) {
  return (last_n_years(years, 5))
}

last_10_years = function(years) {
  return (last_n_years(years, 10))
}

last_n_ennium = function(years, n = 5) {
  Y_S = floor(last_year(years) / n) * n # Beginning of last n-ennium
  Y_E = Y_S + n - 1                     # End of last n-ennium
  
  return (Y_S:Y_E)  
}

last_complete_n_ennium = function(years, n = 5) {
  LN = last_n_ennium(years, n)
  
  if(last_year(LN) > last_year(years)) {
    Y_E = first_year(LN) - 1
    Y_S = Y_E - n + 1
  } else {
    Y_S = first_year(LN)
    Y_E = last_year(LN)
  }
  
  return (Y_S:Y_E)
}
  
last_quinquennium = function(years) { 
  return (last_n_ennium(years, 5))
}

last_complete_quinquennium = function(years) { 
  return (last_complete_n_ennium(years, 5))
}

last_decade = function(years) { 
  return (last_n_ennium(years, 10))
}

last_complete_decade = function(years) { 
  return (last_complete_n_ennium(years, 10))
}

first_n_ennium = function(years, n = 5) {
  Y_S = floor(first_year(years) / n) * n # Beginning of last n-ennium
  Y_E = Y_S + n - 1                     # End of last n-ennium
  
  return (Y_S:Y_E)  
}

first_complete_n_ennium = function(years, n = 5) {
  FQ = first_n_ennium(years, n)
  
  if(first_year(FQ) < first_year(years)) {
    Y_S = last_year(FQ) + 1
    Y_E = Y_S + n - 1
  } else {
    Y_S = first_year(FQ)
    Y_E = last_year(FQ)
  }
  
  return (Y_S:Y_E)
}

first_quinquennium = function(years) { 
  return (first_n_ennium(years, 5))
}

first_complete_quinquennium = function(years) { 
  return (first_complete_n_ennium(years, 5))
}

first_decade = function(years) { 
  return (first_n_ennium(years, 10))
}

first_complete_decade = function(years) { 
  return (first_complete_n_ennium(years, 10))
}

fy   = first_year
ly   = last_year
lny  = last_n_years
l5y  = last_5_years
l10y = last_10_years
lq   = last_quinquennium
lcq  = last_complete_quinquennium
ld   = last_decade
lcd  = last_complete_decade
fq   = first_quinquennium
fcq  = first_complete_quinquennium
fd   = first_decade
fcd  = first_complete_decade

# Wrappers for decade extraction
floor_decade    = function(value){ return(value - value %% 10) }
ceiling_decade  = function(value){ return(floor_decade(value)+10) }
round_to_decade = function(value){ return(round(value / 10) * 10) }

# Rounding function
round_bin = function(size, bin_size) { return (floor(size / bin_size) * bin_size + bin_size/2) }

#prettyNum with default ',' as big mark
pn = function(number, big.mark = ",") {
  return(prettyNum(number, big.mark = big.mark))
}

#prettyNum with no big mark
pnn = function(number) {
  return(pn(number, ""))
}

#Round to hundreds
rh = function(number) {
  return(r_to(number, 100))
}

#Round to thousands
rt = function(number) {
  return(r_to(number, 1000))
}

#Round to tens of thousands
rtt = function(number) {
  return(r_to(number, 10000))
}

#Round to hundreds of thousands
rht = function(number) {
  return(r_to(number, 100000))
}

#Rounds to a base (a multiple of 10)
r_to = function(number, base) {
  return(round(number / base) * base) 
}

print("Common functions initialised!")
