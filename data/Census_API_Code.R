##########################################
# 
# Author: Genevieve Lyons
# Adapted from: Michael Gropper
# Date: 4/29/2020
# Purpose: Pull ZCTA ACS data from API
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

# ## Pull the variable list from the ACS:
# acs5_vars <- listCensusMetadata(name = "acs/acs5",
#                                 vintage = "2010",
#                                 type = "variables")
# 
# # Look at the variables (only the main ones)
# acs5_vars %>% 
#   filter(nchar(acs5_vars$group) == 6) %>% 
#   View()
# 
# #Determine which variable groups to pull
# acs5_groups <- acs5_groups %>% 
#   filter(nchar(name) == 6) %>% 
#   arrange(name)
# 
# # View(acs5_groups)
# 
# write_csv(acs5_groups, "Census_variable_groups.csv")
# 
# #Manually labeled the variable groups
# acs5_groups <- read_excel("Census_variable_groups_withnotations.xlsx")
# 
# #Limit to the groups to be included
# acs5_groups <- acs5_groups %>% filter(Include_GL == "y") #53 groups to include
# 
# #Limit variables to relevant groups
# acs5_vars <- acs5_vars %>% filter(group %in% acs5_groups$name) %>% arrange(group, name) 
# 
# # View(acs5_vars)
# 
# #Write it out to a file
# write_csv(acs5_vars, "Census_data_variables.csv")


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
                           
                           "B01002_001E", #Median Age
                           
                           ### Gen's Code here ###
                           "B05001_001E", 
                           "B05001_002E",
                           
                           "B08006_001E",
                           "B08006_002E",
                           "B08006_008E",
                           "B08006_014E",
                           "B08006_015E",
                           "B08006_016E",
                           "B08006_017E",
                           
                           "B08007_001E",
                           "B08007_002E",
                           
                           "B08013_001E",
                           "B08015_001E",
                           
                           "B08302_001E",
                           "B08302_002E",
                           "B08302_003E",
                           "B08302_004E",
                           "B08302_005E",
                           "B08302_006E",
                           "B08302_007E",
                           "B08302_008E",
                           "B08302_009E",
                           "B08302_010E",
                           "B08302_011E",
                           "B08302_012E",
                           "B08302_013E",
                           "B08302_014E",
                           "B08302_015E",
                           
                           "B09010_001E",
                           "B09010_002E",
                           
                           "B11001_001E",
                           "B11001_003E",
                           "B11001_007E",
                           
                           "B12006_001E",
                           "B12006_002E",
                           "B12006_013E",
                           "B12006_024E",
                           "B12006_035E",
                           "B12006_046E",
                           
                           "B12007_001E",
                           "B12007_002E",
                           
                           "B13002_001E",
                           "B13002_003E",
                           "B13002_007E",
                           
                           "B17011_001E",
                           
                           "B17026_001E",
                           "B17026_002E",
                           "B17026_003E",
                           "B17026_004E",
                           "B17026_005E",
                           "B17026_006E",
                           "B17026_007E",
                           "B17026_008E",
                           "B17026_009E",
                           "B17026_010E",
                           "B17026_011E",
                           "B17026_012E",
                           "B17026_013E",
                           
                           ### Gabby's Code here ###
                           "B19052_001E",
                           "B19052_002E",
                           "B19053_001E",
                           "B19053_002E",
                           "B19055_001E",
                           "B19055_002E",
                           "B19056_001E",
                           "B19056_002E",
                           "B19057_001E",
                           "B19057_002E",
                           "B19058_001E",
                           "B19058_002E",
                           "B19059_001E",
                           "B19059_002E",
                           "B23018_001E",
                           "B25002_001E",
                           "B25002_002E",
                           "B25003_001E",
                           "B25003_002E",
                           "B25018_001E",
                           "B25035_001E",
                           "B25058_001E",
                           "B25077_001E",
                           "B25081_001E",
                           "B25081_002E",
                           "B25105_001E",
                           "B99163_001E",
                           "B99163_002E",
                           "C24040_001E",
                           "C24040_002E",
                           "C24040_003E",
                           "C24040_006E",
                           "C24040_007E",
                           "C24040_008E",
                           "C24040_009E",
                           "C24040_010E",
                           "C24040_012E",
                           "C24040_013E",
                           "C24040_014E",
                           "C24040_017E",
                           "C24040_021E",
                           "C24040_024E",
                           "C24040_027E",
                           "C24040_028E",
                           "C24040_029E",
                           "C24040_030E",
                           "C24040_033E",
                           "C24040_034E",
                           "C24040_035E",
                           "C24040_036E",
                           "C24040_037E",
                           "C24040_039E",
                           "C24040_040E",
                           "C24040_041E",
                           "C24040_044E",
                           "C24040_048E",
                           "C24040_051E",
                           "C24040_054E",
                           "C24040_055E"
                           
                  ),
                  region = "zip code tabulation area:*")

