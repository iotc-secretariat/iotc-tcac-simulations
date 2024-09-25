print("Computing allocation tables for a given scenario...")

# Reduce the labels of some CPCs
CPC_data[CODE == "GBR", `:=` (NAME_EN = "United Kingdom", NAME_FR = "Royaume-Uni")]
CPC_data[CODE == "IRN", `:=` (NAME_EN = "I.R. Iran", NAME_FR = "R.I. d'Iran")]
CPC_data[CODE == "TZA", `:=` (NAME_EN = "Tanzania", NAME_FR = "Tanzanie")]
CPC_data[CODE == "TWN", `:=` (NAME_EN = "Taiwan,China", NAME_FR = "Taiwan,Chine")]
CPC_data[CODE == "KOR", `:=` (NAME_EN = "South Korea", NAME_FR = "Corée du Sud")]

# BASELINE ALLOCATION TABLE ####
BA_ALLOCATION_TABLE = merge(BA_ALLOCATION, CPC_data[, .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE")

BA_ALLOCATION_TABLE[, TAC := TARGET_TAC_T*BASELINE_ALLOCATION*BASELINE_WEIGHT]

BA_ALLOCATION_TABLE_FORMATTED = BA_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, `Allocation (%)` = round(BASELINE_WEIGHT*BASELINE_ALLOCATION*100, 3), `TAC (t)` = round(TAC))]

# COASTAL STATE ALLOCATION TABLES ####

## EQUAL ALLOCATION TABLE ####
CS_EQUAL_ALLOCATION_TABLE = merge(CS_ALLOCATION[, .(CPC_CODE, CSA_EQUAL_ALLOCATION)], CPC_data[STATUS_CODE %in% c("CP", "FE"), .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE", all.y = TRUE)

CS_EQUAL_ALLOCATION_TABLE[is.na(CSA_EQUAL_ALLOCATION), CSA_EQUAL_ALLOCATION := 0]
CS_EQUAL_ALLOCATION_TABLE = CS_EQUAL_ALLOCATION_TABLE[order(as.character(CPC_CODE))]

CS_EQUAL_ALLOCATION_TABLE[, TAC := TARGET_TAC_T*COASTAL_STATE_WEIGHT*CSA_EQUAL_ALLOCATION]

CS_EQUAL_ALLOCATION_TABLE_FORMATTED = CS_EQUAL_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, `Allocation (%)` = round(COASTAL_STATE_WEIGHT*CSA_EQUAL_ALLOCATION*100, 3), `TAC (t)` = round(TAC))]

## SOCIO_ECONOMIC ALLOCATION TABLES ####

### HUMAN DEVELOPMENT INDEX STATUS ALLOCATION TABLE ####
CS_SE_HDI_ALLOCATION_TABLE = merge(CS_ALLOCATION[, .(CPC_CODE, CSA_HDI_ALLOCATION)], CPC_data[STATUS_CODE %in% c("CP", "FE"), .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE", all.y = TRUE)

CS_SE_HDI_ALLOCATION_TABLE = merge(CS_SE_HDI_ALLOCATION_TABLE, CS_SE_data[, .(CODE, HDI_TIER)], by.x = "CPC_CODE", by.y = "CODE", all.x = TRUE)

CS_SE_HDI_ALLOCATION_TABLE[is.na(CSA_HDI_ALLOCATION), HDI_TIER := "-"]
CS_SE_HDI_ALLOCATION_TABLE[is.na(CSA_HDI_ALLOCATION), CSA_HDI_ALLOCATION := 0]
CS_SE_HDI_ALLOCATION_TABLE = CS_SE_HDI_ALLOCATION_TABLE[order(as.character(CPC_CODE))]
CS_SE_HDI_ALLOCATION_TABLE[, TAC := TARGET_TAC_T*COASTAL_STATE_WEIGHT*CSA_HDI_ALLOCATION]

CS_SE_HDI_ALLOCATION_TABLE_FORMATTED = CS_SE_HDI_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, HDI = HDI_TIER, `Allocation (%)` = round(COASTAL_STATE_WEIGHT*CSA_HDI_ALLOCATION*100, 3), `TAC (t)` = round(TAC))]

