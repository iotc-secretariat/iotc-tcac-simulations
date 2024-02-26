# Loading shape file of countries
if(!file.exists("../inputs/shapes/COUNTRY_AREAS_1.0.0_SHP.zip")) 
  
  download.file("https://data.iotc.org/reference/latest/domain/admin/shapefiles/COUNTRY_AREAS_1.0.0_SHP.zip", destfile = "../inputs/shapes/COUNTRY_AREAS_1.0.0_SHP.zip", mode = "wb")


unzip("../inputs/shapes/COUNTRY_AREAS_1.0.0_SHP.zip", overwrite = TRUE, exdir = "../inputs/shapes/")
COUNTRIES = st_read("../inputs/shapes/", layer = "COUNTRY_AREAS_1.0.0")
COUNTRIES = COUNTRIES %>% mutate(CODE = gsub("COU_", "", CODE))
#COUNTRIES = COUNTRIES %>% mutate(CODE = ifelse(CODE %in% c("REU", "MYT"), "EUR", CODE))
COUNTRIES = COUNTRIES %>% mutate(CODE = ifelse(CODE %in% c("FRA"), "FRAT", CODE))

# Filter on IOTC countries
COUNTRIES_IOTC = COUNTRIES %>% filter(CODE %in% CPC$CODE) %>% st_make_valid()

# Create REIO shape
REU = COUNTRIES %>% filter(CODE == "REU") %>% select(c("geometry"))
MYT = COUNTRIES %>% filter(CODE == "MYT") %>% select(c("geometry"))
REIO = st_union(REU, MYT) %>% mutate(CODE = "EUR", NAME_EN = "European Union - land area", NAME_FR = "Union européenne - zone terrestre", LAND_AREA = 2582.43 + 394.9, CENTER_LAT = -16.96843, CENTER_LON = 50.34193) %>% relocate(geometry, .after = CENTER_LON) %>% st_make_valid()

CPC_SF = bind_rows(COUNTRIES_IOTC, REIO) %>% left_join(CPC, by = "CODE")

## Status ####
CPC_STATUS_MAP = 
  ggplot() + 
  geom_sf(data = CPC_SF, aes(fill = STATUS), size = .5) + 
  labs(x = "", y = "") +
  theme(legend.position = "none", legend.title = element_blank()) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
        panel.background = element_rect(fill = "white"))

save_plot("../outputs/maps/CPC_STATUS_MAP.png", CPC_STATUS_MAP, 8, 6)

## SIDS ####
CPC_SIDS_MAP = 
  ggplot() + 
  geom_sf(data = CPC_SF, aes(fill = SIDS), size = .5) + 
  labs(x = "", y = "") +
  theme(legend.position = "none", legend.title = element_blank()) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
        panel.background = element_rect(fill = "white"))

save_plot("../outputs/maps/CPC_SIDS_MAP.png", CPC_SIDS_MAP, 8, 6)

## COASTAL ####
CPC_COASTAL_MAP = 
  ggplot() + 
  geom_sf(data = CPC_SF, aes(fill = COASTAL), size = .5) + 
  labs(x = "", y = "") +
  theme(legend.position = "none", legend.title = element_blank()) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.3), 
        panel.background = element_rect(fill = "white"))

save_plot("../outputs/maps/CPC_COASTAL_MAP.png", CPC_COASTAL_MAP, 8, 6)