View(census_data)


##########################################
## Manipulate the data
##########################################

# Replace the large negative sentinel values (Note: this takes about 10 min to run. Go get a cup of tea.)
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
    
    ### Gen's Code here ###
    
    ## N/A - there were no fields that needed to be renamed but not manipulated
    
    ### Gabby's Code here ###
    
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
         pop_perc_masters_above = excludeme_pop_over_25_masters_above/excludeme_pop_over_25,
         
         ### Gen's Code here ###
         perc_us_citizen = B05001_002E/B05001_001E,
         perc_transport_to_work_car = B08006_002E/B08006_001E,
         perc_transport_to_work_public = B08006_008E/B08006_001E,
         perc_transport_to_work_bike = B08006_014E/B08006_001E,
         perc_transport_to_work_walk = B08006_015E/B08006_001E,
         perc_transport_to_work_taxi = B08006_016E/B08006_001E,
         perc_transport_to_work_workathome = B08006_017E/B08006_001E,
         perc_work_in_state_of_residence = B08007_002E/B08007_001E,
         perc_leave_for_work_12ato459 = B08302_002E/B08302_001E,
         perc_leave_for_work_5to529 = B08302_003E/B08302_001E,
         perc_leave_for_work_530to559 = B08302_004E/B08302_001E,
         perc_leave_for_work_6to629 = B08302_005E/B08302_001E,
         perc_leave_for_work_630to659 = B08302_006E/B08302_001E,
         perc_leave_for_work_7to729 = B08302_007E/B08302_001E,
         perc_leave_for_work_730to759 = B08302_008E/B08302_001E,
         perc_leave_for_work_8to829 = B08302_009E/B08302_001E,
         perc_leave_for_work_830to859 = B08302_010E/B08302_001E,
         perc_leave_for_work_9to959 = B08302_011E/B08302_001E,
         perc_leave_for_work_10to1059 = B08302_012E/B08302_001E,
         perc_leave_for_work_11to1159 = B08302_013E/B08302_001E,
         perc_leave_for_work_12pto359 = B08302_014E/B08302_001E,
         perc_leave_for_work_4pto1159 = B08302_015E/B08302_001E,
         perc_with_Supplemental_Security_Income_cash_public_assistance_income_or_Food_Stamps_SNAP = B09010_002E/B09010_001E,
         perc_married_family = B11001_003E/B11001_001E,
         perc_nonfamily = B11001_007E/B11001_001E,
         perc_never_married = B12006_002E/B12006_001E,
         perc_now_married = B12006_013E/B12006_001E,
         perc_separated = B12006_024E/B12006_001E,
         perc_widowed = B12006_035E/B12006_001E,
         perc_divorced = B12006_046E/B12006_001E,
         med_age_marriage = (B12007_001E+B12007_002E)/2,
         perc_hadbaby_pastyear_married = B13002_003E/B13002_001E,
         perc_hadbaby_pastyear_unmarried = B13002_007E/B13002_001E,
         
         #weighted avg of income to poverty ratio
         weighted_avg_income_to_poverty_ratio = (0.5 * B17026_002E + 0.74 * B17026_003E + 0.99 * B17026_004E + 
                                                 1.24 * B17026_005E + 1.49 * B17026_006E + 1.74 * B17026_007E +
                                                 1.84 * B17026_008E + 1.99 * B17026_009E + 2.99 * B17026_010E + 
                                                 3.99 * B17026_011E + 4.99 * B17026_012E + 6.99 * B17026_013E) / B17026_001E,
         
         #avg of aggregate measures 
         avg_travel_time_to_work_minutes = B08013_001E/excludeme_pop_over_25,
         avg_number_vehicles_count = B08015_001E/excludeme_pop_over_25,
         avg_income_deficit_pastyear = B17011_001E/excludeme_pop_over_25
         
         ### Gabby's Code here ###
         
  ) %>%
  #Only include the cleaned up fields
  select(contains("_")) %>%
  #exclude the excludeme columns
  select(-contains("excludeme")) %>%
  #exclude all the raw columns starting with B or C
  select(-starts_with("B"), -starts_with("C"))


