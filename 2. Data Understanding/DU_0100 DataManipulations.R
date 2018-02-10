#	Basic data manipulation to make plotting the base data easier
if (!require(tidyverse)) {
	install.packages("tidyverse")
	require(tidyverse)
}

in_file = "../0. Data/1DATATHON_SAP_AI_initial_data.csv"
out_file = "../0. Data/D_0010 DU_0100 BaseManipulations.csv"

# Fix working directory
data <- tryCatch(
	read.csv(in_file, header = TRUE, sep = ";", stringsAsFactors = FALSE),
	error = function(e)
		stop("Data not found. Run this script via source command (Ctrl+Shift+Enter): \n\tsource('[SCRIPT]', chdir = TRUE) \nAlternatively, setwd() manually.")
)


data <- data %>% mutate(inProm = case_when(TYPE_OF_PROMOTION != "" ~ 1, TYPE_OF_PROMOTION == "" ~ 0)) %>% 
  mutate(FirstWeekOfProm = case_when(inProm == 1 & lag(inProm) == 0 ~ 1, TRUE ~ 0))


T <- nrow(data)
newPromsDates <- data[data$FirstWeekOfProm == 1, "Week"]

data$LengthOfProm <- rep(NA, T,1)
for (j in 1:(length(newPromsDates)-1)) {
  data[newPromsDates[j], "LengthOfProm"] = sum(data[newPromsDates[j]:(newPromsDates[j+1]-1), "inProm"])
}
#deal with the last one by hand
data[newPromsDates[length(newPromsDates)], "LengthOfProm"] <- 2

data$BaseSales <- rep(NA, T, 1)
for (j in 1:T) {
  if (data[j, "FirstWeekOfProm"] == 1) {
    if (!any(data[(j-data[j,"LengthOfProm"]):(j-1), "inProm"] == 1)) {
      # if all these dates are not in promotion
      data[j, "BaseSales"] = mean(data[(j-data[j,"LengthOfProm"]):(j-1), "VOLUME_OF_SALES"])
    } else {
      # if the length of the promotion period backwards encompases other promotions, use only none promoted values
      sum <- 0
      index <- 1
      for (k in (j-1):((j-data[j,"LengthOfProm"]))) {
        if (data[k, "inProm"]!= 1) {
          sum <- sum + data[k, "BaseSales"]
          index <- index + 1
        }
      }
      data[j, "BaseSales"] = sum / index
    }
  } else {
    if (data[j, "inProm"] == 1) {
      data[j, "BaseSales"] = data[j-1, "BaseSales"]
    } else {
      data[j, "BaseSales"] = data[j, "VOLUME_OF_SALES"]
    }
  }
}

data$BaseSales2 <- rep(NA, T, 1)
for (j in 1:T) {
  if (data[j, "FirstWeekOfProm"] == 1) {
    if (j > 13) {
      tmp <- data[(j-1):(j - 13), c("VOLUME_OF_SALES", "inProm")]
      data[j, "BaseSales2"] = mean(tmp[tmp[, "inProm"] != 1, "VOLUME_OF_SALES"])
    } else {
      tmp <- data[(j-1):(j - 5), c("VOLUME_OF_SALES", "inProm")]
      data[j, "BaseSales2"] = mean(tmp[tmp[, "inProm"] != 1, "VOLUME_OF_SALES"])
    }
  } else {
    if (data[j, "inProm"] == 1) {
      data[j, "BaseSales2"] = data[j-1, "BaseSales2"]
    } else {
      data[j, "BaseSales2"] = data[j, "VOLUME_OF_SALES"]
    }
  }
}


#data <- data %>% mutate(SaleUplift = VOLUME_OF_SALES - BaseSales)
data <- data %>% mutate(SaleUplift = VOLUME_OF_SALES - BaseSales2)

data <- data %>% mutate(SalesYearPast = lag(VOLUME_OF_SALES, n = 52))

data <- data %>% mutate(PercSaleuplift = VOLUME_OF_SALES / BaseSales2 - 1)

#	Write the script:
write.csv2(data, out_file)