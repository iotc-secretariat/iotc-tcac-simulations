l_info("Computing coastal state and catch-based allocations...")

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
                                         NJA_weight                 = CS_NJA_WEIGHT)

# COMPUTE CATCH-BASED ALLOCATION ####
CB_ALLOCATION = catch_based_allocation(CPC_data = CPC_data, CS_SE_data = CS_SE_data,
                                       catch_data = subset_and_postprocess_catch_data(catch_data = catch_data,
                                                                                      species_code = SPECIES_SELECTED,
                                                                                      years        = REFERENCE_YEARS),
                                       average_catch_function = REFERENCE_METHOD,
                                       coastal_weights = ALLOCATION_TRANSITION)

# COMPUTE QUOTA ALLOCATION THROUGHOUT TRANSITION PERIOD ####
QUOTAS = allocate_TAC(TAC = TAC_VALUE, 
               baseline_allocation      = BA_ALLOCATION, baseline_allocation_weight      = BASELINE_WEIGHT, 
               coastal_state_allocation = CS_ALLOCATION, coastal_state_allocation_weight = COASTAL_STATE_WEIGHT, 
               catch_based_allocation   = CB_ALLOCATION, catch_based_allocation_weight   = CATCH_BASED_WEIGHT)
