# Robust package load
if (!require(tidyverse)) {
	install.packages("tidyverse")
	require(tidyverse)
}

in_file = "../0. Data/D_0010 DU_0100 BaseManipulations.csv"#
out_file = "../0. Data/D_0020 BasePriceCalculation.csv"
	
# Fix working directory
data <- tryCatch(
	read.csv2(in_file, header = TRUE, sep = ";", stringsAsFactors = FALSE),
	error = function(e)
		stop("Data not found. Run this script via source command (Ctrl+Shift+Enter): \n\tsource('[SCRIPT]', chdir = TRUE) \nAlternatively, setwd() manually.")
)
data$BasePrice <- rep(NA, T, 1)

## basePrice before first Promotion = Actual price
## basePrice between promotions k and k+ 1 
## is a interpolated value between last week before k and one week before k+1
## base price after last promotion is = actial price

for(j in 1:5) {
  data[j, "BasePrice"] = data[j, "ACTUAL_PRICE"]
}
priceKProm <- NA
indKProm <- 6
priceK1Prom <- data[6, "ACTUAL_PRICE"]
indK1Prom <- NA
for(j in 6:144) {
  if (data[j, "FirstWeekOfProm"] == 1 || indK1Prom < j) {
    priceKProm <- data[j-1, "ACTUAL_PRICE"]
    indKProm <- j-1
    priceK1Prom <- data[j, "ACTUAL_PRICE"]
    indK1Prom <- j
    for (l in (j+1):144) {
      if (priceK1Prom <= data[l, "ACTUAL_PRICE"]) {
        priceK1Prom <- data[l, "ACTUAL_PRICE"]
        indK1Prom <- l
      }
      if (data[l, "FirstWeekOfProm"] == 1) {
        break;
      }
    }
  }
  data[j, "BasePrice"] <-  priceKProm * (indK1Prom - j)  / (indK1Prom - indKProm) +
    priceK1Prom * (j - indKProm) / (indK1Prom - indKProm)
}
data[145, "BasePrice"] <- data[145, "ACTUAL_PRICE"]
data[146, "BasePrice"] <- data[146, "ACTUAL_PRICE"]

#	Export the data

write.csv2(
	x = data,
	file = out_file,
	row.names = F
)