# Setup ------------------------------------------------------------------------

library(dplyr)
library(readxl)
library(readr)

path <- "data-raw/Indiana/evaluation"
indiana <- substring(path, 1, nchar(path) - nchar("evaluation"))

# Read -------------------------------------------------------------------------

data <- list()

data[[1]] <- 
  read_excel(
    paste(path, "sboe-data-er-data-report-12-13.xlsx", sep = "/"),
    sheet= "12-13 corp level ER data",
    skip=1, 
    col_types = "text") %>% 
  rename(
    district = `CORP #`, 
    name = `CORPORATION NAME`, 
    e1 = INEFFECTIVE,
    e2 = `IMPROVEMENT NECESSARY`, 
    e3 = `EFFECTIVE`, 
    e4 = `HIGHLY EFFECTIVE`, 
    eu = `NA`, 
    et = `TOTAL EDUCATORS REPORTED`
  ) %>% 
  mutate(year = 2013)

data[[2]] <- 
  read_excel(
    paste(path, "sboeresultsdatareport2013-14.xlsx", sep = "/"),
    sheet= "Corp",
    range=cell_cols("A:I"), 
    col_types = "text") %>% 
  rename(
    district = `Corp`, 
    name = `Corp Name`, 
    e1 = `1-Ineffective`,
    e2 = `2-Needs Improvement`, 
    e3 = `3-Effective`, 
    e4 = `4-Highly Effective`, 
    eu = `0-N/A`, 
    et = `Total`
  ) %>% 
  mutate(year = 2014) %>% 
  select(-`Corp Grade`) %>% 
  filter(!is.na(name))

data[[3]] <- 
  read_excel(
    paste(path, "2014-15-evaluation-ratings-er-data-website.xlsx", sep = "/"),
    sheet= "Corporation", 
    col_types = "text") %>% 
  rename(
    name = `CorpName`, 
    e1 = `Ineffective\r\n(1)`  ,
    e2 = `Improvement \r\nNecessary\r\n(2)`, 
    e3 = `Effective \r\n(3)`, 
    e4 = `Highly \r\nEffective\r\n(4)`, 
    eu = `Not Rated`, 
    et = `Grand Total`
  ) %>% 
  mutate(year = 2015)

data[[4]] <- 
  read_excel(
    paste(path, "2015-16evaluationratings-er-data.xlsx", sep = "/"),
    sheet = "Corporation", 
    col_types = "text") %>% 
  rename(
    name = `Corporation Name`, 
    e1 = `Ineffective \r\n(1)`  ,
    e2 = `Improvement Necessary \r\n(2)`, 
    e3 = `Effective \r\n(3)`, 
    e4 = `Highly Effective \r\n(4)`, 
    eu = `Not Rated`, 
    et = `Grand Total`
  ) %>% 
  mutate(year = 2016)

# Data format becomes more consistent
er_report_read <- function(filename, sheet = "Corporation") {
  read_excel(
    path = paste(path, filename, sep = "/"), 
    sheet = sheet, 
    col_types = "text",
    skip = 1
  ) %>% 
    select(
      name = `Corporation Name`, 
      e1 = Ineffective,
      e2 = `Needs Improvement`, 
      e3 = `Effective`, 
      e4 = `Highly Effective`,
      eu = `Not Rated`,
      et = `Grand Total`
    )
}

data[[5]] <- 
  er_report_read("er-report-final.xlsx") %>% 
  mutate(year = 2017)

data[[6]] <- 
 er_report_read("17-18-er-data.xlsx") %>% 
  mutate(year = 2018)

data[[7]] <- 
  er_report_read("er-report-18-19-sboe.xlsx", sheet = "Corportation") %>% 
  mutate(year = 2019)

# district directory to merge on district numbers
directory <- read_excel(paste0(indiana,"/2017-2018-school-directory-2017-08-07.xlsx"),
                        col_types = 'text') %>% 
    select(district=`IDOE CORPORATION ID`,
           name = `CORPORATION NAME`) %>% 
    arrange(district)

# stack up the data, fill in nces ids
df <- bind_rows(data) %>% 
  filter(!name %in% c("Grand Total", "(blank)")) %>% 
  mutate(name = case_when(
    name == "North Gibson School Corporation" ~ "North Gibson School Corp",
    name == "Evansville Vanderburgh Sch Corp" ~ "Evansville Vanderburgh School Corp",
    name == "Garrett-Keyser-Butler Com" ~ "Garrett-Keyser-Butler Com Sch Corp",
    name == "Lewis Cass Schools" ~ "Southeastern School Corp",
    TRUE ~ name
  )) %>% 
  left_join(directory, by = "name") %>% 
  mutate(state="IN",
         district =coalesce(district.x, district.y)) %>% 
  select(-district.x, -district.y) %>% 
  arrange(name, year) %>% 
  mutate(district = if_else(is.na(district) & name == lag(name), lag(district), district))

test <- df %>% filter(is.na(district))

# convert numeric
na_conv <- function(x) {
  x = ifelse(tolower(x) == 'less than 10 educators reported', NA, x)
  as.numeric(x)
}

df2 <- df %>% 
  mutate_at(
    vars(e1, e2, e3, e4, eu, et),
    na_conv
  ) %>% 
  rename(localid = district)

write_csv(df2, "data-raw/clean_csv_files/IndianaEval.csv")