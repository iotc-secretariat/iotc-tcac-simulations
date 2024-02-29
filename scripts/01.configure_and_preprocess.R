library(openxlsx)
library(data.table)
library(stringr)
library(scales)

options(scipen = 9999)

read_configuration = function(file = "../cfg/CPC_CONFIGURATIONS.xlsx") {
  print("Reading configuration...")
  
  CPC_CONFIG   = as.data.table(read.xlsx(xlsxFile = file, rowNames = FALSE, sheet = "CPC"))[, 1:8] # Removes unnecessary cols
  
  CPC_CONFIG$CODE       = as.factor (CPC_CONFIG$CODE)
  CPC_CONFIG$STATUS     = as.factor (CPC_CONFIG$STATUS)
  CPC_CONFIG$COASTAL    = as.logical(CPC_CONFIG$COASTAL)
  CPC_CONFIG$HAS_NJA_IO = as.logical(CPC_CONFIG$HAS_NJA_IO)
  CPC_CONFIG$SIDS       = as.logical(CPC_CONFIG$SIDS)
  
  # See para. 6.6(c) of IOTC-2024-TCAC13-REF02 "Draft allocation regime v7", under Coastal State Allocation
  CPC_CONFIG[, NJA_SIZE_WEIGHTING := ifelse(NJA_IOTC_RELATIVE_SIZE == 0, 0, floor(NJA_IOTC_RELATIVE_SIZE * 100) + 1)]
  
  # CPC_CONFIG[NJA_SIZE_WEIGHTING >  0, NJA_SIZE_WEIGHTING_NORMALIZED := NJA_SIZE_WEIGHTING / sum(NJA_SIZE_WEIGHTING)]
  # CPC_CONFIG[NJA_SIZE_WEIGHTING == 0, NJA_SIZE_WEIGHTING_NORMALIZED := 0]

  CS_SE_CONFIG = as.data.table(read.xlsx(xlsxFile = file, rowNames = FALSE, sheet = "COASTAL_STATE_SOCIO_ECONOMIC", na.strings = ""))[1:25] # Removes unnecessary rows 
  CS_SE_CONFIG = CS_SE_CONFIG[order(CODE)]
  
  CS_SE_CONFIG$CODE                            = as.factor (CS_SE_CONFIG$CODE)
  CS_SE_CONFIG$DEVELOPMENT_STATUS              = as.factor (CS_SE_CONFIG$DEVELOPMENT_STATUS)
  CS_SE_CONFIG$PER_CAPITA_FISH_CONSUMPTION_KG  = round(as.numeric(CS_SE_CONFIG$PER_CAPITA_FISH_CONSUMPTION_KG), 2)
  CS_SE_CONFIG$CUV_INDEX                       = round(as.numeric(CS_SE_CONFIG$CUV_INDEX), 2)
  CS_SE_CONFIG$PROP_WORKERS_EMPLOYED_SSF       = round(as.numeric(CS_SE_CONFIG$PROP_WORKERS_EMPLOYED_SSF), 4)
  CS_SE_CONFIG$PROP_FISHERIES_CONTRIBUTION_GDP = round(as.numeric(CS_SE_CONFIG$PROP_FISHERIES_CONTRIBUTION_GDP), 4)
  CS_SE_CONFIG$PROP_EXPORT_VALUE_FISHERY       = round(as.numeric(CS_SE_CONFIG$PROP_EXPORT_VALUE_FISHERY), 4)
  CS_SE_CONFIG$HDI_STATUS                      = as.numeric(CS_SE_CONFIG$HDI_STATUS)
  CS_SE_CONFIG$GNI_STATUS                      = as.factor (CS_SE_CONFIG$GNI_STATUS)

  CS_SE_CONFIG$GNI_STATUS = 
    factor(
      CS_SE_CONFIG$GNI_STATUS,
      levels = c("LO", "LM", "UM", "HI"),
      ordered = TRUE
    )
  
  # To be update when these indicators will be available (required by para. 6.6(1)(b) - Option 1
  #CS_SE_CONFIG$PER_CAPITA_FISH_CONSUMPTION_KG  = NULL
  #CS_SE_CONFIG$CUV_INDEX                       = NULL
  #CS_SE_CONFIG$PROPORTION_WORKERS_EMPLOYED_SSF = NULL
  #CS_SE_CONFIG$FISHERIES_CONTRIBUTION_GDP      = NULL
  #CS_SE_CONFIG$PROPORTION_EXPORT_VALUE_FISHERY = NULL
    
  # See para. 6.6(b) Option 2.i
  CS_SE_CONFIG[CODE == "SOM", HDI_STATUS := min(CS_SE_CONFIG$HDI_STATUS, na.rm = TRUE)] # There's no HDI available for SOM... We assume it's the same as the lowest scored CPC
  
  CS_SE_CONFIG[HDI_STATUS  < 0.55,                     `:=`(HDI_TIER = "LO", HDI_TIER_WEIGHT =  1.00)]
  CS_SE_CONFIG[HDI_STATUS >= 0.55 & HDI_STATUS < 0.70, `:=`(HDI_TIER = "ME", HDI_TIER_WEIGHT =  0.75)]
  CS_SE_CONFIG[HDI_STATUS >= 0.70 & HDI_STATUS < 0.79, `:=`(HDI_TIER = "HI", HDI_TIER_WEIGHT =  0.50)]
  CS_SE_CONFIG[HDI_STATUS >= 0.80,                     `:=`(HDI_TIER = "VH", HDI_TIER_WEIGHT =    NA)] # Should be NA as no developing or least-developed CS exists with this HDI tier
  
  CS_SE_CONFIG$HDI_TIER = 
    factor(
      CS_SE_CONFIG$HDI_TIER,
      levels = c("LO", "ME", "HI", "VH"),
      ordered = TRUE
    )
  
  #CS_SE_CONFIG[!is.na(HDI_TIER_WEIGHT), HDI_TIER_WEIGHT_NORMALIZED := HDI_TIER_WEIGHT / sum(HDI_TIER_WEIGHT, na.rm = TRUE)]
  
  # See para. 6.6(b) Option 2.ii
  CS_SE_CONFIG[GNI_STATUS == "LO", GNI_STATUS_WEIGHT := 1.00]
  CS_SE_CONFIG[GNI_STATUS == "LM", GNI_STATUS_WEIGHT := 0.75]
  CS_SE_CONFIG[GNI_STATUS == "UM", GNI_STATUS_WEIGHT := 0.50]
  CS_SE_CONFIG[GNI_STATUS == "HI", GNI_STATUS_WEIGHT := 0.25]
  
  #CS_SE_CONFIG[!is.na(GNI_STATUS_WEIGHT), GNI_STATUS_WEIGHT_NORMALIZED := GNI_STATUS_WEIGHT / sum(GNI_STATUS_WEIGHT, na.rm = TRUE)]
   
  CS_SE_CONFIG[, COASTAL     := CODE %in% CPC_CONFIG[COASTAL   == TRUE]$CODE]
  CS_SE_CONFIG[, HAS_NJA_IO   := CODE %in% CPC_CONFIG[HAS_NJA_IO == TRUE]$CODE]
  CS_SE_CONFIG[, SIDS_STATUS := CODE %in% CPC_CONFIG[SIDS      == TRUE]$CODE]
  
  # See para. 6.6(b) Option 2.iii
  CS_SE_CONFIG[SIDS_STATUS == TRUE,  SIDS_STATUS_WEIGHT := 1.00]
  CS_SE_CONFIG[SIDS_STATUS == FALSE, SIDS_STATUS_WEIGHT := 0.00]
  
  #CS_SE_CONFIG[!is.na(SIDS_STATUS_WEIGHT), SIDS_STATUS_WEIGHT_NORMALIZED := SIDS_STATUS_WEIGHT / sum(SIDS_STATUS_WEIGHT, na.rm = TRUE)]
  
  CS_SE_CONFIG = CS_SE_CONFIG[, .(CODE, 
                                  COASTAL, HAS_NJA_IO, 
                                  DEVELOPMENT_STATUS,
                                  PER_CAPITA_FISH_CONSUMPTION_KG, 
                                  CUV_INDEX,
                                  PROP_WORKERS_EMPLOYED_SSF,
                                  PROP_FISHERIES_CONTRIBUTION_GDP,
                                  PROP_EXPORT_VALUE_FISHERY,
                                  HDI_STATUS, HDI_TIER, HDI_TIER_WEIGHT,   # HDI_TIER_WEIGHT_NORMALIZED,
                                  GNI_STATUS,           GNI_STATUS_WEIGHT, # GNI_STATUS_WEIGHT_NORMALIZED,
                                  SIDS_STATUS,          SIDS_STATUS_WEIGHT # SIDS_STATUS_WEIGHT_NORMALIZED
                                 )]
  
  return(
    list(
      CPC_CONFIG   = CPC_CONFIG,    # Basic CPC data, including its being a coastal state or having an NJA, as well as the size of the NJA
      CS_SE_CONFIG = CS_SE_CONFIG   # Coastal states data, including their socio-economic indicators
    )
  )
}

