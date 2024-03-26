server = function(input, output, session) {
  output$CPC_summary_table = 
    DT::renderDataTable(
      DT::datatable(
        CPC_DATA, 
        class = "stripe cell-border",
        rownames = FALSE,
        escape = FALSE,
        colnames = c("Code", "Name", "Status", "Is SIDS?", "Is coastal?", "Has NJA in the IO?", "NJA size", "NJA vs. IOTC size", "NJA size weighting"),
        options = 
          list(
            pageLength= 15,
            searching = TRUE,
            autoWidth = TRUE,
            paging    = TRUE,
            info      = TRUE
          ),
        filter = list(position = "top") 
      )
      %>% DT::formatCurrency("NJA_SIZE", mark = ",", digits = 0, currency = "&nbsp;km<sup>2</sup>", before = FALSE)
      %>% DT::formatPercentage("NJA_IOTC_RELATIVE_SIZE", digits = 2)
    )
  
  output$coastal_states_summary_table = 
    DT::renderDataTable(
      DT::datatable(
        CS_SE_DATA, 
        class = "stripe cell-border",
        rownames = FALSE,
        escape = FALSE,
        colnames = c("Code", "Is&nbsp;coastal?", "Has&nbsp;NJA&nbsp;area?", 
                     "Development&nbsp;status", "Pro&nbsp;capita&nbsp;fish&nbsp;consumption", "CUV&nbsp;index", "%&nbsp;workers&nbsp;employed&nbsp;SSF", "%&nbsp;fisheries&nbsp;contrib.&nbsp;to&nbsp;GDP", "%&nbsp;fisheries&nbsp;contrib.&nbsp;total&nbsp;export", 
                     "HDI", "HDI&nbsp;tier", "HDI&nbsp;tier&nbsp;weight", "GNI", "GNI&nbsp;weight", "SIDS&nbsp;status", "SIDS&nbsp;status&nbsp;weight"),
        options = 
          list(
            pageLength= 15,
            searching = TRUE,
            autoWidth = TRUE,
            paging    = TRUE,
            info      = TRUE
          ),
        filter = list(position = "top")
      )
      %>% DT::formatCurrency("PER_CAPITA_FISH_CONSUMPTION_KG", mark = ",", digits = 2, currency = "&nbsp;kg&nbsp;/&nbsp;year", before = FALSE)
      %>% DT::formatRound(c("HDI_TIER_WEIGHT", "GNI_STATUS_WEIGHT"), digits = 2)
      %>% DT::formatPercentage(c("PROP_WORKERS_EMPLOYED_SSF", "PROP_FISHERIES_CONTRIBUTION_GDP", "PROP_EXPORT_VALUE_FISHERY"), digits = 2)
      %>% DT::formatRound("HDI_STATUS", digits = 3)
    )
  
  output$historical_catches_table = 
    DT::renderDataTable(
      DT::datatable(
        ALL_CATCH_DATA, 
        class = "stripe cell-border",
        rownames = FALSE,
        escape = FALSE,
        colnames = c("Year", "Flag state", "Fleet", "Type of fishery", "Fishery", "School type", "Assigned area", "Species", "Catches"),
        options = 
          list(
            pageLength= 50,
            searching = TRUE,
            autoWidth = TRUE,
            paging    = TRUE,
            info      = TRUE
          ),
        filter = list(position = "top")
      )
      %>% DT::formatCurrency("CATCH_MT", mark = ",", digits = 2, currency = "&nbsp;t", before = FALSE)
    )
  
  
  # Baseline weight
  
  output$ba_wgt = renderText({
    paste0(format(as.numeric(input$ba_weight), nsmall = 1), "%")
  })

  # Coastal states weight
  
  output$cs_wgt = renderText({
    paste0(format(as.numeric(input$cs_weight), nsmall = 1), "%")
  })

  # Catch-based weight
  
  output$cb_wgt = renderText({
    paste0(format(as.numeric((100 - input$ba_weight - input$cs_weight)), nsmall = 1), "%")
  })
  
  # Coastal states / equal weight
  
  output$cs_eq_wgt = renderText({
    paste0(format(as.numeric(input$cs_weights[1]), nsmall = 1), "%")
  })
  
  # Coastal states / socio-economic weight
  
  output$cs_se_wgt = renderText({
    paste0(format(as.numeric((input$cs_weights[2] - input$cs_weights[1])), nsmall = 1), "%")
  })
  
  # Coastal states / NJA weight
  
  output$cs_ez_wgt = renderText({
    paste0(format(as.numeric((100 - input$cs_weights[2])), nsmall = 1), "%")
  })

  # Coastal states / socio-economic weight / option #1 / vulnerability
  
  output$cs_se_vul_wgt = renderText({
    paste0(format(as.numeric(input$cs_se_o1_weights[1]), nsmall = 1), "%")
  })
  
  # Coastal states / socio-economic weight / option #1 / priority sectors
  
  output$cs_se_pri_sec_wgt = renderText({
    paste0(format(as.numeric((input$cs_se_o1_weights[2] - input$cs_se_o1_weights[1])), nsmall = 1), "%")
  })
  
  # Coastal states / socio-economic weight / option #1 / disproportionate burden
  
  output$cs_se_dis_bur_wgt = renderText({
    paste0(format(as.numeric((100 - input$cs_se_o1_weights[2])), nsmall = 1), "%")
  })
    
  # Coastal states / socio-economic weight / option #2 / HDI
  
  output$cs_se_HDI_wgt = renderText({
    paste0(format(as.numeric(input$cs_se_o2_weights[1]), nsmall = 1), "%")
  })
  
  # Coastal states / socio-economic weight / option #2 / GNI
  
  output$cs_se_GNI_wgt = renderText({
    paste0(format(as.numeric((input$cs_se_o2_weights[2] - input$cs_se_o2_weights[1])), nsmall = 1), "%")
  })
  
  # Coastal states / socio-economic weight / option #2 / SIDS
  
  output$cs_se_SIDS_wgt = renderText({
    paste0(format(as.numeric((100 - input$cs_se_o2_weights[2])), nsmall = 1), "%")
  })
  
  prepare_output = function(input) {
    unit = input$out_unit
    
    ba_wgt = (input$ba_weight) * 0.01
    cs_wgt = (input$cs_weight) * 0.01
    cb_wgt = (1 - ba_wgt -  cs_wgt)
    
    cs_eq_wgt = (input$cs_weights[1]) * 0.01
    cs_se_wgt = (input$cs_weights[2] - input$cs_weights[1]) * 0.01
    cs_ez_wgt = (100 - input$cs_weights[2] ) * 0.01
    
    cs_se_opt = input$se_option
    
    if(cs_se_opt == "O1") {
      cs_se_option_subweights = 
        list(
          VUL_wgt     = (input$cs_se_o1_weights[1]) * 0.01,
          PRI_SEC_wgt = (input$cs_se_o1_weights[2] - input$cs_se_o1_weights[1]) * 0.01,
          DIS_BUR_wgt = (100 - input$cs_se_o1_weights[2]) * 0.01
        )
    } else {
      cs_se_option_subweights = 
        list(
          HDI_wgt  = (input$cs_se_o2_weights[1]) * 0.01,
          GNI_wgt  = (input$cs_se_o2_weights[2] - input$cs_se_o2_weights[1]) * 0.01,
          SIDS_wgt = (100 - input$cs_se_o2_weights[2]) * 0.01
        )
    }
    
    BA_ALLOCATION = baseline_allocation(CPC_DATA)
    
    CS_ALLOCATION = coastal_state_allocation(CPC_data   = CPC_DATA,
                                             CS_SE_data = CS_SE_DATA,
                                             equal_portion_weight              = cs_eq_wgt,
                                             socio_economic_weight             = cs_se_wgt,
                                             socio_economic_option            = cs_se_opt,
                                             socio_economic_option_subweights = cs_se_option_subweights,
                                             #socio_economic_weight_HDI  = cs_se_HDI_wgt,
                                             #socio_economic_weight_GNI  = cs_se_GNI_wgt,
                                             #socio_economic_weight_SIDS = cs_se_SIDS_wgt,
                                             NJA_weight                  = cs_ez_wgt)
    
    filtered_catch_data = subset_and_postprocess_catch_data(catch_data   = ALL_CATCH_DATA,
                                                            species_code = input$species,
                                                            years        = input$period[1]:input$period[2])
    average_catch_function = period_average_catch_data
    
    if(input$avg_period == "best") {
      average_catch_function = function(catches) { 
        return(best_years_average_catch_data(catches, max_num_years = input$num_years))
      }
    }
    
    CB_ALLOCATION = catch_based_allocation(CPC_data   = CPC_DATA,
                                           CS_SE_data = CS_SE_DATA,
                                           catch_data = filtered_catch_data,
                                           average_catch_function = average_catch_function,
                                           coastal_weights = c(input$cb_year01_wgt * 0.01, input$cb_year02_wgt * 0.01, input$cb_year03_wgt * 0.01,
                                                               input$cb_year04_wgt * 0.01, input$cb_year05_wgt * 0.01, input$cb_year06_wgt * 0.01,
                                                               input$cb_year07_wgt * 0.01, input$cb_year08_wgt * 0.01, input$cb_year09_wgt * 0.01,
                                                               input$cb_year10_wgt * 0.01))
    
    QUOTAS = # Scales down the resulting catches if the output unit is set to 'quota' (so as to get this as % instead)
      allocate_TAC(TAC = ifelse(unit == "quota", 1, input$tac), 
                   baseline_allocation      = BA_ALLOCATION, baseline_allocation_weight      = ba_wgt, #input$ba_wgt * 0.01,
                   coastal_state_allocation = CS_ALLOCATION, coastal_state_allocation_weight = cs_wgt, #input$cs_wgt * 0.01,
                   catch_based_allocation   = CB_ALLOCATION, catch_based_allocation_weight   = cb_wgt) #input$cb_wgt * 0.01)
 
    return(
      QUOTAS
    )
  }
  
  output$quotas_table = DT::renderDataTable({
    unit = input$out_unit
    
    QUOTAS = prepare_output(input)
    
    QUOTAS_DT = 
      DT::datatable(
        QUOTAS, 
        class = "cell-border",
        rownames = FALSE,
        escape = FALSE,
        colnames = c("CPC", paste0("Year #", c(1:10))),
        options = 
          list(
            order = list(list(1, "desc")),
            pageLength= 100,
            autoWidth = FALSE,
            paging    = FALSE,
            searching = FALSE,
            info      = TRUE
          )
      )
    
    if(unit == "quota")
      QUOTAS_DT = QUOTAS_DT %>% DT::formatPercentage(2:ncol(QUOTAS), digits = 2)
    else
      QUOTAS_DT = QUOTAS_DT %>% DT::formatCurrency(2:ncol(QUOTAS), digits = 2, currency = "&nbsp;t", before = FALSE)

    QUOTAS_NORM = QUOTAS[, 2:ncol(QUOTAS)]
    
    if(input$out_heat_style == "color") {
      if(input$out_heat_type  == "by_year") {
        for(column in colnames(QUOTAS_NORM)) {
          breaks = quantile(range(QUOTAS_NORM[[column]]), probs = seq(0, 1, .05))
          colors = round(seq(255, 40, length.out = length(breaks) + 1), 0) %>% { paste0("rgb(255, ", ., ",", ., ")") }
          
          QUOTAS_DT = 
            QUOTAS_DT %>% DT::formatStyle(column, backgroundColor = DT::styleInterval(breaks, colors))
        }
      } else if(input$out_heat_type  == "global") {
        breaks = quantile(range(QUOTAS_NORM), probs = seq(0, 1, .05))
        colors = round(seq(255, 40, length.out = length(breaks) + 1), 0) %>% { paste0("rgb(255, ", ., ",", ., ")") }
        
        QUOTAS_DT = 
          QUOTAS_DT %>% DT::formatStyle(colnames(QUOTAS_NORM), backgroundColor = DT::styleInterval(breaks, colors))
      }
    } else if(input$out_heat_style == "bar") {
      if(input$out_heat_type  == "by_year") {
        for(column in colnames(QUOTAS_NORM)) {
          QUOTAS_DT = 
            QUOTAS_DT %>% DT::formatStyle(column,
                                          background = DT::styleColorBar(range(QUOTAS_NORM[[column]]), "#FF4444"),
                                          backgroundSize = '98% 88%',
                                          backgroundRepeat = 'no-repeat',
                                          backgroundPosition = 'center')
        }
      } else if(input$out_heat_type  == "global") {
        QUOTAS_DT = 
          QUOTAS_DT %>% DT::formatStyle(colnames(QUOTAS_NORM),
                                        background = DT::styleColorBar(range(QUOTAS_NORM), "#FF4444"),
                                        backgroundSize = '98% 88%',
                                        backgroundRepeat = 'no-repeat',
                                        backgroundPosition = 'center')
      }
      
    }
    
    return(
      QUOTAS_DT
    )
  })
  
  output$download_data = downloadHandler(
    filename = function() {
      paste("TCAC13_simulation_", format(Sys.time(), "%Y_%m_%d_%H%M%S"), ".xlsx", sep = "")
    },
    content = function(file) {
      config = data.table(PARAMETER = character(), VALUE = character())
      
      config = rbind(config, as.list(c("SPECIES",      input$species)))
      config = rbind(config, as.list(c("TARGET_TAC_T", input$tac)))
      
      config = rbind(config, as.list(c("BASELINE_WEIGHT",      paste0(format(as.numeric(input$weights[1]), nsmall = 1), "%"))))
      config = rbind(config, as.list(c("COASTAL_STATE_WEIGHT", paste0(format(as.numeric((input$weights[2] - input$weights[1])), nsmall = 1), "%"))))

      config = rbind(config, as.list(c("COASTAL_STATE_EQUAL_WEIGHT",          paste0(format(as.numeric(input$cs_weights[1]), nsmall = 1), "%"))))
      config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_WEIGHT", paste0(format(as.numeric((input$cs_weights[2] - input$cs_weights[1])), nsmall = 1), "%"))))
      
      if(input$se_option == "O1") {
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION", "Option #1")))
  
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION_1_VULNERABILITY_WEIGHT",           paste0(format(as.numeric(input$cs_se_o1_weights[1]), nsmall = 1), "%"))))
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION_1_PRIORITY_SECTOR_WEIGHT",         paste0(format(as.numeric((input$cs_se_o1_weights[2] - input$cs_se_o1_weights[1])), nsmall = 1), "%"))))
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION_1_DISPROPORTIONATE_BURDEN_WEIGHT", paste0(format(as.numeric((100 - input$cs_se_o1_weights[2])), nsmall = 1), "%"))))
      } else if(input$se_option == "O2") { 
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION", "Option #2")))
        
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION_2_HDI_WEIGHT",  paste0(format(as.numeric(input$cs_se_o2_weights[1]), nsmall = 1), "%"))))
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION_2_GNI_WEIGHT",  paste0(format(as.numeric((input$cs_se_o2_weights[2] - input$cs_se_o2_weights[1])), nsmall = 1), "%"))))
        config = rbind(config, as.list(c("COASTAL_STATE_SOCIO_ECONOMIC_OPTION_2_SIDS_WEIGHT", paste0(format(as.numeric((100 - input$cs_se_o2_weights[2])), nsmall = 1), "%"))))
      }

      config = rbind(config, as.list(c("COASTAL_STATE_NJA_WEIGHT",            paste0(format(as.numeric((100 - input$cs_weights[2])), nsmall = 1), "%"))))
      
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT",                  paste0(format(as.numeric((100 - input$weights[2])), nsmall = 1), "%"))))

      config = rbind(config, as.list(c("HISTORICAL_CATCH_INTERVAL_START", input$period[1])))
      config = rbind(config, as.list(c("HISTORICAL_CATCH_INTERVAL_END",   input$period[2])))
      
      config = rbind(config, as.list(c("HISTORICAL_CATCH_AVERAGE",        ifelse(input$avg_period == "best", "Best \"n\" years", "Selected period"))))
      
      if(input$avg_period == "best")
        config = rbind(config, as.list(c("NUMBER_OF_YEARS", input$num_years)))
      
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_01", paste0(format(input$cb_year01_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_02", paste0(format(input$cb_year02_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_03", paste0(format(input$cb_year03_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_04", paste0(format(input$cb_year04_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_05", paste0(format(input$cb_year05_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_06", paste0(format(input$cb_year06_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_07", paste0(format(input$cb_year07_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_08", paste0(format(input$cb_year08_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_09", paste0(format(input$cb_year09_wgt, nsmall = 1), "%"))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_10", paste0(format(input$cb_year10_wgt, nsmall = 1), "%"))))
      
      config = rbind(config, as.list(c("OUTPUT_UNIT", input$out_unit)))
            
      quotas = prepare_output(input)
      
      if(input$out_unit == "quota") {
        quotas = 
          quotas %>% 
            dplyr::mutate_if(startsWith(names(.), "QUOTA_"), scales::percent, accuracy = 0.01)
      } else {
        quotas = 
          quotas %>% 
            dplyr::mutate_if(startsWith(names(.), "QUOTA_"), function(x) paste0(format(round(as.numeric(x), 1), nsmall = 1, big.mark = ","), " t"))
      }
 
      WB = createWorkbook()
      
      addWorksheet(WB, "CPC_REFERENCES")
      addWorksheet(WB, "COASTAL_STATE_REFERENCES")
      addWorksheet(WB, "HISTORICAL_CATCHES")
      addWorksheet(WB, "SIMULATION_CONFIGURATION")
      addWorksheet(WB, "OUTPUT_QUOTAS")
      
      writeData(WB, sheet = 1, CPC_DATA, rowNames = FALSE)
      writeData(WB, sheet = 2, CS_SE_DATA, rowNames = FALSE)
      writeData(WB, sheet = 3, ALL_CATCH_DATA[SPECIES_CODE == input$species], rowNames = FALSE)
      writeData(WB, sheet = 4, config, rowNames = FALSE)
      writeData(WB, sheet = 5, quotas, rowNames = FALSE)

      # Column widths are taken directly from Excel once all cols have been expanded to their maximum
      
      setColWidths(WB, 1, 1:9,  widths = c(5.14, 48.71, 6.86, 5.43, 8.29, 11.29, 8.29, 23, 19.86))
      setColWidths(WB, 2, 1:16, widths = c(5.14, 8.29, 10.71, 21.43, 34.71, 10.43, 30, 34.86, 28.29, 11, 8.14, 16.29, 11.14, 19.43, 11.71, 20))
      setColWidths(WB, 3, 1:9,  widths = c(4.71, 10.57, 11, 12.57, 13.29, 18.71, 15, 13.14, 9.86)) 
      setColWidths(WB, 4, 1   , widths = 56.43)
      setColWidths(WB, 5, 2:11, widths = 15.71)

      activeSheet(WB) <- 5
      
      saveWorkbook(WB, file = file, overwrite = TRUE)
    }
  )
}