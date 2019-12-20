
# Setup ------------------------------------------------------------------------

library(dplyr)
library(readxl)
library(readr)

source("setup.r")

# Read, Clean ------------------------------------------------------------------


path <- paste0(setpath("Idaho"), "/FOIA Request")

list <- list.files(path = path, pattern = "*.xlsx", full.names = TRUE)
list <- list[!grepl("example_file", list)]
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
         name = tolower(name),
         state = "ID"
        ) %>% 
  select(state, year, name, localid, e4, e3, e2, e1)

write_csv(Idaho, "CleanData/IdahoEval.csv")
