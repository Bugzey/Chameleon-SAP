#	File: DU_0300 Generate base volume via ARIMAX.R
#	More exploration (base-R)
# Robust package load
package_list = c("forecast", "zoo")
for (pak in package_list) {
	if (!require(pak, character.only = TRUE)) {
		install.packages(pak)
		require(pak)
	}
}
rm(list=ls())

out_file = "DU_0301 Generate base volume via ARIMAX"
png(
	filename = paste(out_file, "RPlot%02d.png"),
	width = 900,
	height = 800
)
# Fix working directory
data <- tryCatch(
	read.csv2("../0. Data/D_0020 BasePriceCalculation.csv", header = TRUE, sep = ";", stringsAsFactors = FALSE),
	error = function(e)
		stop("Data not found. Run this script via source command (Ctrl+Shift+Enter): \n\tsource('[SCRIPT]', chdir = TRUE) \nAlternatively, setwd() manually.")
)

summary(data)
# sapply(
# 	seq(ncol(data)),
# 	function(column)
# 	{
# 		try(plot(data[, column], type = "b", main = colnames(data)[column]))
# 	}
# )

#	Attempt to arrive at a base volume / price regardless of all 
#		other factors via an ARIMAX model
var_target = "VOLUME_OF_SALES"
var_time = "Week"
var_xreg = c("ACTUAL_PRICE", "COMPETITOR1_PRICE", "COMPETITOR2_PRICE", "COMPETITOR3_PRICE", "COMPETITOR4_PRICE", "COMPETITOR5_PRICE", "COMPETITOR6_PRICE", "COMPETITOR7_PRICE")
#	Prepare data

model_lm = lm(VOLUME_OF_SALES ~ ., data = data[, c(var_target, var_xreg)])
summary(model_lm) # adj. r^2
Box.test(model_lm$residuals) 
	# p-value 0.02: suggests that the model residuals are not
	# independently distributed, but rather that there may be a
	# time-based dependence among them
Acf(model_lm$residuals)
	# Insignificant spikes at lags 1, 3, 5, 8, 11
Pacf(model_lm$residuals)
	# significant spikes at lag 1, 5, 15
	# ARIMA may be appropriate

#	Plot actual vs residual
actual_vs_fitted = cbind(
	actual = model_lm$model$VOLUME_OF_SALES,
	fitted = model_lm$fitted.values
)
plot(
	actual_vs_fitted, 
	asp = 1,
	main = "Linear model"
)
abline(a = 0, b = 1, lty = 2)
	# Discrepancy between actual and fitted values

#	Try auto.arima with all other items as external regressors


model_auto_arima = auto.arima(
	y = data[, var_target],
	stationary = F,
	seasonal = T,
	xreg = data[, var_xreg]
)

summary(model_auto_arima)
	# ARIMA(1, 0, 3), Own price is highly significant, all other
	# competitors' prices are insignificant
	# RMSE = 27 972
	# MAPE = 27%

# ts.plot(model_auto_arima$residuals)
#	# apears stationary, residual MA?

Acf(model_auto_arima$residuals, lag.max = 52, main = forecast:::arima.string(model_auto_arima))
Pacf(model_auto_arima$residuals, lag.max = 52, main = forecast:::arima.string(model_auto_arima))
#	cases are free of significant residual autocorrelation

Box.test(model_auto_arima$residuals)
#	# p-value = 0.9667 - independent residuals

ts.plot(
	actual = model_auto_arima$x,
	fitted = model_auto_arima$fitted,
	stupid_cleaned = model_auto_arima$residuals + mean(model_auto_arima$fitted),
	col = c("black", "blue", "green"),
	ylim = c(0, 250000),
	main = forecast:::arima.string(model_auto_arima)
)
legend(
	x = "topleft",
	legend = c("Actual", "Fitted", "Residuals + Mean"),
	col = c("black", "blue", "green"),
	lty = 1
)
#	# Relatively good on its own, but it misses a lot of the extremes.

#	Artificial clean-up - use the predicted model to "forecast" its
#	own observations, but set all zeroes to the external regressors
xreg_cleaned = data[, var_xreg]
xreg_cleaned[, -which(var_xreg == "ACTUAL_PRICE")] = sapply(
	xreg_cleaned[, -which(var_xreg == "ACTUAL_PRICE")],
	function(x)
		rep(0, length(x))
)
arima_cleaned = Arima(
	y = data[, var_target],
	model = model_auto_arima,
	xreg = xreg_cleaned
)