### GROSS NATIONAL INCOME STATUS ALLOCATION TABLE #####
CS_SE_GNI_ALLOCATION_TABLE = merge(CS_ALLOCATION[, .(CPC_CODE, CSA_GNI_ALLOCATION)], CPC_data[STATUS_CODE %in% c("CP", "FE"), .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE", all.y = TRUE)

CS_SE_GNI_ALLOCATION_TABLE = merge(CS_SE_GNI_ALLOCATION_TABLE, CS_SE_data[, .(CODE, GNI_STATUS)], by.x = "CPC_CODE", by.y = "CODE", all.x = TRUE)

CS_SE_GNI_ALLOCATION_TABLE[is.na(GNI_STATUS), CSA_GNI_ALLOCATION := 0]
CS_SE_GNI_ALLOCATION_TABLE[is.na(GNI_STATUS), GNI_STATUS := "-"]
CS_SE_GNI_ALLOCATION_TABLE = CS_SE_GNI_ALLOCATION_TABLE[order(as.character(CPC_CODE))]
CS_SE_GNI_ALLOCATION_TABLE[, TAC := TARGET_TAC_T*COASTAL_STATE_WEIGHT*CSA_GNI_ALLOCATION]

CS_SE_GNI_ALLOCATION_TABLE_FORMATTED = CS_SE_GNI_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, GNI = GNI_STATUS, `Allocation (%)` = round(COASTAL_STATE_WEIGHT*CSA_GNI_ALLOCATION*100, 3), `TAC (t)` = round(TAC))]

### SMALL ISLANDS DEVELOPING STATUS ALLOCATION TABLE #####
CS_SE_SIDS_ALLOCATION_TABLE = merge(CS_ALLOCATION[, .(CPC_CODE, CSA_SIDS_ALLOCATION)], CPC_data[STATUS_CODE %in% c("CP", "FE"), .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE", all.y = TRUE)

CS_SE_SIDS_ALLOCATION_TABLE[is.na(CSA_SIDS_ALLOCATION), CSA_SIDS_ALLOCATION := 0]
CS_SE_SIDS_ALLOCATION_TABLE = CS_SE_SIDS_ALLOCATION_TABLE[order(as.character(CPC_CODE))]
CS_SE_SIDS_ALLOCATION_TABLE[, TAC := TARGET_TAC_T*COASTAL_STATE_WEIGHT*CSA_SIDS_ALLOCATION]

CS_SE_SIDS_ALLOCATION_TABLE_FORMATTED = CS_SE_SIDS_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, `Allocation (%)` = round(COASTAL_STATE_WEIGHT*CSA_SIDS_ALLOCATION*100, 3), `TAC (t)` = round(TAC))]

## NATIONAL JURISDICTION AREA ALLOCATION TABLE ####
CS_NJA_ALLOCATION_TABLE = merge(CS_ALLOCATION[, .(CPC_CODE, CSA_NJA_ALLOCATION)], CPC_data[STATUS_CODE %in% c("CP", "FE"), .(CODE, STATUS_CODE, NAME_EN, NAME_FR, NJA_SIZE)], by.x = "CPC_CODE", by.y = "CODE", all.y = TRUE)

CS_NJA_ALLOCATION_TABLE[NJA_SIZE == 0, CSA_NJA_ALLOCATION := 0]
CS_NJA_ALLOCATION_TABLE[NJA_SIZE == 0, NJA_SIZE := NA]
CS_NJA_ALLOCATION_TABLE = CS_NJA_ALLOCATION_TABLE[order(as.character(CPC_CODE))]
CS_NJA_ALLOCATION_TABLE[, TAC := TARGET_TAC_T*COASTAL_STATE_WEIGHT*CSA_NJA_ALLOCATION]

CS_NJA_ALLOCATION_TABLE_FORMATTED = CS_NJA_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, `NJA size (km2)` = pn(NJA_SIZE), `Allocation (%)` = round(COASTAL_STATE_WEIGHT*CSA_NJA_ALLOCATION*100, 2), `TAC (t)` = round(TAC))]

# CATCH-BASED ALLOCATION TABLE #####
# Compute allocations (relative to total TAC)
CB_ALLOCATION[, CB_ALLOCATION_1 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_1]
CB_ALLOCATION[, CB_ALLOCATION_2 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_2]
CB_ALLOCATION[, CB_ALLOCATION_3 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_3]
CB_ALLOCATION[, CB_ALLOCATION_4 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_4]
CB_ALLOCATION[, CB_ALLOCATION_5 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_5]
CB_ALLOCATION[, CB_ALLOCATION_6 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_6]
CB_ALLOCATION[, CB_ALLOCATION_7 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_7]
CB_ALLOCATION[, CB_ALLOCATION_8 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_8]
CB_ALLOCATION[, CB_ALLOCATION_9 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_9]
CB_ALLOCATION[, CB_ALLOCATION_10 := CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_10]

