server = function(input, output, session) {
  
  # call the logout module with reactive trigger to hide/show
  logout_init <- shinyauthr::logoutServer( 
    id = "logout", 
    active = reactive(credentials()$user_auth)
  )
  
  # call login module supplying data frame, user and password cols
  # and reactive trigger
  credentials <- shinyauthr::loginServer( 
    id = "login", 
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive({
      logout_init()
    })
  )
  
  observe({
    if(credentials()$user_auth){
      shinyjs::show("main-content")
      shinyjs::hide("login-wrapper")
    }else{
      shinyjs::hide("main-content")
      shinyjs::show("login-wrapper")
    }
  })
  
  # app 
  output$main <- renderUI({
    req(credentials()$user_auth)
    tags$div(
      class = "main-container",
      conditionalPanel(
        condition = "$('html').hasClass('shiny-busy')",
        tags$div(id = "glasspane",
                 tags$div(class = "loading", "Filtering data and preparing output...")
        )
      ),
      tags$div(
        tabsetPanel(
          selected = "simulation",
          tabPanel(
            title = "Reference data",
            value = "ref_data",
            fluidRow(
              column(
                width = 3,
                h5("Select an entity"),
                uiOutput("ref_cpc_selector")
              ),
              column(
                width = 3,
                uiOutput("cpc_map_wrapper")
              ),
              column(
                width = 6,
                uiOutput("ref_cpc_card")
              )
              
            ),
            hr(),
            fluidRow(
              column(
                width = 12,
                tabsetPanel(
                  selected = "ref_data_chart",
                  type = "pills",
                  tabPanel(
                    title = "Chart",
                    value = "ref_data_chart",
                    uiOutput("ref_cpc_data_species_selector"),
                    plotly::plotlyOutput("ref_cpc_catch_plot")
                  ),
                  tabPanel(
                    title = "Data",
                    value = "ref_data_table",
                    fluidRow(
                      column(
                        width = 12,
                        DT::dataTableOutput("ref_cpc_catch_table")
                      )
                    )
                  )
                )
              )
            )
          ),
          tabPanel(
            title = "Simulation",
            value = "simulation",
            fluidRow(
              column(width = 4,
                     style = "border-right: 1px #ccc solid; background-color:#ccc;",
                     h5(strong("Parameters")),
                     hr(),
                     fluidRow(
                       column(width = 6,
                              selectInput("species", "Species", width = "100%", choices = AVAILABLE_SPECIES, selected = "YFT")
                       ),
                       column(width = 6,
                              numericInput("tac", "Target Total Allowable Catch (TAC; t)", value = 421000, min = 10000, step = 10000),
                       )
                     ),
                     
                     span(
                       sliderInput("ba_weight", label = "Baseline weight (%)",
                                   width = "100%",
                                   min = 0, max = 100, value = 0, step = .1, animate = FALSE
                       ) 
                     ), 
                     
                     span(
                       sliderInput("ds_weight", label = "Developing states weight (%)",
                                   width = "100%",
                                   min = 0, max = 100, value = 0, step = .5, animate = FALSE
                       )
                     ),
                     
                     br(),              
                     
                     strong("Baseline weight:"),      textOutput("ba_wgt", inline = TRUE),
                     strong("Developing states weight:"), textOutput("ds_wgt", inline = TRUE),
                     strong("Catch-based weight:"),   textOutput("cb_wgt", inline = TRUE),
                     
                     hr(), 
                     
                     tabsetPanel(
                       selected = "Developing states weights",
                       tabPanel(
                         "Baseline weights",
                         fluidRow(
                           column(width = 12,
                                  div(class="top-padded",
                                      strong("No configuration required")
                                  )
                           )
                         )
                       ),
                       tabPanel(
                         "Developing states weights",
                         fluidRow(
                           column(width = 12,
                                  div(class="top-padded",
                                      span(class="triple",
                                           sliderInput("ds_weights", "Developing states component weights (%)",
                                                       width = "100%",
                                                       min = 0, max = 100, value = c(35, 82.5), step = .5, sep = "", animate = FALSE
                                           )
                                      ),
                                      
                                      br(),
                                      
                                      strong("Equal weight:"),          textOutput("ds_eq_wgt", inline = TRUE),
                                      strong("Least-Developed Country weight:"), textOutput("ds_ldc_wgt", inline = TRUE),
                                      strong("SIDS weight:"),            textOutput("ds_sids_wgt", inline = TRUE),
                                      hr()
                                  )
                           )
                         )
                       ),
                       tabPanel(
                         "Catch-based weights",
                         div(class="top-padded", 
                             sliderInput("period", "Historical catch interval", 
                                         width = "100%",
                                         min = AVAILABLE_YEARS$MIN, 
                                         max = AVAILABLE_YEARS$MAX, 
                                         value = range(2000, 2016),
                                         step = 1, sep = "", animate = FALSE
                             ),
                             fluidRow(
                               column(width = 6,
                                      selectInput ("avg_period", "Historical catch average", width = "100%", choices = AVAILABLE_HISTORICAL_CATCH_AVERAGE_PERIODS, selected = "PE")
                               ), 
                               column(width = 6,
                                      conditionalPanel(
                                        condition = "input.avg_period == 'best'",                           
                                        numericInput("num_years", "Number of years", value = 5, min = 1, max = 60, step = 1)
                                      )
                               )
                             ),  
                             
                             hr(class = "thin"),
                             
                             strong("Coastal state EEZ attribution weights (%)"),
                             
                             hr(),
                             
                             fluidRow(
                               column(width = 2,
                                      numericInput("cb_year01_wgt", "Year #1", value =  10, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year02_wgt", "Year #2", value =  20, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year03_wgt", "Year #3", value =  30, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year04_wgt", "Year #4", value =  40, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year05_wgt", "Year #5", value =  50, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year06_wgt", "Year #6", value =  60, min = 0, max = 100, step = 5)
                               )
                             ),
                             fluidRow(
                               column(width = 2,
                                      numericInput("cb_year07_wgt", "Year #7", value =  70, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year08_wgt", "Year #8", value =  80, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year09_wgt", "Year #9", value =  90, min = 0, max = 100, step = 5)
                               ),
                               column(width = 2,
                                      numericInput("cb_year10_wgt", "Year #10", value = 100, min = 0, max = 100, step = 5)
                               )
                             ),
                             
                             hr(class = "thin")
                             
                         )
                       )
                     )
              ),
              column(width = 8,
                     h5(strong("Results")),
                     hr(),
                     tabsetPanel(
                       selected = "simu_all_entities",
                       tabPanel(
                         title = "All entities",
                         value = "simu_all_entities",
                         fluidRow(
                           column(
                             width = 3,
                             selectInput("out_unit", "Output unit", width = "100%", choices = AVAILABLE_OUTPUT_UNITS, selected = "quota")
                           ),
                           column(
                             width = 3,
                             selectInput("out_heat_style", "Heatmap style", width = "100%", choices = AVAILABLE_HEATMAP_STYLES, selected = "color")
                           ),
                           column(
                             width = 2,
                             selectInput("out_heat_type",  "Heatmap type", width = "100%", choices = AVAILABLE_HEATMAP_TYPES, selected = "global")
                           ),
                           column(
                             width = 4,
                             div(
                               class="button-padded",
                               downloadButton("download_data", "Download", icon=icon("table")),
                               downloadButton("report_full","Download full report",icon=icon("download"))
                             )
                           )
                         ),
                         fluidRow(
                           column(width = 12,
                            tabsetPanel(
                              type = "pills",
                              vertical = TRUE,
                              selected = "simu_all_entities_total",
                              tabPanel(
                                title = tags$b("Total allocation"),
                                value = "simu_all_entities_total",
                                DT::dataTableOutput("all_entities_quotas_table")
                              ),
                              tabPanel(
                                title = "Baseline weight allocation",
                                value = "simu_all_entities_ba",
                                icon = icon("angle-right"),
                                DT::dataTableOutput("all_entities_ba_alloc_table")
                              ),
                              tabPanel(
                                title = "Developing states weight allocation",
                                value = "simu_all_entities_ds",
                                icon = icon("angle-right"),
                                DT::dataTableOutput("all_entities_ds_alloc_table")
                              ),
                              tabPanel(
                                title = "Catch-based weight allocation",
                                value = "simu_all_entities_cb",
                                icon = icon("angle-right"),
                                DT::dataTableOutput("all_entities_cb_alloc_table")
                              )
                            )
                           )
                         )
                       ),
                       tabPanel(
                         title = "By entity",
                         value = "simu_by_entity",
                         h5("Select an entity"),
                         fluidRow(
                           column(width = 3,
                            uiOutput("report_by_entity_selector")
                           ),
                           column(width = 3,
                            uiOutput("report_by_entity_download_wrapper")     
                           )
                         ),
                         fluidRow(
                           column(
                             width = 12,
                             tabsetPanel(
                               type = "pills",
                               vertical = TRUE,
                               selected = "simu_by_entity_total",
                               tabPanel(
                                 title = tags$b("Total allocation"),
                                 value = "simu_by_entity_total",
                                 uiOutput("simu_entity_total_allocations")
                               ),
                               tabPanel(
                                 title = "Details",
                                 value = "simu_by_entity_details",
                                 icon = icon("angle-right"),
                                 uiOutput("simu_entity_detailed_allocations")
                               )
                             )
                             
                           )
                         )
                       )
                     )
              )
            )
          )
        )
      )
    )

  })
  
  #REFERENCE DATA
  #reactives
  selected_cpc <- reactive({
    req(input$ref_cpc)
    filter(ENTITIES, CODE == input$ref_cpc) %>% slice(1)
  })
  selected_cpc_catches <- reactive({
    req(input$ref_cpc)
    catch_selected <- ALL_CATCH_DATA[ALL_CATCH_DATA$FLEET_CODE == input$ref_cpc]
    catch_selected[ASSIGNED_AREA == "HIGH_SEAS", ORIGIN := "High Seas"]
    catch_selected[ASSIGNED_AREA == paste0("NJA_", FLEET_CODE), ORIGIN := "Own NJA"]
    catch_selected[ASSIGNED_AREA != paste0("NJA_", FLEET_CODE) & ASSIGNED_AREA != "HIGH_SEAS", ORIGIN := "Foreign NJAs"]
    catch_selected
  })
  selected_cpc_species_catches <- reactive({
    req(input$ref_cpc)
    req(input$ref_cpc_data_species)
    selected_cpc_catches()[SPECIES_CODE == input$ref_cpc_data_species]
  })
  
  #report by CPC
  output$ref_cpc_selector = renderUI({
    selectizeInput("ref_cpc", label = NULL, selected = NULL, multiple = FALSE, 
                   choices = {
                     entity_choices <- ENTITIES$CODE
                     setNames(entity_choices, ENTITIES$NAME_EN)
                   },options = list( 
                     render = I("{
                      item: function(item, escape) {
                        var icon_href = 'https://raw.githubusercontent.com/fdiwg/flags/release/40/'+item.value.toLowerCase()+'.png';
                        return '<div><img src=\"'+icon_href+'\" height=16 width=28 style=\"margin-bottom:3px\" /> ' + item.label + '</div>'; 
                      },
                      option: function(item, escape) { 
                        var icon_href = 'https://raw.githubusercontent.com/fdiwg/flags/release/40/'+item.value.toLowerCase()+'.png';
                        return '<div><img src=\"'+icon_href+'\" height=16 width=28 style=\"margin-bottom:3px\" /> ' + item.label + '</div>'; 
                      }
                    }"
                     ),
                     placeholder = "Please Select an entity",
                     onInitialize = I('function() { this.setValue(""); }')
                   )
    )
  })
  #chart species selector
  output$ref_cpc_data_species_selector = renderUI({
    req(input$ref_cpc)
    if(!is.null(input$ref_cpc) & input$ref_cpc != ""){
      req(!is.null(selected_cpc_catches()))
      tagList(
        h5("Select a species"),
        selectizeInput("ref_cpc_data_species", label = NULL, selected = NULL, multiple = FALSE, 
                     width = 350,
                     choices = NULL,
                     options = list(
                       options = {
                         entity_choices <- unique(selected_cpc_catches()$SPECIES_CODE)
                         entity_choices <- entity_choices[order(entity_choices)]
                         entity_names = fdi4R::cl_asfis_species[fdi4R::cl_asfis_species$code %in% entity_choices,]
                         species = data.frame(
                           code = entity_choices,
                           label_en = entity_names[order(entity_names$code),]$label,
                           sciname = entity_names[order(entity_names$code),]$definition,
                           stringsAsFactors = FALSE
                         )
                         lapply(seq_len(nrow(species)), function(i) {
                           as.list(species[i, ])
                         })
                       },
                       valueField  = "code",
                       labelField  = "label_en",
                       searchField = c("code", "label_en", "sciname"),
                       render = I("{
                          item: function(item, escape) {
                            var icon_href = 'species/'+item.code+'.png';
                            return '<div>' + item.label_en + ' – <em>' + item.sciname + '</em> <img src=\"'+icon_href+'\" height=30 style=\"margin-bottom:3px;float:right;\" /></div>'; 
                          },
                          option: function(item, escape) {
                            var icon_href = 'species/'+item.code+'.png';
                            return '<div>' + item.label_en + ' – <em>' + item.sciname + '</em> <img src=\"'+icon_href+'\" height=30 style=\"margin-bottom:3px;float:right;\" /></div>'; 
                          }
                        }"
                       ),
                       placeholder = "Please select a species",
                       onInitialize = I('function() { this.setValue(""); }')
                     )
        )
      )
    }else{
      tags$p(tags$em("Select an entity to get information"))
    }
  })
  
  output$ref_cpc_card <- renderUI({
    req(input$ref_cpc)
    if(!is.null(input$ref_cpc) & input$ref_cpc != ""){
      bs4Dash::bs4Card(
        title = tagList(
          img(src = sprintf("https://raw.githubusercontent.com/fdiwg/flags/release/80/%s.png", tolower(input$ref_cpc)), width = "80px"),
          tags$b(selected_cpc()$NAME_EN)
        ),
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        width = 12,
        tagList(
          fluidRow(
            bs4Dash::infoBox(
              title = "Status",
              icon = switch(as.character(selected_cpc()$STATUS_CODE),
                "CP" = icon("landmark"),
                "FE" = icon("ship")
              ),
              color = "info",
              width = 12,
              value = tags$b(selected_cpc()$STATUS)
            )
          ),
          fluidRow(
            bs4Dash::infoBox(
              title = "Coastal State ?",
              width = 6,
              color = "primary",
              value = if(selected_cpc()$IS_COASTAL) tags$b("Yes") else tags$b("No")
            ),
            bs4Dash::infoBox(
              title = "Developing State ?",
              width = 6,
              color = "gray-dark",
              value = if(selected_cpc()$IS_DEVELOPING) tags$b("Yes") else tags$b("No")
            )
          ),
          fluidRow(
            bs4Dash::infoBox(
              title = "Least-Developed country (LDC) ?",
              width = 6,
              color = "maroon",
              value = if(selected_cpc()$IS_LDC) tags$b("Yes") else tags$b("No")
            ),
            bs4Dash::infoBox(
              title = "Small Island Developing State (SIDS) ?",
              width = 6,
              color = "fuchsia",
              value = if(selected_cpc()$IS_SIDS) tags$b("Yes") else tags$b("No")
            )
          )
        )
      )
    }else{
      NULL
    }
  })
  
  output$ref_cpc_characteristics <- renderUI({
    req(input$ref_cpc)
    if(!is.null(input$ref_cpc) & input$ref_cpc != ""){
      tagList(
      
              tags$li(tags$p("Name: ", tags$b(selected_cpc()$NAME_EN))),
              tags$li(tags$p("Name (French): ", tags$b(selected_cpc()$NAME_FR))),
              tags$li(tags$p("Status: ", tags$b(selected_cpc()$STATUS))),
              tags$li(tags$p("SIDS?: ", if(selected_cpc()$IS_SIDS) tags$b("Yes") else tags$b("No")))
      )
    }else{
      tags$p(tags$em("Select an entity to get information"))
    }
  })
  
  output$cpc_map_wrapper <- renderUI({
    leafletOutput("cpc_map", height = 375, width = 400)
  })
  
  output$cpc_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addLayersControl(
        overlayGroups = c("Country/Territory boundaries", "Coastline","NJA part in Indian Ocean", "Overlapping claim part in Indian Ocean"),
        options = layersControlOptions(collapsed = T)
      )
  })
  
  observeEvent(input$ref_cpc, {
    req(input$ref_cpc)
    
    #MAP
    #sf data
    country_polys = fdi4R::un_countries
    country_lines = fdi4R::un_boundaries
    
    #polygon selection
    cpc_admin <- country_polys[country_polys$ISO_3 == input$ref_cpc, ]
    
    # Filter lines for the chosen country (exclude type==6)
    filtered <- country_lines %>%
      dplyr::filter(
        TYPE != 6,
        ISO3_CNT1 == input$ref_cpc | ISO3_CNT2 == input$ref_cpc
      )
    
    #NJA
    njas = fdi4R::wja_level1__x__iotc_indian_ocean_areas[fdi4R::wja_level1__x__iotc_indian_ocean_areas$code2 == "IO_ALL",]
    wja1 = fdi4R::wja_level1 %>% as.data.frame()
    njas = njas %>% dplyr::left_join(wja1, by = dplyr::join_by(code1 == code))
    nja_claims = njas[njas$type == "Overlapping claim",]
    njas = njas[njas$type == "Jurisdiction Area",]
    cpc_nja = njas[regexpr(input$ref_cpc, njas$code1) > 0,] %>% sf::st_collection_extract()
    cpc_nja_claims = nja_claims[regexpr(input$ref_cpc, nja_claims$code1) > 0,] %>% sf::st_collection_extract()
    
    # Mutually exclusive styling classes
    coastal_lines <- filtered %>% dplyr::filter(TYPE %in% c(0))
    dotted_lines <- filtered %>% dplyr::filter(TYPE %in% c(4, 8, 9))
    dashed_lines  <- filtered %>% dplyr::filter(TYPE %in% c(2, 3) & !TYPE %in% c(8, 9))
    solid_lines   <- filtered %>% dplyr::filter(!TYPE %in% c(0, 2, 3, 4, 8, 9))
    
    proxy <- leafletProxy("cpc_map") %>%
      clearGroup("Country/Territory boundaries") %>%
      clearGroup("Coastline") %>%
      clearGroup("NJA part in Indian Ocean") %>%
      clearGroup("Overlapping claim part in Indian Ocean")
    
    # Ppolygon FIRST
    if (nrow(cpc_admin) > 0) {
      proxy <- proxy %>%
        addPolygons(
          data = cpc_admin,
          group = "Country/Territory boundaries",
          fillColor = "grey",
          fillOpacity = 0.6,
          color = "#00000000", # transparent stroke
          weight = 0
        )
    }
    if (nrow(solid_lines) > 0) {
      proxy <- proxy %>%
        addPolylines(
          data = solid_lines,
          group = "Country/Territory boundaries",
          color = "black", weight = 2, opacity = 1
        )
    }
    if (nrow(dashed_lines) > 0) {
      proxy <- proxy %>%
        addPolylines(
          data = dashed_lines,
          group = "Country/Territory boundaries",
          color = "black", weight = 2, opacity = 1,
          dashArray = "8,8"
        )
    }
    if (nrow(dotted_lines) > 0) {
      proxy <- proxy %>%
        addPolylines(
          data = dotted_lines,
          group = "Country/Territory boundaries",
          color = "black", weight = 2, opacity = 1,
          dashArray = "1, 6"
        )
    }
    if (nrow(coastal_lines) > 0) {
      proxy <- proxy %>%
        addPolylines(
          data = coastal_lines,
          group = "Coastline",
          color = "darkblue", weight = 1, opacity = 1
        )
    }
    
    # Zoom to selection if we have features
    if (nrow(filtered) > 0) {
      #bb <- do.call(sf::st_bbox, lapply(list(filtered, cpc_admin, cpc_nja), sf::st_bbox))
      bb <- if(nrow(cpc_nja)>0) sf::st_bbox(cpc_nja) else sf::st_bbox(filtered)
      proxy %>% fitBounds(
        lng1 = as.numeric(bb["xmin"]), lat1 = as.numeric(bb["ymin"]),
        lng2 = as.numeric(bb["xmax"]), lat2 = as.numeric(bb["ymax"])
      )
    }
    # NJA (intersect with Indian Ocean)?
    if (nrow(cpc_nja) > 0){
      proxy <- proxy %>%
        addPolygons(
          data = cpc_nja,
          fillColor = "#22a4e6",
          fillOpacity = 0.8,
          group = "NJA part in Indian Ocean",
          color = "white", # transparent stroke
          weight = 0
        )
    }
    # NJA Overlapping claim (intersect with Indian Ocean)?
    if (nrow(cpc_nja_claims) > 0){
      proxy <- proxy %>%
        addPolygons(
          data = cpc_nja_claims,
          fillColor = "orange",
          fillOpacity = 0.8,
          group = "Overlapping claim part in Indian Ocean",
          color = "white", # transparent stroke
          weight = 0
        )
    }
    
    proxy <- proxy %>%
      removeControl(layerId = "WJA") %>%
      addLegend(
        layerId = "WJA",
        "bottomright", 
        colors = c("#22a4e6","orange"), 
        labels = c("Jurisdiction Area","Overlapping Claim"),
        values = NULL
      )
    
  }, ignoreInit = FALSE)
  
  output$ref_cpc_catch_plot <- plotly::renderPlotly({
    req(input$ref_cpc_data_species)
    req(!is.null(selected_cpc_catches()))
    plotly::plot_ly(selected_cpc_species_catches(), x = ~YEAR, y = ~CATCH_MT, type = 'bar', split = ~ORIGIN) %>% 
      plotly::layout(
        xaxis = list(title = ""), 
        yaxis = list(title = 'Total catch (t)', tickformat = ",.0f"), 
        colorway = RColorBrewer::brewer.pal(3, "Set1"),
        barmode = 'stack', 
        legend = list(
          orientation = "h", 
          x = 0.5, 
          y = -0.05, 
          xanchor = "center", 
          yanchor = "top"
        )
    )
  })
  
  output$ref_cpc_catch_table = DT::renderDataTable({
    req(input$ref_cpc)
    DT::datatable(
      selected_cpc_catches(),
      class = "stripe cell-border",
      rownames = FALSE,
      escape = FALSE,
      colnames = c("Year", "Flag state", "entity", "Type of fishery", "Fishery", "School type", "Assigned area", "Species", "Catches", "Water Jurisdiction Area"),
      options =
        list(
          autoWidth = FALSE,
          dom = 'Bfrtip',
          deferRender = TRUE,
          scroll = FALSE,
          pageLength= 10,
          searching = TRUE,
          autoWidth = TRUE,
          paging    = TRUE,
          info      = TRUE,
          buttons = list(
            list(extend = 'copy'),
            list(extend = 'csv', filename = sprintf("IOTC_TCAC_Historical_Catches_for_%s_species_%s.csv", input$ref_cpc, input$ref_cpc_data_species) , title = NULL, header = TRUE),
            list(extend = 'excel', filename =  sprintf("IOTC_TCAC_Historical_Catches_for_%s_species_%s.xlsx", input$ref_cpc, input$ref_cpc_data_species), title = NULL, header = TRUE),
            list(extend = "pdf", title = sprintf("IOTC_TCAC_Historical_Catches_for_%s_species_%s.pdf", input$ref_cpc, input$ref_cpc_data_species), header = TRUE, orientation = "landscape")
          )
        ),
      filter = list(position = "top")
    ) %>% DT::formatCurrency("CATCH_MT", mark = ",", digits = 2, currency = "", before = FALSE)
  })
  
  # Baseline weight
  
  output$ba_wgt = renderText({
    formatToPercent(input$ba_weight)
  })
  
  # Developing states weight
  
  output$ds_wgt = renderText({
    formatToPercent(input$ds_weight)
  })

  # Catch-based weight
  
  output$cb_wgt = renderText({
    formatToPercent(100 - input$ba_weight - input$ds_weight)
  })
  
  # Developing states / equal weight
  
  output$ds_eq_wgt = renderText({
    formatToPercent(input$ds_weights[1])
  })
  
  # Developing states / LDC weight
  
  output$ds_ldc_wgt = renderText({
    formatToPercent(input$ds_weights[2] - input$ds_weights[1])
  })
  
  # Developing states / SIDS weight
  
  output$ds_sids_wgt = renderText({
    formatToPercent(100 - input$ds_weights[2])
  })
  
  #compute_allocation
  compute_allocation = function(input) {
    unit = input$out_unit
    
    #input tac
    tac = input$tac
    
    #input weights
    ba_wgt = (input$ba_weight) * 0.01
    ds_wgt = (input$ds_weight) * 0.01
    cb_wgt = (1 - ba_wgt -  ds_wgt)
    ds_eq_wgt = (input$ds_weights[1]) * 0.01
    ds_ldc_wgt = (input$ds_weights[2] - input$ds_weights[1]) * 0.01
    ds_sids_wgt = (100 - input$ds_weights[2]) * 0.01
    
    #Baseline allocation
    BA_ALLOCATION = baseline_allocation(CPC_data)
    BA_ALLOCATION[, BA_TAC := ifelse(unit == "quota", 1, tac) * BASELINE_ALLOCATION * ba_wgt]
    
    #Developing state allocation
    DS_ALLOCATION = developing_state_allocation(
      CPC_data   = CPC_data,
      equal_portion_weight = ds_eq_wgt,
      ldc_weight = ds_ldc_wgt,
      sids_weight = ds_sids_wgt
    )
    DS_ALLOCATION[, DS_TAC := ifelse(unit == "quota", 1, tac) * DEVELOPING_STATE_ALLOCATION * ds_wgt]
    
    filtered_catch_data = subset_and_postprocess_catch_data(catch_data   = ALL_CATCH_DATA,
                                                            species_code = input$species,
                                                            years        = input$period[1]:input$period[2],
                                                            onlyHS = FALSE)
    average_catch_function = period_average_catch_data
    
    if(input$avg_period == "best") {
      average_catch_function = function(catches) { 
        return(best_years_average_catch_data(catches, max_num_years = input$num_years))
      }
    }
    
    #Catch-based allocation
    CB_ALLOCATION = catch_based_allocation(CPC_data   = ENTITIES,
                                           catch_data = filtered_catch_data,
                                           average_catch_function = average_catch_function,
                                           coastal_weights = c(input$cb_year01_wgt * 0.01, input$cb_year02_wgt * 0.01, input$cb_year03_wgt * 0.01,
                                                               input$cb_year04_wgt * 0.01, input$cb_year05_wgt * 0.01, input$cb_year06_wgt * 0.01,
                                                               input$cb_year07_wgt * 0.01, input$cb_year08_wgt * 0.01, input$cb_year09_wgt * 0.01,
                                                               input$cb_year10_wgt * 0.01))
    
    QUOTAS = # Scales down the resulting catches if the output unit is set to 'quota' (so as to get this as % instead)
      allocate_TAC(TAC = ifelse(unit == "quota", 1, input$tac), 
                   baseline_allocation      = BA_ALLOCATION, baseline_allocation_weight      = ba_wgt, #input$ba_wgt * 0.01,
                   developing_state_allocation = DS_ALLOCATION, developing_state_allocation_weight = ds_wgt, #input$ds_wgt * 0.01,
                   catch_based_allocation   = CB_ALLOCATION, catch_based_allocation_weight   = cb_wgt) #input$cb_wgt * 0.01)
    
    #set after quota to avoid propagating these columns (used for Catch-based intermediate result display)
    CB_ALLOCATION[, CB_TAC_1 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_1]
    CB_ALLOCATION[, CB_TAC_2 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_2]
    CB_ALLOCATION[, CB_TAC_3 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_3]
    CB_ALLOCATION[, CB_TAC_4 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_4]
    CB_ALLOCATION[, CB_TAC_5 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_5]
    CB_ALLOCATION[, CB_TAC_6 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_6]
    CB_ALLOCATION[, CB_TAC_7 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_7]
    CB_ALLOCATION[, CB_TAC_8 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_8]
    CB_ALLOCATION[, CB_TAC_9 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_9]
    CB_ALLOCATION[, CB_TAC_10 := ifelse(unit == "quota",1,tac) * cb_wgt * CATCH_BASED_ALLOCATION_YEAR_10]
    
    outputs = list(
      BA_ALLOCATION = BA_ALLOCATION,
      DS_ALLOCATION = DS_ALLOCATION,
      CB_ALLOCATION = CB_ALLOCATION,
      QUOTAS = QUOTAS,
      UNIT = unit
    )
    
    return(outputs)
  }
  
  #prepare_allocation_datatable
  prepare_allocation_datatable = function(allocation, component, unit){
    
    dt_alloc = allocation[[component]]
    if(component != "QUOTAS"){
      dt_alloc = dt_alloc[, .SD, .SDcols = colnames(dt_alloc) == "CPC_CODE" |
                            grepl("TAC", colnames(dt_alloc))]
    }
    dt_alloc_basenames = colnames(dt_alloc)
    dt_alloc = base::merge(dt_alloc, CPC_data[, .(CODE, STATUS_CODE, NAME_EN, NAME_FR)], by.x = "CPC_CODE", by.y = "CODE")
    dt_alloc = dt_alloc[, .SD, .SDcols = c("NAME_EN", dt_alloc_basenames[dt_alloc_basenames != "CPC_CODE"])]
    
    allocation_dt = DT::datatable(
      dt_alloc, 
      class = "cell-border",
      rownames = FALSE,
      escape = FALSE,
      colnames = c(
        "CPC", 
        if(component %in% c("CB_ALLOCATION", "QUOTAS")){
          paste0("Year #", c(1:10))
        } else{
          "TAC"
        }
      ),
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
      allocation_dt = allocation_dt %>% DT::formatPercentage(2:ncol(dt_alloc), digits = 2)
    else
      allocation_dt = allocation_dt %>% DT::formatCurrency(2:ncol(dt_alloc), digits = 0, currency = "", before = FALSE)
    
    alloc_NORM = dt_alloc[, 2:ncol(dt_alloc)]
    
    if(input$out_heat_style == "color") {
      if(input$out_heat_type  == "by_year") {
        for(column in colnames(alloc_NORM)) {
          breaks = quantile(range(alloc_NORM[[column]]), probs = seq(0, 1, .05))
          colors = colorRampPalette(c("#ffffff", "#17a2b8"))(length(breaks) + 1)
          
          allocation_dt = 
            allocation_dt %>% DT::formatStyle(column, backgroundColor = DT::styleInterval(breaks, colors))
        }
      } else if(input$out_heat_type  == "global") {
        breaks = quantile(range(alloc_NORM), probs = seq(0, 1, .05))
        colors = colorRampPalette(c("#ffffff", "#17a2b8"))(length(breaks) + 1)
        
        allocation_dt = 
          allocation_dt %>% DT::formatStyle(colnames(alloc_NORM), backgroundColor = DT::styleInterval(breaks, colors))
      }
    } else if(input$out_heat_style == "bar") {
      if(input$out_heat_type  == "by_year") {
        for(column in colnames(alloc_NORM)) {
          allocation_dt = 
            allocation_dt %>% DT::formatStyle(column,
                                          background = DT::styleColorBar(range(alloc_NORM[[column]]), "#17a2b8"),
                                          backgroundSize = '98% 88%',
                                          backgroundRepeat = 'no-repeat',
                                          backgroundPosition = 'center')
        }
      } else if(input$out_heat_type  == "global") {
        allocation_dt = 
          allocation_dt %>% DT::formatStyle(colnames(alloc_NORM),
                                        background = DT::styleColorBar(range(alloc_NORM), "#17a2b8"),
                                        backgroundSize = '98% 88%',
                                        backgroundRepeat = 'no-repeat',
                                        backgroundPosition = 'center')
      }
      
    }
    return(allocation_dt)
  }
  
  computed_allocation <- reactive({
    compute_allocation(input)
  })
  computed_allocation_for_entity <- reactive({
    req(input$reporting_entity)
    if(!is.null(input$reporting_entity) & input$reporting_entity != ""){
      result = lapply(computed_allocation()[1:4], function(x){
        x[CPC_CODE == input$reporting_entity,]
      })
      names(result) = names(computed_allocation())[1:4]
      result$UNIT = computed_allocation()$UNIT
      result
    }else{
      NULL
    }
  })
  
  output$all_entities_quotas_table = DT::renderDataTable({
    unit = input$out_unit
    prepare_allocation_datatable(computed_allocation(), "QUOTAS", unit)
  })
  
  output$all_entities_ba_alloc_table = DT::renderDataTable({
    unit = input$out_unit
    prepare_allocation_datatable(computed_allocation(), "BA_ALLOCATION", unit)
  })
  
  output$all_entities_ds_alloc_table = DT::renderDataTable({
    unit = input$out_unit
    prepare_allocation_datatable(computed_allocation(), "DS_ALLOCATION", unit)
  })
  
  output$all_entities_cb_alloc_table = DT::renderDataTable({
    unit = input$out_unit
    prepare_allocation_datatable(computed_allocation(), "CB_ALLOCATION", unit)
  })
  
  #download table as EXCEL
  output$download_data = downloadHandler(
    filename = function() {
      paste("TCAC_simulation_", format(Sys.time(), "%Y_%m_%d_%H%M%S"), ".xlsx", sep = "")
    },
    content = function(file) {
      
      config = data.table(PARAMETER = character(), VALUE = character())
      
      config = rbind(config, as.list(c("SPECIES",      input$species)))
      config = rbind(config, as.list(c("TARGET_TAC_T", input$tac)))
      
      config = rbind(config, as.list(c("BASELINE_WEIGHT",      formatToPercent(input$ba_weight))))
      config = rbind(config, as.list(c("DEVELOPING_STATE_WEIGHT", formatToPercent(input$ds_weight))))
      config = rbind(config, as.list(c("DEVELOPING_STATE_EQUAL_WEIGHT",          formatToPercent(input$ds_weights[1]))))
      config = rbind(config, as.list(c("DEVELOPING_STATE_SOCIO_ECONOMIC_WEIGHT", formatToPercent(input$ds_weights[2] - input$ds_weights[1]))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT",                  formatToPercent(100 - input$ba_weight - input$cs_weight))))
      
      config = rbind(config, as.list(c("HISTORICAL_CATCH_INTERVAL_START", input$period[1])))
      config = rbind(config, as.list(c("HISTORICAL_CATCH_INTERVAL_END",   input$period[2])))
      config = rbind(config, as.list(c("HISTORICAL_CATCH_AVERAGE",        ifelse(input$avg_period == "best", "Best \"n\" years", "Selected period"))))
      
      if(input$avg_period == "best")
        config = rbind(config, as.list(c("NUMBER_OF_YEARS", input$num_years)))
      
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_01", formatToPercent(input$cb_year01_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_02", formatToPercent(input$cb_year02_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_03", formatToPercent(input$cb_year03_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_04", formatToPercent(input$cb_year04_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_05", formatToPercent(input$cb_year05_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_06", formatToPercent(input$cb_year06_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_07", formatToPercent(input$cb_year07_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_08", formatToPercent(input$cb_year08_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_09", formatToPercent(input$cb_year09_wgt))))
      config = rbind(config, as.list(c("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_10", formatToPercent(input$cb_year10_wgt))))
      
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
      
      writeData(WB, sheet = 1, ENTITIES, rowNames = FALSE)
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
  
  #download report as PDF
  output$report_full = downloadHandler(
    filename = function() {
      paste("TCAC_simulation_", format(Sys.time(), "%Y_%m_%d_%H%M%S"), ".docx", sep = "")
    },
    content = function(file) {
      
      REPORTING_ENTITY = NULL
      
      BASELINE_WEIGHT = as.numeric(input$ba_weight)/100
      DEVELOPING_STATE_WEIGHT = as.numeric(input$ds_weight)/100
      DS_EQUAL_WEIGHT = as.numeric(input$ds_weights[1])/100
      DS_LDC_WEIGHT = as.numeric((input$ds_weights[2] - input$ds_weights[1]))/100
      DS_SIDS_WEIGHT = as.numeric((100 - input$ds_weights[2]))/100
      CATCH_BASED_WEIGHT = as.numeric((100 - input$ba_weight - input$ds_weight))/100
      
      SPECIES_CODE_SELECTED = input$species
      SPECIES_SELECTED = SPECIES_TABLE[SPECIES_CODE == SPECIES_CODE_SELECTED, SPECIES]
      TARGET_TAC_T = input$tac
      HISTORICAL_CATCH_INTERVAL_START = input$period[1]
      HISTORICAL_CATCH_INTERVAL_END = input$period[2]
      HISTORICAL_CATCH_AVERAGE = period_average_catch_data
      HISTORICAL_CATCH_METHOD = ifelse(sum(nchar(deparse(HISTORICAL_CATCH_AVERAGE)))>200, "Best \"n\" years", "Selected period")
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_01 = input$cb_year01_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_02 = input$cb_year02_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_03 = input$cb_year03_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_04 = input$cb_year04_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_05 = input$cb_year05_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_06 = input$cb_year06_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_07 = input$cb_year07_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_08 = input$cb_year08_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_09 = input$cb_year09_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_10 = input$cb_year10_wgt/100
      ALLOCATION_TRANSITION = sapply(1:10, function(x){ eval(parse(text = paste0("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_", sprintf("%02d",x)))) })
      OnlyHS = FALSE
      
      # Source the R allocation scripts
      source("./initialisation/05_SCENARIO_ALLOCATION_COMPUTATION.R", local = TRUE)
      source("./initialisation/06_SCENARIO_ALLOCATION_TABLES.R", local = TRUE)
      
      # General report (DOCX format)
      #out_file = paste0(unlist(strsplit(file, "\\."))[1], ".docx")
      file.copy("./rmd", tempdir(), recursive = TRUE, overwrite = TRUE)
      rmarkdown::render(
        file.path(tempdir(), "rmd", "00_A_SINGLE_SIMULATION_ALL_CPCS.Rmd"),
        output_file = file
      )
      
      # Convert report to PDF
      # wordApp = COMCreate("Word.Application") #creates COM object
      # wordApp[["Documents"]]$Open(Filename = out_file) #opens your docx in wordApp
      # wordApp[["ActiveDocument"]]$SaveAs(file, FileFormat = 17) #saves as PDF
      # wordApp[["ActiveDocument"]]$Close(SaveChanges = TRUE) #Closes the docx
      # wordApp$Quit() #quits the COM Word application
      # rm(list = "wordApp")
      
    })
  
  #report by entity
  output$report_by_entity_selector = renderUI({
    selectizeInput("reporting_entity", label = NULL, selected = NULL, multiple = FALSE, 
                   choices = {
                     entity_choices <- CPC_data$CODE
                     setNames(entity_choices, CPC_data$NAME_EN)
                   },options = list( 
                     render = I("{
                      item: function(item, escape) {
                        var icon_href = 'https://raw.githubusercontent.com/fdiwg/flags/release/40/'+item.value.toLowerCase()+'.png';
                        return '<div><img src=\"'+icon_href+'\" height=16 width=28 style=\"margin-bottom:3px\" /> ' + item.label + '</div>'; 
                      },
                      option: function(item, escape) { 
                        var icon_href = 'https://raw.githubusercontent.com/fdiwg/flags/release/40/'+item.value.toLowerCase()+'.png';
                        return '<div><img src=\"'+icon_href+'\" height=16 width=28 style=\"margin-bottom:3px\" /> ' + item.label + '</div>'; 
                      }
                    }"
                     ),
                     placeholder = "Please select a reporting entity",
                     onInitialize = I('function() { this.setValue(""); }')
                   )
    )
  })
  #download report as PDF
  output$report_by_entity_download = downloadHandler(
    filename = function() {
      paste("TCAC_simulation_", input$reporting_entity, "_", format(Sys.time(), "%Y_%m_%d_%H%M%S"), ".docx", sep = "")
    },
    content = function(file) {
      
      REPORTING_ENTITY = input$reporting_entity
      
      BASELINE_WEIGHT = as.numeric(input$ba_weight)/100
      DEVELOPING_STATE_WEIGHT = as.numeric(input$ds_weight)/100
      DS_EQUAL_WEIGHT = as.numeric(input$ds_weights[1])/100
      DS_LDC_WEIGHT = as.numeric((input$ds_weights[2] - input$ds_weights[1]))/100
      DS_SIDS_WEIGHT = as.numeric((100 - input$ds_weights[2]))/100
      CATCH_BASED_WEIGHT = as.numeric((100 - input$ba_weight - input$ds_weight))/100
      
      SPECIES_CODE_SELECTED = input$species
      SPECIES_SELECTED = SPECIES_TABLE[SPECIES_CODE == SPECIES_CODE_SELECTED, SPECIES]
      TARGET_TAC_T = input$tac
      HISTORICAL_CATCH_INTERVAL_START = input$period[1]
      HISTORICAL_CATCH_INTERVAL_END = input$period[2]
      HISTORICAL_CATCH_AVERAGE = period_average_catch_data
      print(period_average_catch_data)
      HISTORICAL_CATCH_METHOD = ifelse(sum(nchar(deparse(HISTORICAL_CATCH_AVERAGE)))>200, "Best \"n\" years", "Selected period")
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_01 = input$cb_year01_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_02 = input$cb_year02_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_03 = input$cb_year03_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_04 = input$cb_year04_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_05 = input$cb_year05_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_06 = input$cb_year06_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_07 = input$cb_year07_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_08 = input$cb_year08_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_09 = input$cb_year09_wgt/100
      CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_10 = input$cb_year10_wgt/100
      ALLOCATION_TRANSITION = sapply(1:10, function(x){ eval(parse(text = paste0("CATCH_BASED_WEIGHT_NJA_ATTRIBUTION_YEAR_", sprintf("%02d",x)))) })
      OnlyHS = FALSE
      
      # Source the R allocation scripts
      source("./initialisation/05_SCENARIO_ALLOCATION_COMPUTATION.R", local = TRUE)
      source("./initialisation/06_SCENARIO_ALLOCATION_TABLES.R", local = TRUE)
      
      # General report (DOCX format)
      #out_file = paste0(unlist(strsplit(file, "\\."))[1], ".docx")
      file.copy("./rmd", tempdir(), recursive = TRUE, overwrite = TRUE)
      rmarkdown::render(
        file.path(tempdir(), "rmd", "00_A_SINGLE_SIMULATION_ALL_CPCS.Rmd"),
        output_file = file
      )
      
      # Convert report to PDF
      # wordApp = COMCreate("Word.Application") #creates COM object
      # wordApp[["Documents"]]$Open(Filename = out_file) #opens your docx in wordApp
      # wordApp[["ActiveDocument"]]$SaveAs(file, FileFormat = 17) #saves as PDF
      # wordApp[["ActiveDocument"]]$Close(SaveChanges = TRUE) #Closes the docx
      # wordApp$Quit() #quits the COM Word application
      # rm(list = "wordApp")
      
  })
  
  output$report_by_entity_download_wrapper = renderUI({
    req(input$reporting_entity)
    if(!is.null(input$reporting_entity) & input$reporting_entity != ""){
      downloadButton("report_by_entity_download", "Download entity report",icon=icon("download"))
    }else{
      tags$div()
    }
  })
  
  output$simu_entity_total_allocations = renderUI({
    req(!is.null(computed_allocation_for_entity()))
    result = computed_allocation_for_entity()
    unit = result$UNIT
    fluidRow(
      column(
        width = 12,
        bs4Dash::infoBox(
          title = "Total Allowable Catches (TACs)",
          width = 12,
          icon = icon("fish"),
          color = "primary",
          value = plotly::plotlyOutput("entity_quota_plot")
        )
      )
    )
    
  })
  
  output$simu_entity_detailed_allocations = renderUI({
    req(!is.null(computed_allocation_for_entity()))
    result = computed_allocation_for_entity()
    unit = result$UNIT
    
    tagList(
      fluidRow(
        column(
          width = 6,
          bs4Dash::infoBox(
            title = "Baseline allocation",
            width = 12,
            color = "success",
            value = if(nrow(result$BA_ALLOCATION) > 0){
              tagList(
                tags$b(sprintf(
                  "%s t",
                  format(ifelse(unit == "quota", round(result$BA_ALLOCATION$BA_TAC * input$tac), round(result$BA_ALLOCATION$BA_TAC)), big.mark = ",")
                )),
                hr(),
                tags$em(paste0(sprintf(
                  "Allocation: %s",
                  round(ifelse(unit == "quota", result$BA_ALLOCATION$BA_TAC, result$BA_ALLOCATION$BA_TAC / input$tac) * 100, 2)
                ), "%"))
              )
            }else{"–"}
          ),
          bs4Dash::infoBox(
            title = "Developing state allocation",
            width = 12,
            color = "gray-dark",
            value = if(nrow(result$DS_ALLOCATION) > 0){
              tagList(
                tags$b(sprintf(
                  "%s t",
                  format(ifelse(unit == "quota", round(result$DS_ALLOCATION$DS_TAC * input$tac), round(result$DS_ALLOCATION$DS_TAC)), big.mark = ",")
                )),
                hr(),
                tags$em(paste0(sprintf(
                  "Allocation: %s",
                  round(ifelse(unit == "quota", result$DS_ALLOCATION$DS_TAC, result$DS_ALLOCATION$DS_TAC / input$tac) * 100, 2)
                ), "%"))
              )
            }else{"–"}
          )
        ),
        column(
          width = 6,
          bs4Dash::infoBox(
            title = "Catch-based allocation",
            width = 12,
            icon = icon("fish"),
            color = "info",
            value = plotly::plotlyOutput("entity_cb_allocation_plot")
          )
        )
      )
    )
  })
  
  output$entity_quota_plot = renderPlotly({
    req(!is.null(computed_allocation_for_entity()))
    quota_result = computed_allocation_for_entity()$QUOTAS
    quota_result_long <- quota_result %>%
      pivot_longer(
        cols = starts_with("QUOTA_YEAR_"),
        names_to = "YEAR",
        names_prefix = "QUOTA_YEAR_",
        values_to = "QUOTA"
      ) %>%
      mutate(
        YEAR = as.integer(YEAR)
      )
    if(computed_allocation_for_entity()$UNIT == "quota"){
      quota_result_long$QUOTA = quota_result_long$QUOTA * input$tac
    }
    plotly::plot_ly(quota_result_long, x = ~YEAR, y = ~QUOTA, type = 'bar') %>% 
      plotly::layout(
        xaxis = list(title = "YEAR"), 
        yaxis = list(title = 'TAC (t)', tickformat = ",.0f"), 
        colorway = RColorBrewer::brewer.pal(3,"Blues"),
        barmode = 'stack', 
        legend = list(
          orientation = "h", 
          x = 0.5, 
          y = -0.05, 
          xanchor = "center", 
          yanchor = "top"
        )
      )
  })
  
  output$entity_cb_allocation_plot = renderPlotly({
    req(!is.null(computed_allocation_for_entity()))
    cb_result = computed_allocation_for_entity()$CB_ALLOCATION
    cb_result_long <- cb_result[,.(CPC_CODE, CB_TAC_1, CB_TAC_2, CB_TAC_3, CB_TAC_4, CB_TAC_5,
                                   CB_TAC_6, CB_TAC_7, CB_TAC_8, CB_TAC_9, CB_TAC_10)] %>%
      pivot_longer(
        cols = starts_with("CB_TAC_"),
        names_to = "YEAR",
        names_prefix = "CB_TAC_",
        values_to = "TAC"
      ) %>%
      mutate(
        YEAR = as.integer(YEAR)
      )
    if(computed_allocation_for_entity()$UNIT == "quota"){
      cb_result_long$TAC = cb_result_long$TAC * input$tac
    }
    plotly::plot_ly(cb_result_long, x = ~YEAR, y = ~TAC, type = 'bar') %>% 
      plotly::layout(
        xaxis = list(title = "YEAR"), 
        yaxis = list(title = 'Catch-based TAC allocation (t)', tickformat = ",.0f"), 
        colorway = RColorBrewer::brewer.pal(3,"Blues"),
        barmode = 'stack', 
        legend = list(
          orientation = "h", 
          x = 0.5, 
          y = -0.05, 
          xanchor = "center", 
          yanchor = "top"
        )
      )
  })
  
  #observe species for TAC selection
  observeEvent(input$species,{
    updateNumericInput(
      inputId = "tac",
      value = SCENARIO_PARAMETERS[SCENARIO_PARAMETERS$SPECIES_CODE_SELECTED == input$species,][1,]$TARGET_TAC_T
    )
  })
  
  #observe sum of weight
  observeEvent(input$ds_weight,{
    if(input$ba_weight + input$ds_weight > 100){
      updateSliderInput(session = session, inputId = "ds_weight", value = 100 - input$ba_weight)
      postMessage(sprintf("Can't set developing state weight to %s %%. Reducing developing states weight to <b>%s</b> %%", input$ds_weight, 100 - input$ba_weight), "warning")
    }
  })
  observeEvent(input$ba_weight,{
    if(input$ba_weight + input$ds_weight > 100){
      print(sprintf("Can't set ba_weight = %s, reducing weight to %s", input$ba_weight, 100 - input$ds_weight))
      updateSliderInput(session = session, inputId = "ba_weight", value = 100 - input$ds_weight)
      postMessage(sprintf("Can't set baseline weight to %s %%. Reducing baseline weight to <b%s</b> %%", input$ba_weight, 100 - input$ds_weight), "warning")
    }
  })
}