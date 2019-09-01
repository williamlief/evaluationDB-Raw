# Setup ------------------------------------------------------------------------

library(dplyr)
library(readxl)
library(readr)

source("setup.r")

path <- setpath("Indiana")
indiana <- substring(path, 1, nchar(path) - nchar("evaluation"))

# Read -------------------------------------------------------------------------

corp.y1 <- read_excel(
  paste(path, "sboe-data-er-data-report-12-13.xlsx", sep = "/"),
  sheet= "12-13 corp level ER data",
  skip=1)

corp.y2 <- read_excel(
  paste(path, "sboeresultsdatareport2013-14.xlsx", sep = "/"),
  sheet= "Corp",
  range=cell_cols("A:I"))

corp.y3 <- read_excel(
  paste(path, "2014-15-evaluation-ratings-er-data-website.xlsx", sep = "/"),
  sheet= "Corporation")

corp.y4 <- read_excel(
  paste(path, "2015-16evaluationratings-er-data.xlsx", sep = "/"),
  "Corporation")

# most recent district directory
directory <- read_excel(paste0(indiana,"/2017-2018-school-directory-2017-08-07.xlsx")) %>% 
    select(corpnum=1,corp=2) %>% 
    mutate(corpnum=as.numeric(corpnum)) %>% 
    arrange(corp)

# stack up the data
# corp
names(corp.y1) <- c("corpnum", "corp", "e4", "e3", "e2", "e1", "unrated", "total")
corp.y1$year = 2013
corp.y1$e4 <- as.numeric(corp.y1$e4)

names(corp.y2) <- c("corpnum", "corp", "corpgrade", "unrated", "e1", "e2", "e3", "e4", "total")
corp.y2$corpnum <- as.numeric(corp.y2$corpnum)
corp.y2$unrated<- as.numeric(corp.y2$unrated)
corp.y2$year = 2014

names(corp.y3) <- c("corp", "e1", "e2", "e3", "e4","unrated", "total")
corp.y3$e1 <- as.numeric(corp.y3$e1)
corp.y3$year = 2015

names(corp.y4) <- c("corp", "e1", "e2", "e3", "e4","unrated", "total")
corp.y4$year = 2016

corp <- bind_rows(corp.y1, corp.y2, corp.y3, corp.y4) %>% 
    select(-corpgrade) %>% 
    left_join(directory, by="corp") %>% 
    mutate(state="IN",
           corpnum=coalesce(corpnum.x,corpnum.y)) %>% 
    select(-corpnum.x, -corpnum.y) %>% 
    mutate(corp = tolower(corp),
           corp = gsub("community", "com", corp),
           corp = gsub("corporation", "corp", corp),
           corp = gsub("district", "dist", corp),
           corp = gsub("school", "sch", corp)) %>% 
    arrange(corp, year) %>% 
    mutate(corpnum = ifelse(corp==lag(corp) & year==2015, lag(corpnum),corpnum),
           corpnum = ifelse(corp==lag(corp) & year==2016, lag(corpnum),corpnum),
           corpnum = as.character(corpnum)) %>% 
    mutate(e1 = ifelse(is.na(e1),0,e1),
           e2 = ifelse(is.na(e2),0,e2),
           e3 = ifelse(is.na(e3),0,e3),
           e4 = ifelse(is.na(e4),0,e4),
           unrated = ifelse(is.na(unrated),0,unrated),
           total = ifelse(is.na(total),0,total)) %>% 
  mutate_if(is.numeric, as.integer) %>% 
  filter(!is.na(corp)&!is.na(corpnum)) %>% 
  select(state, year, localid=corpnum, name=corp, e1, e2, e3, e4, eu=unrated, et=total)

write_csv(corp, "cleanData/IndianaEval.csv")