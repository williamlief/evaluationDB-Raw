# Setup ------------------------------------------------------------------------

library(dplyr)
library(readxl)
library(readr)
library(pdftools)
library(stringr)

path <- "data-raw/Florida/evaluation"

# Read -------------------------------------------------------------------------

# EvaluationRatings.pdf # 2012
# EduEvalRatings.pdf # 2013
# 1314EduEvalRatings.pdf # 2014
# 1415DistEduEvalRate.pdf # 2015
# 1516DistEduEvalRate.xls # 2016
# 1617DistEduEvalRate.xls # 2017


## Deal with the pdf files. 
# 1 parse pdf text
# 2 clean text
# 3 read in

# 1 parse pdf
text <- list() # text stores all the pdf data
text[[1]] <- pdf_text(paste(path, "EvaluationRatings.pdf", sep = "/"))
text[[2]] <- pdf_text(paste(path, "EduEvalRatings.pdf", sep = "/"))
text[[3]] <- pdf_text(paste(path, "1314EduEvalRatings.pdf", sep = "/"))
text[[4]] <- pdf_text(paste(path, "1415DistEduEvalRate.pdf", sep = "/"))

# 2 clean text
text_read <- list()
text_read[[1]] <- list()
text_read[[1]][1] <- text[[1]][1] # first datafile is split on two pages
text_read[[1]][2] <- text[[1]][2]
text_read[[2]] <- text[[2]][2] # second is one page, but the second page
text_read[[3]] <- text[[3]][1] # third is one page
text_read[[4]] <- text[[4]][1] # fourth is one page

# format cleanup for parsing use '-' as delim because commas in numbers
text_read[[1]] <- lapply(text_read[[1]], str_replace_all, "([a-zA-Z.])(\\s)([a-zA-Z.])", "\\1_\\3")
text_read[2:4] <- lapply(text_read[2:4], str_replace_all, "([a-zA-Z.])(\\s)([a-zA-Z.])", "\\1_\\3")


# 3 Read into csv format
parse <- list()

parse[[1]] <- bind_rows(
  read.csv(text = text_read[[1]][[1]],  skip = 2, head = FALSE, sep = "", colClasses = "character"),
  read.csv(text = text_read[[1]][[2]],  skip = 0, head = FALSE, sep = "", colClasses = "character") 
) %>% 
  rename(localid = V1, 
         name = V2, 
         e4 = V3, 
         e3 = V4, 
         e2.1 = V5, 
         e2.2 = V6, 
         e1 = V7, 
         eu = V8,
         et = V9) %>% 
  filter(localid != "STATE") %>% 
  mutate(year = 2012)


parse[[2]] <- 
  read.csv(text = text_read[[2]], skip = 2, head = FALSE, sep = "", colClasses = "character") %>% 
  select(localid = V1, 
         name = V2, 
         e4 = V3, 
         e3 = V4, 
         e2.1 = V5, 
         e2.2 = V6, 
         e1 = V7, 
         eu = V8,
         et = V9) %>% 
  filter(localid != "State") %>% 
  mutate(year = 2013)


parse[[3]] <- 
  read.csv(text = text_read[[3]], skip = 3, head = FALSE, sep = "", colClasses = "character") %>% 
  select(localid = V1, 
         name = V2, 
         e4 = V3, 
         e3 = V4, 
         e2.1 = V5, 
         e2.2 = V6, 
         e1 = V7, 
         eu = V8,
         et = V9) %>% 
  filter(localid != "Statewide_Total") %>% 
  mutate(year = 2014)


parse[[4]] <- 
  read.csv(text = text_read[[4]], skip = 6, head = FALSE, sep = "", colClasses = "character") %>% 
  select(localid = V1, 
         name = V2, 
         e4 = V3, 
         e3 = V5, 
         e2.1 = V7, 
         e2.2 = V9, 
         e1 = V11, 
         eu = V13,
         et = V15) %>% 
  filter(localid != "STATEWIDE_TOTAL", 
         localid != "Page") %>% 
  mutate(year = 2015)

# Process Excel files - finally some consistent formatting
excel_parse <- function(filename, skip, year) {
  read_excel(paste(path, filename, sep = "/"),
             sheet="Clsrm Tchrs - Pct by Dist", skip = skip, 
             col_types = "text") %>% 
    select(localid = ...1, 
           name = ...2, 
           e4 = N...3, 
           e3 = N...5, 
           e2.1 = N...7, 
           e2.2 = N...9, 
           e1 = N...11, 
           eu = ...13,
           et = ...15) %>% 
    filter(name != "STATEWIDE TOTAL") %>% 
    mutate(year = !!year)
}

parse[[5]] <- 
  excel_parse("1516DistEduEvalRate.xls", 2, 2016)
  
parse[[6]] <- 
  excel_parse("1617DistEduEvalRate.xls", 2, 2017)

parse[[7]] <- 
  excel_parse("1718DistEduEvalRate.xls", 3, 2018)


# Combine and clean up
df <- bind_rows(parse) %>% 
  mutate_at(vars(starts_with("e")), function(x) {as.numeric(gsub(",", "", x))}) %>% 
  mutate(e2 = e2.1+e2.2,   # Florida splits developing category for early career teachers
         name = tolower(name),
         state = "FL") %>%
  select(-e2.1, -e2.2)

write_csv(df, "data-clean/FloridaEval.csv")
