library(rvest)

source('get_form_data.R')

blacklist <- c('capgrossos2001')

# entry page
session <- html_session("http://www.cccc.cat/base-de-dades")
main_page <- read_html("http://www.cccc.cat/base-de-dades")

# get all colles ids
colles <- main_page %>%
  html_nodes("select[name='filters[idColla][]'] option") %>%
  html_attr("value")

# loop over all years and colles
for(year in 2000:2001) {
  
  # for every year create an output folder
  if(!dir.exists(paste0('data/', year))) {
    dir.create(paste0('data/', year))
  }
  
  for(colla in colles) {
     print(colla)
    
    # output file
    if (!(paste0(colla, year) %in% blacklist)) {
      filename <- paste0('data/', year, '/', colla, '_', year, '.tsv')
      get_form_data(colla, year, filename , debug = TRUE)
    }
    
  }
}


