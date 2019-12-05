#----------------------------------------------------------------
#----------------------------------------------------------------#
# extract brain area from AAL atlas from MNI coordinates
# 
# Author: Anja Thiede <anja.thiede@helsinki.fi>
#----------------------------------------------------------------#

# install packages-------------------
install.packages("devtools")
library("devtools")
install_github("yunshiuan/label4MRI")
library(label4MRI)
library(readxl)
if(!require(readr)){
  install.packages('readr')
  library(readr)
}

# read in data and apply MNI function--------------
m <- read_excel("/media/cbru/SMEDY_SOURCES/results/MNI/mni_coordinates_out.xlsx", col_names=FALSE)
#View(m)
names(m)[names(m)=="...3"] <- "x"
names(m)[names(m)=="...4"] <- "y"
names(m)[names(m)=="...5"] <- "z"
Result <- t(mapply(FUN = mni_to_region_name, x = m$x, y = m$y, z = m$z))
View(Result)
write.csv(Result,"/media/cbru/SMEDY_SOURCES/results/MNI/MNI_brain_areas.csv")

mni_to_region_name(65,	-26,	-13)