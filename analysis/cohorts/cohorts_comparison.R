library(tidyverse)
library(ggthemes)
library(scales)
library(forcats)
source('utils.R')

# load database 
load("data/bdcj.RData", verbose = T)

plot_data <- data %>%
  group_by(colla) %>%
  mutate(min_date = min(data)) %>%
  select(colla, min_date) %>%
  filter(row_number()==1)
