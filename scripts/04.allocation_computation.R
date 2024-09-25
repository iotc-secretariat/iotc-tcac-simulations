## BASELINE ALLOCATION FUNCTION ####
# Performs the baseline allocation, by attributing the same relative weight to all CPCs
baseline_allocation = function(CPC_data = read_configuration()$CPC_CONFIG) {
  component_allocation_table = CPC_data[STATUS_CODE %in% c("CP"), .(CPC_CODE = CODE)]
  
  # Baseline allocation - para. 6.5
  component_allocation_table[, BASELINE_ALLOCATION := 1.00 / nrow(component_allocation_table)] 
  # Add TWN
  component_allocation_table = rbindlist(list(component_allocation_table, data.table(CPC_CODE = "TWN", BASELINE_ALLOCATION = 0)))
  
  return(
    component_allocation_table[order(CPC_CODE)]
  )
}

## COASTAL STATE ALLOCATION ####

# Performs the coastal state allocation, considering different options for the socio-economic part, with different socio-economic sub-weights to be provided
# Can be improved by removing the need for the explicit provision of the 'socio_economic_option' parameter
coastal_state_allocation = function(CPC_data,
                                    CS_SE_data,
                                    equal_portion_weight,
                                    socio_economic_weight,
                                    socio_economic_option,
                                    socio_economic_option_subweights, # A list of weights depending on the selected socio-economic option (see previous parameter)
                                    NJA_weight
                                   ) {
  
  all_weights = equal_portion_weight + socio_economic_weight + NJA_weight
  
  if(all_weights != 1)
    stop(paste0("The weights provided for the allocation sub-components should sum up to 100% (now: ", all_weights * 100, "%)"))
   
  print(paste0("Coastal state allocation params: EQ_wgt = ", equal_portion_weight, ", ", 
                                                "SE_wgt = ", socio_economic_weight, ", ",
                                                "EZ_wgt = ", NJA_weight))

  print(paste0("Coastal state socio-economic allocation option: ", socio_economic_option))
  
  if(socio_economic_option == "O1") { # First option (see para. 6.6(1)(b)
    print(paste0("Coastal state socio-economic allocation params: vul_wgt = ",     socio_economic_option_subweights$VUL_wgt,     ", ", 
                                                                 "pri_sec_wgt = ", socio_economic_option_subweights$PRI_SEC_wgt, ", ",
                                                                 "dis_bur_wgt = ", socio_economic_option_subweights$DIS_BUR_wgt))

    all_se_weights = socio_economic_option_subweights$VUL + socio_economic_option_subweights$PRI_SEC + socio_economic_option_subweights$DIS_BUR
  }
    
  if(socio_economic_option == "O2") { # Second option (see para. 6.6(1)(b)
    print(paste0("Coastal state socio-economic allocation params: HDI_wgt = ",  socio_economic_option_subweights$HDI_wgt, ", ", 
                                                                 "GNI_wgt = ",  socio_economic_option_subweights$GNI_wgt, ", ",
                                                                 "SIDS_wgt = ", socio_economic_option_subweights$SIDS_wgt))
    
    all_se_weights = socio_economic_option_subweights$HDI + socio_economic_option_subweights$GNI + socio_economic_option_subweights$SIDS
  }
  
  if(all_se_weights != 1)
    stop(paste0("The weights provided for the socio-economic allocation sub-components should sum up to 100% (now: ", all_se_weights * 100, "%)"))
  
  # We start by considering all CPCs with an area under national jurisdiction in the IO. 
  # Some of them might *not* be considered coastal states though (e.g., EU)
  component_allocation_table = CS_SE_data[HAS_NJA_IO == TRUE]
  
  component_allocation_table = 
    merge(
      component_allocation_table, CPC_data[, .(CODE, NJA_SIZE_WEIGHTING)],
      by = "CODE", all.x = TRUE
    )
  
  # Coastal state allocation - para. 6.6(1)(a) - EQUAL PORTION
  component_allocation_table[, EQUAL_ALLOCATION := 1.00 / nrow(component_allocation_table)]
  
  # Coastal state allocation - para. 6.6(1)(b) - SOCIO-ECONOMIC DATA

  # Option 1
  
  ## It is unclear whether only developing / least developed coastal states should be considered here...
  
  ### Assuming it applies to all (proper) coastal states:
  
  component_allocation_table[IS_COASTAL == TRUE, VUL_PCF_ALLOCATION  := PER_CAPITA_FISH_CONSUMPTION_KG  / sum(PER_CAPITA_FISH_CONSUMPTION_KG, na.rm = TRUE)]
  component_allocation_table[IS_COASTAL == TRUE, VUL_CUVI_ALLOCATION := CUV_INDEX                       / sum(CUV_INDEX , na.rm = TRUE)]
  
  component_allocation_table[IS_COASTAL == TRUE, PRI_SEC_SSF_ALLOCATION  := PROP_WORKERS_EMPLOYED_SSF   / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  component_allocation_table[IS_COASTAL == TRUE, PRI_SEC_SIDS_ALLOCATION := SIDS_STATUS                 / sum(SIDS_STATUS, na.rm = TRUE)]
  
  component_allocation_table[IS_COASTAL == TRUE, DIS_BUR_GDP_ALLOCATION := PROP_WORKERS_EMPLOYED_SSF    / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  component_allocation_table[IS_COASTAL == TRUE, DIS_BUR_EXP_ALLOCATION := PROP_EXPORT_VALUE_FISHERY    / sum(PROP_EXPORT_VALUE_FISHERY, na.rm = TRUE)]

  ### Assuming it applies to developing / least developed coastal states only:
  
  #component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", VUL_PCF_ALLOCATION  := PER_CAPITA_FISH_CONSUMPTION_KG  / sum(PER_CAPITA_FISH_CONSUMPTION_KG, na.rm = TRUE)]
  #component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", VUL_CUVI_ALLOCATION := CUV_INDEX                       / sum(CUV_INDEX , na.rm = TRUE)]
  
  #component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", PRI_SEC_SSF_ALLOCATION  := PROP_WORKERS_EMPLOYED_SSF   / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  #component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", PRI_SEC_SIDS_ALLOCATION := SIDS_STATUS                 / sum(SIDS_STATUS, na.rm = TRUE)]

  #component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", DIS_BUR_GDP_ALLOCATION := PROP_WORKERS_EMPLOYED_SSF    / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  #component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", DIS_BUR_EXP_ALLOCATION := PROP_EXPORT_VALUE_FISHERY    / sum(PROP_EXPORT_VALUE_FISHERY, na.rm = TRUE)]
  
  ## In both cases:
  
  component_allocation_table[is.na(VUL_PCF_ALLOCATION),  VUL_PCF_ALLOCATION  := 0]
  component_allocation_table[is.na(VUL_CUVI_ALLOCATION), VUL_CUVI_ALLOCATION := 0]
  
  component_allocation_table[is.na(PRI_SEC_SSF_ALLOCATION),  PRI_SEC_SSF_ALLOCATION := 0]
  component_allocation_table[is.na(PRI_SEC_SIDS_ALLOCATION), PRI_SEC_SIDS_ALLOCATION   := 0]
  
  component_allocation_table[is.na(DIS_BUR_GDP_ALLOCATION), DIS_BUR_GDP_ALLOCATION := 0]
  component_allocation_table[is.na(DIS_BUR_EXP_ALLOCATION), DIS_BUR_EXP_ALLOCATION := 0]
  
  # We weight every sub-sub-component at 50% as the sub-weighting of each component in 6.6(1)(b)[OPTION 1](i-ii-iii) is not clearly specified: 
  
  component_allocation_table[, VUL_ALLOCATION     := .5 * VUL_PCF_ALLOCATION     + .5 * VUL_CUVI_ALLOCATION]
  component_allocation_table[, PRI_SEC_ALLOCATION := .5 * PRI_SEC_SSF_ALLOCATION + .5 * PRI_SEC_SIDS_ALLOCATION]
  component_allocation_table[, DIS_BUR_ALLOCATION := .5 * DIS_BUR_GDP_ALLOCATION + .5 * DIS_BUR_EXP_ALLOCATION]
  
  # Option 2
  
  ## It is fair to assume it only applies to least developed and developing coastal states only
  
  component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", HDI_ALLOCATION  := HDI_TIER_WEIGHT    / sum(HDI_TIER_WEIGHT,    na.rm = TRUE)]
  component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", GNI_ALLOCATION  := GNI_STATUS_WEIGHT  / sum(GNI_STATUS_WEIGHT , na.rm = TRUE)]
  component_allocation_table[IS_COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", SIDS_ALLOCATION := SIDS_STATUS_WEIGHT / sum(SIDS_STATUS_WEIGHT, na.rm = TRUE)]
  
  component_allocation_table[is.na(HDI_ALLOCATION),  HDI_ALLOCATION  := 0]
  component_allocation_table[is.na(GNI_ALLOCATION),  GNI_ALLOCATION  := 0]
  component_allocation_table[is.na(SIDS_ALLOCATION), SIDS_ALLOCATION := 0]
  
  # Coastal state allocation - para. 6.6(1)(c) - NJA area size.
  # It applies to all CPCs with an NJA in the IO, regardless of whether they're coastal states or not.
  component_allocation_table[, NJA_ALLOCATION := NJA_SIZE_WEIGHTING / sum(NJA_SIZE_WEIGHTING)]

  # Puts together the final allocation table with all three components 
  
  if(socio_economic_option == "O1") { # First option
    component_allocation_table = 
      component_allocation_table[, COASTAL_STATE_ALLOCATION := ((equal_portion_weight * EQUAL_ALLOCATION) + 
                                                                (socio_economic_weight * (socio_economic_option_subweights$VUL_wgt     * VUL_ALLOCATION)    ) + 
                                                                (socio_economic_weight * (socio_economic_option_subweights$PRI_SEC_wgt * PRI_SEC_ALLOCATION)) + 
                                                                (socio_economic_weight * (socio_economic_option_subweights$DIS_BUR_wgt * DIS_BUR_ALLOCATION)) + 
                                                                (NJA_weight * NJA_ALLOCATION))][, .(CPC_CODE = CODE, COASTAL_STATE_ALLOCATION)]
  }

  if(socio_economic_option == "O2") { # Second option
    component_allocation_table_final = 
      component_allocation_table[, .(EQUAL_PORTION_WEIGHT  = equal_portion_weight, 
                                     EQUAL_ALLOCATION, 
                                     CSA_EQUAL_ALLOCATION  = equal_portion_weight * EQUAL_ALLOCATION, 
                                     SOCIO_ECONOMIC_WEIGHT = socio_economic_weight, 
                                     SEW_HDI               = socio_economic_option_subweights$HDI_wgt, 
                                     HDI_ALLOCATION, 
                                     CSA_HDI_ALLOCATION    = socio_economic_weight * socio_economic_option_subweights$HDI_wgt  * HDI_ALLOCATION, 
                                     SEW_GNI               = socio_economic_option_subweights$GNI_wgt, 
                                     GNI_ALLOCATION, 
                                     CSA_GNI_ALLOCATION    = socio_economic_weight * socio_economic_option_subweights$GNI_wgt  * GNI_ALLOCATION, 
                                     SIDS_ALLOCATION,  
                                     CSA_SIDS_ALLOCATION   = socio_economic_weight * socio_economic_option_subweights$SIDS_wgt * SIDS_ALLOCATION, 
                                     NJA_WEIGHT            = NJA_weight, 
                                     NJA_ALLOCATION, 
                                     CSA_NJA_ALLOCATION    = NJA_weight * NJA_ALLOCATION, 
                                     COASTAL_STATE_ALLOCATION = ((equal_portion_weight * EQUAL_ALLOCATION) + 
                                                                  (socio_economic_weight * (socio_economic_option_subweights$HDI_wgt  * HDI_ALLOCATION) ) + 
                                                                  (socio_economic_weight * (socio_economic_option_subweights$GNI_wgt  * GNI_ALLOCATION) ) + 
                                                                  (socio_economic_weight * (socio_economic_option_subweights$SIDS_wgt * SIDS_ALLOCATION)) + 
                                                                  (NJA_weight * NJA_ALLOCATION))), .(CPC_CODE = CODE)]
  }
  
  return(component_allocation_table_final)
}

## CATCH-BASED ALLOCATION FUNCTION ####
catch_based_allocation = function(CPC_data,   # Unused
                                  CS_SE_data, # Unused
                                  catch_data,
                                  average_catch_function,
                                  coastal_weights) {

  print(paste0("Catch-based allocation: NJA attribution weights [", paste0(coastal_weights, collapse = ", "), "]"))
  
  if(length(which(coastal_weights > 100)) > 0)
    stop("The NJA attribution weights should not exceed 100% each")
  
  if(length(which(coastal_weights < 0)) > 0)
    stop("The NJA attribution weights should not be negative")
  
  catch_allocation_table = data.table(CPC_CODE = unique(catch_data$CPC_CODE))
  
  year = 1
  
  # Can be improved by apply-ing the business logic to all elements of the matrix, but this way it's more readable:
  for(weight in coastal_weights) {
    current_data = average_catch_function(weight_catch_data(catch_data, weight))
    current_data[, CATCH_MT := CATCH_MT / sum(CATCH_MT, na.rm = TRUE)]
    
    colnames(current_data)[2] = paste0("CATCH_BASED_ALLOCATION_YEAR_", year)
    
    catch_allocation_table = merge(catch_allocation_table, current_data,
                                   by = "CPC_CODE", all.x = TRUE)
    
    year = year + 1
  }
  
  catch_allocation_table[is.na(catch_allocation_table)] = 0
  
  return(catch_allocation_table)
}

# Performs the allocation of a given TAC (in tons) to the weighted annual quotas (in %) using the various coefficients for the
# three main components and their respective weights
allocate_TAC = function(TAC, 
                        baseline_allocation,      baseline_allocation_weight, 
                        coastal_state_allocation, coastal_state_allocation_weight,
                        catch_based_allocation,   catch_based_allocation_weight) {
  
  all_weights = baseline_allocation_weight + coastal_state_allocation_weight + catch_based_allocation_weight

  if(round(all_weights * 100, 1) != 100)
    stop(paste0("The weights provided for the various allocation components should sum up to 100% (now:", all_weights * 100, "%)"))

  print(paste0("Allocate TAC parameters: [ TAC = ", TAC, 
                                        ", BA_wgt = ", baseline_allocation_weight, 
                                        ", CS_wgt = ", coastal_state_allocation_weight,
                                        ", CB_wgt = ", catch_based_allocation_weight, " ]"))
  
  # Need to 'copy' the inputs, otherwise the code below will update the original allocation tables...
  baseline_allocation      = copy(baseline_allocation)    
  coastal_state_allocation = copy(coastal_state_allocation)
  catch_based_allocation   = copy(catch_based_allocation)

  baseline_allocation     [, BASELINE_ALLOCATION            := TAC * BASELINE_ALLOCATION      * baseline_allocation_weight]
  coastal_state_allocation[, COASTAL_STATE_ALLOCATION       := TAC * COASTAL_STATE_ALLOCATION * coastal_state_allocation_weight]
  catch_based_allocation  [, 2:ncol(catch_based_allocation) := lapply(.SD, function(x) { x * TAC * catch_based_allocation_weight }), .SDcols = 2:ncol(catch_based_allocation)]
  
  # This can definitely be implemented better...
  constant_allocation = merge(baseline_allocation, coastal_state_allocation,  
                              by = "CPC_CODE", 
                              all.x = TRUE)
  
  # Removes NAs in the coastal state allocation (for non-coastal CPCs)
  constant_allocation[is.na(COASTAL_STATE_ALLOCATION), COASTAL_STATE_ALLOCATION := 0.0]
  
  # Calculates the 'constant' allocation for all CPCs as the sum of the baseline allocation and the coastal state allocation factor (does not change with selected catch periods and coastal catches weights)
  constant_allocation = constant_allocation[, CONSTANT_ALLOCATION := BASELINE_ALLOCATION + COASTAL_STATE_ALLOCATION][, .(CPC_CODE, CONSTANT_ALLOCATION)]
  
  # This also can definitely be implemented better...
  final_allocation_table = merge(baseline_allocation[, .(CPC_CODE)], catch_based_allocation,
                                 by = "CPC_CODE", 
                                 all.x = TRUE) # Ensures all CPCs are kept, regardless of whether they had catches in the considered timeframe or not
  
  # Adds the 'constant' allocation (see above) to the catch-based allocations for the first 10 years of projections
  for(CPC in final_allocation_table$CPC_CODE) { 
    # The ifelse(is.na(x), 0, x) part is necessary to address catch-based allocation values for CPCs with no historical catches in the selected period 
    final_allocation_table[CPC_CODE == CPC, 2:ncol(final_allocation_table) := lapply(.SD, function(x) { ifelse(is.na(x), 0, x) + constant_allocation[CPC_CODE == CPC]$CONSTANT_ALLOCATION }), .SDcols = 2:ncol(final_allocation_table)]
  }
  
  # Renames the output columns
  colnames(final_allocation_table)[2:ncol(final_allocation_table)] = paste0("QUOTA_YEAR_", seq(1:(ncol(final_allocation_table) - 1)))
  
  return(
    final_allocation_table
  )
}

