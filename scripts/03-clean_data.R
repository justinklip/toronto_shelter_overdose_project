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
library(arrow)
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

# Aggregate the occupancy data quarterly

# Convert occupancy_date to Date type
occupancy_data <- occupancy_raw_data %>%
  mutate(occupancy_date = as.Date(occupancy_date))

# Add year and quarter columns with full four-digit years
occupancy_data <- occupancy_data %>%
  mutate(
    year = year(occupancy_date),
    year = ifelse(year < 100, year + 2000, year),  # Convert 2-digit years to 4-digit
    year_stage = paste0("Q", quarter(occupancy_date))
  )

# Aggregate the data quarterly by address
aggregated_data <- occupancy_data %>%
  group_by(location_address, year, year_stage) %>%
  summarize(
    total_service_user_count = sum(service_user_count, na.rm = TRUE),
    avg_occupancy_rate_beds = mean(occupancy_rate_beds, na.rm = TRUE),
    avg_occupancy_rate_rooms = mean(occupancy_rate_rooms, na.rm = TRUE),
    .groups = "drop"  # Ungroup after summarizing
  )

# View the aggregated result
print(aggregated_data)

aggregated_data <- aggregated_data %>%
  rename(address = location_address)
### Merge Data ### 
# Ensure both datasets have the same key columns
overdose_raw_data <- overdose_raw_data %>%
  mutate(
    year = as.integer(year),
    year_stage = as.character(year_stage),
    address = as.character(address)  # Ensure 'address' matches in type
  )

aggregated_data <- aggregated_data %>%
  mutate(
    year = as.integer(year),
    year_stage = as.character(year_stage),
    address = as.character(address)  # Ensure 'address' matches in type
  )

# Perform the merge
merged_data <- inner_join(aggregated_data, overdose_raw_data, by = c("address", "year", "year_stage"))


# Create the dummy variable globally for each address
merged_data <- merged_data %>%
  group_by(address) %>%
  mutate(
    is_suspected_non_fatal_na = ifelse(any(is.na(suspected_non_fatal_overdoses)), 1, 0)
  ) %>%
  ungroup()

# Drop rows where non_fatal_overdoses is NA
merged_data <- merged_data %>%
  filter(!is.na(suspected_non_fatal_overdoses))


#Drop if address is NA
cleaned_data <- merged_data %>%
  filter(!is.na(address))

# We prefer bed level data, but if not, we can also use room level
# Generate avg_occupancy_rate and associated dummies
merged_data <- merged_data %>%
  mutate(
    avg_occupancy_rate = ifelse(!is.na(avg_occupancy_rate_beds), avg_occupancy_rate_beds, avg_occupancy_rate_rooms),
    used_avg_occupancy_rate_beds = ifelse(!is.na(avg_occupancy_rate_beds), 1, 0),
    used_avg_occupancy_rate_rooms = ifelse(is.na(avg_occupancy_rate_beds) & !is.na(avg_occupancy_rate_rooms), 1, 0)
  )

merged_data <- merged_data %>%
  mutate(
    is_suspected_non_fatal_less_than_5 = ifelse(suspected_non_fatal_overdoses == "< 5", 1, 0)
  )

cleaned_data <- merged_data %>%
  dplyr::select(-avg_occupancy_rate_beds, -avg_occupancy_rate_rooms, -id, -used_avg_occupancy_rate_rooms)


# Sample data frame

# Function to get the number of days in a quarter
get_days_in_quarter <- function(quarter) {
  switch(quarter,
         "Q1" = 31 + 28 + 31,  # January + February + March
         "Q2" = 30 + 31 + 30,  # April + May + June
         "Q3" = 31 + 31 + 30   # July + August + September
  )
}

# Add a column for the number of days in each quarter
cleaned_data$days_in_quarter <- sapply(cleaned_data$year_stage, get_days_in_quarter)

# Calculate average service user count per day
cleaned_data$daily_avg_users <- cleaned_data$total_service_user_count / cleaned_data$days_in_quarter

cleaned_data <- cleaned_data %>%
  dplyr::select(-days_in_quarter)


# Ensure `daily_avg_users` is numeric
cleaned_data <- cleaned_data %>%
  mutate(daily_avg_users = as.numeric(daily_avg_users))


# View the result
print(cleaned_data)


#### Save data ####
write_parquet(cleaned_data, "data/02-analysis_data/shelter_analysis_data.parquet")
