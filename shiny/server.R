server = function(input, output, session) {
  output$ba_wgt = renderText({
    paste0(format(as.numeric(input$weights[1]), nsmall = 1), "%")
  })

  output$cs_wgt = renderText({
    paste0(format(as.numeric((input$weights[2] - input$weights[1])), nsmall = 1), "%")
  })

  output$cb_wgt = renderText({
    paste0(format(as.numeric((100 - input$weights[2])), nsmall = 1), "%")
  })
  
  output$cs_eq_wgt = renderText({
    paste0(format(as.numeric(input$cs_weights[1]), nsmall = 1), "%")
  })
  
  output$cs_se_wgt = renderText({
    paste0(format(as.numeric((input$cs_weights[2] - input$cs_weights[1])), nsmall = 1), "%")
  })
  
  output$cs_ez_wgt = renderText({
    paste0(format(as.numeric((100 - input$cs_weights[2])), nsmall = 1), "%")
  })
  
  output$cs_se_HDI_wgt = renderText({
    paste0(format(as.numeric(input$cs_se_weights[1]), nsmall = 1), "%")
  })
  
  output$cs_se_GNI_wgt = renderText({
    paste0(format(as.numeric((input$cs_se_weights[2] - input$cs_se_weights[1])), nsmall = 1), "%")
  })
  
  output$cs_se_SIDS_wgt = renderText({
    paste0(format(as.numeric((100 - input$cs_se_weights[2])), nsmall = 1), "%")
  })
  
  output$quotas_table = DT::renderDataTable({
    ba_wgt = (input$weights[1]) * 0.01
    cs_wgt = (input$weights[2] - input$weights[1]) * 0.01
    cb_wgt = (100 - input$weights[2] ) * 0.01
    
    cs_eq_wgt = (input$cs_weights[1]) * 0.01
    cs_se_wgt = (input$cs_weights[2] - input$cs_weights[1]) * 0.01
    cs_ez_wgt = (100 - input$cs_weights[2] ) * 0.01
    
    cs_se_HDI_wgt  = (input$cs_se_weights[1]) * 0.01
    cs_se_GNI_wgt  = (input$cs_se_weights[2] - input$cs_se_weights[1]) * 0.01
    cs_se_SIDS_wgt = (100 - input$cs_se_weights[2]) * 0.01
    
    BA_ALLOCATION = baseline_allocation(CPC_DATA)
    
    CS_ALLOCATION = coastal_state_allocation(CPC_data   = CPC_DATA,
                                             CS_SE_data = CS_SE_DATA,
                                             equal_portion_weight        = cs_eq_wgt,
                                             socio_economic_weight       = cs_se_wgt,
                                              socio_economic_weight_HDI  = cs_se_HDI_wgt,
                                              socio_economic_weight_GNI  = cs_se_GNI_wgt,
                                              socio_economic_weight_SIDS = cs_se_SIDS_wgt,
                                             EEZ_weight                  = cs_ez_wgt)
    
    filtered_catch_data = subset_and_postprocess_catch_data(catch_data   = ALL_CATCH_DATA,
                                                            species_code = input$species,
                                                            years        = input$period[1]:input$period[2])
    average_catch_function = period_average_catch_data
    
    if(input$avg_period == "BY") {
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
    
    QUOTAS = 
      allocate_TAC(TAC = input$tac, 
                   baseline_allocation      = BA_ALLOCATION, baseline_allocation_weight      = ba_wgt, #input$ba_wgt * 0.01,
                   coastal_state_allocation = CS_ALLOCATION, coastal_state_allocation_weight = cs_wgt, #input$cs_wgt * 0.01,
                   catch_based_allocation   = CB_ALLOCATION, catch_based_allocation_weight   = cb_wgt) #input$cb_wgt * 0.01)
    
    return(
      DT::datatable(
        QUOTAS, 
        class = "stripe cell-border",
        rownames = FALSE,
        escape = FALSE,
        options = 
          list(
            pageLength= 100,
            autoWidth = FALSE,
            paging    = FALSE,
            searching = FALSE,
            info      = TRUE
          )
      ) %>% DT::formatCurrency(2:ncol(QUOTAS), digits = 2, currency = "&nbsp;t", before = FALSE)
    )
  })
}