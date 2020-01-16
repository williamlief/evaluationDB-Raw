# Setup ------------------------------------------------------------------------
source("setup.r")

path <- setpath("Connecticut")

library(dplyr)
library(readxl)
library(tidyr)
library(readr)

# Read -------------------------------------------------------------------------

df <- read_excel(paste0(path, "/ctmirror_copypaste.xlsx"), 
                       sheet = 1, skip = 1, na = "") %>% 
  rename(districtyear = `District`,
         e1 = `Below Standard`,
         e2 = `Developing`,
         e3 = `Proficient`,
         e4 = `Exemplary`,
         es = `Unaccounted`,
         et = `Staff`) %>% 
  separate(districtyear, c('name', 'year'), sep = ' \\(')

# Clean ------------------------------------------------------------------------

localid <- read_csv("dataCleaning/CT_name_localid_xwalk.csv")

CT <- df %>% 
  mutate(name = tolower(name),
         state = "CT",
         year = as.numeric(substr(year, 1, 4)) + 1
  ) %>% 
  left_join(localid, by = "name") %>% 
  select(state, name, localid, year, e1, e2, e3, e4, es, et)
  

write_csv(CT, "cleanData/ConnecticutEval.csv")