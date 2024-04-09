l_info("Mapping the areas of national jurisdiction")

# Load countries
#WORLD_BORDERS_SF = ne_countries(returnclass = "sf")

# Load NJAs
IO_NJA = 
  query(
    DB_IOTC_MASTER(), "
    SELECT 
      CODE, 
      NAME_EN, 
      AREA_GEOMETRY.STAsText() AS WKT_GEOM 
    FROM 
      refs_gis.V_IO_NJA_AREAS 
WHERE CODE LIKE 'NJA%'
    AND CODE NOT IN ('NJA_SOM_KEN', 'NJA_SOM_NON_DISPUTED', 'NJA_ATF_MYT', 'NJA_YEM_NON_DISPUTED', 'NJA_YEM_SOM', 'NJA_REU', 'NJA_MYT');" 
  )

# Rename Chagos and ATF NJAs
IO_NJA[CODE == "NJA_IOT", CODE := "NJA_GBR"]
IO_NJA[CODE == "NJA_ATF", CODE := "NJA_FRAT"]

# Merge with NJAs recorded in catch data set
IOTC_NJA = merge(unique(RC[ASSIGNED_AREA != "HIGH_SEAS", .(ASSIGNED_AREA, AREA_CATEGORY)]), IO_NJA, by.x = "ASSIGNED_AREA", by.y = "CODE")

IOTC_NJA_SF = st_as_sf(IOTC_NJA, wkt = "WKT_GEOM", crs = st_crs(4326))

COL_FILL_NJA = iotc.core.utils.aes::unique_colors(25)
COL_OUTLINE_NJA = darken(COL_FILL_NJA, 0.3)

# Visualising the NJAs
IOTC_NJA_MAP = 
  ggplot() + 
  geom_sf(data = CPC_SF, fill = grey(0.95), color = "darkgrey") + 
  geom_sf(data = IOTC_NJA_SF, aes(fill = NAME_EN), size = .5) + 
  scale_x_continuous(limits = c(-17, 149)) + 
  scale_y_continuous(limits = c(-52, 69)) + 
  scale_fill_manual(values = COL_FILL_NJA) + 
  scale_color_manual(values = COL_OUTLINE_NJA) + 
  labs(x = "", y = "") +
  theme(legend.position = "none", legend.title = element_blank()) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
        panel.background = element_rect(fill = "white"))

save_plot("../outputs/maps/IOTC_NJA_MAP.png", IOTC_NJA_MAP, 2.2, 2.1)

# MAP FOR EACH CPC/OBSERVER ####
for (i in 1:nrow(CS_SE_data)){
  
  CS_NJA_SF = IOTC_NJA_SF %>% filter(gsub("NJA_", "", ASSIGNED_AREA) == CS_SE_data[i, CODE])
  
  CS_NJA_MAP = 
    ggplot() + 
    geom_sf(data = CS_NJA_SF, color = "darkgrey") + 
    labs(x = "", y = "") + 
    scale_fill_brewer(palette = "Set3", na.value = grey(0.95)) +  
    theme(legend.position = "none", legend.title = element_blank()) +
    theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
          panel.background = element_rect(fill = "white"))
  
  save_plot(paste0("../outputs/maps/NJAS/MAP_", CS_SE_data[i, CODE], ".png"), CS_NJA_MAP, 8, 4.5)
  
  
}

l_info("Areas of national jurisdiction mapped!")
