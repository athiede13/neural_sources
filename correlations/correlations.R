#----------------------------------------------------------------
#----------------------------------------------------------------#
# Correlational analysis and plots
# 
# Author: Anja Thiede <anja.thiede@helsinki.fi>
#----------------------------------------------------------------#

# import packages ---------------
rm(list = ls()) # clean environment
if(!require(tidyverse)){
  install.packages(tidyverse) # install package if it is not yet installed
  library(tidyverse) # load package
}
if(!require(gridExtra)){
  install.packages('gridExtra')
  library(gridExtra)
}
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
if(!require(tibble)){
  install.packages('tibble')
  library(tibble)
}
if(!require(ggpubr)){
  install.packages('ggpubr')
  library(ggpubr)
}
if(!require(ppcor)){
  install.packages('ppcor')
  library(ppcor)
}

# read data and whole-group correlations ---------
rm(list=ls())
time = 1
#con = "vow_sub"
type = "sub"
os = "windows" # "linux" or "windows"

if (os == "linux") {
  source_data <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv", 
                                sep = ""),
                          col_names = TRUE)
} else {
  source_data <- read_csv(paste("E:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv", 
                                sep = ""),
                          col_names = TRUE)
}
#View(source_data)

# remove outlier & edu
source_data$techn_read[source_data$subject == "sme_031"] <- NA
source_data$edu_time <- NULL

# correlations
method = "pearson"
source_data_one_con <- source_data #%>%
  #filter(condition == con) # comment this out when looking at correlations across deviants
View(source_data_one_con)

phon_lh_all <- pcor.test(source_data_one_con$max_amp_lh, source_data_one_con$phon_proc, source_data_one_con$PIQ, method = method)
phon_rh_all <- pcor.test(source_data_one_con$max_amp_rh, source_data_one_con$phon_proc, source_data_one_con$PIQ, method = method)
source_data_one_con_nan <- na.omit(source_data_one_con) 
View(source_data_one_con_nan)
read_lh_all <- pcor.test(source_data_one_con_nan$max_amp_lh, source_data_one_con_nan$techn_read, source_data_one_con_nan$PIQ, method = method)
read_rh_all <- pcor.test(source_data_one_con_nan$max_amp_rh, source_data_one_con_nan$techn_read, source_data_one_con_nan$PIQ, method = method)
mem_lh_all <- pcor.test(source_data_one_con$max_amp_lh, source_data_one_con$work_mem, source_data_one_con$PIQ, method = method)
mem_rh_all <- pcor.test(source_data_one_con$max_amp_rh, source_data_one_con$work_mem, source_data_one_con$PIQ, method = method)

number <- pcor.test(source_data_one_con$max_amp_lh, source_data_one_con$number_series, source_data_one_con$PIQ, method = method)
visual <- pcor.test(source_data_one_con$max_amp_lh, source_data_one_con$visual_series, source_data_one_con$PIQ, method = method)

# partial correlations separately for the groups --------------
  
source_data_con <- source_data_one_con[!(source_data_one_con$group=="dys"),]
source_data_dys <- source_data_one_con[!(source_data_one_con$group=="con"),]

# correlations for controls only
phon_lh_con <- pcor.test(source_data_con$max_amp_lh, source_data_con$phon_proc, source_data_con$PIQ, method = method)
phon_rh_con <- pcor.test(source_data_con$max_amp_rh, source_data_con$phon_proc, source_data_con$PIQ, method = method)
read_lh_con <- pcor.test(source_data_con$max_amp_lh, source_data_con$techn_read, source_data_con$PIQ, method = method)
read_rh_con <- pcor.test(source_data_con$max_amp_rh, source_data_con$techn_read, source_data_con$PIQ, method = method)
mem_lh_con <- pcor.test(source_data_con$max_amp_lh, source_data_con$work_mem, source_data_con$PIQ, method = method)
mem_rh_con <- pcor.test(source_data_con$max_amp_rh, source_data_con$work_mem, source_data_con$PIQ, method = method)

