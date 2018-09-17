library(tidyverse)
library(ggthemes)
library(scales)
library(forcats)
source('utils.R')

# load database 
load("data/bdcj.RData", verbose = T)

# Nombre total de punts ----
png(filename = "plots/evolucio_punts_totals.png", width =700, height = 500)
  
  plot_data <- data %>%
    # filter(colla == 'Nens del Vendrell') %>%
    mutate(year = as.integer(format(data, "%Y"))) %>%
    group_by(year) %>%
    summarise(score = sum(score, na.rm = T)) %>%
    # Civil war, punts = 0
    rbind(data.frame(year = c(1937,1938), score = c(0,0))) %>%
    arrange(year) %>%
    mutate(score = score + 1)
  
  exp.model <-lm(log(score) ~ year, plot_data)
  timevalues <- seq(1926, 2017, 1)
  fitvalues <- exp(predict(exp.model,list(year = timevalues)))
  exp_fit <- data.frame(year = timevalues, score = fitvalues)

  ggplot(plot_data, aes(x = year, y = score)) + 
    scale_y_continuous(name = "Punts", labels = scales::comma) +
    scale_x_continuous(breaks = seq(1920, 2100, 10)) +
    geom_line(size = 1.1) +
    geom_line(data = exp_fit, color = "red", linetype = 'dashed') +
    theme_fivethirtyeight() + 
    labs(title = "Tots els castells puntuats",
         subtitle = "Valor acumulat de tots els castells puntuables per cada any",
         caption = "FONT: BASE DE DADES COORDINADORA - JOVE TARRAGONA (BDCJ)") +
    theme(plot.title = element_text(colour = "black", hjust = 0), 
          plot.subtitle = element_text(size = rel(1.2), margin = margin(t=5,10,10,10)),
          plot.caption = element_text(margin = margin(t=20,10,10,10),
                                      size = rel(0.65)),
          text = element_text(size=14),
          axis.text = element_text(size = rel(1), colour = "grey30"))
  
dev.off()

# Nombre de colles ----
png(filename = "plots/evolucio_colles.png", width =700, height = 500)

  crisis <- data.frame(lower = c(1973, 1993, 2008), upper = c(1984, 1996, 2018))
  
  plot_data <- data %>%
    mutate(year = format(data, "%Y")) %>%
    group_by(year) %>%
    summarise(num_colles = length(unique(colla)))
  
  ggplot() + 
    scale_y_continuous(name = "Nombre de colles", breaks = seq(0,100, 10)) +
    scale_x_continuous(breaks = seq(1920, 2100, 10)) +
    geom_rect(data = crisis, 
               mapping = aes( xmin = lower , 
                              xmax = upper ,
                              ymin = 0 ,
                              ymax = 100), fill = "red3", alpha = 0.2) + 
    geom_line(data = plot_data, aes(x = as.integer(year), y = num_colles), size = 1.1) +
    annotate("text", x = 1973, y = 103, hjust = 0, angle = 10, label = "Crisis del Petroli") + 
    annotate("text", x = 1993, y = 103, hjust = 0, angle = 10, label = "Crisi post olímpica ") + 
    annotate("text", x = 2008, y = 103, hjust = 0, angle = 10, label = "Crisi actual") + 
    labs(title = "Nombre de colles",
         subtitle = "Expansió en temps de crisi?",
         caption = "FONT: BASE DE DADES COORDINADORA - JOVE TARRAGONA (BDCJ)") +
    theme_fivethirtyeight() +
    theme(plot.title = element_text(colour = "black", hjust = 0), 
          plot.subtitle = element_text(size = rel(1.2), margin = margin(t=5,10,10,10)),
          plot.caption = element_text(margin = margin(t=20,10,10,10),
                                      size = rel(0.65)),
          text = element_text(size=14),
          axis.text = element_text(size = rel(1), colour = "grey30"),
          legend.position="none")

dev.off()
  
# Punts/colla ----
png(filename = "plots/evolucio_punts_per_colla.png", width =700, height = 500)

plot_data <- data %>%
  mutate(year = format(data, "%Y")) %>%
  group_by(year) %>%
  summarise(score = sum(score, na.rm = T), num_colles = length(unique(colla))) %>%
  mutate(y = score/num_colles) %>%
  select(year, y) %>%
  # Civil war, punts = 0
  rbind(data.frame(year = c(1937,1938), y = c(0,0)))
ggplot(plot_data, aes(x = as.integer(year), y = y)) + 
  scale_y_continuous(name = "Punts", labels = scales::comma) +
  scale_x_continuous(breaks =  seq(1920, 2100, 10)) +
  geom_line(size = 1.1) +
  labs(title = "Mitjana de punts per colla",
       subtitle = "Punts totals dividit per nombre de colles actives aquell any",
       caption = "FONT: BASE DE DADES COORDINADORA - JOVE TARRAGONA (BDCJ)") +
  theme_fivethirtyeight() +
  theme(plot.title = element_text(colour = "black", hjust = 0), 
        plot.subtitle = element_text(size = rel(1.2), margin = margin(t=5,10,10,10)),
        plot.caption = element_text(margin = margin(t=20,10,10,10),
                                    size = rel(0.65)),
        text = element_text(size=14),
        axis.text = element_text(size = rel(1), colour = "grey30"))

dev.off()

# El sostre casteller cada any ----

# metadata dels castells
castells <- read_csv('data/castells.csv')

png(filename = "plots/evolucio_maxim_castell.png", width =700, height = 700)

  # primer filtrem els màxims regsitres (castell) per any
  plot_data <- data %>%
    mutate(year = format(data, "%Y")) %>%
    group_by(year) %>%
    filter(score == max(score)) %>%
    filter(row_number()==1) %>%
    left_join(castells, by = 'castell') %>%
    rowwise() %>% 
    mutate(short = short_full(castell_short, status)) %>%
    select(year, short, score, gamma)
  
  # reorder factors (short) with score
  fct_reorder(plot_data$short, plot_data$score)
  
  ggplot(plot_data, aes(x = as.integer(year), y = fct_reorder(short, score), group=1, color = gamma)) + 
    scale_y_discrete() +
    scale_x_continuous(breaks =  seq(1920, 2100, 10)) +
    geom_line(size = 1, colour = "grey79") +
    geom_point(size = 2) + 
    geom_line(data = subset(plot_data, as.integer(year) >= 1966), stat = 'smooth', method='lm', se = F, 
                color = 'red', linetype = 'dashed', alpha = 0.5) + 
    scale_color_hue() +
    labs(title = "Castell més valuós de l'any",
         subtitle = "D'acord amb la darrera taula de puntuació del Concurs",
         caption = "FONT: BASE DE DADES COORDINADORA - JOVE TARRAGONA (BDCJ)") +
    theme_fivethirtyeight() +
    theme(plot.title = element_text(colour = "black", hjust = 0), 
          plot.subtitle = element_text(size = rel(1.2), margin = margin(t=5,10,10,10)),
          plot.caption = element_text(margin = margin(t=20,10,10,10),
                                      size = rel(0.65)),
          text = element_text(size=14),
          axis.text = element_text(size = rel(1), colour = "grey30"))
dev.off()

# Cop que què s'ha superat la millor diada de la història

# Anys d'inici d'activitat de cada colla
colles_metadata <- data %>%
  group_by(colla) %>%
  summarise(fundacio = min(as.numeric(format(data,"%Y")))) %>%
  arrange(fundacio)
