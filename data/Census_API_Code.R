##########################################
# 
# Author: Genevieve Lyons
# Adapted from: Michael Gropper
# Date: 4/29/2020
# Purpose: Pull ZCTA ACS data from API
# Input Data: Census Bureau ACS API
# Output Data: ACS_Tract_Level_Data_2010_2018.rds
#
##########################################


##########################################
## Load up packages, set paths, connect to Census API
##########################################

rm(list = ls())
library(censusapi)
library(tidyverse)
library(readxl)
library(naniar)

# Define paths:
base_path <- c(getwd(), "/") # Personal computer
outpath <- file.path(base_path, "Census_Data")


# Put in Census API key here. You can get it from link on the left hand side of this website, https://www.census.gov/data/developers/guidance/api-user-guide.html
Sys.setenv(CENSUS_KEY="") 

# Reload .Renviron
# readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")

##########################################
## Example API Calls
##########################################

## Look at available APIs
apis <- listCensusApis()
# View(apis)

## Pull some variable groups from the ACS:
acs5_groups <- listCensusMetadata(name = "acs/acs5",
                                vintage = "2010",
                                type = "groups")
# View(acs5_groups) # Want to find table B19013 to get median income.

# Pull geography types:
acs5_geos <- listCensusMetadata(name = "acs/acs5",
                                vintage = "2015",
                                type = "geography")

#### EXAMPLE TO PULL JUST ONE FIELD ####

med_income <- getCensus(name = "acs/acs5",
                        vintage = "2015",
                        vars = c("NAME",
                                 "B19013_001E"),
                        region = "zip code tabulation area:*")

View(med_income)

##########################################
## Determine which variables to pull
##########################################

## Pull the variable list from the ACS:
acs5_vars <- listCensusMetadata(name = "acs/acs5",
                                vintage = "2010",
                                type = "variables")

# Look at the variables (only the main ones)
acs5_vars %>% 
  filter(nchar(acs5_vars$group) == 6) %>% 
  View()

#Determine which variable groups to pull
acs5_groups <- acs5_groups %>% 
  filter(nchar(name) == 6) %>% 
  arrange(name)

# View(acs5_groups)

write_csv(acs5_groups, "Census_variable_groups.csv")

#Manually labeled the variable groups
acs5_groups <- read_excel("Census_variable_groups_withnotations.xlsx")

#Limit to the groups to be included
acs5_groups <- acs5_groups %>% filter(Include_GL == "y") #53 groups to include

#Limit variables to relevant groups
acs5_vars <- acs5_vars %>% filter(group %in% acs5_groups$name) %>% arrange(group, name) 

# View(acs5_vars)

#Write it out to a file
write_csv(acs5_vars, "Census_data_variables.csv")


##########################################
## Pull the data
##########################################

census_data <- getCensus(name = "acs/acs5",
                  vintage = "2015",
                  vars = c("NAME", 
                           "B19013_001E", # Median household income.
                           
                           "B25001_001E", # Housing units.
                           
                           "B02001_001E", # Total population
                           "B02001_002E", # White population
                           "B02001_003E", # Black population
                           "B02001_004E", # American Indian/Alaskan population
                           "B02001_005E", # Asian population
                           "B02001_006E", # Native Hawaiian/pacific islander
                           "B02001_007E", # Some other race
                           "B02001_008E", # Two or more races
                           
                           "B06009_001E", # num pop 25 or over for denominator of education tables.
                           "B06009_002E", # Less than HS
                           "B06009_003E", # HS grad (and equivalent)
                           "B06009_004E", # Some college or assoc
                           "B06009_005E", # Bachelor's degree
                           "B06009_006E",  # Graduate or professional
                           
                           "B01002_001E" #Median Age
                  ),
                  region = "zip code tabulation area:*")

View(census_data)


##########################################
## A quick check on the relationships in NY
##########################################


covid_data <- read_csv("coronavirus-data/tests-by-zcta.csv", col_types = cols(.default = "c"))
covid_data$Positive <- as.numeric(covid_data$Positive)
covid_data$Total <- as.numeric(covid_data$Total)
covid_data$zcta_cum.perc_pos <- as.numeric(covid_data$zcta_cum.perc_pos)

