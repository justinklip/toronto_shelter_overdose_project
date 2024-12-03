#### Preamble ####
# Purpose: Simulates a dataset with the shelters with overdose amounts and quarter.
# Author: Justin Klip
# Date: 25 November 2024
# Contact: justin.klip@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse` package must be installed
# Any other information needed? Make sure you are in the `toronto_shelter_overdose_project` rproj


#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(MASS)
set.seed(314)


#### Data Expectations #### 
## Overdose Data: ##
# Shelter Name
# Shelter Address
# Year
# Quarter
# Suspected number of overdoses

## Daily Shelter Occupancy Data: ##
# Shelter Name
# Shelter Address
# Date (Daily)
# Total Attendance
# Capacity
# Program Type (e.g domestic violence, emergency, refugee, homeless)

#### Toronto Shelter Information ####
toronto_shelters <- tibble(
  shelter_id = 1:10,
  shelter_name = c(
    "Seaton House", "Scarborough Village Residence", "Birkdale Residence", 
    "Covenant House", "The Salvation Army Gateway", "Women's Residence",
    "Fred Victor Centre", "Homes First Society", "Sojourn House", "Eva's Place"
  ),
  shelter_address = c(
    "339 George St, Toronto, ON", "3306 Kingston Rd, Scarborough, ON", 
    "1229 Ellesmere Rd, Scarborough, ON", "20 Gerrard St E, Toronto, ON", 
    "107 Jarvis St, Toronto, ON", "674 Dundas St W, Toronto, ON",
    "145 Queen St E, Toronto, ON", "800 Adelaide St W, Toronto, ON", 
    "101 Ontario St, Toronto, ON", "360 Lesmill Rd, North York, ON"
  ),
  # Generate random capacities with mean = 200 and sd = 50, rounded to nearest integer
  capacity = round(rnorm(10, mean = 200, sd = 50)),
  program_type = c(
    "Homeless", "Emergency", "Domestic Violence", "Youth", 
    "Homeless", "Women's Emergency", "Homeless", "Refugee", 
    "Refugee", "Youth"
  )
)

#### Overdose Data Simulation ####
simulate_overdose_data <- function(shelters, years = 2021:2024) {
  # Generate overdose data by year and quarter
  overdose_data <- expand.grid(
    year = years,
    quarter = 1:4,
    shelter_id = shelters$shelter_id
  ) %>%
    left_join(shelters, by = "shelter_id") %>%
    mutate(
      suspected_overdoses = round(rnorm(n = n(), mean = 5, sd = 3)),
      suspected_overdoses = pmax(0, suspected_overdoses) # No negative overdoses
    ) %>%
    select(shelter_name, shelter_address, year, quarter, suspected_overdoses)
  
  return(overdose_data)
}

#### Daily Shelter Occupancy Data Simulation ####
simulate_daily_occupancy_data <- function(shelters, start_date = "2021-01-01", end_date = "2024-12-31") {
  # Generate daily data for each shelter
  daily_data <- expand.grid(
    date = seq.Date(from = as.Date(start_date), to = as.Date(end_date), by = "day"),
    shelter_id = shelters$shelter_id
  ) %>%
    left_join(shelters, by = "shelter_id") %>%
    mutate(
      # Generate total attendance below capacity
      total_attendance = round(runif(n = n(), min = 0.5 * capacity, max = capacity)),
      total_attendance = pmin(total_attendance, capacity) # Ensure attendance ≤ capacity
    ) %>%
    select(shelter_name, shelter_address, date, total_attendance, capacity, program_type)
  
  return(daily_data)
}

#### Simulate and Combine Data ####
# Simulate Overdose Data
simulated_overdose_data <- simulate_overdose_data(shelters = toronto_shelters, years = 2021:2024)

# Simulate Daily Shelter Occupancy Data
simulated_daily_occupancy_data <- simulate_daily_occupancy_data(shelters = toronto_shelters, start_date = "2021-01-01", end_date = "2024-12-31")

# Output Preview
print("Overdose Data Sample:")
print(head(simulated_overdose_data))

print("Daily Shelter Occupancy Data Sample:")
print(head(simulated_daily_occupancy_data))

#### Save data ####
write_csv(simulated_overdose_data, "data/00-simulated_data/simulated_overdose_data.csv")
write_csv(simulated_daily_occupancy_data, "data/00-simulated_data/simulated_daily_occupancy_data.csv")
