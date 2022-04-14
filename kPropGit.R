library(dplyr)

## INPUTS ##
startingPitcher <- "Gerrit Cole" 
oppTeam <- "TOR"


## OPPONENT ADJUSTMENT ##
oppDat <- read.csv("teamKData.csv")                                                   #Read .csv file with MLB team K% for the 2021 season from Fangraphs
teamRates <- filter(oppDat) %>% dplyr::select(K) %>% unlist                           #Convert dataframe of 2021 K% into a vector called "teamRates"
oppRate <- filter(oppDat, ï..Team==oppTeam) %>% dplyr::select(K) %>% unlist               #Identify K% of opposing team and store it in a variable called "oppRate"
oppKAboveAvg <- oppRate - mean(teamRates)                                             #Calculate the opposing team's K% above league average


## STRIKEOUT DISTRIBUTION ##
pitDat <- read.csv("pitcherKData.csv")                                                ##Read .csv file with pitcher's 2020, 2021, & projected 2022 K%.
                                                                                        ##File also contains projected total batters faced per game TBF/GS
rates <- filter(pitDat, ï..Name==startingPitcher) %>%                                 ##Convert dataframe of inputted starting pitcher K%'s into a vector
  dplyr::select(X2,X1,X0) %>% unlist                                                  
mean <- mean(rates) - (oppKAboveAvg/2)                                                ##Find the average of the starting pitcher's K% and adjust based on opponent
std <- sd(rates)                                                                      ##Find the standard deviation of the starting pitcher's K%

x <- rnorm(1000, mean, std)*(filter(pitDat, ï..Name==startingPitcher) %>%             ##Create a normal distribution of 1000 random K%'s and multiply by pitcher's TBF/GS
                               dplyr::select(TBF.GS) %>% unlist)

## PLOT ##
hist(x, main = paste("Distribution of K's:", startingPitcher))                        ##Create a histogram of pitchers strikeout distribution over the course of one outing

## TOTALS ##
kProb <- mean(x > 7)                                                                  ##Calculate the probability of the pitcher throwing more than 4 Ks.
print(kProb)                                                                          ##4 is arbitrary. Replace ">" with other conditions 