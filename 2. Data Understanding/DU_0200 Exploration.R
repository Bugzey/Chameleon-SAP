if (!require(tidyverse)) {
	install.packages("tidyverse")
	require(tidyverse)
}

rm(list=ls())
# Fix working directory
in_file = "../0. Data/D_0010 DU_0100 BaseManipulations.csv"
data <- tryCatch(
	read.csv2(in_file, header = TRUE, sep = ";", stringsAsFactors = FALSE),
	error = function(e)
		stop("Data not found. Run this script via source command (Ctrl+Shift+Enter): \n\tsource('[SCRIPT]', chdir = TRUE) \nAlternatively, setwd() manually.")
)
print(getwd())
#data <- read.csv("0. Data/1DATATHON_SAP_AI_initial_data.csv", header = TRUE, sep = ";", stringsAsFactors = FALSE)

data %>% head()

#	Plotting
png(
	filename = "DU_0201 Exploration Plot %02d.png",
	width = 800,
	height = 600,
	type = "cairo",
	antialias = "default"
)
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

#	Stop plotting device
dev.off()

