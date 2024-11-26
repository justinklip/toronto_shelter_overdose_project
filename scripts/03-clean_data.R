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

### Retrieve the Data ### 

occupancy_raw_data_2021 <- read_csv("data/01-raw_data_2021.csv")
occupancy_raw_data_2022 <- read_csv("data/01-raw_data_2022.csv")
occupancy_raw_data_2023 <- read_csv("data/01-raw_data_2023.csv")

#### Merge Shelter Data ####
occupancy_data <- bind_rows(
  occupancy_raw_data_2023,
  occupancy_raw_data_2022,
  occupancy_raw_data_2021
)


#### Clean data ####


occupancy_raw_data <- 
overdose_raw_data <- read_csv("/data/01-raw_data.csv")

### Append the Occupancy Data Together ### 
smartbind(occupancy_raw_data_2021, occupancy_raw_data_2022, occupancy_raw_data_2023)

cleaned_data <-
  raw_data |>
  janitor::clean_names() |>
  select(wing_width_mm, wing_length_mm, flying_time_sec_first_timer) |>
  filter(wing_width_mm != "caw") |>
  mutate(
    flying_time_sec_first_timer = if_else(flying_time_sec_first_timer == "1,35",
                                   "1.35",
                                   flying_time_sec_first_timer)
  ) |>
  mutate(wing_width_mm = if_else(wing_width_mm == "490",
                                 "49",
                                 wing_width_mm)) |>
  mutate(wing_width_mm = if_else(wing_width_mm == "6",
                                 "60",
                                 wing_width_mm)) |>
  mutate(
    wing_width_mm = as.numeric(wing_width_mm),
    wing_length_mm = as.numeric(wing_length_mm),
    flying_time_sec_first_timer = as.numeric(flying_time_sec_first_timer)
  ) |>
  rename(flying_time = flying_time_sec_first_timer,
         width = wing_width_mm,
         length = wing_length_mm
         ) |> 
  tidyr::drop_na()

#### Save data ####
write_csv(cleaned_data, "outputs/data/analysis_data.csv")
