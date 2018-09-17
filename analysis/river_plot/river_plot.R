library(tidyverse)
library(ggthemes)
library(scales)
library(forcats)
library(streamgraph)
source('utils.R')

# load database 
load("data/bdcj.RData", verbose = T)

# 161 colles x 90 anys = 14490

plot_data <- data %>%
  mutate(colla = as.character(colla),
    year = as.integer(format(data, "%Y"))) %>%
  group_by(year, colla) %>%
  summarise(score = sum(score, na.rm = T)) %>%
  group_by(year) %>%
  top_n(n = 4, wt = score)
  
empty_df <- expand.grid(colla = unique(plot_data$colla), year = unique(plot_data$year))
empty_df$score <- 0

plot_data <- as.data.frame(plot_data) %>%
  rbind(empty_df) %>%
  group_by(year, colla) %>%
  summarise(score = sum(score, na.rm = T)) %>%
  group_by(year) %>%
  mutate(score = score/sum(score))

  

plot_data %>%
  ggplot(aes(x = year, y = score)) +
    geom_area(aes(group = colla, fill = colla), position = 'stack') + 
    theme_fivethirtyeight() +
    theme(legend.position="none")
    
