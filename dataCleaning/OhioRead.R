
# Setup ------------------------------------------------------------------------

library(dplyr)
library(readxl)

source("setup.r")

path <- setpath("Ohio")
path2 <- stringr::str_replace(path, "Ohio/evaluation", "Ohio/District_teacher_data")

# Read 2013-14 data ------------------------------------------------------------

df <- read_excel(paste(path, 
                       "2014-SY-Ohio-Teacher-and-Principal-Evaluations.xlsx", 
                       sep = "/"), 
                 sheet="Teachers - District") %>%
    rename(localid = `District IRN`,
           name = `District Name`,
           e1 = `Number of Teachers evaluated as Ineffective`,
           e2 = `Number of Teachers evaluated as Developing`,
           e3 = `Number of Teachers evaluated as Skilled`,
           e4 = `Number of Teachers evaluated as Accomplished`)

# any category with less than three teachers is suppressed. I am filling in zeros

Ohio_14 <- df %>% 
  mutate(state="OH",
         name=tolower(name),
         e1=as.numeric(e1),
         e2=as.numeric(e2),
         e3=as.numeric(e3),
         e4=as.numeric(e4),
         
         e1_impute = ifelse(is.na(e1),1,0),
         e1 = ifelse(is.na(e1),0,e1),
         
         e2_impute = ifelse(is.na(e2),1,0),
         e2 = ifelse(is.na(e2),0,e2),
         
         e3_impute = ifelse(is.na(e3),1,0),
         e3 = ifelse(is.na(e3),0,e3),
         
         e4_impute = ifelse(is.na(e4),1,0),
         e4 = ifelse(is.na(e4),0,e4),
         
         et = e1+e2+e3+e4,
         year = 2014) %>% 
  select(state, year, localid, name, e1, e2, e3, e4, et, e1_impute, e2_impute, e3_impute, e4_impute)

# Read District_teacher_data ---------------------------------------------------

# 2017 data
df1 <- read_excel(paste(path2, 
                        "DISTRICT_TEACHER_2017_fin.xls", 
                        sep = "/"), 
                  sheet=1) %>% 
  select(localid = `District IRN`,
         name = `District Name`,
         et = `Average Number of Full Time Teachers`,
         p1 = `% of Teachers  Evaluated as  Ineffective`,
         p2 = `% of Teachers  Evaluated as  Developing`,
         p3 = `% of Teachers  Evaluated as Skilled`,
         p4 = `% of Teachers  Evaluated as  Accomplished`,
         ps = `% of Teachers  Evaluations Not Completed`) %>% 
  mutate(year = 2017, 
         p1=as.numeric(p1) * 100,
         p2=as.numeric(p2) * 100,
         p3=as.numeric(p3) * 100,
         p4=as.numeric(p4) * 100)

# 2018 data
df2 <- read_excel(paste(path2, "DIST_LRC_2018_EDUCATOR_DATA.xlsx",
                        sep = "/"),
                  sheet = 1) %>% 
  select(localid = `District IRN`,
         name = `District Name`,
         et = `FTE Full Time Tchrs`,
         p1 = `Pct Tchrs Evaluated Ineffective`,
         p2 = `Pct Tchrs Evaluated Developing`,
         p3 = `Pct Tchrs Evaluated Skilled`,
         p4 = `Pct Tchrs Evaluated Accomplished`,
         ps = `Pct Tchrs Eval Not Completed`) %>% 
  mutate(year = 2018)

# 2019 data
df3 <- read_excel(paste(path2, "DIST_LRC_2019_EDUCATOR_DATA.xlsx",
                        sep = "/"),
                  sheet = 2) %>%
  select(localid = `District IRN`,
         name = `District Name`,
         et = `Number of Full Time Teachers (FTE)`,
         p1 = `Percent of Teachers Evaluated as Ineffective`,
         p2 = `Percent of Teachers Evaluated as Developing`,
         p3 = `Percent of Teachers Evaluated as Skilled`,
         p4 = `Percent of Teachers Evaluated as Accomplished`,
         ps = `Percent Teachers whose Evaluations were Not Completed`) %>% 
  mutate(year = 2019)

Ohio_dtd <- bind_rows(df1, df2, df3) %>% 
  mutate(name = tolower(name),
         state = "OH") %>% 
  mutate(et = as.numeric(et))

# Combine and save -------------------------------------------------------------

Ohio <-
  bind_rows(Ohio_14, Ohio_dtd) %>% 
  arrange(localid, year)

# checking n obs by years observed
test <- Ohio %>% group_by(localid) %>% mutate(years = paste(year, collapse = ",")) %>% ungroup()
test %>% 
  group_by(years) %>% 
  summarize(
    n = n(),
    sum(et))
check1 <- test %>% filter(years == "2014")
check2 <- test %>% filter(years == "2017,2018,2019") %>% distinct(localid, name)
# The 2014 only seem to be all charter schools
# The 2014 document states that not all district implemented evaluations. 
# We see 'defiance city' has evaluated principals but not teachers in 2014, has
# evaluation data for teachers in 2017+. 
# leaving data as is - will need to be careful when comparing trends from 2014
# to 2017+ due to shift in districts represented. BUT already need to be cautious
# because of time gap. Approximately 82% of teacher count is present in all years.

readr::write_csv(Ohio, "CleanData/OhioEval.csv")
