2 - 1 - 24
3 - 13 - 36
4 - 25 - 48
actPrice <- data[, "ACTUAL_PRICE"]

rollingMonthMax <- numeric(13)
rollingMonthMax[1] <- actPrice[which.max(actPrice[1:12])]
for (i in 2:12) {
  ind <- (1 + (i - 2)* 12):(i*12)
  if (any(ind>T)) {
    ind <- ind[ind<=T]
  }
  tmp <- actPrice[ind]
  rollingMonthMax[i] <- tmp[which.max(tmp)]
}

rollingMonthMax[13] <- actPrice[which.max(actPrice[(T-11):T])]
x <-  (1 + (c(1:13) - 1)*12)
bp <- approx(x, rollingMonthMax, data[,"Week"], rule = 2)
