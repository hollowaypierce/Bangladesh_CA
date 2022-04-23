library(tidyverse)
library(sf)
library(spatialreg)
library(spdep)
library(GGally)
library(here)

# setwd("D:\\Masters Classes\\Spring_2022\\GEOG 803\\R_Scripts")
here::i_am("02_Regression.R")

mgrid <- st_read(here("source_data","MGrid_Clipped.shp"))

# change distance covariates from unites of meter's to kilometers (div by 1000)
mgrid <- mgrid %>%
  mutate(Towns_Dist_km = Towns_Dist / 1000,
         Roads_Dist_km = Roads_Dist / 1000, 
         Water_Dist_km = Water_Dist / 1000,
         Parks_Dist_km = Parks_Dist / 1000)

#drop uneeded columns
mgrid <- select(mgrid,-c("X_Coordina","Y_Corrdina", "Towns_Dist", "Roads_Dist", "Water_Dist", "Parks_Dist"))


# summary stats of covariates
summary(mgrid)


#crop change: X19_03_sub_
#what do these variables mean?
ggplot(data=sample_n(mgrid,10000), 
       aes(x=X19_03_sub_,y=CA_NetLoss))+
  geom_point(alpha=0.05)+
  geom_abline(intercept=0,slope=-1)

#defining spatial neighbors (5 NEAREST neighbors) - can't do contiguity because of islands
nb <- knn2nb(knearneigh(st_centroid(st_geometry(mgrid)), k = 5))

# nb <- knn2nb(knearneigh(st_centroid(st_geometry(mgrid)), k = 5), sym=T)
# listw <- nb2listw(nb, style="W")


listw <- nb2listw(nb)

# # 2019 -2003 OLS model
# summary(ols <- mgrid %>% 
#           st_drop_geometry() %>% 
#           select(-c(OID_, CA_NetLoss)) %>%
#           #mutate(across(-X19_03_sub_,~log10(.x+0.01))) %>% 
#           lm(data=.,X19_03_sub_  ~. ))


# NetLoss OLS model
summary(ols <- mgrid %>%
  st_drop_geometry() %>%
  select(-c(OID_,X19_03_sub_)) %>%
  #mutate(across(-X19_03_sub_,~log10(.x+0.01))) %>%
  lm(data=.,CA_NetLoss ~. ))

# # export regression tables
# library(jtools)
# library(huxtable)
# library(officer)
# library(flextable)
# 
# export_summs(ols,  scale = TRUE, to.file = "docx", file.name = "test.docx")

#Scatterplot matrix of (a sample of) the regression variables
mgrid %>% 
  sample_n(2000) %>% 
  st_drop_geometry() %>% 
  select(-c(OID_,X19_03_sub_)) %>% 
  ggpairs()


#add country boundaries for plotting residuals
library(mapdata)
library(maps)
library(ggspatial)

country_bounds <- st_as_sf(raster::getData("GADM", country = "Bangladesh", level = 0))

#plotting residuals
mgrid$res <- residuals(ols)

ggplot() +
  geom_sf(data = country_bounds, color = "black", fill = NA) +
  geom_sf(data=mgrid, aes(fill=res),color=NA)+
  theme_bw() +
  scale_fill_gradient2(low = "blue",mid="white", high = "red") +
    labs(fill = "Residuals") +
    annotation_scale()

# testing for autocorrelation

moran.test(mgrid$CA_NetLoss,listw=listw) #autocorrelation before regression

lm.morantest(ols,listw=listw) #autocorrelation AFTER regression

res <- lm.LMtests(ols,listw=listw, test= "all" ) #indicates the use of a spatial lag model
summary(res)

#spatial lag model
library(spdep)
library(spatialreg)

sar_model <- mgrid%>% 
  st_drop_geometry() %>% 
  dplyr::select(-c(OID_,X19_03_sub_)) %>%
  lagsarlm(data=.,CA_NetLoss ~. , listw=listw)
