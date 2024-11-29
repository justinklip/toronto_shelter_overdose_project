#### Preamble ####
# Purpose: Tests the analysis_data
# Author: Justin Klip
# Date: 28 November 2024 
# Contact: justin.klip@mail.utoronto.ca
# License: MIT
# Pre-requisites: 03-clean_data.R and it's prerequisites
# Any other information needed? Make sure you open "toronto_shelter_overdose_project" rproj


#### Workspace setup ####
library(tidyverse)
library(testthat)
library(here)
library(arrow)

analysis_data <- read_parquet(here("data", "02-analysis_data", "shelter_analysis_data.parquet"))


#### Test data ####

# Define tests
test_that("Data validation tests", {
  
  # Test that avg_percent_occupancy is nonnegative and <= 100
  expect_true(all(analysis_data$avg_occupancy_rate >= 0, na.rm = TRUE), 
              "avg_occupancy_rate contains negative values")
  expect_true(all(analysis_data$avg_occupancy_rate <= 100, na.rm = TRUE), 
              "avg_occupancy_rate exceeds 100")
  
  # Test that nonfatal overdoses is nonnegative
  expect_true(all(analysis_data$non_fatal_overdoses >= 0, na.rm = TRUE), 
              "non_fatal_overdoses contains negative values")
  
  # Test that total_service_user_count is nonnegative
  expect_true(all(analysis_data$total_service_user_count >= 0, na.rm = TRUE), 
              "total_service_user_count contains negative values")
  
  # Check that is_suspected_non_fatal_na is 1 or 0
  expect_true(all(analysis_data$is_suspected_non_fatal_na %in% c(0, 1)), 
              "is_suspected_non_fatal_na is not a dummy variable")
  
  # Check that used_avg_occupancy_rate_beds is 1 or 0
  expect_true(all(analysis_data$used_avg_occupancy_rate_beds %in% c(0, 1)), 
              "used_avg_occupancy_rate_beds is not a dummy variable")
  
  # Ensure year is 2021, 2022, or 2023
  valid_years <- c(2021, 2022, 2023)
  expect_true(all(analysis_data$year %in% valid_years), 
              "Year contains values outside 2021-2023")
  
  # Check that is_suspected_non_fatal_less_than_5 is 1 or 0
  expect_true(all(analysis_data$is_suspected_non_fatal_less_than_5 %in% c(0, 1)), 
              "is_suspected_non_fatal_less_than_5 is not a dummy variable")
  
  # Check for NAs in key variables
  key_vars <- c("total_service_user_count", "suspected_non_fatal_overdoses", "avg_occupancy_rate")
  for (var in key_vars) {
    expect_false(any(is.na(analysis_data[[var]])), 
                 paste(var, "contains NA values"))
  }
})

# No big errors, so can proceed to analysis.