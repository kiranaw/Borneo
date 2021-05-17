library(tidyverse)
library(ggplot2)
library(ggpubr)

oatEnergyGain <- read_csv("analysis/oatEnergyGain.csv")

#filter by 10
oatEnergyGain10 <- oatEnergyGain %>% filter(energyGain %% 20 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.energygain.traveldist <- ggplot(oatEnergyGain10, aes(x = energyGain, y = travelDistance)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "travel distance") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.traveldist 

bp.energygain.movecost <- ggplot(oatEnergyGain10, aes(x = energyGain, y = energyExpenditure)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "movement cost") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.movecost 

bp.energygain.energyIntake <- ggplot(oatEnergyGain10, aes(x = energyGain, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "energy intake") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.energyIntake 

bp.energygain.walk <- ggplot(oatEnergyGain10, aes(x = energyGain, y = walk)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.walk 

bp.energygain.sway <- ggplot(oatEnergyGain10, aes(x = energyGain, y = sway)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.sway 

bp.energygain.climb <- ggplot(oatEnergyGain10, aes(x = energyGain, y = climb)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.climb 

bp.energygain.descent <- ggplot(oatEnergyGain10, aes(x = energyGain, y = descent)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.descent

bp.energygain.brachiate <- ggplot(oatEnergyGain10, aes(x = energyGain, y = brachiation)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.brachiate

bp.energygain.traveltime <- ggplot(oatEnergyGain10, aes(x = energyGain, y = travellingBudget)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.traveltime

bp.energygain.restingtime <- ggplot(oatEnergyGain10, aes(x = energyGain, y = restingBudget)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.restingtime

bp.energygain.feedingtime <- ggplot(oatEnergyGain10, aes(x = energyGain, y = feedingBudget)) +
  geom_boxplot(aes(group = energyGain)) +
  labs(x = "energy acquired / tree", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.feedingtime

oat_energyacq_all <- ggarrange(
  bp.energygain.traveldist, 
  bp.energygain.movecost, 
  bp.energygain.energyIntake, 
  bp.energygain.walk, 
  bp.energygain.sway, 
  bp.energygain.climb, 
  bp.energygain.descent,
  bp.energygain.brachiate,
  bp.energygain.traveltime,
  bp.energygain.restingtime,
  bp.energygain.feedingtime,
  common.legend = TRUE, legend = "bottom")
