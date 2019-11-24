setwd("C:/Users/zjm/Desktop/Idaho Foia Request")
library(dplyr)
library(readxl)
library(readr)

list <- list.files(pattern = "*.xlsx", full.names = TRUE)
files <- lapply(list, read_excel, sheet = 1, na = "**", col_types = "text")

df <- bind_rows(files) %>% 
  rename(name = `DistrictName`,
         localid = `DistrictNumber`,
         year = `SchoolYear`,
         e4 = `Distinguished`,
         e3 = `Proficient`,
         e2 = `Basic`,
         e1 = `Unsatisfactory`)

Idaho <- df %>% 
  mutate(year = as.numeric(substr(year, 6, 9)),
         name = tolower(name)
        ) %>% 
  select(year, name, localid, e4, e3, e2, e1)

write_csv(Idaho, "IdahoEval.csv")
