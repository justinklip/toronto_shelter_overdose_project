#### Preamble ####
# Purpose: Merges and then cleans the shelter and occupancy data sets to analyze
# Author: Justin Klip 
# Date: 25 November 2024 
# Contact: justin.klip@mail.utoronto.ca 
# License: MIT
# Pre-requisites: 
# - 02-download_data.R is ran, 
# Any other information needed? Make sure you open "toronto_shelter_overdose_project" rproj

#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(gtools)
library(janitor)
#### Retrieve Data ####

occupancy_raw_data <- read_csv("data/01-raw_data/occupancy_raw_data.csv")
overdose_raw_data <- read_csv("data/01-raw_data/overdose_raw_data.csv")

### Clean Data ### 

# Clean column names
occupancy_raw_data <- occupancy_raw_data %>%
  clean_names()
overdose_raw_data <- overdose_raw_data %>%
  clean_names()

# Make sure the years in both data sets align (drop pre-2021 in overdose data)
overdose_raw_data <- overdose_raw_data %>%
  filter(year %in% c(2021, 2022, 2023))

#

### Merge Data ### 

#### Save data ####
write_csv(cleaned_data, "outputs/data/analysis_data.csv")
