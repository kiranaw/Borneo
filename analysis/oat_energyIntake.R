library(tidyverse)
library(ggplot2)
library(ggpubr)

oatEnergyIntake <- read_csv("analysis/oatEnergyIntake.csv")

#filter by 10
oatEnergyIntake10 <- oatEnergyIntake %>% filter(energyIntake %% 2 == 0) #%>% filter (energyIntake %% 1 == 0)

bp.energyIntake.traveldist <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = travelDistance)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "travel distance") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energyIntake.traveldist 

bp.energyIntake.movecost <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = energyExpenditure)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "movement cost") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energyIntake.movecost

bp.energyIntakeRate.energyIntake <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "energy intake (kcal / day)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energyIntakeRate.energyIntake

bp.energyIntake.walk <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = walk)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "walk (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energyIntake.walk

bp.energyIntake.sway <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = sway)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "sway (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energyIntake.sway

bp.energyIntake.climb <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = climb)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "climb (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1)) 

#bp.energygain.climb 

bp.energyIntake.descent <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = descent)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "descent (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1))

#bp.energygain.descent

bp.energyIntake.brachiate <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = brachiation)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "brachiation (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1))

#bp.energygain.brachiate

bp.energyIntake.traveltime <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = travellingBudget)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "travel time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1))

#bp.energygain.traveltime

bp.energyIntake.restingtime <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = restingBudget)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "resting time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1))

#bp.energygain.restingtime

bp.energyIntake.feedingtime <- ggplot(oatEnergyIntake10, aes(x = energyIntake, y = feedingBudget)) +
  geom_boxplot(aes(group = energyIntake)) +
  labs(x = "energy intake rate (kcal / min)", y = "feeding time (%)") +
  theme(text = element_text(size=10),
        axis.text.y = element_text(angle=90, hjust=1))

#bp.energygain.feedingtime

oat_energyIntakeRate_all <- ggarrange(
  bp.energyIntake.traveldist, 
  bp.energyIntake.movecost,
  bp.energyIntakeRate.energyIntake,
  bp.energyIntake.walk, 
  bp.energyIntake.sway, 
  bp.energyIntake.climb,
  bp.energyIntake.descent,
  bp.energyIntake.brachiate, 
  bp.energyIntake.traveltime,
  bp.energyIntake.restingtime,
  bp.energyIntake.feedingtime,
  common.legend = TRUE, legend = "bottom")



