#### Preamble ####
# Purpose: Tests the analysis_data
# Author: Justin Klip
# Date: 28 November 2024 
# Contact: justin.klip@mail.utoronto.ca
# License: MIT
# Pre-requisites: 03-clean_data.R and it's prerequisites
# Any other information needed? None


#### Workspace setup ####
library(tidyverse)
library(testthat)

data <- read_csv("data/02-analysis_data/analysis_data.csv")


#### Test data ####
# Test that the avg_percent_occupancy is nonnegative, less than or equal 100

# Test nonfatal overdoses is nonnegative

# Test that total_service_user_count is nonnegative

# Check that the is_suspected_non_fatal na is 1 or 0, as it is dummy

# Run the same test but for used_avg_occupancy_rate_beds

# Make sure the dates are just 2021-2023 as that is our data

# Check if that is_suspected_non_fatal_less_than_5 is only 1 or 0.

# Check for Na's in total_service-user_count, overdoses, and occupancy



