## BASELINE ALLOCATION FUNCTION ####
# Performs the baseline allocation, by attributing the same relative weight to all CPCs
baseline_allocation = function(CPC_data = read_entities()) {
  component_allocation_table = CPC_data[STATUS_CODE %in% c("CP"), .(ENTITY_CODE = CODE)]
  
  # Baseline allocation - para. 6.5
  component_allocation_table[, BASELINE_ALLOCATION := 1.00 / nrow(component_allocation_table)] 
  # Add TWN
  component_allocation_table = rbindlist(list(component_allocation_table, data.table(ENTITY_CODE = "TWN", BASELINE_ALLOCATION = 0)))
  
  return(
    component_allocation_table[order(ENTITY_CODE)]
  )
}

## DEVELOPING STATE ALLOCATION ####
#QUESTIONs:
#- how to compute LDC_ALLOCATION?
#- NJA_weight?
developing_state_allocation = function(CPC_data,
                                       equal_portion_weight,
                                       ldc_weight,
                                       sids_weight) {
  
  all_weights = equal_portion_weight + ldc_weight + sids_weight
  
  if(all_weights != 1)
    stop(paste0("The weights provided for the allocation sub-components should sum up to 100% (now: ", all_weights * 100, "%)"))
 
  print(paste0("Developing state allocation params: EQ_wgt = ", equal_portion_weight, ", ", 
               "LDC_wgt = ", ldc_weight, ", ",
               "SIDS_wgt = ", sids_weight))
  
  ##TO REVIEW => recycled from coastal_state_allocation
  
  # We start by considering all CPCs with an area under national jurisdiction in the IO + IS_DEVELOPING 
  # Some of them might *not* be considered coastal states though (e.g., EU)
  component_allocation_table = CPC_data[IS_COASTAL == TRUE & IS_DEVELOPING == TRUE,]
  
  # Coastal state allocation - para. 6.6(1)(a) - EQUAL PORTION
  component_allocation_table[, EQUAL_ALLOCATION := 1.00 / nrow(component_allocation_table)]
  component_allocation_table[IS_LDC == TRUE, LDC_ALLOCATION := LDC_STATUS_WEIGHT / sum(LDC_STATUS_WEIGHT, na.rm = TRUE)]
  component_allocation_table[IS_SIDS == TRUE, SIDS_ALLOCATION := SIDS_STATUS_WEIGHT / sum(SIDS_STATUS_WEIGHT, na.rm = TRUE)]
  component_allocation_table[is.na(LDC_ALLOCATION), LDC_ALLOCATION := 0] #NEW need LDC_STATUS_WEIGHT
  component_allocation_table[is.na(SIDS_ALLOCATION), SIDS_ALLOCATION := 0]
  
  #developing state allocation table
  component_allocation_table[, DEVELOPING_STATE_EQUAL_ALLOCATION := equal_portion_weight * EQUAL_ALLOCATION]
  component_allocation_table[, DEVELOPING_STATE_LDC_ALLOCATION := ldc_weight * LDC_ALLOCATION]
  component_allocation_table[, DEVELOPING_STATE_SIDS_ALLOCATION := sids_weight * SIDS_ALLOCATION]
  component_allocation_table = component_allocation_table[, DEVELOPING_STATE_ALLOCATION := (DEVELOPING_STATE_EQUAL_ALLOCATION + 
                                                              DEVELOPING_STATE_LDC_ALLOCATION + 
                                                              DEVELOPING_STATE_SIDS_ALLOCATION)][, .(ENTITY_CODE = CODE, 
                                                                                                     DEVELOPING_STATE_EQUAL_ALLOCATION,
                                                                                                     DEVELOPING_STATE_LDC_ALLOCATION,
                                                                                                     DEVELOPING_STATE_SIDS_ALLOCATION,
                                                                                                     DEVELOPING_STATE_ALLOCATION)]
  
  
  return(component_allocation_table)
   
}

