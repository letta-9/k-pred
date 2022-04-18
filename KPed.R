# Import dplyr library

library(dplyr)



# User input starting pitcher and opponent 

pitcher <- "Rich Hill" # User input starting pitcher
oppTeam <- "MIN" # User input opponent



# Read .csv file that contains the L/R splits of 2021 K% of starters
# Identify average total batters faced per game of the 2021 season
# Identify handedness of the starting pitcher
# Read .csv file of opponent lineup that contains batters' handeness and 2021 K% L/R splits

pitcherRates <- read.csv("BOS Pitchers.csv") %>% filter(PITCHER == pitcher)
projTBF <- round(pitcherRates %>% dplyr::select(TBF) %>% unlist, 2)
hand <- read.csv("BOS Pitchers.csv") %>% filter(PITCHER == pitcher) %>% dplyr::select(HND) %>% unlist 
lineup <- read.csv(paste(oppTeam,"Batters.csv"))



# If statement that identifies the batters' K% associated with the handedness of the starting pitcher

if (hand == "RHP") {
  lineup <- select(lineup, BATTER, HND, vs.R) 
} else {
  lineup <- select(lineup, BATTER, HND, vs.L) 
}



# For loop that iterates through the lineup and creates a new column in the lineup dataframe with the pitchers K%
# depending on righty vs lefty

for (i in 1:9){
  if (lineup[i,2] == "R"){
    lineup[i,4] = pitcherRates[1,4]
  } else if (lineup[i,2] == "L"){
    lineup[i,4] = pitcherRates[1,3]
  } else {
    if (hand == "RHP"){
      lineup[i,4] = pitcherRates[1,3]
    } else if (hand == "LHP") { 
      lineup[i,4] = pitcherRates[1,4]
    }
  }
}



# Take the average of the pitcher's K% and the batters' K% and input into new column called "ADJ"
  
lineup <- rename(lineup, PIT = V4)
lineup["ADJ"] <- (lineup[3] + lineup$PIT) / 2
lineup <- select(lineup, BATTER, ADJ)



# Depending on the total batters faced of the starter, append the lineup to itself to create a complete
# batting order of the game

if (projTBF > 9 && projTBF <= 18) {
  lineup <- rbind(lineup, head(lineup, projTBF - 9))
} else if (projTBF > 18 && projTBF <= 27) {
  lineup2 <- rbind(lineup,lineup)
  lineup <- rbind(lineup2, head(lineup, projTBF - 18))  
} else {
  lineup2 <- rbind(lineup,lineup)
  lineup3 <- rbind(lineup2,lineup)
  lineup <- rbind(lineup3, head(lineup, projTBF - 27))  
}



# Create an empty vector to store K totals

kVector <- vector("numeric",1000)



# Iterate through the lineup, determining if each at-bat resulted in a strikeout or not using adjusted K rate percentage
# Simulate each game 1000x, storing the sums of each game in the kVector

for (y in 1:1000){

  for (x in 1:projTBF){
    lineup[x, "K"] <- rbinom(1,1,lineup[x,"ADJ"])
  }
  
  lineupV <- unlist(lineup["K"])
  kVector[y] <- sum(lineupV)
}



# Create a histogram plot of the contents of the kVector and display the mean of the data on the graph

hist(kVector, main = paste(pitcher, "vs", oppTeam), xlab = "Strikeouts")
abline(v = mean(kVector), col = "red", lwd = 2)
text(mean(kVector)*1.5, 175, paste("Mean =", mean(kVector)), col = "red")

