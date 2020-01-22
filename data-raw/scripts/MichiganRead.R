# Setup ------------------------------------------------------------------------

library(dplyr)
library(readr)

MIpath <- "data-raw/Michigan/evaluation"

# Read -------------------------------------------------------------------------

df <- 
  read.csv(paste0(MIpath, "/EducatorEffectivenessTrend.csv"),
               header = TRUE, skip = 2, nrows = 7093) %>%
  select(year = `School.Year`,
         name = `Location.Name`,
         localid = `Location.Code`,
         et = `Total.Count`,
         e4 = `HighlyEffective.Count`,
         e3 = `Effective.Count`,
         e2 = `MinimallyEffective.Count`,
         e1 = `Ineffective.Count`)

warning("nrows is hardcoded, when updating data remember to increase this value")

toNumber = function(e)
{
  as.numeric(gsub(",", "", e))
}

Michigan <- df %>%
  mutate(
    state = "MI",
    name = tolower(name),
    year = as.numeric(substr(year, 1, 4)) + 1
    ) %>%
  mutate_at(
    vars(et, e1, e2, e3, e4), 
    list(~toNumber(.))
    ) %>%
  filter(name != 'statewide') %>% 
  select("state", "year", "name", "localid", "et", "e4", "e3", "e2", "e1")

write_csv(Michigan, "data-raw/clean_csv_files/MichiganEval.csv")
