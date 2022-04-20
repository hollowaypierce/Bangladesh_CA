############################
# GEOG 803 Data
#
#
#
############################

#Set up
library(tidyverse)
library(here)
library(igraph)
library(readxl)
library(sf)
library(GGally)

# Download data from website
here::i_am("01_DataSummary.R")

dest = "D:\\Masters Classes\\Spring_2022\\GEOG 803\\R_Scripts\\source_data\\Bang_Data.csv"

bang_data <- read_csv(dest)

#data summary

summary(bang_data)

# clean up, only keep needed columns
# NAs?

# read in as st file
bang_shp <- st_read("D:\\Masters Classes\\Spring_2022\\GEOG 803\\TEMP\\Bang_data_country_clip.shp")
bang_shp <- bang_shp %>%
    rename(road_dis = MEAN, town_dis = MEAN_1, park_dis = MEAN_12, water_dis =MEAN_12_13) %>%
    select(id, Crop_Aband, Precip_mea, DEM_mean, Pop_dens_m, road_dis, town_dis, park_dis, water_dis) %>%
    mutate(Precip_mea = ifelse(Precip_mea==0,NA,Precip_mea)) %>%
    filter(!is.na(Precip_mea))

    
bang_shp %>%
    summary()

bang_shp %>% st_drop_geometry() %>% 
    sample_n(5000) %>% 
    select(-id) %>% 
    ggpairs()

ols <- bang_shp %>% 
    st_drop_geometry() %>% 
    select(-id) %>% 
    lm(data=., Crop_Aband ~. )

ols %>%
    summary()

# running regressions 
library(spatialreg)
library(spdep)

nb <- poly2nb(bang_shp)
nb <- knn2nb(knearneigh(st_centroid(st_geometry(bang_shp)), k = 5))
listw <- nb2listw(nb)

lm.morantest(ols,listw=listw)

bang_shp$res <- residuals(ols)
bang_shp %>% sample_n(14000) %>% 
    ggplot()+geom_sf(aes(fill=res), color=NA)+theme_minimal()+
    scale_fill_gradient2(low = "blue",mid="white", high = "red")

