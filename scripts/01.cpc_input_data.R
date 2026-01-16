read_entities = function(file = "./inputs/data/iotc_entities.csv") {
  print("Read entities...")
  entities = fread(file)
  
  entities[, CODE        := as.factor(ISO3_CODE)]
  entities[, STATUS_CODE := as.factor(STATUS_CODE)]
  entities[, STATUS      := as.factor(STATUS)]
  entities[, IS_COASTAL  := as.logical(IS_COASTAL)]
  entities[, IS_DEVELOPING := as.logical(IS_DEVELOPING)]
  entities[, IS_LDC     := as.logical(IS_LDC)]
  entities[, IS_SIDS     := as.logical(IS_SIDS)]
  
  # See para. 6.6(c) of IOTC-2024-TCAC13-REF02 "Draft allocation regime v7", under Coastal State Allocation
  entities[, NJA_SIZE_WEIGHTING := ifelse(NJA_IO_SIZE == 0, 0, floor(NJA_IO_SIZE * 100) + 1)]
 
  entities[IS_SIDS == TRUE,  SIDS_STATUS_WEIGHT := 1.00]
  entities[IS_SIDS == FALSE, SIDS_STATUS_WEIGHT := 0.00]
  entities[IS_LDC == TRUE, LDC_STATUS_WEIGHT := 1]
  entities[IS_LDC == FALSE, LDC_STATUS_WEIGHT := 0]

  return(entities)
}