## CATCH-BASED ALLOCATION FUNCTION ####
catch_based_allocation = function(CPC_data,
                                  catch_data,
                                  average_catch_function,
                                  coastal_weights) {

  print(paste0("Catch-based allocation: NJA attribution weights [", paste0(coastal_weights, collapse = ", "), "]"))
  
  if(length(which(coastal_weights > 100)) > 0)
    stop("The NJA attribution weights should not exceed 100% each")
  
  if(length(which(coastal_weights < 0)) > 0)
    stop("The NJA attribution weights should not be negative")
  
  catch_allocation_table = data.table(ENTITY_CODE = unique(catch_data$ENTITY_CODE))
  
  year = 1
  
  # Can be improved by apply-ing the business logic to all elements of the matrix, but this way it's more readable:
  for(weight in coastal_weights) {
    current_data = average_catch_function(weight_catch_data(catch_data, weight))
    current_data[, CATCH_MT := CATCH_MT / sum(CATCH_MT, na.rm = TRUE)]
    
    colnames(current_data)[2] = paste0("CATCH_BASED_ALLOCATION_YEAR_", year)
    
    catch_allocation_table = base::merge(catch_allocation_table, current_data,
                                   by = "ENTITY_CODE", all.x = TRUE)
    
    year = year + 1
  }
  
  catch_allocation_table[is.na(catch_allocation_table)] = 0
  
  return(catch_allocation_table)
}

# Performs the allocation of a given TAC (in tons) to the weighted annual quotas (in %) using the various coefficients for the
# three main components and their respective weights
allocate_TAC = function(TAC, 
                        baseline_allocation,
                        baseline_allocation_weight,
                        developing_state_allocation,
                        developing_state_allocation_weight,
                        catch_based_allocation,
                        catch_based_allocation_weight) {
  
  all_weights = baseline_allocation_weight + developing_state_allocation_weight + catch_based_allocation_weight

  if(round(all_weights * 100, 1) != 100)
    stop(paste0("The weights provided for the various allocation components should sum up to 100% (now:", all_weights * 100, "%)"))

  print(paste0("Allocate TAC parameters: [ TAC = ", TAC, 
                                        ", BA_wgt = ", baseline_allocation_weight,
                                        ", DS_wgt = ", developing_state_allocation_weight,
                                        ", CB_wgt = ", catch_based_allocation_weight, " ]"))
  
  # Need to 'copy' the inputs, otherwise the code below will update the original allocation tables...
  baseline_allocation      = copy(baseline_allocation)    
  developing_state_allocation = copy(developing_state_allocation)
  catch_based_allocation   = copy(catch_based_allocation)
  
  baseline_allocation     [, BASELINE_ALLOCATION            := TAC * BASELINE_ALLOCATION * baseline_allocation_weight]
  developing_state_allocation[, DEVELOPING_STATE_ALLOCATION       := TAC * DEVELOPING_STATE_ALLOCATION * developing_state_allocation_weight]
  catch_based_allocation  [, 2:ncol(catch_based_allocation) := lapply(.SD, function(x) { x * TAC * catch_based_allocation_weight }), .SDcols = 2:ncol(catch_based_allocation)]
  
  # This can definitely be implemented better...
  constant_allocation = base::merge(baseline_allocation, developing_state_allocation,  
                              by = "ENTITY_CODE", 
                              all.x = TRUE)
  
  # Removes NAs in the coastal state allocation (for non-coastal CPCs)
  constant_allocation[is.na(DEVELOPING_STATE_ALLOCATION), DEVELOPING_STATE_ALLOCATION := 0.0]
  
  # Calculates the 'constant' allocation for all CPCs as the sum of the baseline allocation and the developing state allocation factor (does not change with selected catch periods and coastal catches weights)
  constant_allocation = constant_allocation[, CONSTANT_ALLOCATION := BASELINE_ALLOCATION + DEVELOPING_STATE_ALLOCATION][, .(ENTITY_CODE, CONSTANT_ALLOCATION)]
  
  # This also can definitely be implemented better...
  final_allocation_table = base::merge(baseline_allocation[, .(ENTITY_CODE)], catch_based_allocation,
                                 by = "ENTITY_CODE", 
                                 all.x = TRUE) # Ensures all CPCs are kept, regardless of whether they had catches in the considered timeframe or not
  
  # Adds the 'constant' allocation (see above) to the catch-based allocations for the first 10 years of projections
  for(CPC in final_allocation_table$ENTITY_CODE) { 
    # The ifelse(is.na(x), 0, x) part is necessary to address catch-based allocation values for CPCs with no historical catches in the selected period 
    final_allocation_table[ENTITY_CODE == CPC, 2:ncol(final_allocation_table) := lapply(.SD, function(x) { ifelse(is.na(x), 0, x) + constant_allocation[ENTITY_CODE == CPC]$CONSTANT_ALLOCATION }), .SDcols = 2:ncol(final_allocation_table)]
  }
  
  # Renames the output columns
  colnames(final_allocation_table)[2:ncol(final_allocation_table)] = paste0("QUOTA_YEAR_", seq(1:(ncol(final_allocation_table) - 1)))
  
  return(
    final_allocation_table
  )
}

