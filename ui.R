ui = function() {
  return(
    fluidPage(
      title = "IOTC TCAC simulation tool v1.1",
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
      # add logout button UI 
      div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
      # add login panel UI function
      shinyauthr::loginUI(id = "login"),
      # app (once logged in)
      uiOutput("main")
    )
  )
}