# Compute TACs
CB_ALLOCATION[, TAC_1 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_1]
CB_ALLOCATION[, TAC_2 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_2]
CB_ALLOCATION[, TAC_3 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_3]
CB_ALLOCATION[, TAC_4 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_4]
CB_ALLOCATION[, TAC_5 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_5]
CB_ALLOCATION[, TAC_6 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_6]
CB_ALLOCATION[, TAC_7 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_7]
CB_ALLOCATION[, TAC_8 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_8]
CB_ALLOCATION[, TAC_9 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_9]
CB_ALLOCATION[, TAC_10 := TARGET_TAC_T*CATCH_BASED_WEIGHT*CATCH_BASED_ALLOCATION_YEAR_10]

# Merge with CPC data
CB_ALLOCATION_TABLE = merge(CB_ALLOCATION, CPC_data[, .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE")

### ALL YEARS ####

# QUOTAS
CB_ALLOCATION_QUOTAS_ALL_YEARS_TABLE_FORMATTED = CB_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, 
                                                                         Y1 = round(CB_ALLOCATION_1*100, 2), 
                                                                         Y2 = round(CB_ALLOCATION_2*100, 2), 
                                                                         Y3 = round(CB_ALLOCATION_3*100, 2), 
                                                                         Y4 = round(CB_ALLOCATION_4*100, 2), 
                                                                         Y5 = round(CB_ALLOCATION_5*100, 2), 
                                                                         Y6 = round(CB_ALLOCATION_6*100, 2), 
                                                                         Y7 = round(CB_ALLOCATION_7*100, 2), 
                                                                         Y8 = round(CB_ALLOCATION_8*100, 2), 
                                                                         Y9 = round(CB_ALLOCATION_9*100, 2), 
                                                                         Y10 = round(CB_ALLOCATION_10*100, 2)
)]
# TACS
CB_ALLOCATION_TACS_ALL_YEARS_TABLE_FORMATTED = CB_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, 
                                                                       Y1 = round(TAC_1), 
                                                                       Y2 = round(TAC_2), 
                                                                       Y3 = round(TAC_3), 
                                                                       Y4 = round(TAC_4), 
                                                                       Y5 = round(TAC_5), 
                                                                       Y6 = round(TAC_6), 
                                                                       Y7 = round(TAC_7), 
                                                                       Y8 = round(TAC_8), 
                                                                       Y9 = round(TAC_9), 
                                                                       Y10 = round(TAC_10)
)]

### FINAL YEAR ####
CB_ALLOCATION_TABLE_FORMATTED = CB_ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, `Allocation Y10 (%)` = round(CB_ALLOCATION_10*100, 2), `TAC Y10 (t)` = round(TAC_10))]

# FINAL ALLOCATION TABLE ####