View(census_data_clean)




##########################################
## Save the data as csv
##########################################

write_csv(census_data_clean, "Census_Data_Cleaned.csv")

##########################################
## A few graphs of NYC
##########################################

#Load in the NYC COVID Data
covid_data <- read_csv("coronavirus-data/tests-by-zcta.csv", col_types = cols(.default = "c"))

#Cast values as numeric
covid_data$Positive <- as.numeric(covid_data$Positive)
covid_data$Total <- as.numeric(covid_data$Total)
covid_data$zcta_cum.perc_pos <- as.numeric(covid_data$zcta_cum.perc_pos)

#Join census and covid data
covid_census <- left_join(covid_data, census_data_clean, by = c("MODZCTA" = "zip_code_tabulation_area"))


#Plot: Cases vs Income
covid_census %>% ggplot() +
  geom_point(aes(median_house_income, Positive)) +
  xlab("Income") + 
  ylab("Cases") + 
  scale_x_log10() + 
  scale_y_log10() 

#Plot: Cases vs Income to Poverty Ratio
covid_census %>% ggplot() +
  geom_point(aes(weighted_avg_income_to_poverty_ratio, Positive)) +
  xlab("Weighted Income to Poverty Ratio") + 
  ylab("Cases") + 
  scale_y_log10()

#Plot: Cases vs Travel Time to Work
covid_census %>% ggplot() +
  geom_point(aes(avg_travel_time_to_work_minutes, Positive)) +
  xlab("Average Travel Time to Work") + 
  ylab("Cases") + 
  scale_y_log10()

#Plot: Cases vs # Vehicles
covid_census %>% ggplot() +
  geom_point(aes(avg_number_vehicles_count, Positive)) +
  xlab("Average # Vehicles") + 
  ylab("Cases") + 
  scale_y_log10()

#Plot: Cases vs Income deficit
covid_census %>% ggplot() +
  geom_point(aes(avg_income_deficit_pastyear, Positive)) +
  xlab("Average Income Deficit in Past Year") + 
  ylab("Cases") + 
  scale_x_log10() + 
  scale_y_log10() 
  

#Plot: Cases vs Race (perc black) 
covid_census %>% ggplot() +
  geom_point(aes(pop_perc_black, Positive)) +
  xlab("Percent Black Population") + 
  ylab("Cases") + 
  scale_x_log10() + 
  scale_y_log10()

#Plot: Cases vs Education (perc grad)
covid_census %>% ggplot() +
  geom_point(aes(pop_perc_masters_above, Positive)) +
  xlab("Percent Population with Graduate Degree") + 
  ylab("Cases") + 
  scale_x_log10() + 
  scale_y_log10()

#Plot: Cases vs Education (perc bach)
covid_census %>% ggplot() +
  geom_point(aes(pop_perc_bachelor, Positive)) +
  xlab("Percent Population with Bachelors Degree") + 
  ylab("Cases") + 
  scale_x_log10() + 
  scale_y_log10()

#Plot: Cases vs Education (perc no HS)
covid_census %>% ggplot() +
  geom_point(aes(pop_perc_under_hs, Positive)) +
  xlab("Percent Population with Under High School Degree") + 
  ylab("Cases") + 
  scale_x_log10() + 
  scale_y_log10()




