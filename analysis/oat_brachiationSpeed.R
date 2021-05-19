library(tidyverse)
library(ggplot2)
library(ggpubr)

oatBrachiationSpeed <- read_csv("oatBrachiationSpeed.csv")

#filter by 10
oatBrachiationSpeed10 <- oatBrachiationSpeed %>% filter((brachiationSpeed * 10) %% 1 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.brachiationSpeed.traveldist <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = travelDistance)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "travel distance (m)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.traveldist

bp.brachiationSpeed.movecost <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = energyExpenditure)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "movement cost (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.movecost

bp.brachiationSpeed.energyIntake <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "energy intake (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.energyIntake

bp.brachiationSpeed.walk <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = walk)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.walk

bp.brachiationSpeed.sway <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = sway)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.sway

bp.brachiationSpeed.climb <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = climb)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.climb

bp.brachiationSpeed.descent <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = descent)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.descent

bp.brachiationSpeed.brachiate <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = brachiation)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.brachiate

bp.brachiationSpeed.travelTime <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = travellingBudget)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.travelTime

bp.brachiationSpeed.restingTime <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = restingBudget)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.restingTime

bp.brachiationSpeed.feedingTime <- ggplot(oatBrachiationSpeed10, aes(x = brachiationSpeed, y = feedingBudget)) +
  geom_boxplot(aes(group = brachiationSpeed)) +
  labs(x = "brachiation speed (m/s)", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.brachiationSpeed.feedingTime

oat_brachiationSpeed_all <- ggarrange(
  bp.brachiationSpeed.traveldist, 
  bp.brachiationSpeed.movecost,
  bp.brachiationSpeed.energyIntake,
  bp.brachiationSpeed.walk, 
  bp.brachiationSpeed.sway, 
  bp.brachiationSpeed.climb,
  bp.brachiationSpeed.descent,
  bp.brachiationSpeed.brachiate, 
  bp.brachiationSpeed.travelTime,
  bp.brachiationSpeed.restingTime,
  bp.brachiationSpeed.feedingTime,
  common.legend = TRUE, legend = "bottom")



