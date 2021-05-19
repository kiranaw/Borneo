library(tidyverse)
library(ggplot2)
library(ggpubr)

oatBodyWeight <- read_csv("oatBodyWeight.csv")

#filter by 10
oatBodyWeight10 <- oatBodyWeight #%>% filter(energyIntake %% 2 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.bodyWeight.traveldist <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = travelDistance)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "travel distance (m)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.traveldist

bp.bodyWeight.movecost <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = energyExpenditure)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "movement cost (kcal)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.movecost

bp.bodyWeight.energyIntake <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "energy intake (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.energyIntake

bp.bodyWeight.walk <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = walk)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.walk

bp.bodyWeight.sway <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = sway)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.sway

bp.bodyWeight.climb <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = climb)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.climb 

bp.bodyWeight.descent <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = descent)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.descent

bp.bodyWeight.brachiate <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = brachiation)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.brachiate

bp.bodyWeight.travelTime <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = travellingBudget)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.travelTime

bp.bodyWeight.restingTime <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = restingBudget)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.restingTime

bp.bodyWeight.feedingTime <- ggplot(oatBodyWeight10, aes(x = bodyWeight, y = feedingBudget)) +
  geom_boxplot(aes(group = bodyWeight)) +
  labs(x = "body weight (kg)", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.bodyWeight.feedingTime

oat_bodyWeight_all <- ggarrange(
  bp.bodyWeight.traveldist, 
  bp.bodyWeight.movecost,
  bp.bodyWeight.energyIntake,
  bp.bodyWeight.walk, 
  bp.bodyWeight.sway, 
  bp.bodyWeight.climb,
  bp.bodyWeight.descent,
  bp.bodyWeight.brachiate, 
  bp.bodyWeight.travelTime,
  bp.bodyWeight.restingTime,
  bp.bodyWeight.feedingTime,
  common.legend = TRUE, legend = "bottom")



