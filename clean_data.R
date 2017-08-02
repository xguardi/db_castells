library(tidyverse)

# Read all log files from under the data/ folder
log_files <- list.files('data/', pattern = ".tsv$", recursive = TRUE)

# read and join all logs
data <- data.frame()
for(file in log_files) {
  tmp_data <- read_tsv(file = paste0('data/', file), 
                       col_names = c('data', 'poblacio', 'diada', 'colla', 'castell', 'status', 'dummy'))
  data <- rbind(data, tmp_data)
}

# remove duplicates. Here the dummy field comes handy to avoid removing
# the same castell performed twice on the same diada
data <- data %>%
  distinct(data, poblacio, diada, colla, castell, status, dummy)

