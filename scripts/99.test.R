#### EXAMPLE FOR YFT ASSUMING A TAC OF 500000 t
source("01.configure_and_preprocess.R")

CPC_data   = read_configuration()$CPC_CONFIG
CS_SE_data = read_configuration()$CS_SE_CONFIG

catch_data = read_catch_data()

BA_ALLOCATION = baseline_allocation()

CS_ALLOCATION = coastal_state_allocation(CPC_data = CPC_data, CS_SE_data = CS_SE_data,
                                         equal_portion_weight       = 0.350,
                                         socio_economic_weight      = 0.475,
                                          socio_economic_option     = "O2",
                                          socio_economic_option_subweights = 
                                           list(
                                             HDI_wgt  = 0.3,
                                             GNI_wgt  = 0.3,
                                             SIDS_wgt = 0.4
                                           ),
                                         NJA_weight                 = 0.175)

CB_ALLOCATION = catch_based_allocation(CPC_data = CPC_data, CS_SE_data = CS_SE_data,
                                       catch_data = subset_and_postprocess_catch_data(catch_data = catch_data,
                                                                                      species_code = "YFT",
                                                                                      years        = 2000:2016),
                                       average_catch_function = period_average_catch_data,
                                       coastal_weights = seq(.1, 1, .1))

CB_ALLOCATION2 = catch_based_allocation(catch_data = subset_and_postprocess_catch_data(catch_data = catch_data,
                                                                                       species_code = "YFT",
                                                                                       years        = 1950:2016),
                                        average_catch_function = function(x) { return(best_years_average_catch_data(x, 5)) }, 
                                        coastal_weights = seq(.1, 1, .1))

QUOTAS = 
  allocate_TAC(TAC = 500000, 
               baseline_allocation      = BA_ALLOCATION, baseline_allocation_weight      = .1, # 10% from baseline allocation
               coastal_state_allocation = CS_ALLOCATION, coastal_state_allocation_weight = .2, # 20% from coastal state allocation
               catch_based_allocation   = CB_ALLOCATION, catch_based_allocation_weight   = .7) # 70% from catch-based allocation

QUOTAS2 = 
  allocate_TAC(TAC = 500000, 
               baseline_allocation      = BA_ALLOCATION,  baseline_allocation_weight      = .1, # 10% from baseline allocation
               coastal_state_allocation = CS_ALLOCATION,  coastal_state_allocation_weight = .6, # 60% from coastal state allocation
               catch_based_allocation   = CB_ALLOCATION2, catch_based_allocation_weight   = .3) # 30% from catch-based allocation

# Example ####
SPECIES_SELECTED  = "YFT"
TAC_EXAMPLE       = 500000
CPC_CODE_SELECTED = "IDN"
CATCH_PERIOD      = 2000:2016

# Mean annual catch of YFT in 2000-2016
RC_YFT_2000_2016 = RC_RAW[SPECIES_CODE == SPECIES_SELECTED & YEAR %in% CATCH_PERIOD, .(CATCH = sum(CATCH_MT/length(2000:2016))), keyby = (CPC_CODE = FLEET_CODE)]

# Mean annual catch of YFT in 2000-2016 for the CPCs
RC_YFT_2000_2016_CPCS = merge(RC_YFT_2000_2016[!CPC_CODE %in% c("NEI", "OTH")], CPC_data[, .(CODE, NAME_EN)], by.x = "CPC_CODE", by.y = "CODE", all = TRUE)

RC_YFT_2000_2016_CPCS[is.na(CATCH), CATCH := 0]

# Mean annual catch of YFT in 2000-2016 taken by CPCs inside NJAs of non-IOTC members
# Those catches cannot be reallocated to the non-IOTC members
RC_RAW[SPECIES_CODE == SPECIES_SELECTED & YEAR %in% CATCH_PERIOD & !FLEET_CODE %in% c("NEI", "OTH") & !ASSIGNED_AREA %in% c("HIGH_SEAS", paste0("NJA_", sort(unique(CPC_data$CODE)))), .(CATCH = sum(CATCH_MT/length(CATCH_PERIOD))), keyby = .(ASSIGNED_AREA)][order(-CATCH)]

# Display information on IDN
CPC_DATA_IDN   = CPC_data[CODE == CPC_CODE_SELECTED]
CS_SE_DATA_IDN = CS_SE_data[CODE == CPC_CODE_SELECTED]

## Baseline allocation
BA_ALLOCATION[CPC_CODE == CPC_CODE_SELECTED]
BA_ALLOCATION[CPC_CODE == CPC_CODE_SELECTED, BASELINE_ALLOCATION] * TAC_EXAMPLE * 0.1

## Coastal state allocation
CS_ALLOCATION[CPC_CODE == CPC_CODE_SELECTED]
CS_ALLOCATION[CPC_CODE == CPC_CODE_SELECTED, COASTAL_STATE_ALLOCATION] * TAC_EXAMPLE * 0.2

## Catch-based allocation
# NB. ABNJ_CATCH_MT indicates catches from the CPC in other NJAs (through agreements)
IDN_CATCH_FOREIGN_NJAs = catch_data[!ASSIGNED_AREA %in% c("NJA_IDN", "HIGH_SEAS") & FLEET_CODE == "IDN" & YEAR %in% 2000:2016 & SPECIES_CODE == "YFT"][, .(CATCH = sum(CATCH_MT/length(2000:2016))), keyby = .(ASSIGNED_AREA)][order(-CATCH)]

FOREIGN_CPCS_CATCH_IDN_NJA = catch_data[ASSIGNED_AREA %in% c("NJA_IDN") & FLEET_CODE != "IDN" & YEAR %in% 2000:2016 & SPECIES_CODE == "YFT"][, .(CATCH = sum(CATCH_MT/length(2000:2016))), keyby = .(FLEET_CODE)][order(-CATCH)]

subset_and_postprocess_catch_data(catch_data, SPECIES_SELECTED, CATCH_PERIOD)[CPC_CODE == CPC_CODE_SELECTED][, .(NJA_CATCH_MT = sum(NJA_CATCH_MT/length(CATCH_PERIOD)), HS_CATCH_MT = sum(HS_CATCH_MT/length(CATCH_PERIOD)), ABNJ_CATCH_MT = sum(ABNJ_CATCH_MT/length(CATCH_PERIOD)), FOREIGN_CATCH_MT = sum(FOREIGN_CATCH_MT/length(CATCH_PERIOD))), keyby = .(CPC_CODE)]

subset_and_postprocess_catch_data(catch_data, SPECIES_SELECTED, CATCH_PERIOD)[, .(NJA_CATCH_MT = sum(NJA_CATCH_MT/length(CATCH_PERIOD)), HS_CATCH_MT = sum(HS_CATCH_MT/length(CATCH_PERIOD)), ABNJ_CATCH_MT = sum(ABNJ_CATCH_MT/length(CATCH_PERIOD)), FOREIGN_CATCH_MT = sum(FOREIGN_CATCH_MT/length(CATCH_PERIOD)))]

CB_ALLOCATION[CPC_CODE == CPC_CODE_SELECTED, .(PERIOD = "2000-2016", PERCENT_ALLOCATED = CATCH_BASED_ALLOCATION_YEAR_10*100), .(CPC_CODE)]

CB_ALLOCATION[CPC_CODE == CPC_CODE_SELECTED, CATCH_BASED_ALLOCATION_YEAR_10] * TAC_EXAMPLE * 0.7

