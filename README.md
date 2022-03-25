# Investigating Cropland Abandonment Drivers in Bangladesh

While I am still in the initial data collection and cleaning phase I have had the pleasure of working alongside two PhD candidates at UNC on analyzing drivers behind Cropland Abandonment in Bangladesh.

Our dependent varible for analysis, Cropland Abaondment, is sourced from a comprehensive raster analysis conducted by the [Global Cropland Analysis & Discovery Lab](https://glad.umd.edu/dataset/croplands). Their datasets provide a valuable window into understanding the sptial change of cropland dynamics worldwide in the 21st century.

Our paper is currently still in the intial draft phase but below are intial data visualizations and a data table I created for our study, showing the various data sources we are working with.

## Visualization of Data Sources for Spatial Regression 

![Bangladesh Data Maps](https://github.com/hollowaypierce/Bangladesh_CA/blob/main/Images/Map_tiles.png)

## Data Table

| Data | Description | Sources |
| ------------- | -------------| -------------|
 Precipitation | Mean annual precipitation across June 1st to  October 30th, 2000-2017, 0.05˚ resolution grid point |Bangladesh Meteorological Department (http://datalibrary.bmd.gov.bd/maproom/Agriculture/Historical/) |
Slope and Elevation | ASTER Global Digital Elevation Model V003 at 30m spatial resolution | The United States Geological Survey (https://www.usgs.gov/centers/eros/science/) | 
Population Density | Gridded ( 1km grid points) UN-Adjusted Population density of annual temporal resolution for 2003-2019 | WorldPop (https://www.worldpop.org/) |
Roads | Global Roads Open Access Data Set (gROADS), v1 data from 1980 – 2010 in polyline format | NASA Socioeconomic Data and Applications Center SEDAC(https://sedac.ciesin.columbia.edu/)| 
Water Bodies | Water bodies larger than 0.2 square kilometers at a 30m spatial resolution | Land Processes Distributed Active Archive Center https://lpdaac.usgs.gov/ | Cropland Loss | Globally consistent cropland extent time-series at 30m spatial resolution, data from 2003-2019 | Global Land Analysis and Discovery (GLAD) (https://glad.umd.edu/dataset/croplands) |
Spatial Data | GIS vector data of forests, parks, settlements, and administrative boundaries | The Humanitarian Data Exchange (https://data.humdata.org/) |


