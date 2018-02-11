Witty title 

Introduction
Metadata
Business Understanding
Data Understanding
Data Preparation
Modelling
Evaluation
Deployment
Conclusion

## Introduction


## Metadata
Case: The SAP Case – Analyze Sales
Team: Chameleon
Memebers:
* Stefan Panev (stephen.panev@gmail.com), 
* Metodi Nikolov (metodi.nikolov@gmail.com), 
* Ivan Vrategov (ivanvrategov@gmail.com, 
* Radoslav Dimitrov (rdimitrov@indeavr.com)

Mentors:
* Alexander Efremov(aefremov@gmail.com)
* Agamemnon Baltagiannis (agamemnon.baltagiannis@sap.com)

Team Toolset:
The project is conducted primarily in R using RStudio as a graphical user interface. Some auxiliary analyses were conducted in Microsoft Excel due to the small size of the data.

Packages:
tidyverse (ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats)
forecast
zoo


## Business Understanding
Who: Retail business
What: The effects of price promitions of a retail cleint and of their competitors on sales volume

The purpose of this project is to analyse what effects promotions conducted both by a retail client and by competing firms have on the client's overall volume of sales. By including these factors along with other derived variables we aim to create a predictive model that describes the marginal effects of each base variable on the client's overall sales volume.

An ideal solution to the case should include a complete description of each separate work step, a well-defined project structure, independently executable code, adequate data visualisation, an outline of the results achieved as well as an evaluation of modelling accuracy and model specification.



Data Understanding
Creating Dummy Varaibles
Ploting variables against each other
https://github.com/Bugzey/Chameleon-SAP

Data Understanding
Chart 1 Ploloting the volume of sales agains the weeks, it is devided by the different types of promotions. There is a lot of variation.
Chart 2 Ploting the actual price against the weeks, it is devided by the different types of promotions. Usually the price variation is less then 20%
case A and E are exceptions.
Chart 3 Ploting the volume of sales against the weeks, it is devided by the different types of promotions. A type of promotion is having the highest volumes.
Chart 4 Ploting the actual price against the weeks, it is devided by the different types of promotions. A type is having the lowest prices.
Chart 5 Ploting the volume of sales against the weeks, it is devided by the different types of promotions.
Chart 6 Ploting the dummy variavle BaseSales against the weeks, the latest weeks have the highest baselines.
Chart 7 Ploting the dummy variavle SalesYearPast against the weeks, the situation is similar to that of Chart 6.

Note 1 the Chart numbering in github is not the same as here. Here the sourced code is being followed on the numbering.
Note 2 The legend of charts 6-8 the name of the color does not match with the true colors.

Data Preparation
1. Raw Data:
Dataset 1--> Data Type: Sales --> Data Format: CSV
Dataset 2--> Data Type: Manipolated Data Sales (D_0010 DU_0100 BaseManipulations.csv) --> Data Format: CSV (dummy variables have been added to the intial dataset) for the compeditors.
Dataset 3--> Data Type: (D_0020 BasePriceCalculation.csv) --> Data Format: CSV

Modeling
We have created a model based on the D_0020 BasePriceCalculation.csv and the results are presented in M_0101 Result.txt.
Step 1. The Logarithmic function is used to transform the used data.
Step 2. The Mutate function is being used to transform the different types of promotions to quantitative values.
Step 3. The NA values are replaced with 0.
Step 4. The differences between the actual price and the compeditor price is calculated.
Step 5. Model output:
We calculate the predicted demand of the products based of the actual price, compeditors prices and price difference between the actual and that of the compeditors.
The Intercept, PriceEffect,CompRet1,inProm,timeInProm,percOfWeeksInPromLast3Month,priceDiff1,priceDiff3 are statistically significant in line
with their respective p-values, when they are less then 0.05.
Coefficients:
                            Estimate Std. Error t value Pr(>|t|)    
(Intercept)                  9.13284    0.18883  48.366  < 2e-16 ***
priceEffect                  0.92996    0.44559   2.087 0.038854 *  
compRet1                    -1.25071    0.32456  -3.854 0.000183 ***
compRet2                    -0.45717    0.29101  -1.571 0.118636    
compRet6                    -1.66276    1.37856  -1.206 0.229963    
compRet7                    -0.15867    0.69568  -0.228 0.819946    
inProm                       0.26994    0.07691   3.510 0.000618 ***
timeInProm                  -0.06379    0.02255  -2.828 0.005430 ** 
numberOfComps                0.04774    0.04094   1.166 0.245714    
percOfWeeksInPromLast3Month -0.49448    0.14245  -3.471 0.000705 ***
priceDiff1                  -1.03707    0.48008  -2.160 0.032607 *  
priceDiff2                  -0.15236    0.19179  -0.794 0.428400    
priceDiff3                  -0.86797    0.23202  -3.741 0.000275 ***
priceDiff4                   0.20621    0.22537   0.915 0.361903    
priceDiff5                  -0.46843    0.31719  -1.477 0.142159    
priceDiff6                   0.38055    0.73227   0.520 0.604174    
priceDiff7                  -0.72119    0.98848  -0.730 0.466963 
The Adjusted R-squared is 0.709. This means the model explains approximatedly 71% of the behavior of.

Evaluation
TBA

Deployment
If this has more data especially for the compeditors it could make for a better use of an application that predicts the fluctuations of the volume of sales based on the imput prices.
The current amount of data makes in not very usefull for any practical applications.

We used the following sources:
https://www.crosscap.com/blog/guide-to-analyzing-the-overall-lift-of-a-retail-promotion
