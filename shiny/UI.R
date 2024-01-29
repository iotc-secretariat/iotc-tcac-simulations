ui = function() {
  return(
    fluidPage(
      title = "IOTC TCAC simulation tool v1.0",
      tags$style(
        HTML("
        #glasspane {
        	position: fixed;
        	height: 100%;
        	width: 100%;
        	background-color: #99999933;
        	z-index: 10000;
        }
        
        .loading {
        	width: 320px;
        
        	color: #000000;
        	background-color: white;
        
        	font-weight: bold;
        	font-size: 100%;
        
        	padding: 1em;
        	margin-left: calc(50vw - 160px);
        	margin-top: calc(40vh);
        
        	text-align: center;
        
        	border-radius: 1em;
        	border: 2px solid gray;
        
        	-webkit-box-shadow: -1px 10px 25px -11px rgba(0,0,0,0.75);
        	-moz-box-shadow: -1px 10px 25px -11px rgba(0,0,0,0.75);
        	box-shadow: -1px 10px 25px -11px rgba(0,0,0,0.75);
         }
        
        #main + .tab-content,
        #data + .tab-content
        {
          padding: .5em;
        }

        .left-padded { 
          padding-left: 2em;
        }
        
        .top-padded {
          padding-top: 2em;
        }
        
        hr.thin {
          margin-top: 0 !important;
        }
        
       .triple .irs-line {
          background: #428bca;
          border-top: #428bca;
          border-bottom: #428bca;
        }
      ")
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
                span("IOTC TCAC simulation tool v1.0")
              )
            )
          ),
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
                  numericInput("num_years", "Number of years (for 'best n years' only) ", value = 5, min = 1, max = 60, step = 1)
                )
              ),
              hr(class="thin"),
              
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
                            span(class="triple",
                                 sliderInput("cs_se_weights", "Socio-economi sub-component weights (%)",
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
                ),
                tabPanel(
                  "Catch-based weights",
                  div(class="top-padded", 
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
              DT::dataTableOutput("quotas_table")
            )
          )
        )
      )
    )
  )
}