# Global state allocation table for merging
CS_ALLOCATION_TABLE = merge(CS_ALLOCATION[, .(CPC_CODE, COASTAL_STATE_ALLOCATION)], CPC_data[STATUS_CODE %in% c("CP", "FE"), .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE", all.y = TRUE)

CS_ALLOCATION_TABLE[, TAC := TARGET_TAC_T*COASTAL_STATE_WEIGHT*COASTAL_STATE_ALLOCATION]
CS_ALLOCATION_TABLE[is.na(COASTAL_STATE_ALLOCATION), COASTAL_STATE_ALLOCATION := 0]

# Combine BA and CS allocation tables
ALLOCATION_TABLE = merge(BA_ALLOCATION_TABLE[, .(CPC_CODE, NAME_EN, NAME_FR, STATUS_CODE, BS_ALLOCATION = BASELINE_WEIGHT*BASELINE_ALLOCATION, BS_TAC = TAC)], 
                         CS_ALLOCATION_TABLE[, .(CPC_CODE, CS_ALLOCATION = COASTAL_STATE_WEIGHT*COASTAL_STATE_ALLOCATION, CS_TAC = TAC)], by = "CPC_CODE")

# Add CB allocation table
ALLOCATION_TABLE = merge(ALLOCATION_TABLE, 
                         CB_ALLOCATION_TABLE[, .(CPC_CODE, CB_ALLOCATION_1, CB_ALLOCATION_2, CB_ALLOCATION_3, CB_ALLOCATION_4, CB_ALLOCATION_5, CB_ALLOCATION_6, CB_ALLOCATION_7, CB_ALLOCATION_8, CB_ALLOCATION_9, CB_ALLOCATION_10, CB_TAC_1 = TAC_1, CB_TAC_2 = TAC_2, CB_TAC_3 = TAC_3, CB_TAC_4 = TAC_4, CB_TAC_5 = TAC_5, CB_TAC_6 = TAC_6, CB_TAC_7 = TAC_7, CB_TAC_8 = TAC_8, CB_TAC_9 = TAC_9, CB_TAC_10 = TAC_10)], by = "CPC_CODE")

# Compute sum of quotas
ALLOCATION_TABLE[, QUOTA_1 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_1]
ALLOCATION_TABLE[, QUOTA_2 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_2]
ALLOCATION_TABLE[, QUOTA_3 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_3]
ALLOCATION_TABLE[, QUOTA_4 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_4]
ALLOCATION_TABLE[, QUOTA_5 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_5]
ALLOCATION_TABLE[, QUOTA_6 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_6]
ALLOCATION_TABLE[, QUOTA_7 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_7]
ALLOCATION_TABLE[, QUOTA_8 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_8]
ALLOCATION_TABLE[, QUOTA_9 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_9]
ALLOCATION_TABLE[, QUOTA_10 := BS_ALLOCATION + CS_ALLOCATION + CB_ALLOCATION_10]

# Compute sum of TACs
ALLOCATION_TABLE[, TAC_1 := TARGET_TAC_T*QUOTA_1]
ALLOCATION_TABLE[, TAC_2 := TARGET_TAC_T*QUOTA_2]
ALLOCATION_TABLE[, TAC_3 := TARGET_TAC_T*QUOTA_3]
ALLOCATION_TABLE[, TAC_4 := TARGET_TAC_T*QUOTA_4]
ALLOCATION_TABLE[, TAC_5 := TARGET_TAC_T*QUOTA_5]
ALLOCATION_TABLE[, TAC_6 := TARGET_TAC_T*QUOTA_6]
ALLOCATION_TABLE[, TAC_7 := TARGET_TAC_T*QUOTA_7]
ALLOCATION_TABLE[, TAC_8 := TARGET_TAC_T*QUOTA_8]
ALLOCATION_TABLE[, TAC_9 := TARGET_TAC_T*QUOTA_9]
ALLOCATION_TABLE[, TAC_10 := TARGET_TAC_T*QUOTA_10]

## QUOTA ALLOCATION TABLE ####

### ALL YEARS ####
ALLOCATION_QUOTAS_ALL_YEARS_TABLE_FORMATTED = ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, 
                                                                   Y1 = round(QUOTA_1*100, 2), 
                                                                   Y2 = round(QUOTA_2*100, 2), 
                                                                   Y3 = round(QUOTA_3*100, 2), 
                                                                   Y4 = round(QUOTA_4*100, 2), 
                                                                   Y5 = round(QUOTA_5*100, 2), 
                                                                   Y6 = round(QUOTA_6*100, 2), 
                                                                   Y7 = round(QUOTA_7*100, 2), 
                                                                   Y8 = round(QUOTA_8*100, 2), 
                                                                   Y9 = round(QUOTA_9*100, 2), 
                                                                   Y10 = round(QUOTA_10*100, 2))]

# TACS
ALLOCATION_TACS_ALL_YEARS_TABLE_FORMATTED = ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, 
                                                                 Y1 = round(TAC_1), 
                                                                 Y2 = round(TAC_2), 
                                                                 Y3 = round(TAC_3), 
                                                                 Y4 = round(TAC_4), 
                                                                 Y5 = round(TAC_5), 
                                                                 Y6 = round(TAC_6), 
                                                                 Y7 = round(TAC_7), 
                                                                 Y8 = round(TAC_8), 
                                                                 Y9 = round(TAC_9), 
                                                                 Y10 = round(TAC_10))]

### FINAL YEAR ONLY ####
QUOTA_TABLE_FORMATTED = ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, `Baseline` = round(BS_ALLOCATION*100, 3), `Coastal States` = round(CS_ALLOCATION*100, 3), `Catch-based`= round(CB_ALLOCATION_10*100, 3), `Total` = round(BS_ALLOCATION*100 + CS_ALLOCATION*100 + CB_ALLOCATION_10*100, 3))]

### FINAL YEAR ONLY ####
TAC_TABLE_FORMATTED = ALLOCATION_TABLE[, .(Code = CPC_CODE, Entity = NAME_EN, Entité = NAME_FR, Status = STATUS_CODE, `Baseline` = round(TARGET_TAC_T*BS_ALLOCATION), `Coastal States` = round(TARGET_TAC_T*CS_ALLOCATION), `Catch-based`= round(CB_TAC_10), `Total` = round(TAC_10))]

print("Allocation tables computed for a given scenario!")