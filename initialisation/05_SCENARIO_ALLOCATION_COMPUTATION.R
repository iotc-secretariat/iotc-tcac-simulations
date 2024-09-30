print("Computing allocations for one given scenario...")

# COMPUTE BASELINE ALLOCATION ####
BA_ALLOCATION = baseline_allocation()

# COMPUTE COASTAL STATE ALLOCATION ####
CS_ALLOCATION = coastal_state_allocation(CPC_data = CPC_data, CS_SE_data = CS_SE_data,
                                         equal_portion_weight       = CS_EQUAL_WEIGHT,
                                         socio_economic_weight      = CS_SOCIO_ECONOMIC_WEIGHT,
                                         socio_economic_option      = "O2",
                                         socio_economic_option_subweights = 
                                           list(
                                             HDI_wgt  = SE_HDI_WEIGHT,
                                             GNI_wgt  = SE_GNI_WEIGHT,
                                             SIDS_wgt = SE_SID_WEIGHT
                                           ),
                                         NJA_weight = CS_NJA_WEIGHT)

# COMPUTE CATCH-BASED ALLOCATION ####
CB_ALLOCATION = catch_based_allocation(CPC_data = CPC_data, CS_SE_data = CS_SE_data,
                                       catch_data = subset_and_postprocess_catch_data(catch_data = catch_data,
                                                                                      species_code = SPECIES_CODE_SELECTED,
                                                                                      years = HISTORICAL_CATCH_INTERVAL_START:HISTORICAL_CATCH_INTERVAL_END, 
                                                                                      onlyHS = OnlyHS),
                                       average_catch_function = HISTORICAL_CATCH_AVERAGE,
                                       coastal_weights = ALLOCATION_TRANSITION)

# COMPUTE QUOTA ALLOCATION THROUGHOUT TRANSITION PERIOD ####
QUOTAS = allocate_TAC(TAC = TARGET_TAC_T, 
                      baseline_allocation = BA_ALLOCATION, baseline_allocation_weight = BASELINE_WEIGHT, 
               coastal_state_allocation = CS_ALLOCATION, coastal_state_allocation_weight = COASTAL_STATE_WEIGHT, 
               catch_based_allocation   = CB_ALLOCATION, catch_based_allocation_weight   = CATCH_BASED_WEIGHT)


if(!is.null(REPORTING_ENTITY)){
 CS_ALLOCATION = CS_ALLOCATION[CS_ALLOCATION$CPC_CODE == REPORTING_ENTITY,] 
 CB_ALLOCATION = CB_ALLOCATION[CB_ALLOCATION$CPC_CODE == REPORTING_ENTITY,]
 QUOTAS = QUOTAS[QUOTAS$CPC_CODE == REPORTING_ENTITY,]
}

print("Allocations computed for one given scenario!")
