# Abstract

This document describes the list of changes and improvements to make to the App:

* Computation / Datasets

- Update the NJA size in the entity reference file in accordance with the new NJA spatial layer
- Update Australian NJA to reflect the 4 components present in the Indian Ocean in the map: c("AUS", "AUS_CCK", "AUS_CXR", "AUS_HMD") => _HMD part is not intersecting IOTC area of competence so it is not displayed, the other features are_

* Labelling

- Replace "Target TAC (t)" by "Target Total Allowable Catch (TAC; t)" => _DONE_
- Replace "Albacore tuna" by "Albacore" in the species code list/drop-down list => _DONE_
- Replace "Select a entity" by "Select an entity" in the Reference data tab => _DONE_
- Replace "Please select a entity" by "Please select an entity" in the drop-down list of the Reference data tab = > _DONE_
- Enrich the catch dataset with labels/names for flag state, entity, type of fishery, fishery, school type, assigned area species
- The headers (column names) of the catch dataset should read: Year, Flag state code, Flag Sate, Entity code, Entity, Type of fishery code, Type of fishery, Fishery code, Fishery, School type code, School type, Assigned area code, Assigned Area (**Do we really need to keep the codes, maybe for potential advanced users??**)
- The right column header should not read **TAC** in the `Results` panel, as the TAC represents the total value of catch allowed. It could read "Value", corresponding either to Quota (%) or "Catches (t)" depending on the variable selected through the scroll-down list. It could also read each of those when selected, if not complicated to implement.

* UI

- Add European Union flag => _To address through FDI_
- Possibility to improve the quality of the flag logos (other source?) => _To address through FDI_
- Add general disclaimer and individual short disclaimers on each map (see below)

* Features

- Add an option of export of the Catch Dataset (Data) in the Reference data tab (DT package)
- Remove "t" from the Catches column => _DONE_
- Change colour palettes from red to blue for the simulation results: 'All entities' tab => _DONE_
- Remove the 2 decimal places in the simulation results: 'All entities' tab  => _DONE_
- Remove the "t" standing for metric tonnes in the simulation results: 'All entities' tab => _DONE_
- Remove "High Seas only catches" [Focus exclusively on catches estimate to have been taken in Areas Beyond National Jurisdiction (High Seas; HS)] in Simulation configuration panel (bottom) => _DONE_
- Add information on the species selected for the Results "By entity"
- Possibility to add the FAO drawings for the 5 species of interest to the TCAC

* Documentation

- Update "ReadMe" file to reflect changes in the App

# Tool Tips

## Parameters

- Baseline weight (%)

# Map & Spatial Data Disclaimer

The designations employed and the presentation of material on the maps and spatial layers included in this application do not imply the expression of any opinion whatsoever on the part of the Secretariat of the United Nations, the Food and Agriculture Organization of the United Nations (FAO), or the Indian Ocean Tuna Commission (IOTC) concerning the legal status of any country, territory, city or area, or of its authorities, or concerning the delimitation of its frontiers or boundaries.

Water Jurisdiction Areas (WJAs) shown in this application are derived from the Marine Regions database, produced by the Flanders Marine Institute (VLIZ) and made available through [Marine Regions](https://www.marineregions.org/). The use of these data is subject to the terms and conditions and disclaimer provided by VLIZ (see the Marine Regions disclaimer at: <https://www.marineregions.org/disclaimer.php>
).

The representation of maritime zones, including areas subject to overlapping or disputed claims, is intended solely for analytical and visualisation purposes and does not constitute recognition, endorsement, or acceptance of any claim or boundary.

For maps including the Indian subcontinent, the following cartographic note applies: Dotted line represents approximately the Line of Control in Jammu and Kashmir agreed upon by India and Pakistan. The final status of Jammu and Kashmir has not yet been agreed upon by the parties.

**Short disclaimer** to include on each map: _The boundaries and names shown and the designations used on this map do not imply official endorsement or acceptance by the United Nations_

# Catch Data Disclaimer

- 
- 
- 
- 