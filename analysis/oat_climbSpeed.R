library(tidyverse)
library(ggplot2)
library(ggpubr)

oatClimbSpeed <- read_csv("oatClimbSpeed.csv")

#filter by 10
oatclimbSpeed10 <- oatClimbSpeed %>% filter((climbSpeed * 10) %% 1 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.climbSpeed.traveldist <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = travelDistance)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "travel distance (m)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.traveldist

bp.climbSpeed.movecost <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = energyExpenditure)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "movement cost (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.movecost

bp.climbSpeed.energyIntake <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "energy intake (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.energyIntake

bp.climbSpeed.walk <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = walk)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.walk

bp.climbSpeed.sway <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = sway)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.sway

bp.climbSpeed.climb <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = climb)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.climb

bp.climbSpeed.descent <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = descent)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.descent

bp.climbSpeed.brachiate <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = brachiation)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.brachiate

bp.climbSpeed.travelTime <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = travellingBudget)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.travelTime

bp.climbSpeed.restingTime <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = restingBudget)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.restingTime

bp.climbSpeed.feedingTime <- ggplot(oatclimbSpeed10, aes(x = climbSpeed, y = feedingBudget)) +
  geom_boxplot(aes(group = climbSpeed)) +
  labs(x = "climb speed (m/s)", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.climbSpeed.feedingTime

oat_climbSpeed_all <- ggarrange(
  bp.climbSpeed.traveldist, 
  bp.climbSpeed.movecost,
  bp.climbSpeed.energyIntake,
  bp.climbSpeed.walk, 
  bp.climbSpeed.sway, 
  bp.climbSpeed.climb,
  bp.climbSpeed.descent,
  bp.climbSpeed.brachiate, 
  bp.climbSpeed.travelTime,
  bp.climbSpeed.restingTime,
  bp.climbSpeed.feedingTime,
  common.legend = TRUE, legend = "bottom")



