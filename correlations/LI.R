#----------------------------------------------------------------
#----------------------------------------------------------------#
# Lateralization indices and their group differences
# 
# Author: Anja Thiede <anja.thiede@helsinki.fi>
#----------------------------------------------------------------#

# import packages ---------------
rm(list = ls()) # clean environment
if(!require(readr)){
  install.packages('readr')
  library(readr)
}
if(!require(ggplot2)){
  install.packages('ggplot2')
  library(ggplot2)
}
if(!require(dplyr)){
  install.packages('dplyr')
  library(dplyr)
}

# read data ---------
rm(list=ls())
time = 1
con = "vow"
type = "sub"
os = "windows" # "linux" or "windows"

if (os == "linux") {
  source_data <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv", 
                                sep = ""),
                          col_names = TRUE)
} else {
  source_data <- read_csv(paste("H:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv", 
                                sep = ""),
                          col_names = TRUE)
}

# lateralization indices (LI)
LI <- (source_data$max_amp_lh-source_data$max_amp_rh)/(source_data$max_amp_lh+source_data$max_amp_rh)
#View(LI)
source_data$LI=LI

source_data_one_con <- source_data %>%
  filter(condition == con)
View(source_data_one_con$LI)
ggplot(source_data_one_con, aes(x = group, y=LI)) +
  geom_boxplot(aes(color = group), fill = "white",
                 position = "identity") +
  scale_color_manual(values = c("#00AFBB", "#E7B800")) +
  labs(title=con) +
  stat_summary(fun.y=mean, colour="darkred", geom="point", 
               shape=18, size=3,show.legend = FALSE)

# descriptives and stats
shapiro.test(source_data_one_con$LI)
source_data_one_con %>%
  group_by(group) %>%
  dplyr::summarize(mean = round(mean(LI, na.rm = TRUE), digits=2), sd = round(sd(LI, na.rm = TRUE), digits=2))
t.test(LI ~ group, data = source_data_one_con, paired = FALSE)
