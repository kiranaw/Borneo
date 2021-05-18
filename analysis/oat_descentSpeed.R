library(tidyverse)
library(ggplot2)
library(ggpubr)

oatDescentSpeed <- read_csv("oatDescentSpeed.csv")

#filter by 10
oatdescentSpeed10 <- oatDescentSpeed %>% filter((descentSpeed * 10) %% 1 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.descentSpeed.traveldist <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = travelDistance)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "travel distance (m)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.traveldist

bp.descentSpeed.movecost <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = energyExpenditure)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "movement cost (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.movecost

bp.descentSpeed.energyIntake <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "energy intake (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.energyIntake

bp.descentSpeed.walk <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = walk)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.walk

bp.descentSpeed.sway <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = sway)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.sway

bp.descentSpeed.climb <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = climb)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.climb

bp.descentSpeed.descent <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = descent)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.descent

bp.descentSpeed.brachiate <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = brachiation)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.brachiate

bp.descentSpeed.travelTime <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = travellingBudget)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.travelTime

bp.descentSpeed.restingTime <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = restingBudget)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.restingTime

bp.descentSpeed.feedingTime <- ggplot(oatdescentSpeed10, aes(x = descentSpeed, y = feedingBudget)) +
  geom_boxplot(aes(group = descentSpeed)) +
  labs(x = "descent speed (m/s)", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.descentSpeed.feedingTime

oat_descentSpeed_all <- ggarrange(
  bp.descentSpeed.traveldist, 
  bp.descentSpeed.movecost,
  bp.descentSpeed.energyIntake,
  bp.descentSpeed.walk, 
  bp.descentSpeed.sway, 
  bp.descentSpeed.climb,
  bp.descentSpeed.descent,
  bp.descentSpeed.brachiate, 
  bp.descentSpeed.travelTime,
  bp.descentSpeed.restingTime,
  bp.descentSpeed.feedingTime,
  common.legend = TRUE, legend = "bottom")



