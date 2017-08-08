library(tidyverse)

# Read all log files from under the data/ folder
log_files <- list.files('data/', pattern = ".tsv$", recursive = TRUE)

# metadata
castells <- read_csv('data/castells.csv')

# read and join all logs
data <- data.frame()
for(file in log_files) {
  print(paste0('Parsing ', file))
  tmp_data <- read_delim(file = paste0('data/', file), 
                         delim = "\t",
                         quote = "",
                         col_types = cols(), # suppress column type match message
                         col_names = c('data', 'poblacio', 'diada', 'colla', 'castell', 'status', 'dummy'))
  data <- rbind(data, tmp_data)
}

# remove duplicates. Here the dummy field comes handy to avoid removing
# the same castell performed twice on the same diada
data <- data %>%
  distinct(data, poblacio, diada, colla, castell, status, dummy) %>%
  left_join(castells, by = 'castell')