# correlations for dyslexics only
phon_lh_dys <- pcor.test(source_data_dys$max_amp_lh, source_data_dys$phon_proc, source_data_dys$PIQ, method = method)
phon_rh_dys <- pcor.test(source_data_dys$max_amp_rh, source_data_dys$phon_proc, source_data_dys$PIQ, method = method)
source_data_dys_nan <- na.omit(source_data_dys) 
read_lh_dys <- pcor.test(source_data_dys_nan$max_amp_lh, source_data_dys_nan$techn_read, source_data_dys_nan$PIQ, method = method)
read_rh_dys <- pcor.test(source_data_dys_nan$max_amp_rh, source_data_dys_nan$techn_read, source_data_dys_nan$PIQ, method = method)
mem_lh_dys <- pcor.test(source_data_dys$max_amp_lh, source_data_dys$work_mem, source_data_dys$PIQ, method = method)
mem_rh_dys <- pcor.test(source_data_dys$max_amp_rh, source_data_dys$work_mem, source_data_dys$PIQ, method = method)

wlt_lh_dys <- pcor.test(source_data_dys$max_amp_lh, source_data_dys$word_list_time, source_data_dys$PIQ, method = "spearman")
wla_lh_dys <- pcor.test(source_data_dys$max_amp_lh, source_data_dys$word_list_acc, source_data_dys$PIQ, method = "spearman")
plt_lh_dys <- pcor.test(source_data_dys$max_amp_lh, source_data_dys$pseudoword_list_time, source_data_dys$PIQ, method = "spearman")
pla_lh_dys <- pcor.test(source_data_dys$max_amp_lh, source_data_dys$pseudoword_list_acc, source_data_dys$PIQ, method = "spearman")

# results step 1--------------
phon_lh_all
phon_rh_all
read_lh_all
read_rh_all
mem_lh_all
mem_rh_all
phon_lh_con
phon_rh_con
read_lh_con
read_rh_con
mem_lh_con
mem_rh_con
phon_lh_dys
phon_rh_dys
read_lh_dys
read_rh_dys
mem_lh_dys
mem_rh_dys

# results step 2--------------
con
#mem_lh_all
#mem_lh_con
#read_lh_dys
read_rh_dys

# results step 3---------------
con
number
visual

con
wlt_lh_dys 
wla_lh_dys 
plt_lh_dys 
pla_lh_dys

# collect signif correlations and make plots-------------

# figure characteristics
element_text_size = 12
title_text_size = 18
fill = "group"
shape = 21
size = 2
palette = c("#0073C2FF", "orange") # "jco"
add = "reg.line" #"reg.line" #"none"#
add.params = list(color = "group")
conf.int = TRUE 
cor.coef = FALSE
cor.method = "pearson"
# geom_smooth
color_geom="black"
method="lm"
se=TRUE
linetype="solid"
fullrange=TRUE
legend.position = "none"

# MMF
time = 1
type = "sub"
os = "windows" # "linux" or "windows"

if (os == "linux") {
  source_data <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv",
                                sep = ""),
                          col_names = TRUE)
} else {
  source_data <- read_csv(paste("E:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv",
                                sep = ""),
                          col_names = TRUE)
}

# significant whole-group correlations
# scatter plots
# extract residuals from linear regression
amp_resid_whole <- resid(lm(max_amp_lh~PIQ, source_data))*1000
mem_resid_whole <- resid(lm(work_mem~PIQ, source_data))
source_data <- add_column(.data = source_data, amp_resid_whole, mem_resid_whole)
whole_group <- ggscatter(source_data, y = "amp_resid_whole", x = "mem_resid_whole", 
                         title = "",
                         fill = fill, shape = shape, size = size,
                         add = "none", add.params = add.params, conf.int = conf.int, 
                         cor.coef = cor.coef, cor.method = cor.method,
                         ylab = "MMF lh | PIQ [pAm]", xlab = "work mem | PIQ [std]",
                         palette = palette) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(data = filter(source_data, group == "con"), method = "lm", fill="#0073C2FF") +
  geom_smooth(color=color_geom, method=method, se=se, linetype=linetype, fullrange=fullrange) +
  theme(legend.position = legend.position) 

con = "dur_sub"

source_data_dur1 <- source_data %>%
  filter(condition == con)
amp_resid_dur1 <- resid(lm(max_amp_lh~PIQ,source_data_dur1))*1000
mem_resid_dur <- resid(lm(work_mem~PIQ,source_data_dur1))
source_data_dur1 <- add_column(.data = source_data_dur1, amp_resid_dur1, mem_resid_dur)
dur_mem1 <- ggscatter(source_data_dur1, y = "amp_resid_dur1", x = "mem_resid_dur", 
                          title = "",
                          fill = fill, shape = shape, size = size,
                          add = "none", add.params = add.params, conf.int = conf.int, 
                          cor.coef = cor.coef, cor.method = cor.method,
                          ylab = paste("MMF ", substr(con,0,3), " lh | PIQ [pAm]", sep = ""), 
                          xlab = "work mem | PIQ [std]",
                          palette = c("orange", "#0073C2FF")) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(color=color_geom, method=method, se=se, linetype=linetype, fullrange=fullrange) +
  theme(legend.position = legend.position) 

