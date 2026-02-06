

# Load packages -----------------------------------------------------------

library(tidyverse)
library(tidymodels)
library(knitr)

# Read data ---------------------------------------------------------------

submission <- read_csv("submission/tsa_pt_spread_moneyball_is_life_2026.csv")
games <- read_csv("data/game_scores.csv")
teams <- read_csv("data/2026_team_stats.csv")

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
    away_pts = PTS...3,
    home_pts = PTS...5
  ) %>%
  mutate(
    spread = home_pts - away_pts
  )

games <- games %>% #mismatched college team names
  mutate(
    home_team = case_when(
      home_team == "Ohio State" ~ "Ohio St.",
      home_team == "Pitt" ~ "Pittsburgh",
      home_team == "Miami" ~ "Miami FL",
      home_team == "Miami (FL)" ~ "Miami FL",
      home_team == "NC State" ~ "N.C. State",
      home_team == "Florida State" ~ "Florida St.",
      home_team == "Southern Methodist" ~ "SMU",
      TRUE ~ home_team
    ),
    away_team = case_when(
      away_team == "Ohio State" ~ "Ohio St.",
      away_team == "Pitt" ~ "Pittsburgh",
      away_team == "Miami" ~ "Miami FL",
      away_team == "Miami (FL)" ~ "Miami FL",
      away_team == "NC State" ~ "N.C. State",
      away_team == "Florida State" ~ "Florida St.",
      away_team == "Southern Methodist" ~ "SMU",
      TRUE ~ away_team
    )
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
  drop_na(spread, home_adjoe, away_adjoe)


# Train/test split --------------------------------------------------------

set.seed(123)

split <- initial_split(games_model, prop = 0.8) #80% training data
train_data <- training(split)
test_data <- testing(split)



# Fit model ---------------------------------------------------------------

lm_model <- lm(spread ~ adjoe_diff + adjde_diff + barthag_diff + tempo_diff,
      data = train_data)



# Evaluate ----------------------------------------------------------------


preds <- predict(lm_model, test_data)

mae_vec(
  truth = test_data$spread,
  estimate = as.numeric(preds)
)

#aim for mae_vec ~10-12


# Predict submission ------------------------------------------------------

# Normalize submission team names to match teams_small$team
# 1) Remove completely blank rows (these are creating NA teams)
submission <- submission %>%
  filter(!if_all(everything(), is.na))

# 2) Normalize team names so they match teams_small$team
submission <- submission %>%
  mutate(
    Home = case_when(
      Home == "Ohio State" ~ "Ohio St.",
      Home == "Pitt" ~ "Pittsburgh",
      Home == "Miami" ~ "Miami FL",
      Home == "Miami (FL)" ~ "Miami FL",
      Home == "NC State" ~ "N.C. State",
      Home == "Florida State" ~ "Florida St.",
      Home == "Southern Methodist" ~ "SMU",
      TRUE ~ Home
    ),
    Away = case_when(
      Away == "Ohio State" ~ "Ohio St.",
      Away == "Pitt" ~ "Pittsburgh",
      Away == "Miami" ~ "Miami FL",
      Away == "Miami (FL)" ~ "Miami FL",
      Away == "NC State" ~ "N.C. State",
      Away == "Florida State" ~ "Florida St.",
      Away == "Southern Methodist" ~ "SMU",
      TRUE ~ Away
    )
  )

# Build the same features for submission games
submission_games <- submission %>%
  rename(away_team = Away, home_team = Home) %>%
  left_join(teams_small, by = c("home_team" = "team")) %>%
  rename_with(~paste0("home_", .), adjoe:adjt) %>%
  left_join(teams_small, by = c("away_team" = "team")) %>%
  rename_with(~paste0("away_", .), adjoe:adjt) %>%
  mutate(
    adjoe_diff = home_adjoe - away_adjoe,
    adjde_diff = home_adjde - away_adjde,
    barthag_diff = home_barthag - away_barthag,
    tempo_diff = home_adjt - away_adjt
  )

# Predict and fill pt_spread
submission$pt_spread <- as.numeric(predict(lm_model, submission_games))

# Quick checks
sum(is.na(submission$pt_spread))      # should be 0
summary(submission$pt_spread)

# Export
write_csv(submission, "FINAL_SUBMISSION.csv")
