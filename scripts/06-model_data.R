#### Preamble ####
# Purpose: Models the Effect of Shelter Occupancy on Overdoses
# Author: Justin Klip
# Date: 28 November 2024
# Contact: justin.klip@mail.utoronto.ca
# License: MIT
# Pre-requisites: 03-clean_data.R and it's prerequisites
# Any other information needed? None

#### Load required libraries ####
library(tidyverse)
library(MASS) # For Negative Binomial Regression
library(arrow)
library(here)
library(ggplot2)

#### Read data ####
analysis_data <- read_parquet(here("data", "02-analysis_data", "shelter_analysis_data.parquet"))

#### Prepare data ####

#### Fit Negative Binomial Regression Model ####
nb_model <- glm.nb(suspected_non_fatal_overdoses ~ 
                     total_service_user_count + 
                     avg_occupancy_rate,
                   data = analysis_data)

#### View Model Summary ####
summary(nb_model)

#### Predicted Values ####
# Add predictions to the dataset
analysis_data <- analysis_data %>%
  mutate(predicted_overdoses = predict(nb_model, type = "response"))

#### Visualize Model ####
# Plot observed vs. predicted values
ggplot(analysis_data, aes(x = total_service_user_count)) +
  geom_point(aes(y = suspected_non_fatal_overdoses), color = "blue", alpha = 0.6) +
  geom_line(aes(y = predicted_overdoses), color = "red", size = 1) +
  labs(
    title = "Negative Binomial Regression: Observed vs Predicted",
    x = "Total Quarterly Users",
    y = "Suspected Non-Fatal Overdoses"
  ) +
  theme_minimal()

#linear model
lm_model <- lm(suspected_non_fatal_overdoses ~ 
                 total_service_user_count + 
                 avg_occupancy_rate +
                 used_avg_occupancy_rate_beds +
                 is_suspected_non_fatal_na,
               data = analysis_data)

# View the summary of the model
summary(lm_model)


#### Save model ####
saveRDS(
  first_model,
  file = "models/first_model.rds"
)