read_raw_catch_data = function(file = "../cfg/IOTC-2023-TCAC12-DATA01 - Historical catch estimates.xlsx") {
  return(
    as.data.table(
      read.xlsx(
        xlsxFile = file, 
        rowNames = FALSE,
        sheet = "Data"
      )
    )
  )
}

read_catch_data = function(file = "../cfg/HISTORICAL_CATCH_ESTIMATES.csv", CPC_data = read_configuration()$CPC_CONFIG) { 
  # These are the ones used for the TCAC12 interactive app, and represent the output of
  # the initialization process for https://bitbucket.org/iotc-ws/iotc-tcac/src/master/
  
  POSTPROCESSED_CATCH_DATA = 
    as.data.table(
      read.csv2(
        file = file, 
        sep = ",",
        header = TRUE
      )
    )

  # For the time being we consider the Chagos archipelago to still be under sovereignty of GBR
  POSTPROCESSED_CATCH_DATA[ASSIGNED_AREA == "NJA_CHAGOS", ASSIGNED_AREA := "NJA_GBR"]
  
  # We need to decide if we want to keep only catches from current CPCs for the catch-based allocation part
  # In that case:
  POSTPROCESSED_CATCH_DATA = POSTPROCESSED_CATCH_DATA[FLEET_CODE %in% CPC_data[STATUS == "CPC"]$CODE]

  # We need to decide if we want to consider only catches in the high seas or within CPC NJAs
  # In that case:
  POSTPROCESSED_CATCH_DATA = POSTPROCESSED_CATCH_DATA[ASSIGNED_AREA == "HIGH_SEAS" | ASSIGNED_AREA %in% paste0("NJA_", CPC_data[HAS_NJA_IO == TRUE]$CODE)]

  POSTPROCESSED_CATCH_DATA$FLAG_CODE        = factor(POSTPROCESSED_CATCH_DATA$FLAG_CODE)
  POSTPROCESSED_CATCH_DATA$FLEET_CODE       = factor(POSTPROCESSED_CATCH_DATA$FLEET_CODE)
  POSTPROCESSED_CATCH_DATA$FISHERY_TYPE     = factor(POSTPROCESSED_CATCH_DATA$FISHERY_TYPE)
  POSTPROCESSED_CATCH_DATA$FISHERY_CODE     = factor(POSTPROCESSED_CATCH_DATA$FISHERY_CODE)
  POSTPROCESSED_CATCH_DATA$SCHOOL_TYPE_CODE = factor(POSTPROCESSED_CATCH_DATA$SCHOOL_TYPE_CODE)
  POSTPROCESSED_CATCH_DATA$ASSIGNED_AREA    = factor(POSTPROCESSED_CATCH_DATA$ASSIGNED_AREA)
  POSTPROCESSED_CATCH_DATA$SPECIES_CODE     = factor(POSTPROCESSED_CATCH_DATA$SPECIES_CODE)
  POSTPROCESSED_CATCH_DATA$CATCH_MT         = as.numeric(POSTPROCESSED_CATCH_DATA$CATCH_MT)
  
  return(POSTPROCESSED_CATCH_DATA)
}

