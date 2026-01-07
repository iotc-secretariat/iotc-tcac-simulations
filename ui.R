ui = function() {
  return(
    fluidPage(
      title = "IOTC TCAC simulation tool v2.0",
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
      # add logout button UI 
      div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
      # add login panel UI function
      shinyauthr::loginUI(
        id = "login",
        title = tagList(
          img(src = "iotc-logo.png", height = "96px"),br(),br(),
          tags$b("IOTC TCAC simulation tool"),
          tags$small("v2.0 (2026-01-04)"),
          
        ),
        login_title = "Login"
      ),
      # app (once logged in)
      uiOutput("main")
    )
  )
}
