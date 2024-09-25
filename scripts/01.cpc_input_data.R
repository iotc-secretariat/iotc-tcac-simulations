read_configuration = function(file = "../cfg/CPC_CONFIGURATIONS.xlsx") {
  print("Reading configuration...")
  
  CPC_CONFIG   = as.data.table(read.xlsx(xlsxFile = file, rowNames = FALSE, sheet = "CPC"))[, 1:10] # Removes unnecessary cols
  
  CPC_CONFIG[, CODE        := as.factor(CODE)]
  CPC_CONFIG[, STATUS_CODE := as.factor(STATUS_CODE)]
  CPC_CONFIG[, STATUS      := as.logical(STATUS)]
  CPC_CONFIG[, IS_COASTAL  := as.logical(IS_COASTAL)]
  CPC_CONFIG[, IS_SIDS     := as.logical(IS_SIDS)]
  CPC_CONFIG[, HAS_NJA_IO  := as.logical(HAS_NJA_IO)]
  
  # See para. 6.6(c) of IOTC-2024-TCAC13-REF02 "Draft allocation regime v7", under Coastal State Allocation
  CPC_CONFIG[, NJA_SIZE_WEIGHTING := ifelse(NJA_IOTC_RELATIVE_SIZE == 0, 0, floor(NJA_IOTC_RELATIVE_SIZE * 100) + 1)]
  
  # CPC_CONFIG[NJA_SIZE_WEIGHTING >  0, NJA_SIZE_WEIGHTING_NORMALIZED := NJA_SIZE_WEIGHTING / sum(NJA_SIZE_WEIGHTING)]
  # CPC_CONFIG[NJA_SIZE_WEIGHTING == 0, NJA_SIZE_WEIGHTING_NORMALIZED := 0]
  
  CS_SE_CONFIG = as.data.table(read.xlsx(xlsxFile = file, rowNames = FALSE, sheet = "COASTAL_STATE_SOCIO_ECONOMIC", na.strings = ""))[1:25] # Removes unnecessary rows 
  CS_SE_CONFIG = CS_SE_CONFIG[order(CODE)]
  
  CS_SE_CONFIG[, CODE                            := as.factor(CODE)]
  CS_SE_CONFIG[, DEVELOPMENT_STATUS              := as.factor(DEVELOPMENT_STATUS)]
  CS_SE_CONFIG[, PER_CAPITA_FISH_CONSUMPTION_KG  := round(as.numeric(PER_CAPITA_FISH_CONSUMPTION_KG), 2)]
  CS_SE_CONFIG[, CUV_INDEX                       := round(as.numeric(CUV_INDEX), 2)]
  CS_SE_CONFIG[, PROP_WORKERS_EMPLOYED_SSF       := round(as.numeric(PROP_WORKERS_EMPLOYED_SSF), 4)]
  CS_SE_CONFIG[, PROP_FISHERIES_CONTRIBUTION_GDP := round(as.numeric(PROP_FISHERIES_CONTRIBUTION_GDP), 4)]
  CS_SE_CONFIG[, PROP_EXPORT_VALUE_FISHERY       := round(as.numeric(PROP_EXPORT_VALUE_FISHERY), 4)]
  CS_SE_CONFIG[is.na(HDI_STATUS), HDI_STATUS     := as.numeric(HDI_STATUS)]   # Missing value for SOM
  CS_SE_CONFIG[, GNI_STATUS                      := as.factor (GNI_STATUS)]
  
  CS_SE_CONFIG[, GNI_STATUS := 
    factor(
      CS_SE_CONFIG$GNI_STATUS,
      levels = c("LO", "LM", "UM", "HI"),
      ordered = TRUE
    )]
  
  # To be update when these indicators will be available (required by para. 6.6(1)(b) - Option 1
  #CS_SE_CONFIG$PER_CAPITA_FISH_CONSUMPTION_KG  = NULL
  #CS_SE_CONFIG$CUV_INDEX                       = NULL
  #CS_SE_CONFIG$PROPORTION_WORKERS_EMPLOYED_SSF = NULL
  #CS_SE_CONFIG$FISHERIES_CONTRIBUTION_GDP      = NULL
  #CS_SE_CONFIG$PROPORTION_EXPORT_VALUE_FISHERY = NULL
  
  # See para. 6.6(b) Option 2.i
  CS_SE_CONFIG[CODE == "SOM", HDI_STATUS := min(CS_SE_CONFIG$HDI_STATUS, na.rm = TRUE)] # There's no HDI available for SOM... We assume it's the same as the lowest scored CPC
  
  CS_SE_CONFIG[HDI_STATUS  < 0.55,                     `:=` (HDI_TIER = "LO", HDI_TIER_WEIGHT =  1.00)]
  CS_SE_CONFIG[HDI_STATUS >= 0.55 & HDI_STATUS < 0.70, `:=` (HDI_TIER = "ME", HDI_TIER_WEIGHT =  0.75)]
  CS_SE_CONFIG[HDI_STATUS >= 0.70 & HDI_STATUS < 0.79, `:=` (HDI_TIER = "HI", HDI_TIER_WEIGHT =  0.50)]
  CS_SE_CONFIG[HDI_STATUS >= 0.80,                     `:=` (HDI_TIER = "VH", HDI_TIER_WEIGHT =    NA)] # Should be NA as no developing or least-developed CS exists with this HDI tier
  
  CS_SE_CONFIG[, HDI_TIER := 
    factor(
      CS_SE_CONFIG$HDI_TIER,
      levels = c("LO", "ME", "HI", "VH"),
      ordered = TRUE
    )]
  
  #CS_SE_CONFIG[!is.na(HDI_TIER_WEIGHT), HDI_TIER_WEIGHT_NORMALIZED := HDI_TIER_WEIGHT / sum(HDI_TIER_WEIGHT, na.rm = TRUE)]
  
  # See para. 6.6(b) Option 2.ii
  CS_SE_CONFIG[GNI_STATUS == "LO", GNI_STATUS_WEIGHT := 1.00]
  CS_SE_CONFIG[GNI_STATUS == "LM", GNI_STATUS_WEIGHT := 0.75]
  CS_SE_CONFIG[GNI_STATUS == "UM", GNI_STATUS_WEIGHT := 0.50]
  CS_SE_CONFIG[GNI_STATUS == "HI", GNI_STATUS_WEIGHT := 0.25]
  
  #CS_SE_CONFIG[!is.na(GNI_STATUS_WEIGHT), GNI_STATUS_WEIGHT_NORMALIZED := GNI_STATUS_WEIGHT / sum(GNI_STATUS_WEIGHT, na.rm = TRUE)]
  
  CS_SE_CONFIG[, IS_COASTAL  := CODE %in% CPC_CONFIG[IS_COASTAL   == TRUE, CODE]]
  CS_SE_CONFIG[, HAS_NJA_IO  := CODE %in% CPC_CONFIG[HAS_NJA_IO == TRUE, CODE]]
  CS_SE_CONFIG[, SIDS_STATUS := CODE %in% CPC_CONFIG[IS_SIDS == TRUE, CODE]]
  
  # See para. 6.6(b) Option 2.iii
  CS_SE_CONFIG[SIDS_STATUS == TRUE,  SIDS_STATUS_WEIGHT := 1.00]
  CS_SE_CONFIG[SIDS_STATUS == FALSE, SIDS_STATUS_WEIGHT := 0.00]
  
  #CS_SE_CONFIG[!is.na(SIDS_STATUS_WEIGHT), SIDS_STATUS_WEIGHT_NORMALIZED := SIDS_STATUS_WEIGHT / sum(SIDS_STATUS_WEIGHT, na.rm = TRUE)]
  
  CS_SE_CONFIG = CS_SE_CONFIG[, .(CODE, NAME_EN, NAME_FR, 
                                  IS_COASTAL, HAS_NJA_IO, 
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
