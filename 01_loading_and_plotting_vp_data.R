


# This script shows how to load, transform and plot vertical profile data to create plots that are similar to the two plots on this site:
#https://www.meteo.be/services/birdDetection/#/

# Setting working directory
setwd("/data/P-Prosjekter2/312202_visavis/WP1")


# Loading packages
if (!require("pacman")) install.packages("pacman")
# Loading and installing packages if not already installed
pacman::p_load(
  bioRad,
  dplyr,
  ggplot2,
  viridis
  )


# Loading data ----------------

# Loading single vertical profile (vp)
vp_nohgb <- read_vpfiles("data/vp/nohgb/2023/03/vp2023-03-15 01-06-03.h5")

# Extracting data component of vp file
vp_nohgb_data <- vp_nohgb[["data"]]
# see ?summary.vp for a description of the variables in the vp

# Plotting bird density in single vertical profile
ggplot(vp_nohgb_data, aes(x = dens, y = height)) + 
  geom_point(size = 1) + geom_path() + theme_bw() +
  ylab("Metres above sea level") + xlab("Animals pr km^3") + ggtitle("nohgb")



# Loading vertical profile time series (vpts)
vpts_nohgb <- readRDS("data/vpts/nohgb_2022-09-16.rds") # Contains all vertical profiles from the 16th of september 2022.

# Converting vpts into tidy data.frame:
vpts_nohgb_df <- as.data.frame(vpts_nohgb)




# Plotting migration traffic rate -----------------------------

# To create the first plot showing migration density during the whole day, 
# We can use the integrate_profile function to aggregate migration traffic from all altitudinal layers into one value
vpts_nohgb_integrated <- integrate_profile(vpts_nohgb)

ggplot(vpts_nohgb_integrated, aes(x = datetime, y = mtr)) + geom_point() + geom_line() + theme_bw() + 
  ylab("Migration traffic rate (birds/km/h)") + xlab("datetime")
# This plot shows one value for each scan (every 10 minutes), but we can easily aggregate the time if we want.

# see details under ?integrate_profile for a description of the different variables. We could choose to create plots for several of these variables
# like was possible at the website. I think mtr and vid are most relevant.




# Plotting altitudinal distribution of migration traffic rate --------------

ggplot(vpts_nohgb_df, aes(x = datetime, y = height, fill = dens)) + geom_tile() + scale_fill_viridis(na.value = "grey80") + ylab("Height (meters") + 
  theme_bw() + guides(fill=guide_legend(title="Birds pr km^3")) + theme(axis.title.x = element_blank())




