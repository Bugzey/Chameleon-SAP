library(tidyverse)

data <- read.csv("1DATATHON_SAP_AI_initial_data.csv", header = TRUE, sep = ";", stringsAsFactors = FALSE)

data %>% head()

str(data)
data[data == 0] = NA
# remove the week - its the same as row
colNamesData <- colnames(data)
data %>% select(contains("COMPE"), -VOLUME_OF_SALES, Week, -TYPE_OF_PROMOTION, ACTUAL_PRICE) %>% 
  gather(provider, price, -Week) %>%  ggplot(aes(x = Week, y = price)) + geom_line() +geom_point() + facet_wrap(~provider)

data %>% select(ACTUAL_PRICE, Week, TYPE_OF_PROMOTION) %>% 
  ggplot(aes(x = Week, y = ACTUAL_PRICE)) + geom_line() +facet_wrap(~TYPE_OF_PROMOTION)

data %>% select(VOLUME_OF_SALES, Week, TYPE_OF_PROMOTION) %>% 
  ggplot(aes(x = Week, y = VOLUME_OF_SALES)) + geom_line() + facet_wrap(~TYPE_OF_PROMOTION)


data %>% select(ACTUAL_PRICE, Week, TYPE_OF_PROMOTION) %>% 
  ggplot(aes(x = Week, y = ACTUAL_PRICE)) + geom_point(aes(colour = TYPE_OF_PROMOTION)) 

# this one is nice
data %>% select(VOLUME_OF_SALES, Week, TYPE_OF_PROMOTION) %>% 
  ggplot(aes(x = Week, y = VOLUME_OF_SALES)) + geom_col(aes(fill = TYPE_OF_PROMOTION)) 


data %>% select(BaseSales, Week, VOLUME_OF_SALES) %>% 
  ggplot() + geom_line(aes(x = Week, y = BaseSales, colour = "blue"))+
  geom_line(aes(x = Week, y = VOLUME_OF_SALES, colour = "red")) 

data %>% select(SaleUplift, Week, BaseSales2) %>% 
  ggplot() + geom_line(aes(x = Week, y = BaseSales2), colour = "blue")+
  geom_line(aes(x = Week, y = SaleUplift), colour = "red") 


data %>% select(SalesYearPast, Week, VOLUME_OF_SALES) %>% 
  ggplot() + geom_line(aes(x = Week, y = SalesYearPast, colour = "blue"))+
  geom_line(aes(x = Week, y = VOLUME_OF_SALES, colour = "red")) 

data %>% select(BaseSales, Week, VOLUME_OF_SALES, BaseSales2) %>% 
  ggplot() + geom_line(aes(x = Week, y = BaseSales, colour = "blue"))+
  geom_line(aes(x = Week, y = VOLUME_OF_SALES, colour = "red")) +
  geom_line(aes(x = Week, y = BaseSales2, colour = "green"))

