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
      fread(
        file = file, 
        sep = ",",
        header = TRUE, 
        stringsAsFactors = TRUE
    )
  
  # For the time being we consider the Chagos archipelago to still be under sovereignty of GBR
  POSTPROCESSED_CATCH_DATA[ASSIGNED_AREA == "NJA_CHAGOS", ASSIGNED_AREA := "NJA_GBR"]
  
  # We need to decide if we want to keep only catches from current CPCs for the catch-based allocation part
  # In that case:
  POSTPROCESSED_CATCH_DATA = POSTPROCESSED_CATCH_DATA[FLEET_CODE %in% CPC_data[STATUS_CODE %in% c("CP", "FE")]$CODE]
  
  # We need to decide if we want to consider only catches in the high seas or within CPC NJAs
  # In that case:
  POSTPROCESSED_CATCH_DATA = POSTPROCESSED_CATCH_DATA[ASSIGNED_AREA == "HIGH_SEAS" | ASSIGNED_AREA %in% paste0("NJA_", CPC_data[HAS_NJA_IO == TRUE]$CODE)]
  
  return(POSTPROCESSED_CATCH_DATA)
}

subset_and_postprocess_catch_data = function(catch_data,
                                             species_code,
                                             years, 
                                             onlyHS = FALSE) {  
  
# onlyHS: all catches from foreign fleets in NJAs will be set to 0
  
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
  
  if(onlyHS == TRUE) catch_data_all[, `:=` (ABNJ_CATCH_MT = 0, FOREIGN_CATCH_MT = 0)]
  
  
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
