#### Preamble ####
# Purpose: Downloads and saves the data from Open Data Toronto
# Author: Justin Klip 
# Date: 20 November 2024
# Contact: justin.klip@mail.utoronto.ca
# License: MIT
# Pre-requisites: None
# Any other information needed?: Make sure you are in the `toronto_shelter_overdose_project` rproj


#### Workspace setup ####
library(opendatatoronto)
library(tidyverse)
library(dplyr)
library(gtools)

#### Download data for Overdoses ####

# get package
package <- show_package("0d1fb545-d1b2-4e0a-b87f-d8a1835e5d85")
package

# get all resources for this package
resources <- list_package_resources("0d1fb545-d1b2-4e0a-b87f-d8a1835e5d85")

# identify datastore resources; by default, Toronto Open Data sets datastore resource format to CSV for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))

# load the second datastore, which has quarterly data by shelter
overdose_raw_data <- filter(datastore_resources, row_number()==2) %>% get_resource()
overdose_raw_data

#### Save data ####
write_csv(overdose_raw_data, "data/01-raw_data/overdose_raw_data.csv") 

### Do the same for the shelter occupancy data

# get package
package <- show_package("21c83b32-d5a8-4106-a54f-010dbe49f6f2")
package

# get all resources for this package
resources <- list_package_resources("21c83b32-d5a8-4106-a54f-010dbe49f6f2")

# identify datastore resources; by default, Toronto Open Data sets datastore resource format to CSV for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))

# load the 2021-2023 datastore (as that is the limit of our overdose data)
occupancy_raw_data_2023 <- filter(datastore_resources, row_number()==2) %>% get_resource()
occupancy_raw_data_2022 <- filter(datastore_resources, row_number()==3) %>% get_resource()
occupancy_raw_data_2021 <- filter(datastore_resources, row_number()==4) %>% get_resource()

# Append the daily occupancy data so it's all in one data set

occupancy_raw_data <- bind_rows(
  occupancy_raw_data_2023,
  occupancy_raw_data_2022,
  occupancy_raw_data_2021
)

#### Save data ####
write_csv(occupancy_raw_data, "data/01-raw_data/occupancy_raw_data.csv") 

         
