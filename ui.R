ui = function() {
  return(
    
    fluidPage(
      shinyjs::useShinyjs(),
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "fao-home.min.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "fao-theme.min.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "fao-adds.css")
      ),
      div(id = "login-wrapper", # add login panel UI function
          customLoginUI(
            id = "login",
            title = tagList(
              img(src = "iotc-logo.png", height = "96px"),br(),br(),
              tags$b("IOTC TCAC simulation tool"),
              tags$small(sprintf("v%s (%s)", getAppVersion(), getAppDate())),
              
            ),
            login_title = "Login",
          )
      ),
      shinyjs::hidden(
        div(id = "main-content",
          bs4Dash::bs4DashPage(
            header = bs4Dash::dashboardHeader(
              # title = tagList(
              #   img(src = "iotc-logo.png", height = "48px", style = "margin:5px;"), 
              #   span("IOTC TCAC simulation tool v2.0 [ ", style = "margin-left:10px;"),
              #   a("source code", href = "https://github.com/iotc-secretariat/iotc-tcac-simulations", target = "_BLANK"),
              #   span(" | ", style = "margin-left:2px;margin-right:2px;"),
              #   a("readme", href = "readme.html", target = "_BLANK"),
              #   span(" | ", style = "margin-left:2px;margin-right:2px;"),
              #   a("user manual", href = "usermanual.html", target = "_BLANK"),
              #   span(" | ", style = "margin-left:2px;margin-right:2px;"),
              #   a("disclaimer", href = "disclaimer.html", target = "_BLANK"),
              #   span(" ]")
              # ),
              title = tagList(
                img(src = "https://design-system.fao.org/images/logo/fao-logo-three-lines.svg", height = "48px", alt = "FAO", style = "display:flex"), 
                #img(src = "iotc-logo.png", height = "48px", alt = "IOTC", style = "margin:5px;"),
                tags$span(
                  "IOTC TCAC Simulation Tool",
                  class = "ms-3 ps-3 fw-semibold text-uppercase vertical-sep-header"
                ),
                tags$a(
                  href = "https://github.com/iotc-secretariat/iotc-tcac-simulations",
                  target = "_blank",
                  class = "text-decoration-none vertical-sep-footer",
                  "Source code"
                ),
                tags$a(
                  href = "readme.html",
                  target = "_blank",
                  class = "text-decoration-none vertical-sep-footer",
                  "Readme"
                ),
                tags$a(
                  href = "usermanual.html",
                  target = "_blank",
                  class = "text-decoration-none vertical-sep-footer",
                  "User manual"
                ),
                tags$a(
                  href = "disclaimer.html",
                  target = "_blank",
                  class = "text-decoration-none vertical-sep-footer",
                  "Disclaimer"
                )
              ),
              rightUi = tags$li(
                class = "dropdown",
                shinyauthr::logoutUI(id = "logout", style = NULL)
              )
            ),
            sidebar = dashboardSidebar(disable = T),
            body = bs4Dash::dashboardBody(
              # app (once logged in)
              uiOutput("main"),
              app_footer(getAppId(), getAppVersion(), getAppDate()),
              fao_footer()
            )
         )
        )
      )
    )
  )
}
