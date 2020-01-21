path <- "data-raw/Rhode Island/evaluation"

library(dplyr)
library(readxl)
library(tidyr)
library(readr)

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

toNumber = function(e)
{
  as.numeric(gsub(",", "", e))
}

RhodeIsland <- df %>% 
  separate(name, c("year", "localid", "name"), sep = "\\|") %>% 
  mutate(year = as.numeric(substr(year, 1, 4)),
         name = tolower(name)) %>% 
  mutate_at(
    vars(e4, e3, e2, e1, es, et), 
    list(~toNumber(.))
  ) %>% 
  select(year, localid, name, e4, e3, e2, e1, es, et)

write_csv(RhodeIsland, "data-clean/RhodeIslandEval.csv")
