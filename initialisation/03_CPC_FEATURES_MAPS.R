# Loading shape file of countries
if(!file.exists("../inputs/shapes/COUNTRY_AREAS_1.0.0_SHP.zip")) 
  
  download.file("https://data.iotc.org/reference/latest/domain/admin/shapefiles/COUNTRY_AREAS_1.0.0_SHP.zip", destfile = "../inputs/shapes/COUNTRY_AREAS_1.0.0_SHP.zip", mode = "wb")


unzip("../inputs/shapes/COUNTRY_AREAS_1.0.0_SHP.zip", overwrite = TRUE, exdir = "../inputs/shapes/")

COUNTRIES = st_read("../inputs/shapes/", layer = "COUNTRY_AREAS_1.0.0")
COUNTRIES = COUNTRIES %>% mutate(CODE = gsub("COU_", "", CODE)) %>% select(c("CODE", "NAME_EN", "NAME_FR", "geometry"))

# Filter on IOTC countries
COUNTRIES_WITHOUT_REIO = COUNTRIES %>% mutate(STATUS = ifelse(CODE %in% CPC_data[STATUS %in% c("CP", "OBS"), CODE], "CP", ifelse(CODE == "LBR", "CNPC", NA))) %>% filter(!CODE %in% c("AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE", "MYT", "REU"))

#COUNTRIES_IOTC = COUNTRIES %>% filter(CODE %in% CPC_data$CODE) %>% st_make_valid()

# Create REIO shape
REIO_GEOMS = COUNTRIES %>% filter(CODE %in% c("AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE", "MYT", "REU")) %>% select(c("geometry"))

REIO = REIO_GEOMS %>% dplyr::summarise() %>% mutate(CODE = "EUR", NAME_EN = "European Union - land area", NAME_FR = "Union européenne - zone terrestre", STATUS = "CP") %>% relocate(geometry, .after = STATUS) %>% st_make_valid()

COUNTRIES_SF = bind_rows(COUNTRIES_WITHOUT_REIO, REIO) %>% left_join(CPC_data[, -c("NAME_EN", "SIDS", "STATUS")], by = "CODE") %>% left_join(CS_SE_data[, -c("COASTAL", "HAS_NJA_IO", "PER_CAPITA_FISH_CONSUMPTION_KG", "CUV_INDEX", "PROP_WORKERS_EMPLOYED_SSF", "PROP_FISHERIES_CONTRIBUTION_GDP", "PROP_EXPORT_VALUE_FISHERY")], by = "CODE")

# MAPS FOR ALL CPCS ####

## IOTC STATUS ####
CPC_STATUS_MAP = 
  ggplot() + 
  geom_sf(data = COUNTRIES_SF, aes(fill = STATUS), color = "darkgrey", size = .5) + 
  labs(x = "", y = "") + 
  scale_fill_brewer(palette = "Set1", na.value = grey(0.95)) +  
  scale_x_continuous(limits = c(-17, 149)) + 
  scale_y_continuous(limits = c(-52, 69)) + 
  theme(legend.position = "none", legend.title = element_blank()) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
        panel.background = element_rect(fill = "white"))

save_plot("../outputs/maps/CPC_STATUS_MAP.png", CPC_STATUS_MAP, 2.2, 2.1)

## COASTAL ####
CPC_COASTAL_MAP = 
  ggplot() + 
  geom_sf(data = COUNTRIES_SF, aes(fill = COASTAL), color = "darkgrey", size = .5) + 
  labs(x = "", y = "") + 
  scale_fill_brewer(palette = "Set1", na.value = grey(0.95)) +  
  scale_x_continuous(limits = c(-17, 149)) + 
  scale_y_continuous(limits = c(-52, 69)) + 
  theme(legend.position = "none", legend.title = element_blank()) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
        panel.background = element_rect(fill = "white"))

save_plot("../outputs/maps/CPC_COASTAL_MAP.png", CPC_COASTAL_MAP, 2.2, 2.1)

# HAS_NJA_IO
CPC_HAS_NJA_IO_MAP = 
  ggplot() + 
  geom_sf(data = COUNTRIES_SF, aes(fill = HAS_NJA_IO), color = "darkgrey", size = .5) + 
  labs(x = "", y = "") + 
  scale_fill_brewer(palette = "Set3", na.value = grey(0.95)) +  
  scale_x_continuous(limits = c(-17, 149)) + 
  scale_y_continuous(limits = c(-52, 69)) + 
  theme(legend.position = "none", legend.title = element_blank()) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
        panel.background = element_rect(fill = "white"))

save_plot("../outputs/maps/CPC_HAS_NJA_IO_MAP.png", CPC_HAS_NJA_IO_MAP, 2.2, 2.1)

# MAP FOR EACH CPC/OBSERVER ####


for (i in 1:nrow(CPC_data)){
  
  CPC_SF = COUNTRIES_SF %>% filter(CODE == CPC_data[i, CODE])
  
  CPC_MAP = 
    ggplot() + 
    geom_sf(data = CPC_SF, color = "darkgrey") + 
    labs(x = "", y = "") + 
    scale_fill_brewer(palette = "Set3", na.value = grey(0.95)) +  
    theme(legend.position = "none", legend.title = element_blank()) +
    theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
          panel.background = element_rect(fill = "white"))
  
  save_plot(paste0("../outputs/maps/CPCS/MAP_", CPC_data[i, CODE], ".png"), CPC_MAP, 8, 4.5)
  
  
}
