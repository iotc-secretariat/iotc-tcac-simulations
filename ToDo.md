# Abstract

This document describes the list of changes and improvements to make to the App:

* Labelling

- Replace EEZ by NJA for consistency in the header "Coastal state EEZ attribution weights" of the Parameters Panel. It should read "Coastal state NJA attribution weights"

- Enrich the catch dataset with labels/names for flag state, entity, type of fishery, fishery, school type, assigned area species

- The headers (column names) of the catch dataset should read: Year, Flag state code, Flag Sate, Entity code, Entity, Type of fishery code, Type of fishery, Fishery code, Fishery, School type code, School type, Assigned area code, Assigned Area (**Do we really need to keep the codes, maybe for potential advanced users??**)

- The right column header should not read **TAC** in the `Results` panel, as the TAC represents the total value of catch allowed. It could read "Value", corresponding either to Quota (%) or "Catches (t)" depending on the variable selected through the scroll-down list. It could also read each of those when selected, if not complicated to implement.

* UI

- Add constraint to the sliders so that the sum equals to 100%. Right now, it is possible to get negative values for the Catch-based weight

- Add general disclaimer and individual short disclaimers on each map:

_The boundaries and names shown and the designations used on this map do not imply official endorsement or acceptance by the United Nations._

- Fix separation between map widget and frame with information on 

* Features

- Add an option of export of the Catch Dataset (Data) in the Reference data tab (DT package)
- Add information on the species selected for the Results "By entity"
