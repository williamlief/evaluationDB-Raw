source("setup.r")

path <- setpath("Rhode Island")

library(dplyr)
library(readxl)
library(tidyr)
library(readr)
library(stringr)

df <- read_excel(paste(path, 
                        "numbers of educators by YR-LEA-FERating-ToSend.xlsx", 
                        sep = "/"), 
                  sheet=1) %>% 
  rename(name = `Row Labels`,
         e4 = `HE`,
         e3 = `E`,
         e2 = `D`,
         e1 = `I`,
         es = `Not available`,
         et = `Grand Total`)

RhodeIsland <- df %>% 
  mutate(year = as.numeric(substr(name, 1, 4)) + 1,
         localid = str_split(name, "\\|")[2])

         