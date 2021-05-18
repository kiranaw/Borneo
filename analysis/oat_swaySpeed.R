library(tidyverse)
library(ggplot2)
library(ggpubr)

oatSwaySpeed <- read_csv("oatSwaySpeed.csv")

#filter by 10
oatSwaySpeed10 <- oatSwaySpeed %>% filter((swaySpeed * 10) %% 1 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.swaySpeed.traveldist <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = travelDistance)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "travel distance (m)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.traveldist

bp.swaySpeed.movecost <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = energyExpenditure)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "movement cost (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.movecost

bp.swaySpeed.energyIntake <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "energy intake (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.energyIntake

bp.swaySpeed.walk <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = walk)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.walk

bp.swaySpeed.sway <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = sway)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.sway

bp.swaySpeed.climb <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = climb)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.climb

bp.swaySpeed.descent <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = descent)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.descent

bp.swaySpeed.brachiate <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = brachiation)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.brachiate

bp.swaySpeed.travelTime <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = travellingBudget)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.travelTime

bp.swaySpeed.restingTime <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = restingBudget)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.restingTime

bp.swaySpeed.feedingTime <- ggplot(oatSwaySpeed10, aes(x = swaySpeed, y = feedingBudget)) +
  geom_boxplot(aes(group = swaySpeed)) +
  labs(x = "sway speed (m/s)", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.swaySpeed.feedingTime

oat_swaySpeed_all <- ggarrange(
  bp.swaySpeed.traveldist, 
  bp.swaySpeed.movecost,
  bp.swaySpeed.energyIntake,
  bp.swaySpeed.walk, 
  bp.swaySpeed.sway, 
  bp.swaySpeed.climb,
  bp.swaySpeed.descent,
  bp.swaySpeed.brachiate, 
  bp.swaySpeed.travelTime,
  bp.swaySpeed.restingTime,
  bp.swaySpeed.feedingTime,
  common.legend = TRUE, legend = "bottom")



