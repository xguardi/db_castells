library(tidyverse)
library(httr)
library(xml2)
library(stringr)

# fills the form and scraps the data for a given colla and year
get_form_data <- function(colla, year, filename, debug = FALSE) {
  
  url <- "http://www.cccc.cat/base-de-dades"
  
  print(paste0("Getting data for ", colla, " - ", year))
  # we are going to dumpt the logs on a file. 
  # remove if it already exists
  if (file.exists(filename)) file.remove(filename)
  
  # iterate over pagination until we have no more data
  more_pages <- TRUE
  page_index <- 1
  while(more_pages) {
    
    # form fields
    fields <- list(
      'tipus' = 1,
      'filters[inici]' = paste0('01/01/', year),
      'filters[fi]' = paste0('31/12/', year),
      'filters[idColla][]' = colla,
      'pag' = page_index
    )
    
    # post request
    r <- POST(url, 
              body = fields, 
              encode = 'form',
              user_agent('libcurl/7.43.0 r-curl/0.9.7 httr/1.2.1'))
    # read as xml
    r <- content(r, as = "parsed", encoding = "utf-8")
    
    # diades
    diades <- r %>% 
      html_nodes(xpath = '/html/body/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/div/div[3]') %>%
      html_nodes('div') %>%
      head(-1) # remove last element
    
    # table of castells
    table_castells <- r %>% 
      html_nodes(xpath = '/html/body/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/div/div[3]') %>%
      html_nodes('table')
    
    # if we still have data
    if (length(diades) > 0) {
      
      if (debug) print(page_index)
      page_index <- page_index + 1
      
      # iterate over diades
      for(i in 1:length(diades)) { 
        
        s <- html_text(diades[[i]]) %>%
          str_trim()
        
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
        files <- table_castells[[i]] %>%
          html_nodes("tr")
        # we use a dummy_counter of each castell so we can
        # avoid removing two equal castells later on when
        # we detect duplicates
        log_dummy <- 0
        for(j in 1:length(files)) {
          log_dummy <- log_dummy + 1
          columnes <- files[[j]] %>%
            html_nodes("td") %>%
            html_text() %>%
            str_trim()
          if (j == 1) { 
            log_colla <- columnes[1]
          } else {
            if(columnes[1] != '') {
              log_colla <- columnes[1]
              log_dummy <- 1
            } 
          } 
          log <- paste(log_data, 
                      log_poblacio, 
                      log_nom, 
                      log_colla, 
                      columnes[2], 
                      columnes[3], 
                      log_dummy,
                      sep = "\t")
          # write record
          write(log, file = filename, sep = ";", append = TRUE)
        }
      }
      
      max_pagination <- r %>% 
        html_node('div.pagination-nums') %>% 
        html_nodes('input') %>%
        html_attr('value') %>%
        max()
      if(is.na(max_pagination)) max_pagination <- 1
      # if (debug) print(paste0('Max page: ', max_pagination))
      
      if(page_index > max_pagination) {
        if (debug) print("No more pages.")
        more_pages <- FALSE 
      }
      
    } else {
      if (debug) print("No more pages.")
      more_pages <- FALSE 
    } # end diades
  } # end while more_pages

}