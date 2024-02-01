# IOTC TCAC 13 - Allocation simulations

This document provides an overview of the preliminary assumptions and final outputs produced by the simulation of the allocation criteria defined in [IOTC-2024-TCAC13-REF02](https://iotc.org/sites/default/files/documents/2023/11/IOTC-2024-TCAC13-REF02E_TCAC_draft_Allocation_Regime_v7_clean.docx) as developed by the IOTC Secretariat.

## Configuration

The definition of all relevant parameters characterising each CPC with respect to the allocation criteria is provided in the [`cfg/CPC_CONFIGURATIONS.xlsx`](https://bitbucket.org/iotc-ws/iotc-tcac-simulations/raw/8ce5f9630e1e3ef119848324bd4b71132f0e1336/cfg/CPC_CONFIGURATIONS.xlsx) file.

This includes two worksheets:

-   `CPC` - listing all current IOTC CPCs and CNCPs together with their:

    -   mnemonic code

    -   official English name (as IOTC CPC)

    -   CPC / CPNC status

    -   *small islands developing state* (SIDS) status

    -   coastal state status

    -   presence of a *national jurisdiction area* (NJA) within the Indian Ocean

    -   size of the NJA (in km^2^, calculated from the shapefiles available to the IOTC Secretariat and originally downloaded from the VLIZ / Marine Regions [*maritime boundaries* database](https://www.marineregions.org/eezsearch.php))

    -   relative size of the NJA with respect to the IOTC area.

-   `COASTAL_STATE_SOCIO_ECONOMIC` - listing all IOTC CPCs that are either a coastal state or have a NJA within the Indian Ocean, together with their development status (retrieved from [here](https://www.un.org/development/desa/dpad/wp-content/uploads/sites/45/WESP2020_Annex.pdf)), and a set of socio-economic indicators to address the requirements of both *Option 1* and *Option 2* in [IOTC-2024-TCAC13-REF02](https://iotc.org/sites/default/files/documents/2023/11/IOTC-2024-TCAC13-REF02E_TCAC_draft_Allocation_Regime_v7_clean.docx) para. 6.6(1)(b).

    -   The indicators required by *Option 1*, i.e.:

        -   per capita fish consumption

        -   *Commonwealth Universal Vulnerability index* (CUVI)

        -   proportion of fish workers employed in small-scale and artisanal fisheries

        -   fisheries contribution to GDP

        -   proportion of total export value made up of fisheries exports

            are not yet available to the IOTC Secretariat and have therefore been replaced bydummy values.

            | For this reason, caution should be made when assessing the results produced by the simulation through *Option 1*, and the IOTC Secretariat will update the required socio-economic indicators as soon as these will be provided by the proponents.

    -   The HDI (2021) and GNI indicators required by *Option 2* have been extracted from [here](https://hdr.undp.org/data-center/human-development-index#/indicies/HDI) and [here](https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-group), respectively, with the HDI index for the EU averaged from [here](https://www.theglobaleconomy.com/rankings/human_development/European-union/).

### Assumptions

#### CPC / coastal state configuration

The identification of a CPC as *being* or *not being* an IOTC coastal state is still a matter of debate for some nations that have areas under national jurisdiction within the Indian Ocean.

For the sake of this simulation we assume the following:

-   That beside having an NJA in the Indian Ocean, `FRAT` (*France (OT)*) shall be *de facto* considered an IOTC coastal state (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) *Chair's explanatory memorandum to TCAC12 participants*).

-   That `EUR` (*European Union / REIO*) has an NJA in the Indian Ocean (i.e., the NJA around Réunion and Mayotte) and that for this reason "(...) *should benefit from an allocation that relates to the size of the EEZ of its outermost territories in the IOTC area of competence.*" (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) *Chair's explanatory memorandum to TCAC12 participants*).

-   That `EUR` (*European Union / REIO*), notwithstanding the above "(...) *would not be seeking the application of paragraph 6.6(1)(b) of the coastal state allocation criteria (...)*" (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) *Chair's explanatory memorandum to TCAC12 participants*).

-   That there are different views as whether `EUR` (*European Union / REIO*) "(...) *should benefit from the portion of the coastal state allocation criteria related to aspirations under paragraph 6.6(1)(a) (...)*" (see [IOTC-2023-TCAC12-04](https://iotc.org/sites/default/files/documents/2023/09/IOTC-2023-TCAC12-04_E_-_Chairs_Explanatory_Note.pdf) *Chair's explanatory memorandum to TCAC12 participants*).

> In lack of other indications, the simulation considers `EUR` (*European Union / REIO*) as benefiting from this portion of allocation.

-   That clarity shall be made regarding the sovereignty over the NJA of the Chagos archipelago which are currently disputed between two IOTC CPCs (`MUS` and `GBR`) as this will have an impact not only on the attribution of the relative NJA area weight for the coastal state allocation criteria, but also on the status of `GBR` (*United Kingdom of Great Britain and Northern Ireland*) as a coastal state itself.

> In lack of other indications, the simulation considers `GBR` (*United Kingdom of Great Britain and Northern Ireland*) as having sovereignty over the NJA of the Chagos archipelago, and that this will not automatically qualify the CPC as a coastal state.
>
> Furthermore, `GBR` focal points have confirmed that the CPC will request the application of paragraph 6.6(1)(a) and (c) of the coastal state allocation criteria, but not (b), and this has been properly reflected in the current implementation of the TCAC simulations made by the Secretariat.

#### Historical catches

This information is crucial to calculate the third component (*catch-based*) of the allocation criteria, is available for all years from 1950 to 2021 and can be downloaded from: [`cfg/HISTORICAL_CATCH_ESTIMATES.csv`](https://bitbucket.org/iotc-ws/iotc-tcac-simulations/raw/3b65fece8385b6e051e2b984f46b21bc9dd73bdd/cfg/HISTORICAL_CATCH_ESTIMATES.csv).

It has to be noted how the need of apportioning historical catches by fleet according to the area of operation (high seas vs. the NJA of any given coastal state) requires the IOTC Secretariat to estimate this information through a process that has been presented at the last TCAC meeting in October 2023, and agreed by the meeting participants.

For this reason, the historical catch series with full area breakdown is only available for the five major IOTC species (albacore, bigeye, skipjack, swordfish, and yellowfin tuna) and has been estimated using the regular grid vs. NJA overlapping area fraction as a way of assigning catches estimated for the former to the area that falls within a given NJA.

> At this stage of the process, there is no additional information from CPCs that might confirm whether their catches in a given grid shall only be attribute to the flag state or not. For this reason, the simulation uses the information in the `ASSIGNED_AREA` column of the historical catch series to calculate the catches for a given coastal state / flag state (when required).

For the sake of calculating the catch-based allocation weight for each CPC, information on historical catches is averaged across a selectable timeframe with two possible approaches that compute:

-   the annual average across the entire time period

-   the average of the best 'n' years across the time period

In the latter case, the *best years* are considered to be those with the highest catches across the selected period (for a given fleet / species).

# User interface

TBD
