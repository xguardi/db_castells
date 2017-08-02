library(tidyverse)

data <- read_tsv('data/bordegassos_2000.tsv',
                 col_names = c('data', 'poblacio', 'diada', 'colla', 'castell', 'status'))
