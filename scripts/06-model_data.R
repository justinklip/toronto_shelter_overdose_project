#### Preamble ####
# Purpose: Models the Effect of Shelter Occupancy on Overdoses
# Author: Justin Klip
# Date: 28 November 2024
# Contact: justin.klip@mail.utoronto.ca
# License: MIT
# Pre-requisites: 03-clean_data.R and it's prerequisites
# Any other information needed? None


#### Workspace setup ####
library(tidyverse)
library(rstanarm)

#### Read data ####
analysis_data <- read_parquet(here("data", "02-analysis_data", "shelter_analysis_data.parquet"))
### Model data ####


# Model #1, Hurdle Model
library(pscl)

# Ensure suspected_non_fatal_overdoses_numeric column is created properly
analysis_data <- analysis_data %>%
  mutate(suspected_non_fatal_overdoses_numeric = case_when(
    suspected_non_fatal_overdoses == "< 5" ~ NA_real_,  # "< 5" becomes NA
    suspected_non_fatal_overdoses == "0" ~ 0,           # "0" becomes numeric zero
    TRUE ~ as.numeric(suspected_non_fatal_overdoses)    # All other values are converted to numeric
  ))

# Create a binary indicator for zero vs non-zero overdoses
analysis_data <- analysis_data %>%
  mutate(overdose_binary = case_when(
    suspected_non_fatal_overdoses_numeric == 0 ~ 0,           # Zero overdoses
    suspected_non_fatal_overdoses == "< 5" ~ 1,               # "< 5" treated as non-zero (for hurdle part)
    suspected_non_fatal_overdoses_numeric >= 5 ~ 1             # Non-zero overdoses (>= 5)
  ))

# Filter data to only include non-zero overdoses (>=5)
count_data <- analysis_data %>%
  filter(suspected_non_fatal_overdoses_numeric >= 5)

# Fit the hurdle model
model_hurdle <- hurdle(
  suspected_non_fatal_overdoses_numeric ~ avg_occupancy_rate, 
  data = analysis_data, 
  dist = "negbin",   # Negative Binomial for count model (you can also use "poisson" for Poisson regression)
  zero = "binomial"  # Logistic regression for zero vs non-zero part
)


#Model #2

# Install and load the necessary package
library(MASS)

# Assuming your_data is your dataset
# Convert the dependent variable to an ordered factor (adjust levels as needed)
analysis_data$suspected_non_fatal_overdoses <- factor(analysis_data$suspected_non_fatal_overdoses, 
                                                  ordered = TRUE, 
                                                  levels = c("0", "<5", "5", "6", "7", "8", "9", "10"))

# Fit the ordinal logistic regression model
model <- polr(suspected_non_fatal_overdoses ~ avg_occupancy_rate, 
              data = analysis_data, 
              Hess = TRUE)

# View the summary of the model
summary(model)

# Check the Akaike Information Criterion (AIC) for model fit
AIC(model)

# Make predictions on the data (probabilities for each category)
predicted_probs <- predict(model, newdata = analysis_data, type = "probs")

# Display predicted probabilities (optional)
head(predicted_probs)



first_model <-
  stan_glm(
    formula = flying_time ~ length + width,
    data = analysis_data,
    family = gaussian(),
    prior = normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_intercept = normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_aux = exponential(rate = 1, autoscale = TRUE),
    seed = 853
  )


#### Save model ####
saveRDS(
  first_model,
  file = "models/first_model.rds"
)


