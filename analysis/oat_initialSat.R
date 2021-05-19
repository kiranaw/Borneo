oatInitsat <- read_csv("analysis/oatInitialSatiation.csv")

#filter by 10
oatInitialSat10 <- oatInitsat %>%  filter(initialSatiation %% 25 == 0) 

bp.initsat.traveldist <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = travelDistance)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "travelDistance") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.moveCost <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = energyExpenditure)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "movement cost") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.energyGain <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = totalEnergyIntake)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "energy gain") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.walk <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = walk)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "walk") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.walk

bp.initsat.sway <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = sway)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "sway") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.sway


bp.initsat.brachiate <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = brachiation)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "brachiation") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.brachiate

bp.initsat.climb <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = climb)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "climb") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.climb

bp.initsat.feeding <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = feedingBudget)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "feeding time") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.feeding

bp.initsat.travel <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = travellingBudget)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "travelling time") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.travel

bp.initsat.rest <- ggplot(oatInitialSat10, aes(x = initialSatiation, y = restingBudget)) +
  geom_boxplot(aes(group = initialSatiation)) +
  labs(x = "initialSatiation", y = "resting time") +
  theme(text = element_text(size=15),
        axis.text.y = element_text(angle=90, hjust=1)) 

bp.initsat.rest
