# Robust package load
if (!require(tidyverse)) {
	install.packages("tidyverse")
	require(tidyverse)
}

# Fix working directory
data <- tryCatch(
	read.csv("0. Data/1DATATHON_SAP_AI_initial_data.csv", header = TRUE, sep = ";", stringsAsFactors = FALSE),
	error = function(e)
		stop("Data not found. Run this script via source command (Ctrl+Shift+Enter): \n\tsource('[SCRIPT]', chdir = TRUE) \nAlternatively, setwd() manually.")
)
