l_info("Loading some TableFormat function")

TableFormat = function(DataTable){
  
  DataTableFT = 
    DataTable %>% 
    flextable() %>% 
    flextable::font(part = "all", fontname = "calibri") %>% 
    flextable::fontsize(part = "all", size = 10) %>% 
    bold(part = "header") %>% 
    bg(part = "header", bg = "grey") %>% 
    fontsize(part = "all", size = 9) %>% 
    align(align = "center", part = "header") %>% 
    align(j = 1, align = "center", part = "body") %>% 
    border_inner() %>% 
    border_outer(border = fp_border(width = 2)) %>% 
    autofit() 

  return(DataTableFT)
  }

l_info("TableFormat function loaded!")