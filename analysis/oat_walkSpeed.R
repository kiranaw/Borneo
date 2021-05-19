library(tidyverse)
library(ggplot2)
library(ggpubr)

oatWalkSpeed <- read_csv("oatWalkSpeed.csv")

#filter by 10
oatWalkSpeed10 <- oatWalkSpeed #%>% filter(energyIntake %% 2 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.walkspeed.traveldist <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = travelDistance)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "travel distance (m)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkspeed.traveldist

bp.walkspeed.movecost <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = energyExpenditure)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "movement cost (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkspeed.movecost

bp.walkspeed.energyIntake <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "energy intake (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkspeed.energyIntake

bp.walkspeed.walk <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = walk)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkspeed.walk

bp.walkspeed.sway <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = sway)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkspeed.sway

bp.walkspeed.climb <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = climb)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkSpeed.climb

bp.walkSpeed.descent <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = descent)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkSpeed.descent

bp.walkSpeed.brachiate <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = brachiation)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkSpeed.brachiate

bp.walkSpeed.travelTime <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = travellingBudget)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkSpeed.travelTime

bp.walkSpeed.restingTime <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = restingBudget)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkSpeed.restingTime

bp.walkSpeed.feedingTime <- ggplot(oatWalkSpeed10, aes(x = walkSpeed, y = feedingBudget)) +
  geom_boxplot(aes(group = walkSpeed)) +
  labs(x = "walk speed (m/s)", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.walkSpeed.feedingTime

oat_walkSpeed_all <- ggarrange(
  bp.walkspeed.traveldist, 
  bp.walkspeed.movecost,
  bp.walkspeed.energyIntake,
  bp.walkspeed.walk, 
  bp.walkspeed.sway, 
  bp.walkspeed.climb,
  bp.walkSpeed.descent,
  bp.walkSpeed.brachiate, 
  bp.walkSpeed.travelTime,
  bp.walkSpeed.restingTime,
  bp.walkSpeed.feedingTime,
  common.legend = TRUE, legend = "bottom")



