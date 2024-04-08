l_info("Describing the historical catch estimates...")

# READING THE DATA ####

## Pre-processed data ####
RC = copy(catch_data)

# Add area category
RC[ASSIGNED_AREA == "HIGH_SEAS", AREA_CATEGORY := "Areas beyond national jurisdiction (ABNJ)"]
RC[ASSIGNED_AREA != "HIGH_SEAS", AREA_CATEGORY := "National jurisdiction areas (NJA)"]

# PLOTTING THE GENERAL DATA ####

## Annual time series by category of area ####
COL_AREA_CATEGORY = color_table(colors = brewer.pal(3, "Set1"))

RC_AREA_CATEGORY_BARPLOT = 
  value_bar(data = RC, value = "CATCH_MT", time = "YEAR", fill_by = "AREA_CATEGORY", colors = COL_AREA_CATEGORY, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 1, trim_labels = FALSE) + theme(legend.position = "bottom")

save_plot("../outputs/charts/RC_AREA_CATEGORY_BARPLOT.png", RC_AREA_CATEGORY_BARPLOT, 8, 4.5)

## Annual time series by fleet for each species ####

# Define colours for fleets
COL_RC_FLEET = color_table(unique_colors(length(unique(RC$FLEET_CODE))))
COL_RC_FLEET[, FILL_BY := sort(unique(RC$FLEET_CODE))]
COL_RC_FLEET[, FILL_BY := factor(FILL_BY, levels = sort(unique(RC$FLEET_CODE)))]

### All species ####
RC_FLEET_BARPLOT = 
  value_bar(data = RC, value = "CATCH_MT", time = "YEAR", fill_by = "FLEET_CODE", colors = COL_RC_FLEET, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 3) + theme(legend.position = "bottom")

save_plot("../outputs/charts/RC_FLEET_BARPLOT.png", RC_FLEET_BARPLOT, 8, 4.5)

### Albacore ####
RC_ALB_FLEET_COLORS = COL_RC_FLEET[FILL_BY %in% RC[SPECIES_CODE == "ALB", FLEET_CODE]]

RC_ALB_FLEET_BARPLOT = 
  value_bar(data = RC[SPECIES_CODE == "ALB"], value = "CATCH_MT", time = "YEAR", fill_by = "FLEET_CODE", colors = RC_ALB_FLEET_COLORS, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 3) + theme(legend.position = "bottom")

save_plot("../outputs/charts/RC_ALB_FLEET_BARPLOT.png", RC_ALB_FLEET_BARPLOT, 8, 4.5)

### Bigeye tuna ####
RC_BET_FLEET_COLORS = color_table(unique_colors(length(unique(RC[SPECIES_CODE == "BET", FLEET_CODE]))))

RC_BET_FLEET_BARPLOT = 
  value_bar(data = RC[SPECIES_CODE == "BET"], value = "CATCH_MT", time = "YEAR", fill_by = "FLEET_CODE", colors = RC_BET_FLEET_COLORS, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 3) + theme(legend.position = "bottom")

save_plot("../outputs/charts/RC_BET_FLEET_BARPLOT.png", RC_BET_FLEET_BARPLOT, 8, 4.5)

### Skipjack tuna ####
RC_SKJ_FLEET_COLORS = color_table(unique_colors(length(unique(RC[SPECIES_CODE == "SKJ", FLEET_CODE]))))

RC_SKJ_FLEET_BARPLOT = 
  value_bar(data = RC[SPECIES_CODE == "SKJ"], value = "CATCH_MT", time = "YEAR", fill_by = "FLEET_CODE", colors = RC_SKJ_FLEET_COLORS, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 3) + theme(legend.position = "bottom")

save_plot("../outputs/charts/RC_SKJ_FLEET_BARPLOT.png", RC_SKJ_FLEET_BARPLOT, 8, 4.5)

### Swordfish ####
RC_SWO_FLEET_COLORS = color_table(unique_colors(length(unique(RC[SPECIES_CODE == "SWO", FLEET_CODE]))))

RC_SWO_FLEET_BARPLOT = 
  value_bar(data = RC[SPECIES_CODE == "SWO"], value = "CATCH_MT", time = "YEAR", fill_by = "FLEET_CODE", colors = RC_SWO_FLEET_COLORS, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 3) + theme(legend.position = "bottom")

save_plot("../outputs/charts/RC_SWO_FLEET_BARPLOT.png", RC_SWO_FLEET_BARPLOT, 8, 4.5)

### Yellowfin tuna ####
RC_YFT_FLEET_COLORS = color_table(unique_colors(length(unique(RC[SPECIES_CODE == "YFT", FLEET_CODE]))))

RC_YFT_FLEET_BARPLOT = 
  value_bar(data = RC[SPECIES_CODE == "YFT"], value = "CATCH_MT", time = "YEAR", fill_by = "FLEET_CODE", colors = RC_YFT_FLEET_COLORS, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 3) + theme(legend.position = "bottom")

save_plot("../outputs/charts/RC_YFT_FLEET_BARPLOT.png", RC_YFT_FLEET_BARPLOT, 8, 4.5)

# PLOTTING THE FLEET-SPECIFIC DATA ####

## Flag-specific catches in high seas and any NJA
for (j in CPC_data[STATUS %in% c("CP", "OBS"), CODE]){
  
  RC_CPC = RC[FLEET_CODE == j]
  
  if(nrow(RC_CPC)>0)
  {
  RC_CPC_AREA_CATEGORY_BARPLOT = 
  value_bar(data = RC_CPC, value = "CATCH_MT", time = "YEAR", fill_by = "AREA_CATEGORY", colors = COL_AREA_CATEGORY, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 1, trim_labels = FALSE) + theme(legend.position = "bottom")
    save_plot(paste0("../outputs/charts/CPCS/Category/", j, "_RC_AREA_CATEGORY_BARPLOT.png"), RC_CPC_AREA_CATEGORY_BARPLOT, 8, 4.5)
  }
}

## Catches in the NJA of each CP from all flags
COL_CATCH_ORIGIN = color_table(colors = brewer.pal(3, "Set3"))

for (j in CS_SE_data$CODE){

RC_NJA = RC[gsub("NJA_", "", ASSIGNED_AREA) == j]
RC_NJA[FLEET_CODE == j, ORIGIN := "National"]
RC_NJA[FLEET_CODE != j, ORIGIN := "Foreign"]

if(nrow(RC_NJA)>0)
{
  RC_NJA_CATCH_ORIGIN_BARPLOT = 
    value_bar(data = RC_NJA, value = "CATCH_MT", time = "YEAR", fill_by = "ORIGIN", colors = COL_CATCH_ORIGIN, x_axis_label = "", y_axis_label = "Total catch (x1,000 t)", scale = 1000, num_legend_rows = 1, trim_labels = FALSE) + theme(legend.position = "bottom")
  save_plot(paste0("../outputs/charts/CPCS/Origin/", j, "_RC_NJA_CATCH_ORIGIN_BARPLOT.png"), RC_NJA_CATCH_ORIGIN_BARPLOT, 8, 4.5)
}
}
