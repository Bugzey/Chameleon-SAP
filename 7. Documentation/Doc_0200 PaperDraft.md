# Tiny smart data modelled with a not-so-tiny smart model
_Team Chameleons_

## Metadata
Case: The SAP Case - Analyze Sales

Team: Chameleon

Project URL: [https://github.com/Bugzey/Chameleon-SAP](https://github.com/Bugzey/Chameleon-SAP)

Memebers:

* Stefan Panev ([stephen.panev@gmail.com](mailto:stephen.panev@gmail.com)), 
* Metodi Nikolov ([metodi.nikolov@gmail.com](mailto:metodi.nikolov@gmail.com)), 
* Ivan Vrategov ([ivanvrategov@gmail.com](mailto:ivanvrategov@gmail.com)), 
* Radoslav Dimitrov ([rdimitrov@indeavr.com](mailto:rdimitrov@indeavr.com))

Mentors:

* Alexander Efremov ([aefremov@gmail.com](mailto:aefremov@gmail.com))
* Agamemnon Baltagiannis ([agamemnon.baltagiannis@sap.com](mailto:agamemnon.baltagiannis@sap.com))

Team Toolset:

The project is conducted primarily in R using RStudio as a graphical user interface. Some auxiliary analyses were conducted in Microsoft Excel due to the small size of the data.

Packages:

* tidyverse (ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats)
* forecast
* zoo


## Business Understanding
Who: Retail business
What: The effects of price promitions of a retail cleint and of their competitors on sales volume

The purpose of this project is to analyse what effects promotions conducted both by a retail client and by competing firms have on the client's overall volume of sales. By including these factors along with other derived variables we aim to create a predictive model that describes the marginal effects of each base variable on the client's overall sales volume.

An ideal solution to the case should include a complete description of each separate work step, a well-defined project structure, independently executable code, adequate data visualisation, an outline of the results achieved as well as an evaluation of modelling accuracy and model specification.

Finally, a desirable but optional stretch goal is an interactive user interface that allows plugging in arbitrary values. The interface should then update the model predictions in real time.


## Data Understanding
After we have carfully defined the business case as requested by SAP, we move on to a detailed exploration of all the data available to us. We examine the values, spread and continuity of each variable separately.

Our dataset with the file name ```1DATATHON_SAP_AI_initial_data.csv``` has the following variables:

* Week - index of the observation time period in weeks
* VOLUME_OF_SALES - volume of sales in an unknown unit of measurement
* ACTUAL_PRICE - the price set by the client at every moment in time
* COMPETITOR1_PRICE - price set by competing firm Nr. 1
* COMPETITOR2_PRICE - price set by competing firm Nr. 2
* COMPETITOR3_PRICE - price set by competing firm Nr. 3
* COMPETITOR4_PRICE - price set by competing firm Nr. 4
* COMPETITOR5_PRICE - price set by competing firm Nr. 5
* COMPETITOR6_PRICE - price set by competing firm Nr. 6
* COMPETITOR7_PRICE - price set by competing firm Nr. 7
* TYPE_OF_PROMOTION - classifier for the type of promotion that the client offers

### Descriptive visualisation
Since the entire dataset depicts a time sequence of variables, we opt to visualise the data via combinations of line charts and bar charts where the week index serves as an x-axis and the variable under observations is depictd on the y-axis.

Chart DU\_0200 01 - line charts of all prices

![2. Data Understanding/DU_0200 Exploration Plot 01.png](2. Data Understanding/DU_0200 Exploration Plot 01.png)

The first plot in the series examines the price levels exhibited by the client and all competing firms. Initially we disregard information about promotions. The defining feature in this visualisation is the discontinuity in the prices of most competing firms. The gaps between relatively homogenous series of competitor prices indicate periods where a competitor is not active in the market.

The above revelation suggests that we need to control for the presense and absense of competitors in all subsequent analyses.

Chart Du\_0200 04 - scatterplot of price against week, promotions colour-coded

![2. Data Understanding/DU_0200 Exploration Plot 04.png](2. Data Understanding/DU_0200 Exploration Plot 04.png)

An initial attempt to visualise the effect of promotions produced a scatterplot of prices where the scatter points are colour-coded according to the type of promotion offered at the time; the x-axis shows the week index. We notice that gray-coded price points Tend to occupy the top quadrants of the plot. As a result, the promotions included in the data appear to correspond to price reductions. Other types of pomotion such as a "two for one" scheme are not explicitly excluded, since they can be interpreted as, for example, a 50% reduction in price.

However, The visualisation in this form omits any sequences of promotion and volume.

Chart Du\_0200 05 - barplot of volume of sales with bars during a promotion period colour-coded

![2. Data Understanding/DU_0200 Exploration Plot 05.png](2. Data Understanding/DU_0200 Exploration Plot 05.png)

Similarly to the previous plot, here we depict the sales volume for each week and depict the promotion type by colouring the graph. Price points where a promotion is not active are coloured in dark gray. This visualisation confirms that massive spikes in sales volumes are observed during promotional periods, whereas the volumes drop back to a background level after a promotion has ended.

Thus we confirm, at least on a visual and intuitive level, the sequencial dependense of the sales volume on the promotions offered by the client. 

As a result from the data exploration depicted above, we first identify the need to control for data gaps around competitor prices, since any tranditional modelling techniques for predicting continuous variables cannot take missing values into account. On the other hand, leaving the observations as zeroes might bias the predictors and underestimate the effects of competitors' presense in the market. Finally, we confirm the intuitive result that promotional periods correspond to higher overall sales volume.

All of the above insights will be taken into account when preparing the dataset and generating auxiluary variables in the subsequent data preparation step.


## Data Preparation

The task at hand is to model the Upsale, which we define as the change in trading volume resulting from the application various promotions. In other words – how much new sales did the product received because we applied a price reduction.

In order to do this we need: firstly, we need to know what would be the trading volume had there been no price reductions – we will refer to this as Base Volume. This will be our dependent variable; it needs to be noted that there is a model for the calculation of that volume and ultimately, multiple models will need to be checked.
Subsequent work will use the logarithmic of the Upsale, to deal with possible scaling issues.

Next, we need to create our explanatory variables. From general considerations, the price reduction seems to be a needed component – this unfortunately, this variable is not part of the supplied data. Thus, we will need to estimate the discount, by calculating first a Base Price – the price of the product without any promotions/discounts. Again this will have to be estimated and we provide two possible algorithms, with more possible.


## Modeling

### Modelling of the Base Volume.
The selected model for base volume is the following:

1. during non-promotion weeks, the base volume is actual volume.
2. at the onset of a promotion, the base volume is calculated as the average volume over the last 3 months, excluding periods of promotions.
3. during a promotion (from week 2 onward) the base volume is the previous base volume.

This is one possible way to estimate Base Volume, with fine tuning of periods or the usage of YoY changes, or part year for the same period. Their implementation depends on further metadata – type of product, calendar dates etc.

![7. Documentation/Doc_0201 VolumeVsBaseVolume.png](7. Documentation/Doc_0201 VolumeVsBaseVolume.png)

### Modelling of Base Price
The estimate of the Base Price also could be done in multiple ways. We will present two algorithms, with results following one of them (source code has both).

Before that, the selected algorithms were based on the assumption that the Base Price needs to be larger than the actual price the product is being sold, the counter possibility doesn’t make economic sense.
Additionally, it is expected that the Base Price doesn’t exhibit excessive price change variability.

**Algorithm 1:**

1. assume that the price in the period before the onset of a promotion is a base price. form the set of all such prices.
2. between such consecutive days, find any dates/prices couples that are larger than the two end points - add them to the set.
3. perform a linear interpolation between the dates/ values in the set
4. perform any corrections where the resulting lines are below the actual price.

The shortcoming of this algorithm is that it follows the actual price too closely and is smooth (the variability of price changes is too large).

**Algorithm 2:**
1. take a 6 month period and find its mid point.
2. the base price for that point is the maximum price over the same 6 month period.
3. move the period 3 months forward.
4. the starting points Base Price is the maximum for the next 3 months; the ending period is the last maximum as well.
5. calculate the linear approximation from the dates and base values.

This algorithm overcomes the two shortcomings of algorithm 1, however, it could be improved - the length of the periods can be fine-tuned (based on the type of the product) as well as the type approximation, it could for example be a cubic spline to lead to smoother line.

![7. Documentation/Doc_0202 Doc_0202 BasePriceToActual.png](7. Documentation/Doc_0202 Doc_0202 BasePriceToActual.png) 

### Creation of additional predictors.

1. Discount factor (priceEffect)

The percentage difference between the actual price and base price. The sign of the variable is chosen so that a discount will have a positive effect on the Upsale.

2. Price changes of competitor products (compRet).

These variables show if other products have discounts or promotions. It is expected that discounts in competing product will have negative effect on Upsale.

3. Difference between prices of our product and competitors (priceDiff)

The difference in prices of products, or how much cheaper or more expensive our product is compared to the competition - cheaper products are expected to have larger Upsale.

4. Is the product in promotion (inProm)?

Even if the product is trading at discount to base price, the consumer may be less inclined to
buy unless the product is in promotion.

5. How long has the product been in promotion (timeInProm)?

Variable representing the length of the current promotion – in order to capture "consumer fatigue" - having a product being on current promotion too long my lead to reduction in Upsale.

6. Percentage of time the product has been in promotion the last 3 months (percOfWeeksInPromLast3Month).

Linked again with consumer fatigue, too many (even is different) promotions could reduce sale/upsale.

7. Number of competitors on the market (numberOfComps)

Having too many competing product may reduce sales/upsales.


### Model and model fit
The selected model to estimate the dependence of the dependent variable via a linear regression. The model is being estimated via OLS.
Further, step-wise selection is being applied to reduce the number of variables in the final model.

We have created a model based on the `D_0020 BasePriceCalculation.csv` and the results are presented in `M_0101 Result.txt`.

Step 1. The Logarithmic function is used to transform the used data.

Step 2. The Mutate function is being used to transform the different types of promotions to quantitative values.

Step 3. The NA values are replaced with 0.

Step 4. The differences between the actual price and the compeditor price is calculated.

Step 5. Model output:

We calculate the predicted demand of the products based of the actual price, compeditors prices and price difference between the actual and that of the compeditors.

The Intercept, PriceEffect, CompRet1, inProm, timeInProm, percOfWeeksInPromLast3Month, priceDiff1, priceDiff3 are statistically significant in line with their respective p-values, when they are less then 0.05.

Depicted below is the complete model summary:
```
Call:
lm(formula = Upsale ~ priceEffect + compRet1 + compRet2 + compRet6 + 
    inProm + timeInProm + priceDiff1 + priceDiff3 + priceDiff6 + 
    priceDiff7, data = dataForModelling)

Residuals:
    Min      1Q  Median      3Q     Max 
-0.6259 -0.1229  0.0165  0.1277  0.4877 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  0.27669    0.16601   1.667 0.097904 .  
priceEffect  1.24976    0.42306   2.954 0.003701 ** 
compRet1    -1.27857    0.31058  -4.117 6.66e-05 ***
compRet2    -0.57768    0.25962  -2.225 0.027734 *  
compRet6    -1.73124    1.17025  -1.479 0.141370    
inProm       0.30498    0.07040   4.332 2.86e-05 ***
timeInProm  -0.07816    0.02072  -3.773 0.000241 ***
priceDiff1  -0.69756    0.35221  -1.981 0.049678 *  
priceDiff3  -0.77447    0.16703  -4.637 8.26e-06 ***
priceDiff6   0.91963    0.36010   2.554 0.011764 *  
priceDiff7  -1.44757    0.59601  -2.429 0.016466 *  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.2115 on 135 degrees of freedom
Multiple R-squared:  0.7523,	Adjusted R-squared:  0.7339 
F-statistic: 40.99 on 10 and 135 DF,  p-value: < 2.2e-16
```

## Evaluation
The step-wise procedure selects the following predictors:

* the actual discount - larger discount leads to larger upsale.
* being in discount - having promotions leads to increase in sales.
* the changes in prices of competitors lead to reduction in the upsale, but not all products have the same effect on the dependent variable. This could mean that these product are not direct competitors, but still have cannibalization effect on the product under review.
* the difference in price between our product and the competing products pay a role in the size of upsales.
* There is a small, but statistically significant effect from the length of the promotion, in the negative sense. Thus, one could argue for some consumer fatigue, though it is not very large. Promotions should probably be kept up to 4 weeks to negate the effect of this.


## Deployment

Our model has a big room for improvement. For example, it is important what type of promotion we are running – pure price reduction, different positioning of our product in the store, etc. Another aspect for improvement would be information whether our competitors are in promotion and if they are, what type of promotion it is.

Moreover, data for production cost is vital for determining the effect of promotions as it is important metric for calculating the base price of the product and from it the price effect of the promotion.

However, with the current type and amount of data provided we build a model with relatively high training accuracy. We managed to achieve an adjusted coefficient of determination of 0.73 and the model would have some practical applications in explaining the volume of sales of our product.

Based on the output we can conclude that:

* the fact that we are promoting the product has positive effect on the volume of sales;
* longer promotions have negative effect on the volume of sales;
* a big number of promotions run in the last 3 months has negative effects on the volume of sales.

## Resources

[https://www.crosscap.com/blog/guide-to-analyzing-the-overall-lift-of-a-retail-promotion](https://www.crosscap.com/blog/guide-to-analyzing-the-overall-lift-of-a-retail-promotion)

[http://www.jstor.org/stable/pdf/184154.pdf?refreqid=excelsior:5a7c4890283758e1f361318b1f98d010](http://www.jstor.org/stable/pdf/184154.pdf?refreqid=excelsior:5a7c4890283758e1f361318b1f98d010)

