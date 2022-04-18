# kPred

This R script simulates the strikeout totals of MLB starting pitchers based on the K% of the starting pitcher and the K% of each batter in the starting lineup.
Beacuse batters and pitchers have differnt strikeout numbers vs lefties and righties, 2021 L/R K% splits are used in calculations.
The script simulates a game by interating through the lineup determining if each outcome resulted in a strikeout.
K totals are summed and the process is simulated 1000x.
A histogram is produced to show the distribution of the outcomes as well as the mean of the data.
User can manually input data from any starting pitcher and any lineup in the .csv files for full customization.
Rich Hill of the Boston Red Sox vs the Minnesota Twins is used as an example.


