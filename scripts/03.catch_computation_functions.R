# Calculates the average catch data over an entire timeframe
period_average_catch_data = function(weighted_catch_data) {
  return(
    weighted_catch_data[, .(CATCH_MT = sum(CATCH_MT) / .N), keyby = .(CPC_CODE)]
  )
}

# Calculates the average catch data for the 'best' n-years in a given entire timeframe, where 'best' means 'with higher catches recorded'
# In doing so, it uses the weighted catch data (see the 'weight_catch_data' function) that take into account the ABNJ / foreign flag catch attribution
best_years_average_catch_data = function(weighted_catch_data,
                                         max_num_years) {
  weighted_catch_best_years =
    # See: https://stackoverflow.com/questions/14800161/select-the-top-n-values-by-group
    weighted_catch_data[,.SD[order(CATCH_MT, decreasing = TRUE),][1:max_num_years], by = "CPC_CODE"][, .(CPC_CODE, YEAR, CATCH_MT)][order(CPC_CODE, YEAR)][!is.na(CATCH_MT)]
  
  return(
    weighted_catch_best_years[, .(CATCH_MT = sum(CATCH_MT) / .N), keyby = .(CPC_CODE)]
  )
}
