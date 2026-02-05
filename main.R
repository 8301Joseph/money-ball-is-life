

# Load packages -----------------------------------------------------------

library(tidyverse)
library(tidymodels)
library(knitr)

# Read data ---------------------------------------------------------------

submission <- read_csv("submission/tsa_pt_spread_moneyball_is_life_2026.csv")
games <- read_csv("game_scores.csv")
teams <- read_csv("2026_team_stats.csv")

acc_teams <- c(
  "Duke","UNC","Virginia","Virginia Tech","NC State",
  "Wake Forest","Clemson","Louisville","Miami",
  "Florida State","Georgia Tech","Pitt",
  "Boston College","Notre Dame","Syracuse","SMU"
)


# Create target (Spread) --------------------------------------------------

games <- games %>%
  rename(
    away_team = `Visitor/Neutral`,
    home_team = `Home/Neutral`,
    away_pts = PTS,
    home_pts = PTS.1
  ) %>%
  mutate(
    spread = home_pts - away_pts
  )


# Join team stats ---------------------------------------------------------

teams_small <- teams %>% #useful team stats
  select(team, adjoe, adjde, barthag, adjt)

# ADJOE — Adjusted Offensive Efficiency (Points scored per 100 possessions, 
#                                       adjusted for opponent quality.)
# ADJDE — Adjusted Defensive Efficiency (Points allowed per 100 possessions, 
#                                       adjusted for opponent quality.)
# BARTHAG — Power Rating (Pythagorean formula combining ADJOE and ADJDE)
# ADJT — Adjusted Tempo (Possessions per 40 minutes, adjusted for opponents.)


games_joined <- games %>%
  left_join(teams_small, by = c("home_team" = "team")) %>%
  rename_with(~paste0("home_", .), adjoe:adjt) %>%
  left_join(teams_small, by = c("away_team" = "team")) %>%
  rename_with(~paste0("away_", .), adjoe:adjt)


# Build variables ---------------------------------------------------------

games_model <- games_joined %>%
  mutate(
    adjoe_diff = home_adjoe - away_adjoe,
    adjde_diff = home_adjde - away_adjde,
    barthag_diff = home_barthag - away_barthag,
    tempo_diff = home_adjt - away_adjt
  ) %>%
  drop_na()


# Train/test split --------------------------------------------------------

set.seed(123)

split <- initial_split(games_model, prop = 0.8) #80% training data
train_data <- training(split)
test_data <- testing(split)



# Fit model ---------------------------------------------------------------

lm_model <- linear_reg() %>%
  set_engine("lm") %>%
  fit(spread ~ adjoe_diff + adjde_diff + barthag_diff + tempo_diff,
      data = train_data)




