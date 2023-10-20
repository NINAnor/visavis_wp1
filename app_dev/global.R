###### global file visAvis WP1 visualization app

##

proj_path<-"P:/312202_visavis/WP1"
library(ggplot2)

# Loading packages
if (!require("pacman")) install.packages("pacman")
# Loading and installing packages if not already installed
pacman::p_load(
  bioRad,
  dplyr,
  ggplot2,
  viridis
)

vp_nohgb <- read_vpfiles(paste0(proj_path,"/data/vp/nohgb/2023/03/test.h5"))


# Extracting data component of vp file
vp_nohgb_data <- vp_nohgb[["data"]]
# see ?summary.vp for a description of the variables in the vp

# Plotting bird density in single vertical profile
ggplot(vp_nohgb_data, aes(x = dens, y = height)) + 
  geom_point(size = 1) + geom_path() + theme_bw() +
  ylab("Metres above sea level") + xlab("Animals pr km^3") + ggtitle("nohgb")