subset_and_postprocess_catch_data = function(catch_data,
                                             species_code,
                                             years) {
  
  catch_data = catch_data[SPECIES_CODE == species_code & YEAR %in% years, .(CATCH_MT = sum(CATCH_MT, na.rm = TRUE)),
                                                                            keyby = .(FLEET_CODE, YEAR, ASSIGNED_AREA)]

  catch_data_NJA       = catch_data[ASSIGNED_AREA == paste0("NJA_", FLEET_CODE),                                .(NJA_CATCH_MT     = sum(CATCH_MT, na.rm = TRUE)), keyby = .(CPC_CODE = FLEET_CODE, YEAR)]
  catch_data_HS        = catch_data[ASSIGNED_AREA == "HIGH_SEAS",                                               .(HS_CATCH_MT      = sum(CATCH_MT, na.rm = TRUE)), keyby = .(CPC_CODE = FLEET_CODE, YEAR)]
  catch_data_other_NJA = catch_data[ASSIGNED_AREA != paste0("NJA_", FLEET_CODE) & ASSIGNED_AREA != "HIGH_SEAS", .(ABNJ_CATCH_MT    = sum(CATCH_MT, na.rm = TRUE)), keyby = .(CPC_CODE = FLEET_CODE, YEAR)]
  catch_data_foreign   = catch_data[ASSIGNED_AREA != paste0("NJA_", FLEET_CODE) & ASSIGNED_AREA != "HIGH_SEAS", .(FOREIGN_CATCH_MT = sum(CATCH_MT, na.rm = TRUE)), keyby = .(CPC_CODE = str_sub(ASSIGNED_AREA, 5), YEAR)]

  catch_data_all = 
    merge.data.table(
      catch_data_NJA, # CPC catches in their own NJA
      catch_data_HS,  # CPC catches on the high seas
      by = c("CPC_CODE", "YEAR"),
      all.x = TRUE, all.y = TRUE
    )
  
  catch_data_all = 
    merge.data.table(
      catch_data_all,
      catch_data_other_NJA, # CPC catches into foreign NJAs
      by = c("CPC_CODE", "YEAR"),
      all.x = TRUE, all.y = TRUE
    )
  
  catch_data_all = 
    merge.data.table(
      catch_data_all,
      catch_data_foreign,   # Foreign catches in the CPC NJA
      by = c("CPC_CODE", "YEAR"),
      all.x = TRUE, all.y = TRUE
    )
  
  catch_data_all[is.na(NJA_CATCH_MT),     NJA_CATCH_MT     := 0]
  catch_data_all[is.na(HS_CATCH_MT),      HS_CATCH_MT      := 0]
  catch_data_all[is.na(ABNJ_CATCH_MT),    ABNJ_CATCH_MT    := 0]
  catch_data_all[is.na(FOREIGN_CATCH_MT), FOREIGN_CATCH_MT := 0]

  return(catch_data_all)
}

