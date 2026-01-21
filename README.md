---
title: "TCAC Application – Data and Methodological Notes"
output: html_document
---

# Overview

This repository hosts a Shiny application developed by the IOTC Secretariat to explore how alternative allocation scenarios affect the distribution of total catch among IOTC Contracting Parties and Cooperating Non-Contracting Parties (CPCs). Users can adjust parameters reflecting CPC status, historical catch levels, and catches within National Jurisdiction Areas (NJAs) by foreign fleets. The tool is intended to support transparent discussion and informed decision-making within the framework of the Technical Committee on Allocation Criteria (TCAC).

# Input Data

### Entity Reference Table {#entities}

The definitions of all parameters used to characterise each CPC in relation to the allocation criteria are provided in the [`inputs/data/iotc_entities.csv`](./inputs/data/iotc_entities.csv) file. This file lists all current IOTC *Contracting Parties* (CP) and *Cooperating Non-Contracting Parties* (CNCP), as well as Taiwan,China as a *Fishing Entity* (FE), together with the following information:

| Field name        | Description | Source |
| :------ | :--------------------- | :-------- |
| `ISO3_CODE`       | Three-letter ISO 3166-1 alpha-3 country code | [IOTC Reference Data (2026)](https://data.iotc.org/reference/latest/domain/admin/#Entities) | 
| `NAME_EN`         | Official name of the Contracting Party, Cooperating Non-Contracting Party, or Fishing Entity in English | [IOTC Reference Data (2026)](https://data.iotc.org/reference/latest/domain/admin/#Entities) |
| `NAME_FR`         | Official name of the Contracting Party, Cooperating Non-Contracting Party, or Fishing Entity in French | [IOTC Reference Data (2026))](https://data.iotc.org/reference/latest/domain/admin/#Entities) |
| `STATUS_CODE`     | IOTC membership status code: `CP` (Contracting Party), `CNCP` (Cooperating Non-Contracting Party), or `FE` (Fishing Entity) | [IOTC Reference Data (2026)](https://data.iotc.org/reference/latest/domain/admin/#CPCs) |
| `STATUS`          | Descriptive label corresponding to `STATUS_CODE` (e.g. *Contracting Party*, *Cooperating Non-Contracting Party*, *Fishing Entity*) | [IOTC Reference Data (2026)](https://data.iotc.org/reference/latest/domain/admin/#CPCs) |
| `IS_DEVELOPING`   | Indicator of developing country status* according to [United Nations classification (`TRUE` / `FALSE`) | [UN (2020)](https://www.un.org/development/desa/dpad/wp-content/uploads/sites/45/WESP2020_Annex.pdf) |
| `IS_LDC`          | Indicator of Least Developed Country (LDC) status according to United Nations classification (`TRUE` / `FALSE`) | [UN (2026)](https://unstats.un.org/unsd/methodology/m49/#ldc) |
| `IS_SIDS`         | Indicator of Small Island Developing State (SIDS) status according to United Nations classification (`TRUE` / `FALSE`) | [UN (2026)](https://unstats.un.org/unsd/methodology/m49/#sids) |
| `IS_COASTAL`      | Indicator of coastal State status within the IOTC Area of Competence (`TRUE` / `FALSE`) | [Flanders Marine Institute (2026)](https://www.marineregions.org/) |
| `NJA_IO_SIZE`     | Surface area (in square kilometres) of the NJA within the Indian Ocean (see [NJA section](#njas) for details) | [Flanders Marine Institute (2026)](https://www.marineregions.org/) |

*Seychelles is classified as a coastal developing country within the IOTC, consistent with its status as a SIDS recognised by the United Nations (UN). Although Seychelles has a high level of human development and income per capita, it is not classified as a developed country in the UN system and remains eligible for developing-country and SIDS-specific provisions under IOTC frameworks.

### Historical Catches {#catch}

This information is essential for calculating the third component (*catch-based*) of the allocation criteria and can be downloaded from [`inputs/data/HISTORICAL_CATCH_ESTIMATES.csv`](./HISTORICAL_CATCH_ESTIMATES.csv). The file can be opened as a spreadsheet using MS Excel, LibreOffice Calc, Google Sheets, or any text editor.

The catch input file used by the TCAC application contains aggregated catch estimates by year, flag, fleet, fishery, area, and species. The definitions of the fields included in this file are provided below.

| Field name           | Description |
|:------- | :-------------------------- |
| `YEAR`               | Year of fishing activity |
| `FLAG_CODE`          | Code identifying the [flag State](https://data.iotc.org/reference/latest/domain/admin/#countries), as defined in the IOTC reference list of countries |
| `FLEET_CODE`         | Code identifying the [fishing fleet](https://data.iotc.org/reference/latest/domain/admin/#fleets), as defined in the IOTC reference list of fleets |
| `FISHERY_TYPE`       | Code identifying the main fishery category: `ART` (Artisanal) or `IND` (Industrial) |
| `FISHERY_CODE`       | Code identifying the [fishing gear](https://data.iotc.org/reference/latest/domain/fisheries/#Gears) used, as defined in the IOTC reference list of fishing gears |
| `SCHOOL_TYPE_CODE`   | Code identifying the type of tuna school association: `LS` (school associated with a drifting floating object, natural or artificial) or `FS` (free-swimming school) |
| `ASSIGNED_AREA`      | Area where the catch is assigned. Values include Areas Beyond National Jurisdiction (`HIGH_SEAS`) and National Jurisdiction Areas (`NJA_xxx`), where the last three characters correspond to the relevant [country code](https://data.iotc.org/reference/latest/domain/admin/#countries), e.g. `NJA_COM` for the National Jurisdiction Area of Comoros |
| `SPECIES_CODE`       | Code identifying the [species](https://data.iotc.org/reference/latest/domain/biology/#IOTCspecies) : `ALB` (albacore), `BET` (bigeye tuna), `SKJ` (skipjack tuna), `SWO` (swordfish), `YFT` (yellowfin tuna) |
| `CATCH_MT`           | Estimated catch, expressed in metric tonnes |

Historical catch data are available for all years from 1950 to 2021 stratified by year, fleet, gear, school type, species, and assigned area.

It is important to note that the need to apportion historical catches by flag or fleet according to the area of operation (high seas versus the NJA of any given coastal state) requires the IOTC Secretariat to estimate this information. This estimation process was presented at the TCAC meeting in October 2023 (see [IOTC-2023-TCAC12-INF02](https://iotc.org/documents/TCAC/12/INF02)).

For this reason, the historical catch series with a full area breakdown is only available for the five major IOTC species (albacore, bigeye tuna, skipjack tuna, swordfish, and yellowfin tuna). These data have been estimated using the regular grid versus the NJA overlapping area fraction to assign catches estimated for the former to the area that falls within a given NJA.

### National Jurisdiction Areas {#njas}

#### Source

The National Jurisdiction Areas (NJAs) of the IOTC CPCs were sourced from the Flanders Marine Institute (VLIZ) *maritime boundaries* geodatabase (<https://doi.org/10.14284/628>). The corresponding spatial layers are available for download from the IOTC Reference Data Catalogue (https://data.iotc.org/reference/latest/domain/admin/shapefiles/IO_NJA_AREAS_2.0.0_SHP.zip).

#### Assumptions

For the purposes of allocating catches to NJAs within the simulations implemented in the TCAC application, the following assumptions were applied:

i. For historical reasons, the waters of the Chagos Archipelago, considered here as part of the NJAs of Mauritius, were treated as being under the sovereignty of the United Kingdom of Great Britain and Northern Ireland (`GBR`), under the administration of the British Indian Ocean Territory prior to 2021. A full Marine Protected Area has been in place since April 2010 and, consequently, no official fisheries catches have been reported from these waters since that date, except for a coastal handline fishery;

ii. Disputed areas involving Mayotte, Tromelin, and the Glorioso Islands (Îles Glorieuses) were treated as follows: waters associated with Mayotte (France) with Comoros (`FRA_COM_MYT`) and France with Madagascar and Mauritius (`FRA_MDG_MUS`) were attributed to France (`FRA`), while waters associated with Madagascar with France (`MDG_FRA`) were attributed to the France Overseas Territories (`ATF`). This assumption was adopted to simplify the allocation procedure and to ensure internal consistency with long-standing IOTC statistical practices, whereby catches from these areas have historically been attributed accordingly in national submissions and Secretariat compilations. This treatment is applied solely for analytical purposes within the TCAC application and does not prejudice the positions of CPCs with respect to sovereignty or maritime claims;

iii. Although Mayotte became an overseas department of France in 2011, catches associated with Mayotte are attributed to France in IOTC datasets from 2014 onwards, corresponding to the point at which reporting practices and fleet attribution became consistently aligned with French national submissions. Accordingly, catches taken in the waters of Mayotte during the period 1995–2013 were allocated to the France Overseas Territories (`ATF`), and to France (`FRA`) thereafter;

iv. The NJA for the Islamic Republic of Iran (`IRN`) was defined as the combination of the Iranian NJA (`IRN`) and the maritime areas subject to dispute with the United Arab Emirates (`ARE_IRN`) and Iraq (`IRQ_IRN`);

v. The NJA for Sudan (SDN) was defined as the combination of the Sudanese NJA (`SDN`) and the maritime area subject to dispute with Egypt (`SDN_EGY` );

vi. Catches estimated to have been taken in the NJAs of non-IOTC CPCs -- United Arab Emirates (`ARE`), Bahrain (`BHR`), Djibouti (`DJI`), Egypt (`EGY`), Eritrea (`ERI`), Iraq (`IRQ`), Jordan (`JOR`), Kuwait (`KWT`), Myanmar (`MMR`), Qatar (`QAT`), Saudi Arabia (`SAU`), and Timor-Leste (`TLS`), including disputed areas (Eritrea with Djibouti (`ERI_DJI`) and Qatar with Saudi Arabia and the United Arab Emirates (`QAT_SAU_ARE`) -- were aggregated under the assigned area `OTHER`;

vii. Catch data reported for incorrect spatial grids (i.e. located outside the Indian Ocean) could not be assigned to any NJA or to the high seas and were therefore excluded from the analysis.

#### Surface Areas

Surface areas of NJAs were computed using the _st_area()_ function in R after projecting geometries to the Eckert IV equal-area projection (Eck4). Resulting area estimates were expressed in square kilometres, and geometries were subsequently re-projected to WGS 84 (EPSG:4326) for storage and visualisation.

## Allocation Computation

All weights are expressed in percentage (%) of the total value of the Total Allowable Catch (TAC) expressed in metric tonnes (t). 

### Baseline Weight

The **baseline weight** (%) represents the portion of the TAC that is allocated evenly among the the 29 IOTC Contracting Parties (CPs): Australia (`AUS` ), Bangladesh (`BGD`), China (`CHN`), Comoros (`COM`), European Union (`EUR`), France Overseas Territories (`ATF`), India (`IND`), Indonesia (`IDN`), I.R. Iran (`IRN`), Japan (`JPN`), Kenya (`KEN`), Madagascar (`MDG`), Malaysia (`MYS`), Maldives (`MDV`), Mauritius (`MUS`), Mozambique (`MOZ`), Oman (`OMN`), Pakistan (`PAK`), Philippines (`PHL`), Republic of Korea (`KOR`), Seychelles (`SYC`), Somalia (`SOM`), South Africa (`ZAF`), Sri Lanka (`LKA`), Sudan (`SDN`), Thailand (`THA`), United Kingdom of Great Britain and Northern Ireland (`GBR`), United Republic of Tanzania (`TZA`), and Yemen (`YEM`).

_Example_. If the baseline weight is set to 10%, each contractin party receives an equal share of the TAC equal to 10% ÷ 29 ≈ 0.345%. For a TAC of 421,000 t (the default case for yellowfin tuna), this corresponds to approximately 1,452 t per contracting party.

### Developing States Weight

The **developing states weight** (%) represents the portion of the TAC that is allocated among the 21 IOTC developing coastal states: Bangladesh (`BGD`), Comoros (`COM`), India (`IND`), Indonesia (`IDN`), 
I.R. Iran (`IRN`), Kenya (`KEN`), Madagascar (`MDG`), Malaysia (`MYS`), Maldives (`MDV`), Mauritius (`MUS`), Mozambique (`MOZ`), Oman (`OMN`), Pakistan (`PAK`), Seychelles (`SYC`), Somalia (`SOM`), South Africa (`ZAF`), Sri Lanka (`LKA`), Sudan (`SDN`), Thailand (`THA`), United Republic of Tanzania (`TZA`), and Yemen (`YEM`).

This allocation component comprises three sub-components: (i) an equal-weight component, (ii) a least-developed country (LDC) component, and (iii) a small island developing States (SIDS) component. The relative contribution of each sub-component can be adjusted by the user to reflect different weighting schemes for developing coastal states according to their status.

#### Equal Weight

The **equal-weight** (%) sub-component of the developing states allocation component represents the portion of the TAC that is allocated evenly among the the 21 IOTC developing coastal states: Bangladesh (`BGD`), Comoros (`COM`), India (`IND`), Indonesia (`IDN`), I.R. Iran (`IRN`), Kenya (`KEN`), Madagascar (`MDG`), Malaysia (`MYS`), Maldives (`MDV`), Mauritius (`MUS`), Mozambique (`MOZ`), Oman (`OMN`), Pakistan (`PAK`), Seychelles (`SYC`), Somalia (`SOM`), South Africa (`ZAF`), Sri Lanka (`LKA`), Sudan (`SDN`), Thailand (`THA`), United Republic of Tanzania (`TZA`), and Yemen (`YEM`).

_Example_. If the developing states weight is set to 10% and the equal weight is set to 35%, each developing coastal state receives an equal share of the TAC equal to 10% x 35% ÷ 21 ≈ 0.17%. For a TAC of 421,000 t (the default case for yellowfin tuna), this corresponds to approximately 702 t per developing coastal state.

#### Least-Developed Country Weight

The **least-developed country weight** (%) sub-component of the developing states allocation component represents the portion of the TAC that is allocated evenly among the the 8 IOTC least-developed coastal states: Bangladesh (`BGD`), Comoros (`COM`), Madagascar (`MDG`), Mozambique (`MOZ`), Somalia (`SOM`), Sudan (`SDN`), United Republic of Tanzania (`TZA`), and Yemen (`YEM`).

_Example_. If the developing states weight is set to 10% and the least-developed country weight is set to 47.5%, each least-developed coastal state receives an equal share of the TAC equal to 10% x 47.5% ÷ 8 ≈ 0.59%. For a TAC of 421,000 t (the default case for yellowfin tuna), this corresponds to approximately 2,500 t per least-developed coastal state.

#### Small Island Developing State Weight

The **small island developing state weight** (%) sub-component of the developing states allocation component represents the portion of the TAC that is allocated evenly among the the 4 IOTC SIDS: Comoros (`COM`), Maldives (`MDV`), Mauritius (`MUS`), and Seychelles (`SYC`).

_Example_. If the developing states weight is set to 10% and the small island developing state weight is set to 20%, each SIDS receives an equal share of the TAC: 10% x 20% ÷ 4 ≈ 0.5%. For a TAC of 421,000 t (the default case for yellowfin tuna), this corresponds to approximately 2,105 t per SIDS.

### Catch-Based Weight

The **catch-based weight** (%) represents the portion of the TAC allocated to each CPC in proportion to its contribution to the total catch of the species over a selected historical reference period.

To calculate this allocation component, historical catch data are averaged over a user-selected reference period using one of two alternative approaches:

-   the annual average over the entire reference period; or
-   the average of the best _n_ years within the reference period.

Under the latter approach, the _best years_ are defined as those with the highest reported catches for a given CPC and species during the selected reference period.

_Example_. If the catch-based weight is set to 50% and the reference period of 2000-2016 is selected, 
