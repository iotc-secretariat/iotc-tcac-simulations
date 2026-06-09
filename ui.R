ui = function() {
  return(
    
    fluidPage(
      shinyjs::useShinyjs(),
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
      div(id = "login-wrapper", # add login panel UI function
          customLoginUI(
            id = "login",
            title = tagList(
              img(src = "iotc-logo.png", height = "96px"),br(),br(),
              tags$b("IOTC TCAC simulation tool"),
              tags$small("v2.0.0 (2026-03-02)"),
              
            ),
            login_title = "Login",
          )
      ),
      shinyjs::hidden(
        div(id = "main-content",
          bs4Dash::bs4DashPage(
            header = bs4Dash::dashboardHeader(
              title = tagList(
                img(src = "iotc-logo.png", height = "48px", style = "margin:5px;"), 
                span("IOTC TCAC simulation tool v2.0 [ ", style = "margin-left:10px;"),
                a("source code", href = "https://github.com/iotc-secretariat/iotc-tcac-simulations", target = "_BLANK"),
                span(" | ", style = "margin-left:2px;margin-right:2px;"),
                a("readme", href = "readme.html", target = "_BLANK"),
                span(" | ", style = "margin-left:2px;margin-right:2px;"),
                a("user manual", href = "usermanual.html", target = "_BLANK"),
                span(" | ", style = "margin-left:2px;margin-right:2px;"),
                a("disclaimer", href = "disclaimer.html", target = "_BLANK"),
                span(" ]")
              ),
              rightUi = tags$li(
                class = "dropdown",
                shinyauthr::logoutUI(id = "logout", style = NULL)
              )
            ),
            sidebar = dashboardSidebar(disable = T),
            body = bs4Dash::dashboardBody(
              # app (once logged in)
              uiOutput("main")
            )
         )
        )
      )
    )
  )
}