census_data %>% filter(zip_code_tabulation_area %in% covid_data$MODZCTA) %>% View()

covid_census <- left_join(covid_data, census_data, by = c("MODZCTA" = "zip_code_tabulation_area"))

View(covid_census)

#Cases vs Income
plot(log(covid_census$B19013_001E), log(covid_census$Positive))

covid_census %>% ggplot() +
  geom_point(aes(B19013_001E, Positive)) +
  xlab("Income") + 
  ylab("Cases") + 
  scale_x_log10() + 
  scale_y_log10() + 

#Cases vs Race (perc black) 
plot(covid_census$B02001_003E / covid_census$B02001_001E, covid_census$Positive)
plot(covid_census$B02001_003E / covid_census$B02001_001E, covid_census$zcta_cum.perc_pos)

#Cases vs Education (perc grad)
plot(covid_census$B06009_006E / covid_census$B06009_001E, covid_census$Positive)
#Cases vs Education (perc bach)
plot(covid_census$B06009_005E / covid_census$B06009_001E, covid_census$Positive)


##########################################
## Manipulate the data
##########################################

# Replace the large negative sentinel values 
census_data <- replace_with_na_all(census_data, condition = ~.x == -666666666)

#Rename the fields and calculate the percentages
census_data_clean <- census_data %>%
  rename(
    "median_house_income" = "B19013_001E", # Median household income
    "housing_units" = "B25001_001E", # Housing units.
    
    "pop_total" = "B02001_001E", # Total population"
    "excludeme_pop_white" = "B02001_002E", # White population"
    "excludeme_pop_black" = "B02001_003E", # Black population"
    "excludeme_pop_indian_alaskan" = "B02001_004E", # American Indian/Alaskan population"
    "excludeme_pop_asian" = "B02001_005E", # Asian population"
    "excludeme_pop_pacific_islander" = "B02001_006E", # Native Hawaiian/pacific islander"
    "excludeme_pop_other" = "B02001_007E", # Some other race"
    "excludeme_pop_multiple" = "B02001_008E", # Two or more races"
    
    "excludeme_pop_over_25" = "B06009_001E", # num pop 25 or over for denominator of education tables."
    "excludeme_pop_over_25_lt_hs" = "B06009_002E", # Less than HS
    "excludeme_pop_over_25_hs" = "B06009_003E", # HS grad (and equivalent)
    "excludeme_pop_over_25_some_college" = "B06009_004E", # Some college or assoc
    "excludeme_pop_over_25_bachelors" = "B06009_005E", # Bachelor's degree
    "excludeme_pop_over_25_masters_above" = "B06009_006E",  # Graduate or professional
    
    "med_age" = "B01002_001E" #Median Age
  ) %>%
  # Calculate some percentages
  mutate(pop_perc_white = excludeme_pop_white/pop_total,
         pop_perc_black = excludeme_pop_black/pop_total,
         pop_perc_indian_alaskan = excludeme_pop_indian_alaskan/pop_total,
         pop_perc_asian = excludeme_pop_asian/pop_total,
         pop_perc_all_other = (excludeme_pop_other + excludeme_pop_pacific_islander + excludeme_pop_multiple)/pop_total,
         
         pop_perc_under_hs = excludeme_pop_over_25_lt_hs/excludeme_pop_over_25,
         pop_perc_hs = excludeme_pop_over_25_hs/excludeme_pop_over_25,
         pop_perc_some_college = excludeme_pop_over_25_some_college/excludeme_pop_over_25,
         pop_perc_bachelor = excludeme_pop_over_25_bachelors/excludeme_pop_over_25,
         pop_perc_masters_above = excludeme_pop_over_25_masters_above/excludeme_pop_over_25
  ) %>%
  #Only include the cleaned up fields
  select(contains("_")) %>%
  #exclude the excludeme columns
  select(-contains("excludeme"))


View(census_data_clean)


##########################################
## Save the data as csv
##########################################