# duration lh and number series
numb_resid_dur <- resid(lm(number_series~PIQ,source_data_dur1))
source_data_dur1 <- add_column(.data = source_data_dur1, numb_resid_dur)
dur_numb <- ggscatter(source_data_dur1, y = "amp_resid_dur1", x = "numb_resid_dur", 
                      title = "",
                      fill = fill, shape = shape, size = size,
                      add = "none", add.params = add.params, conf.int = conf.int, 
                      cor.coef = cor.coef, cor.method = cor.method,
                      ylab = paste("MMF ", substr(con,0,3), " lh | PIQ [pAm]", sep = ""), 
                      xlab = "number series | PIQ [std]",
                      palette = c("orange", "#0073C2FF")) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(color=color_geom, method=method, se=se, linetype=linetype, fullrange=fullrange) +
  theme(legend.position = legend.position) 


# rh and reading
#amp_resid_whole_rh <- resid(lm(max_amp_rh~PIQ, source_data))*1000
#read_resid_whole <- resid(lm(techn_read~PIQ, source_data))
#source_data <- add_column(.data = source_data, read_resid_whole, amp_resid_whole_rh)
# remove outlier
#source_data <- source_data[!source_data$subject == "sme_031",]
#View(source_data)
#read <- ggscatter(source_data, y = "amp_resid_whole_rh", x = "read_resid_whole", 
#                         title = "",
#                         fill = fill, shape = shape, size = size,
#                         add = "none", add.params = list(color = "orange"), conf.int = conf.int, 
#                         cor.coef = cor.coef, cor.method = cor.method,
#                         ylab = "MMF rh | PIQ [pAm]", xlab = "tech read | PIQ [z]",
#                         palette = palette) +
#  theme_set(theme_pubr(base_size = element_text_size)) +
#  geom_smooth(data = filter(source_data, group == "dys"), method = "lm", colour="orange", fill="orange") +
#  theme(legend.position = legend.position) 

# late MMF
time = 2
type = "sub"
os = "windows" # "linux" or "windows"

if (os == "linux") {
  source_data2 <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv",
                                sep = ""),
                          col_names = TRUE)
} else {
  source_data2 <- read_csv(paste("E:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv",
                                sep = ""),
                          col_names = TRUE)
}

# remove outlier
source_data2 <- source_data2[!source_data2$subject == "sme_031",]

amp_rh_resid2 <- resid(lm(max_amp_rh~PIQ,source_data2))*1000
read_resid2 <- resid(lm(techn_read~PIQ,source_data2))
source_data2 <- add_column(.data = source_data2, amp_rh_resid2, read_resid2)
read2 <- ggscatter(source_data2, y = "amp_rh_resid2", x = "read_resid2",
                          title = "",
                          fill = fill, shape = shape, size = size,
                          add = "none", add.params = add.params, conf.int = conf.int,
                          cor.coef = cor.coef, cor.method = cor.method,
                          ylab = "late MMF rh | PIQ [pAm]", xlab = "tech read | PIQ [z]",
                          palette = c("#0073C2FF", "orange")) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(data = filter(source_data2, group == "dys"), method = "lm", colour="orange", fill="orange") +
  theme(legend.position = legend.position)

# plot all

ggarrange(whole_group, dur_mem1, dur_numb, read2, labels = c("Working memory","", "", "Technical reading"),
          label.x = -0.05, label.y = 1.025,
          font.label = list(size = title_text_size, face = "plain"),
          ncol = 3, nrow = 2,
          common.legend = TRUE, legend="bottom", align="hv")

if (os == "linux") {
  ggsave("/media/cbru/SMEDY_SOURCES/results/correlations/corr_v3.pdf", width = 31, height = 12, units = "cm")
  ggsave("/media/cbru/SMEDY_SOURCES/results/correlations/corr_v3.png", width = 31, height = 12, units = "cm")
} else {
  ggsave("E:/results/correlations/corr_v3.pdf", width = 22.5, height = 15, units = "cm")
  ggsave("E:/results/correlations/corr_v3.png", width = 22.5, height = 15, units = "cm")
}