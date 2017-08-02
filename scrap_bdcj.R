library(rvest)
library(magrittr)
library(stringr)

colla <- 'bordegassos'
any <- 2000
filename <- paste0('data/', colla, '_', year, '.tsv')
get_form_data(colla, any, filename , debug = TRUE)


# script parameters
year <- 2000
output_file <- paste0("logs/bd_cccc_", year, ".tsv")
if (file.exists(output_file)) file.remove(output_file)

# main page
session <- html_session("http://www.cccc.cat/base-de-dades")
main_page <- read_html("http://www.cccc.cat/base-de-dades")

# parse all colles ids
colles <- main_page %>%
  html_nodes("select[name='filters[idColla][]'] option") %>%
  html_attr("value")

# loop over all possible colla id values
for (colla_i in 1:5) {
# for (colla_i in 1:length(colles)) {
  
  # colla
  colla <- colles[colla_i]
  print(paste0("Scraping for ", colla))
  
  # Fill the form, submit and get the first results page
  form <- html_form(main_page)[[2]]
  form <- form %>%
    set_values('filters[inici]' = paste0('01/01/', year),
               'filters[fi]' = paste0('31/12/', year),
               'filters[idColla][]' = colla)
  main_results_page <- submit_form(session = session, form)
  
  # Find the number of pagination pages we will need to go through
  pagination <- main_results_page %>% 
    html_node('div.pagination-nums') %>% 
    html_nodes('input')
  
  if (length(pagination) > 0) {
    max_pagination <- as.integer(pagination[length(pagination)] %>% html_attr('value'))
  } else {
    max_pagination <- 1
  }
  print(paste0('Pagination:', max_pagination))
  
  # Iterate over all pagination pages
  for (pagination_i in 1:max_pagination) {
  # for (pagination_i in 1:1) {
    
    print(paste0("Page:", pagination_i))
    
    # parse the data
    if (pagination_i == 1) {
      page <- main_results_page
    } else {
      # To follow the pagination links we need to go through another
      # form submission. There are two forms on the page before reaching
      # the pagination forms.
      form <- html_form(main_results_page)[[1 + pagination_i]] 
      page <- submit_form(session = session, form)
    }
    
    #page <- response %>% html_node("//div[@style='margin-top:10px;']")
    page <- page %>% 
      html_nodes(xpath = '/html/body/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/div/div[3]')
    
    # Check there are results
    # if(page %>% html_nodes('div.alert') %>% length() == 0) {
    #   print("Empty!")
    # }
    
    # Diades
    diades <- page %>%
      html_nodes('div') %>%
      head(-1) # remove last element
    
    # Table of castells
    castells_tables <- page %>%
      html_nodes('table')
    
    # Safety check
    # if(length(diades) != length(castells_tables)) {
    #   print("ERROR: diades and tables different!")
    # }
    if (length(diades) > 0) {
      
      for(i in 1:length(diades)) { 
        
        s <- html_text(diades[[i]]) %>%
          str_trim()
        # DEBUG
        print(s)
        
        # Date
        log_data <- str_sub(s, 1, 10)
        # Name and location
        s <- str_sub(s, 11, str_length(s)) %>%
          str_trim() %>%
          str_split(',')
        log_nom <- s[[1]][1] %>%
          str_trim()
        log_poblacio <- s[[1]][[2]] %>%
          str_trim()
        
        # Table of castells
        files <- castells_tables[[i]] %>%
          html_nodes("tr")
        for(j in 1:length(files)) {
          columnes <- files[[j]] %>%
            html_nodes("td") %>%
            html_text() %>%
            str_trim()
          if (j == 1) { log_colla <- columnes[1]}
          # write record
          write(paste(log_data, log_poblacio, log_nom, log_colla, columnes[2], columnes[3], sep = "\t"), 
                file = output_file, 
                sep = ";", 
                append = TRUE)
        }
      }
    }
    
    # table = result.next_sibling.next_sibling
    # for tr in table.search("tr")
    # cells = tr.search("td")
    # # Busquem el id de colla
    # if cells[0].text.strip! != ''
    # colla_id = colles.key(cells[0].text.strip!)
    # end
    # # Busquem el id del castell
    # castell_id = castells.key(cells[1].text.strip!)
    # if castell_id.nil?
    # puts 'Castell desconegut: ' + cells[1].text.strip!.to_s
    # end
    # # Busqume el status del castell
    # status_desc = cells[2].text.strip!
    #   status = "D" if status_desc == "Descarregat"
    # status = "C" if status_desc == "Carregat" 
    # status = "ID" if status_desc == "Intent desmuntat"
    # status = "I" if status_desc == "Intent"
  }
}

