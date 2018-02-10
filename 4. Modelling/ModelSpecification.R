dataForModelling <- data[, c("Week", "BasePrice", "TYPE_OF_PROMOTION", "ACTUAL_PRICE", "BaseSales2", "VOLUME_OF_SALES", "inProm", 
                             "COMPETITOR1_PRICE", "COMPETITOR2_PRICE", "COMPETITOR3_PRICE", "COMPETITOR4_PRICE", "COMPETITOR5_PRICE",
                             "COMPETITOR6_PRICE", "COMPETITOR7_PRICE", "LengthOfProm")]

dataForModelling <- dataForModelling %>% mutate(BaseSales = log(BaseSales2), priceEffect = -log( ACTUAL_PRICE / BasePrice))
dataForModelling <- dataForModelling %>% 
  mutate(promA = case_when(TYPE_OF_PROMOTION == "A" ~ 1, TRUE ~ 0)) %>% 
  mutate(promB = case_when(TYPE_OF_PROMOTION == "B" ~ 1, TRUE ~ 0)) %>%
  mutate(promC = case_when(TYPE_OF_PROMOTION == "C" ~ 1, TRUE ~ 0)) %>%
  mutate(promD = case_when(TYPE_OF_PROMOTION == "D" ~ 1, TRUE ~ 0)) %>%
  mutate(promE = case_when(TYPE_OF_PROMOTION == "E" ~ 1, TRUE ~ 0)) 

dataForModelling <- dataForModelling %>% mutate(Upsale = log(VOLUME_OF_SALES / BaseSales))
dataForModelling <- dataForModelling %>% 
  mutate(compRet1 = log(COMPETITOR1_PRICE) - log(lag(COMPETITOR1_PRICE))) %>% 
  mutate(compRet2 = log(COMPETITOR2_PRICE) - log(lag(COMPETITOR2_PRICE))) %>% 
  mutate(compRet3 = log(COMPETITOR3_PRICE) - log(lag(COMPETITOR3_PRICE))) %>% 
  mutate(compRet4 = log(COMPETITOR4_PRICE) - log(lag(COMPETITOR4_PRICE))) %>% 
  mutate(compRet5 = log(COMPETITOR5_PRICE) - log(lag(COMPETITOR5_PRICE))) %>% 
  mutate(compRet6 = log(COMPETITOR6_PRICE) - log(lag(COMPETITOR6_PRICE))) %>% 
  mutate(compRet7 = log(COMPETITOR7_PRICE) - log(lag(COMPETITOR7_PRICE)))

dataForModelling[is.na(dataForModelling$compRet1),"compRet1"] = 0
dataForModelling[is.na(dataForModelling$compRet2),"compRet2"] = 0
dataForModelling[is.na(dataForModelling$compRet3),"compRet3"] = 0
dataForModelling[is.na(dataForModelling$compRet4),"compRet4"] = 0
dataForModelling[is.na(dataForModelling$compRet5),"compRet5"] = 0
dataForModelling[is.na(dataForModelling$compRet6),"compRet6"] = 0
dataForModelling[is.na(dataForModelling$compRet7),"compRet7"] = 0

dataForModelling[is.na(dataForModelling$LengthOfProm), "LengthOfProm"] <- 0
dataForModelling <- dataForModelling %>% 
  mutate(priceDiff1 = ACTUAL_PRICE - COMPETITOR1_PRICE) %>% 
  mutate(priceDiff2 = ACTUAL_PRICE - COMPETITOR2_PRICE) %>% 
  mutate(priceDiff3 = ACTUAL_PRICE - COMPETITOR3_PRICE) %>% 
  mutate(priceDiff4 = ACTUAL_PRICE - COMPETITOR4_PRICE) %>% 
  mutate(priceDiff5 = ACTUAL_PRICE - COMPETITOR5_PRICE) %>% 
  mutate(priceDiff6 = ACTUAL_PRICE - COMPETITOR6_PRICE) %>% 
  mutate(priceDiff7 = ACTUAL_PRICE - COMPETITOR7_PRICE) 

dataForModelling[is.na(dataForModelling$priceDiff1),"priceDiff1"] = 0
dataForModelling[is.na(dataForModelling$priceDiff2),"priceDiff2"] = 0
dataForModelling[is.na(dataForModelling$priceDiff3),"priceDiff3"] = 0
dataForModelling[is.na(dataForModelling$priceDiff4),"priceDiff4"] = 0
dataForModelling[is.na(dataForModelling$priceDiff5),"priceDiff5"] = 0
dataForModelling[is.na(dataForModelling$priceDiff6),"priceDiff6"] = 0
dataForModelling[is.na(dataForModelling$priceDiff7),"priceDiff7"] = 0



dataForModelling$timeFromLastProm <- rep(0, T, 1)

for (i in 9:T) {
  if (dataForModelling$inProm[i] == 1) {
    dataForModelling$timeFromLastProm[i]  <- 0
  } else {
    dataForModelling$timeFromLastProm[i] <- dataForModelling$timeFromLastProm[i-1] + 1
  }
}

dataForModelling$timeInProm <- rep(0, T, 1)
for (i in 6:T) {
  if (dataForModelling$inProm[i] == 0) {
    dataForModelling$timeInProm[i]  <- 0
  } else {
    dataForModelling$timeInProm[i] <- dataForModelling$timeInProm[i-1] + 1
  }
}

###

dataForModelling$numberOfComps <- rowSums(!is.na(data[, c("COMPETITOR1_PRICE", "COMPETITOR2_PRICE", 
                                                          "COMPETITOR3_PRICE", "COMPETITOR4_PRICE", 
                                                          "COMPETITOR5_PRICE", "COMPETITOR6_PRICE",
                                                          "COMPETITOR7_PRICE")]))
dataForModelling$percOfWeeksInPromLast3Month <- rep(0, T, 1)

for (i in 13:T) {
  dataForModelling[i, "percOfWeeksInPromLast3Month"] <- mean(dataForModelling[ (i-11):i ,"inProm"])
}




frm <- as.formula(paste("Upsale ~ priceEffect +", 
                        #paste(paste0("prom", c("A", "B", "C", "D", "E")), collapse =  "+"), "+", 
                        paste(paste0("compRet", c(1, 2, 6, 7)), collapse = "+"),
                        "+inProm + timeInProm  + numberOfComps + percOfWeeksInPromLast3Month + ",
                        paste(paste0("priceDiff", c(1:7)), collapse = "+"),
                        sep = ""))
model <- lm(frm, dataForModelling )
summary(model)

