# Money(ball) is Life – ACC Spread Prediction

This project builds a model to predict NCAA men’s basketball point spreads for ACC games using team efficiency metrics.

The objective is to estimate the expected margin of victory (home score − away score) for upcoming matchups.

---

## Repository Structure

data/  
- `game_scores.csv` – historical game results  
- `2026_team_stats.csv` – team efficiency metrics  

submission/  
- `tsa_pt_spread.csv` – schedule for prediction  

code  
- R scripts for data cleaning, modeling, and prediction  

---

## Method Summary

We train a linear regression model using opponent-adjusted efficiency statistics:

- Adjusted Offensive Efficiency (ADJOE)  
- Adjusted Defensive Efficiency (ADJDE)  
- Adjusted Tempo (ADJT)

Predictors are constructed as **home–away differences** to reflect relative team strength.

Model:
spread ~ adjoe_diff + adjde_diff + barthag_diff + tempo_diff

where:
spread = home_pts − away_pts

---

## Validation

- 80/20 train-test split  
- Mean Absolute Error (MAE) used for evaluation  
- Test MAE ≈ 8 points  

---

## How to Run

1. Open the project in RStudio  
2. Install required packages:
tidyverse
tidymodels
knitr

3. Run the main script to:
- Clean data  
- Train the model  
- Generate predictions  
- Export the submission file  

---

## Team

**(Money)ball is Life**

Joseph Glasson  
Daniel Murong
