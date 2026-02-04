

# Load packages -----------------------------------------------------------

library(tidyverse)
library(tidymodels)
library(knitr)

# Tidy data ---------------------------------------------------------------

submission <- read_csv("submission/tsa_pt_spread_moneyball_is_life_2026.csv")

acc_teams <- c(
  "Duke","UNC","Virginia","Virginia Tech","NC State",
  "Wake Forest","Clemson","Louisville","Miami",
  "Florida State","Georgia Tech","Pitt",
  "Boston College","Notre Dame","Syracuse","SMU"
)





