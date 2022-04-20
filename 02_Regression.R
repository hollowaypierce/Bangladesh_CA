library(tidyverse)
library(sf)
library(spatialreg)
library(spdep)
library(GGally)
library(here)

setwd("D:\\Masters Classes\\Spring_2022\\GEOG 803\\R_Scripts")
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
listw <- nb2listw(nb)

# NetLoss OLS model 
summary(ols <- mgrid %>% 
          st_drop_geometry() %>% 
          select(-c(OID_, CA_NetLoss)) %>%
          #mutate(across(-X19_03_sub_,~log10(.x+0.01))) %>% 
          lm(data=.,X19_03_sub_  ~. ))


# 2019 -2003 OLS model
summary(ols <- mgrid %>% 
  st_drop_geometry() %>% 
  select(-c(OID_,X19_03_sub_)) %>%
  #mutate(across(-X19_03_sub_,~log10(.x+0.01))) %>% 
  lm(data=.,CA_NetLoss ~. ))

# export regression tables
library(jtools)
library(huxtable)
library(officer)
library(flextable)

export_summs(ols,  scale = TRUE, to.file = "docx", file.name = "test.docx")

#Scatterplot matrix of (a sample of) the regression variables
mgrid %>% 
  sample_n(2000) %>% 
  st_drop_geometry() %>% 
  select(-c(OID_,CA_NetLoss)) %>% 
  ggpairs()

#plotting residuals
mgrid$res <- residuals(ols)
ggplot(data=mgrid)+
  geom_sf(aes(fill=res),color=NA)+
  theme_minimal()+
  scale_fill_gradient2(low = "blue",mid="white", high = "red")

#add country boundaries for plotting residuals
library(rnaturalearth)
library(rnaturalearthdata)

world <- ne_countries(scale = "medium", returnclass = "sf")

moran.test(mgrid$X19_03_sub_,listw=listw) #autocorrelation before regression
lm.morantest(ols,listw=listw) #autocorrelation AFTER regression
lm.LMtests(ols,listw=listw) #indicates the use of a spatial lag model

#spatial lag model
sar_model <- mgrid%>% 
  st_drop_geometry() %>% 
  select(-c(OID_,CA_NetLoss)) %>%
  lagsarlm(data=., X19_03_sub_ ~., listw=listw)
