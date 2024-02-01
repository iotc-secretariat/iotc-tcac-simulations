ui = function() {
  return(
    fluidPage(
      title = "IOTC TCAC simulation tool v1.0",
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
      tags$div(
        class = "main-container",
        conditionalPanel(
          condition = "$('html').hasClass('shiny-busy')",
          tags$div(id = "glasspane",
                   tags$div(class = "loading", "Filtering data and preparing output...")
          )
        ),
        tags$div(
          fluidRow(
            column(
              width = 8,
              h4(
                img(src = "iotc-logo.png", height = "48px"), 
                span("IOTC TCAC simulation tool v1.0 [ "),
                a("source code", href = "https://bitbucket.org/iotc-ws/iotc-tcac-simulations/src/master/", target = "_BLANK"),
                span(" | "),
                a("readme", href = "./README.html"),
                span(" ]")
              )
            )
          ),
          tabsetPanel(
            selected = "Simulation results",
            tabPanel(
              "Reference data",
              tabsetPanel(
                tabPanel(
                  "CPC summary",
                  fluidRow(
                    column(width = 12,
                      DT::dataTableOutput("CPC_summary_table")
                    )
                  )
                ),
                tabPanel(
                  "Coastal states summary",
                  fluidRow(
                    column(width = 12,
                      DT::dataTableOutput("coastal_states_summary_table")
                    )
                  )
                ),
                tabPanel(
                  "Historical catches",
                  fluidRow(
                    column(width = 12,
                           DT::dataTableOutput("historical_catches_table")
                    )
                  )
                )
              )
            ),
            tabPanel(
              "Simulation results",
              fluidRow(
                column(width = 4,
                  fluidRow(
                    column(width = 6,
                      selectInput("species", "Species", width = "100%", choices = AVAILABLE_SPECIES, selected = "YFT")
                    ),
                    column(width = 6,
                      numericInput("tac", "Target TAC (t)", value = 500000, min = 10000, step = 10000),
                    )
                  ),
                  
                  span(class="triple",
                    sliderInput("weights", label = "Main component weights (%)",
                                width = "100%",
                                min = 0, max = 100, value = c(10, 70), step = .5, sep = "", animate = FALSE
                    )
                  ),
                  
                  br(),              
                  
                  strong("Baseline weight:"),      textOutput("ba_wgt", inline = TRUE),
                  strong("Coastal state weight:"), textOutput("cs_wgt", inline = TRUE),
                  strong("Catch-based weight:"),   textOutput("cb_wgt", inline = TRUE),
                  
                  hr(), 
                  
                  tabsetPanel(
                    selected = "Coastal state weights",
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
                      "Coastal state weights",
                      fluidRow(
                        column(width = 12,
                          div(class="top-padded",
                            span(class="triple",
                              sliderInput("cs_weights", "Coastal state component weights (%)",
                                          width = "100%",
                                          min = 0, max = 100, value = c(35, 82.5), step = .5, sep = "", animate = FALSE
                              )
                            ),
                            
                            br(),
                            
                            strong("Equal weight:"),          textOutput("cs_eq_wgt", inline = TRUE),
                            strong("Socio-economic weight:"), textOutput("cs_se_wgt", inline = TRUE),
                            strong("EEZ weight:"),            textOutput("cs_ez_wgt", inline = TRUE),
                                            
                            hr(),
                            
                            fluidRow(
                              column(
                                width = 12,
                                selectInput ("se_option", "Socio-economic options", width = "100%", choices = AVAILABLE_SOCIO_ECONOMIC_OPTIONS, selected = "O2")
                              )
                            ),
                            conditionalPanel(
                              condition = "input.se_option == 'O1'",
                              fluidRow(
                                column(
                                  width = 12,
                                  span(class="triple",
                                       sliderInput("cs_se_o1_weights", "Option #1 - Socio-economic sub-component weights (%)",
                                                   width = "100%",
                                                   min = 0, max = 100, value = c(30, 70), step = .5, sep = "", animate = FALSE
                                       )
                                  ),
                                  
                                  br(),
                                  
                                  strong("Vulnerability weight:"),    textOutput("cs_se_vul_wgt",     inline = TRUE),
                                  strong("Priority sectors weight:"), textOutput("cs_se_pri_sec_wgt", inline = TRUE),
                                  strong("Disprop. burden weight:"),  textOutput("cs_se_dis_bur_wgt", inline = TRUE)
                                )
                              )
                            ),
                            conditionalPanel(
                              condition = "input.se_option == 'O2'",
                              fluidRow(
                                column(
                                  width = 12,
                                  span(class="triple",
                                       sliderInput("cs_se_o2_weights", "Option #2 - Socio-economic sub-component weights (%)",
                                                   width = "100%",
                                                   min = 0, max = 100, value = c(30, 70), step = .5, sep = "", animate = FALSE
                                       )
                                  ),
                                  
                                  br(),
                                  
                                  strong("HDI weight:"),  textOutput("cs_se_HDI_wgt",  inline = TRUE),
                                  strong("GNI weight:"),  textOutput("cs_se_GNI_wgt",  inline = TRUE),
                                  strong("SIDS weight:"), textOutput("cs_se_SIDS_wgt", inline = TRUE)
                                )
                              )
                            )
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
                        )
                      )
                    )
                  )
                ),
                column(width = 8,
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
                      width = 3,
                      selectInput("out_heat_type",  "Heatmap type", width = "100%", choices = AVAILABLE_HEATMAP_TYPES, selected = "global")
                    ),
                    column(
                      width = 3,
                      div(
                        class="button-padded",
                        downloadButton("download_data", "Download")
                      )
                    )
                  ),
                  fluidRow(
                    column(width = 12,
                      DT::dataTableOutput("quotas_table")
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
}
