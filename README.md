# Conversation Dynamics
SFI Complex System Summer School project

Aim: explore the dynamics of natural language conversations into opinion space.

New Steps:
1. Translate speeches to English
2. Extract relevant speeches using keywords
3. Get exploratory plots
  a. Number of speeches vs time (by party, by politician)
  b. Length of these speeches
4. Get some basic history understanding
  a. Landmark votes
  b. Key parties/players
  c. Important news stories
5. Hand-label some relevant speeches to make validation set (10 per decade?)
6. Improve model
  a. Include wikipedia-neutral corpus into model data 
  b. Train models (basic ones first) 
  c. Test on validation data of speeches
  d. If good:
       Run model on whole dataset
