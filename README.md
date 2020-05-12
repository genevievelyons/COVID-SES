# Socio-Economic Status and COVID-19: A New York City Case Study
## A Machine Learning Approach to Identify Communities At Risk
### Gabrielle LaRosa, Genevieve Lyons, Franklin Yang, Rebecca Youngerman

## Report and Results

The full report, including analysis and conclusions, can be found in `Socio-Economic Status and COVID-19 A New York City Case Study.pdf`.

All supporting analysis and replicability information can be found in `Master-Analysis.ipynb`. For exploratory and data trending analysis, please see `EDA/ScatterAndLine.ipynb`. 

Check out a gif of the NYC daily cases by zip code [HERE](https://github.com/genevievelyons/COVID-SES/blob/master/EDA/maps/new_map_normal_small.gif). 

![](https://github.com/genevievelyons/COVID-SES/blob/master/EDA/maps/new_map_normal_small.gif)

## Data Sources

Cumulative COVID-19 positive cases were sourced from [NYC Health Coronavirus Data](https://github.com/nychealth/coronavirus-data). Running `grab_zct.sh` will scrape the GitHub history of this repo so that you may calculate daily incidence. However, please see the caveats in our report regarding the quality of this daily incidence data. 

SES data were sourced from the [US Census Bureau](https://www.census.gov/). This data is only accessible via API. See `data/Census_API_Code.R` for the API extraction, which generates the flat file `Census_Data_Cleaned.csv`.

Hospital accessibility data were sourced from the [Healthcare Cost Report Information System](https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/Cost-Reports) via [RAND Hospital Data](https://www.hospitaldatasets.org/) to create `rand_hcris_free_2020_02_01.csv`.

