#### Preamble ####
# Purpose: Tests the structure and validity of the simulated occupancy and overdose data
# Date: 25 November 2024
# Contact: justin.klip@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
  # - The `testthat` package must be installed and loaded 
  # - The 'validate' package must be installed and loaded
  # - The 'tidyverse' package must be installed and loaded
  # - 00-simulate_data.R must have been run
# Any other information needed? Make sure you are in the `toronto_shelter_overdose_project` rproj


#### Workspace setup ####
library(testthat)
library(tidyverse)
library(here)

# Load the simulated data
simulated_overdose_data <- read_csv(here("data", "00-simulated_data", "simulated_overdose_data.csv"))
simulated_daily_occupancy_data <- read_csv(here("data", "00-simulated_data", "simulated_daily_occupancy_data.csv"))

#### Loading Test for Both Data Sets ####

# Test if the overdose data was successfully loaded
if (exists("simulated_overdose_data")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}
# Test if the shelter data was successfully loaded
if (exists("simulated_daily_occupancy_data")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}

#### Overdose Data Tests ####

# Check for missing values
test_that("Overdose data has no missing values", {
  expect_false(any(is.na(simulated_overdose_data)))
})

# Check for empty strings
test_that("Overdose data has no empty strings", {
  check_empty_strings <- function(df) {
    sapply(df, function(col) {
      if (is.character(col)) {
        return(any(trimws(col) == ""))
      }
      return(FALSE)
    }) %>% any()
  }
  expect_false(check_empty_strings(simulated_overdose_data))
})

# Check column count
test_that("Overdose data has the correct number of columns", {
  expect_equal(ncol(simulated_overdose_data), 5)
})

# Check column names
test_that("Overdose data has the correct column names", {
  expected_columns <- c("shelter_name", "shelter_address", "year", "quarter", "suspected_overdoses")
  expect_named(simulated_overdose_data, expected_columns)
})

# Check if suspected overdoses are non-negative
test_that("Overdose data has no negative overdose counts", {
  expect_true(all(simulated_overdose_data$suspected_overdoses >= 0))
})
#### Daily Occupancy Data Tests ####

# Check for missing values
test_that("Daily occupancy data has no missing values", {
  expect_false(any(is.na(simulated_daily_occupancy_data)))
})

# Check for empty strings
test_that("Daily occupancy data has no empty strings", {
  check_empty_strings <- function(df) {
    sapply(df, function(col) {
      if (is.character(col)) {
        return(any(trimws(col) == ""))
      }
      return(FALSE)
    }) %>% any()
  }
  expect_false(check_empty_strings(simulated_daily_occupancy_data))
})

# Check column count
test_that("Daily occupancy data has the correct number of columns", {
  expect_equal(ncol(simulated_daily_occupancy_data), 6)
})

# Check column names
test_that("Daily occupancy data has the correct column names", {
  expected_columns <- c("shelter_name", "shelter_address", "date", "total_attendance", "capacity", "program_type")
  expect_named(simulated_daily_occupancy_data, expected_columns)
})

# Check if total attendance is less than or equal to capacity
test_that("Daily occupancy does not exceed capacity", {
  expect_true(all(simulated_daily_occupancy_data$total_attendance <= simulated_daily_occupancy_data$capacity))
})

#We see after the tests, our only issue is with a package, which is fine, so our simulated data is good.