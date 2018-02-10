# Team Chameleon Repository at Datathon 2018
Working on the case for SAP. More info [here](https://www.datasciencesociety.net/datathon/2018/02/04/the-sap-case-analyze-sales/)

## Project Organisation
The project is structured following the Cross-Industry Standard Practice in Data Mining (CRISP-DM). We include the following folders:

**0. Data** Contains all files containing any data. The data as provided by SAP should be left untouched with its original filenames. Newly-created data files of files imported from elsewhere can be included here along with a prefix.

**1. Business Understanding** - Documentation about the business case and goal of the project.

**2. Data Understanding** - Exploartory scripts and output graphics.

**3. Data Preparation** - Scripts that transform the data after a thorough exploration phase. The output from the scripts can be saved in 0. Data.

**4. Modelling** - Scripts that conduct the actual modelling operations.

**5. Evaluation** - Model accuracy testing scripts.

**6. Deployment** - After optimal models have been selected, we can create new scripts that automate the entire process so far end export the results in a user-friendly system such as R Shiny, interactive Excel tables or similar. 

**7. Documentation** \- Optionally, we can draft our final article here before uploading it on the Datathon website.

## Naming convention
It is strongly advised to use sequential prefixes before each filename. That way, we know the sequential order in which
each file or folder in the project should be executed in order to arrive at the final resut.

Example:

3. Data Preparation
..* DP\_010 First steps.R
..* DP\_011 First steps graph 01.png
..* DP\_012 First steps graph 02.png
..* DP\_020 Second approach.R