# Updates the catches for the ABNJ (i.e., other CPCs' NJA) and for the catches of foreign flagged vessels within a CPC's NJA
weight_catch_data = function(catch_data,
                             coastal_weight) {
   return(
     catch_data[, .(CATCH_MT = sum(NJA_CATCH_MT + 
                                   HS_CATCH_MT + 
                                   ABNJ_CATCH_MT * ( 1 - coastal_weight) + 
                                   FOREIGN_CATCH_MT * coastal_weight)), 
                    keyby = .(CPC_CODE, YEAR)][CATCH_MT > 0]
  )
}

# Calculates the average catch data over an entire timeframe
period_average_catch_data = function(weighted_catch_data) {
  return(
    weighted_catch_data[, .(CATCH_MT = sum(CATCH_MT) / .N), keyby = .(CPC_CODE)]
  )
}

# Calculates the average catch data for the 'best' n-years in a gvien entire timeframe, where 'best' means 'with higher catches recorded'
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


## BASELINE ALLOCATION FUNCTION ####
# Performs the baseline allocation, by attributing the same relative weight to all CPCs
baseline_allocation = function(CPC_data = read_configuration()$CPC_CONFIG) {
  component_allocation_table = CPC_data[STATUS == "CPC", .(CPC_CODE = CODE)]
  
  # Baseline allocation - para. 6.5
  component_allocation_table[, BASELINE_ALLOCATION := 1.00 / nrow(component_allocation_table)] 
  
  return(
    component_allocation_table
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
  
  component_allocation_table[COASTAL == TRUE, VUL_PCF_ALLOCATION  := PER_CAPITA_FISH_CONSUMPTION_KG  / sum(PER_CAPITA_FISH_CONSUMPTION_KG, na.rm = TRUE)]
  component_allocation_table[COASTAL == TRUE, VUL_CUVI_ALLOCATION := CUV_INDEX                       / sum(CUV_INDEX , na.rm = TRUE)]
  
  component_allocation_table[COASTAL == TRUE, PRI_SEC_SSF_ALLOCATION  := PROP_WORKERS_EMPLOYED_SSF   / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  component_allocation_table[COASTAL == TRUE, PRI_SEC_SIDS_ALLOCATION := SIDS_STATUS                 / sum(SIDS_STATUS, na.rm = TRUE)]
  
  component_allocation_table[COASTAL == TRUE, DIS_BUR_GDP_ALLOCATION := PROP_WORKERS_EMPLOYED_SSF    / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  component_allocation_table[COASTAL == TRUE, DIS_BUR_EXP_ALLOCATION := PROP_EXPORT_VALUE_FISHERY    / sum(PROP_EXPORT_VALUE_FISHERY, na.rm = TRUE)]

  ### Assuming it applies to developing / least developed coastal states only:
  
  #component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", VUL_PCF_ALLOCATION  := PER_CAPITA_FISH_CONSUMPTION_KG  / sum(PER_CAPITA_FISH_CONSUMPTION_KG, na.rm = TRUE)]
  #component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", VUL_CUVI_ALLOCATION := CUV_INDEX                       / sum(CUV_INDEX , na.rm = TRUE)]
  
  #component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", PRI_SEC_SSF_ALLOCATION  := PROP_WORKERS_EMPLOYED_SSF   / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  #component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", PRI_SEC_SIDS_ALLOCATION := SIDS_STATUS                 / sum(SIDS_STATUS, na.rm = TRUE)]

  #component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", DIS_BUR_GDP_ALLOCATION := PROP_WORKERS_EMPLOYED_SSF    / sum(PROP_WORKERS_EMPLOYED_SSF, na.rm = TRUE)]
  #component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", DIS_BUR_EXP_ALLOCATION := PROP_EXPORT_VALUE_FISHERY    / sum(PROP_EXPORT_VALUE_FISHERY, na.rm = TRUE)]
  
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
  
  component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", HDI_ALLOCATION  := HDI_TIER_WEIGHT    / sum(HDI_TIER_WEIGHT,    na.rm = TRUE)]
  component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", GNI_ALLOCATION  := GNI_STATUS_WEIGHT  / sum(GNI_STATUS_WEIGHT , na.rm = TRUE)]
  component_allocation_table[COASTAL == TRUE & DEVELOPMENT_STATUS != "DE", SIDS_ALLOCATION := SIDS_STATUS_WEIGHT / sum(SIDS_STATUS_WEIGHT, na.rm = TRUE)]
  
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
                                     CSA_SIDS_ALLOCATION   = socio_economic_weight * socio_economic_option_subweights$SIDS_wgt * SIDS_ALLOCATION, 
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
  
  if(all_weights != 1)
    stop(paste0("The weights provided for the various allocation components should sum up to 100% (now:", all_weights * 100, " %)"))

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