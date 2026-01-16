print("Computing allocations for one given scenario...")

# COMPUTE BASELINE ALLOCATION ####
BA_ALLOCATION = baseline_allocation(CPC_data = CPC_data)

# COMPUTE DEVELOPING STATE ALLOCATION
DS_ALLOCATION = developing_state_allocation(CPC_data = CPC_data,
                                            equal_portion_weight = DS_EQUAL_WEIGHT,
                                            ldc_weight = DS_LDC_WEIGHT,
                                            sids_weight = DS_SIDS_WEIGHT)
# COMPUTE CATCH-BASED ALLOCATION ####
CB_ALLOCATION = catch_based_allocation(CPC_data = CPC_data,
                                       catch_data = subset_and_postprocess_catch_data(catch_data = catch_data,
                                                                                      species_code = SPECIES_CODE_SELECTED,
                                                                                      years = HISTORICAL_CATCH_INTERVAL_START:HISTORICAL_CATCH_INTERVAL_END, 
                                                                                      onlyHS = OnlyHS),
                                       average_catch_function = HISTORICAL_CATCH_AVERAGE,
                                       coastal_weights = ALLOCATION_TRANSITION)

# COMPUTE QUOTA ALLOCATION THROUGHOUT TRANSITION PERIOD ####
QUOTAS = allocate_TAC(TAC = TARGET_TAC_T, 
                      baseline_allocation = BA_ALLOCATION, 
                      baseline_allocation_weight = BASELINE_WEIGHT, 
                      developing_state_allocation = DS_ALLOCATION,
                      developing_state_allocation_weight = DEVELOPING_STATE_WEIGHT,
                      catch_based_allocation   = CB_ALLOCATION, 
                      catch_based_allocation_weight   = CATCH_BASED_WEIGHT)


if(!is.null(REPORTING_ENTITY)){
 DS_ALLOCATION = DS_ALLOCATION[DS_ALLOCATION$CPC_CODE == REPORTING_ENTITY,] 
 # CS_ALLOCATION = CS_ALLOCATION[CS_ALLOCATION$CPC_CODE == REPORTING_ENTITY,] 
 CB_ALLOCATION = CB_ALLOCATION[CB_ALLOCATION$CPC_CODE == REPORTING_ENTITY,]
 QUOTAS = QUOTAS[QUOTAS$CPC_CODE == REPORTING_ENTITY,]
}

print("Allocations computed for one given scenario!")
