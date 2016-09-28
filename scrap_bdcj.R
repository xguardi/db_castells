library(rvest)
library(magrittr)

session <- html_session("http://www.cccc.cat/base-de-dades")

page <- read_html("http://www.cccc.cat/base-de-dades")
# parse all colles ids
colles <- page %>%
  html_nodes("select[name='filters[idColla][]'] option") %>%
  html_attr("value")

# DEBUG
target <- colles[1]

# look for the main form
form <- html_form(page)[[2]]
form <- form %>%
  set_values('filters[inici]' = '01/01/2000',
             'filters[fi]' = '31/12/2000',
             'filters[idColla][]' = target)
results_page <- submit_form(session = session, form)

# number of pagination pages
pagination <- results_page %>% html_node('.pagination-nums') %>% html_nodes('input')
if (length(pagination) > 0) {
  max_page <- as.integer(pagination[length(pagination)] %>% html_attr('value'))
} else {
  max_page <- 1
}

# Iterate over all pagination pages
for (page in 1:max_page) {
  
  # parse the data
  response <- results_page
  data <- response %>% html_node("//div[@style='margin-top:10px;']")[0]
  
  # first we check we have results
  if (anchor.search("div.alert").length > 0
}

