
# Setup ------------------------------------------------------------------------

library(dplyr)
library(readxl)
library(readr)

path <- "data-raw/New Jersey/evaluation"

# Read -------------------------------------------------------------------------

# "When one performance level is suppressed due to n-size, and all 4 performance
# level ratings are present, the next lowest staff count will be suppressed 
# (record will not be part of the file), to disallow roll-up to find the rating 
# count for the first level suppressed and thus potentially identify educators."

# NJ suppresses the count in any category with <10, and the next lowest category, 
# but reports the total number of teachers rated
# I compare the reported total to the sum of the unsuppressed categories.
# If they match I replace nas with 0
# If only e1 and e2 are missing, I impute the difference between the reported 
# total and the sum to e2

raw <- list()
raw[[1]] <- read_excel(paste(path, "NJDOE_STAFF_EVAL_1314.xlsx", sep = "/"), col_types="text") %>% 
  mutate(year = 2014)

raw[[2]] <- read_excel(paste(path, "NJDOE_STAFF_EVAL_1415.xlsx", sep = "/"), col_types="text") %>% 
  mutate(year = 2015)

raw[[3]] <- read_excel(paste(path, "NJDOE_STAFF_EVAL_1516.xlsx", sep = "/"), col_types="text") %>% 
  mutate(year = 2016)

nj <- bind_rows(raw) %>% 
  filter(SCHOOL_ID == "999" & CATEGORY == "TEACHERS" & LEA_NAME != "COUNTY TOTAL" & LEA_NAME != "statewide") %>% 
  select(DISTRICT_CODE,COUNTY_CODE,name=LEA_NAME,e1=INEFFECTIVE,e2=PARTIALLY_EFFECTIVE,e3=EFFECTIVE,e4=HIGHLY_EFFECTIVE,et=TOTAL,year) %>% 
  mutate(state = "NJ",
         DISTRICT_CODE = ifelse(nchar(DISTRICT_CODE)==2,paste0(00,DISTRICT_CODE),DISTRICT_CODE),
         DISTRICT_CODE = ifelse(nchar(DISTRICT_CODE)==3,paste0(0,DISTRICT_CODE),DISTRICT_CODE),
         localid = paste0(COUNTY_CODE,DISTRICT_CODE),
         name=tolower(name)) %>% 
  mutate_at(vars(e1, e2, e3, e4, et), 
            function(x) as.numeric(gsub("\\*", NA, x))) %>% # * indicates data suppression
  rowwise %>% 
  mutate(sum=sum(e1,e2,e3,e4, na.rm=T),
         nna = is.na(e1)+is.na(e2)+is.na(e3)+is.na(e4),
         e1 = if_else(nna==1 & is.na(e1),0,e1),
         e2_impute = if_else(nna==2 & is.na(e1) & is.na(e2), 1, 0),
         e2 = if_else(nna==2 & is.na(e1) & is.na(e2), et-sum, e2),
         e1 = if_else(et==sum&is.na(e1),0,e1),
         e2 = if_else(et==sum&is.na(e2),0,e2),
         e3 = if_else(et==sum&is.na(e3),0,e3),
         e4 = if_else(et==sum&is.na(e4),0,e4)) %>% 
  mutate_if(is.numeric, as.integer) %>% 
  select(state, year, localid, name, e1, e2, e3, e4, et, e2_impute) %>% 
  filter(name!="statewide")

write_csv(nj, "data-clean/NewJerseyEval.csv")