ts.plot(
	arima_cleaned$x, 
	arima_cleaned$fitted, col = c("black", "blue"),
	main = forecast:::arima.string(arima_cleaned),
	sub = "All competitor prices forced to 0 <=> base volume"
)
legend(
	x = "topleft",
	legend = c("Actual", "Fitted"),
	col = c("black", "blue"),
	lty = 1
)
#	Without having calculated our own base price, we can eliminate
#	the effects of competitor prices on the volume of sales. 
#	Surprisingly, the overall level of the cleaned volume is 
#	lower than the actual observations. Some periods even 
#	(e.g. 100-110) show a massive reduction in volume. This is 
#	indicative of the fact that some competitor's promotion might
#	be contributing to our own sales.
#		
#	However, we notice a leftover cannibalisation effect after a huge
#	spike in sales related to a promotion. To clean these out,
#	we can add lagged promotional prices as other external regressors.
#	The challenge is to figure out how many lags we need to account
#	for.

#	Analysis of lagged effects of all promotions
#	must use zoo's lag
calc_xreg_lags = function(data, var_target, var_xreg)
{
	xreg_lags = list()
	for (regressor in var_xreg) {
		cur_reg = zoo(data[, regressor])
		cur_df = data.frame(
			data[, var_target],
			cur_reg,
			lag(cur_reg, 1, na.pad = TRUE),
			lag(cur_reg, 2, na.pad = TRUE),
			lag(cur_reg, 3, na.pad = TRUE),
			lag(cur_reg, 4, na.pad = TRUE),
			lag(cur_reg, 5, na.pad = TRUE),
			lag(cur_reg, 6, na.pad = TRUE),
			lag(cur_reg, 7, na.pad = TRUE),
			lag(cur_reg, 8, na.pad = TRUE),
			lag(cur_reg, 9, na.pad = TRUE),
			lag(cur_reg, 10, na.pad = TRUE)
		)
		colnames(cur_df) = c(
			var_target,
				paste0(
				regressor, 0:10
			)
		)
		xreg_lags = c(xreg_lags, list(cur_df))
	}
	#pairs(data.frame(data[, var_target], xreg_lags[[1]]))
	
	cor_df = t(data.frame(sapply(
		xreg_lags,
		function(x)
			round(cor(x, use = "complete.obs")[, 1], 2)
	)))
	colnames(cor_df) = c("Self", paste0("Lag", 0:10))
	rownames(cor_df) = var_xreg
	return(cor_df)
}

cor_df = calc_xreg_lags(data, var_target, var_xreg)
write.csv2(
	x = cor_df,
	file = paste0(out_file, " Lagged competitor correlation.csv"),
	row.names = F
)
View(cor_df)
#	Observation: the correlation between our current VOLUME_OF_
#	SALES is at best weakly correlated with the past values of 
#	the sales price of any competitor.
#	
#	Conclusion: we can safely ignore the lagged effects of our
#	competitor's prices
#	
#	COunter example: the myriad of 0-values in competitors' price
#	data might bias the correlations. Will redo the analysis
#	while removing the 0-observations.

data_dezeroed = data[, c(var_target, var_xreg)]
data_dezeroed[, var_xreg] = sapply(
	data_dezeroed[, var_xreg],
	function(x)
		ifelse(x == 0, NA, x)
)

cor_df_dezeroed = calc_xreg_lags(data_dezeroed, var_target, var_xreg)
write.csv2(
	x = cor_df,
	file = paste0(out_file, " Lagged competitor correlation (0 to NA).csv"),
	row.names = F
)
#	Correlations of dezeroed competitor prices mostly confirm our 
#	previous observations: there are no strong correlations between the target
#	and any lagged competitor prices.
#	
#	Oddly, some competitors exhibit a medium (in absolute terms)
#	correlation at about lags 4-5, while competitor 6 has 
#	|0.6| at lag 1.

#	Final attempt at cleaning - plug in a calculated base price.
xreg_base = xreg_cleaned
xreg_base[, "ACTUAL_PRICE"] = data[, "BasePrice"]

arima_cleaned_base = Arima(
	y = data[, var_target],
	model = model_auto_arima,
	xreg = xreg_base
)

ts.plot(
	arima_cleaned_base$x,
	arima_cleaned_base$fitted,
	col = c("black", "blue"),
	main = forecast:::arima.string(arima_cleaned_base),
	sub = "Volume and Price forced to base versions"
)
legend(
	x = "topleft",
	legend = c("Actual", "Fitted"),
	col = c("black", "blue"),
	lty = 1
)
#	Plugging in the "base price" reduces the sales volume 
#	tremendously.
dev.off()