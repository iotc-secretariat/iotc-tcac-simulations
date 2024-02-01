# IOTC TCAC 13 - Allocation simulations

This document provides an overview of the assumptions made, and of the output produced by the R scripts that implement the allocation criteria as defined in [IOTC-2024-TCAC13-REF02](https://iotc.org/sites/default/files/documents/2023/11/IOTC-2024-TCAC13-REF02E_TCAC_draft_Allocation_Regime_v7_clean.docx).

## Configuration

The definition of all relevant parameters characterising each CPC with respect to the allocation criteria is provided in the `cfg/CPC_CONFIGURATIONS.xlsx` file.

This includes two worksheets:

-   `CPC` - listing all current IOTC CPCs and CNCPs with their code, English name, CPC status, *small islands developing state* (SIDS) status, coastal state status, presence of a *national jurisdiction area* (NJA) within the Indian Ocean, size of the NJA (in km\^2) , and relative size of the NJA with respect to the IOTC area.

    The size of the NJAs has been calculated from the shapefiles available to the IOTC Secretariat and originally downloaded from the VLIZ / Marine Regions [*maritime boundaries* database](https://www.marineregions.org/eezsearch.php).

-   `COASTAL_STATE_SOCIO_ECONOMIC` - listing all IOTC CPCs that are either a coastal state or have a NJA within the Indian Ocean, together with their development status (retrieved from [here](https://www.un.org/development/desa/dpad/wp-content/uploads/sites/45/WESP2020_Annex.pdf)), and a set of socio-economic indicators to address the requirements of both *Option 1* and *Option 2* in [IOTC-2024-TCAC13-REF02](https://iotc.org/sites/default/files/documents/2023/11/IOTC-2024-TCAC13-REF02E_TCAC_draft_Allocation_Regime_v7_clean.docx) para. 6.6(1)(b). More specifically, the following indicators required by *Option 1*, i.e.:

    -   per capita fish consumption

    -   Commonwealth Universal Vulnerability index (CUVI)

    -   proportion of fish workers employed in small-scale and artisanal fisheries

    -   fisheries contribution to GDP

    -   proportion of total export value made up of fisheries exports

        are not yet available to the IOTC Secretariat, and have been replaced with dummy values.

        Conversely, the HDI (2021) and GNI indicators required by *Option 2* have been extracted from [here](https://hdr.undp.org/data-center/human-development-index#/indicies/HDI) and [here](https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-group), respectively, with the HDI index for the EU averaged from [here](https://www.theglobaleconomy.com/rankings/human_development/European-union/).

### Assumptions

The identification of a CPC as being or not an IOTC coastal state is still a matter of debate for some nations that have areas under national jurisdiction within the Indian Ocean.

For the sake of this simulation we assume the following:

-   That beside having an NJA in the Indian Ocean, `FRAT` (*France (OT)*) shall be *de facto* considered an IOTC coastal state (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) \_Chair's explanatory memorandum to TCAC12 participants).

-   That `EUR` (*European Union / REIO*) has an NJA in the Indian Ocean (i.e., the NJA around Réunion and Mayotte) and that for this reason "(...) *should benefit from an allocation that relates to the size of the EEZ of its outermost territories in the IOTC area of competence.*" (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) *Chair's explanatory memorandum to TCAC12 participants*).

-   That `EUR` (*European Union / REIO*), notwithstanding the above "(...) *would not be seeking the application of paragraph 6.6(1)(b) of the coastal state allocation criteria (...)*" (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) *Chair's explanatory memorandum to TCAC12 participants*).

-   That there are different views as whether `EUR` (*European Union / REIO*) "(...) *should benefit from the portion of the coastal state allocation criteria related to aspirations under paragraph 6.6(1)(a) (...)*" (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) *Chair's explanatory memorandum to TCAC12 participants*).

> In lack of other indications, the simulation considers `EUR` (*European Union / REIO*) as benefiting from this portion of allocation

-   That clarity shall be made regarding the sovereignty over the NJA of the Chagos archipelago which are currently disputed between two IOTC CPCs (`MUS` and `GBR`) as this will have an impact not only on the attribution of the relative NJA area weight for the coastal state allocation criteria, but also on the status of `GBR` (*United Kingdom of Great Britain and Northern Ireland*) as a coastal state itself.

> In lack of other indications, the simulation considers `GBR` (*United Kingdom of Great Britain and Northern Ireland*) as having sovereignty over the NJA of the Chagos archipelago, and that this will not automatically qualify the CPC as a coastal state. Furthermore, `GBR` focal points have confirmed that the CPC will request the application of paragraph 6.6(1)(a) and (c) the coastal state allocation criteria, but not (b), and this has been properly reflected in the current implementation of the TCAC simulations. 

# User interface
