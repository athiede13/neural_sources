#----------------------------------------------------------------
#----------------------------------------------------------------#
# Correlational analysis and plots for matched PIQ sample
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
time = 2
con = "vow_sub"
type = "sub"
os = "windows" # "linux" or "windows"

if (os == "linux") {
  source_data <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned_matched.csv", 
                                sep = ""),
                          col_names = TRUE)
} else {
  source_data <- read_csv(paste("D:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned_matched.csv", 
                                sep = ""),
                          col_names = TRUE)
}

# remove outlier & edu
source_data$techn_read[source_data$subject == "sme_031"] <- NA
source_data$edu_time <- NULL

# correlations
method = "pearson" #before "spearman"
source_data_one_con <- source_data %>%
  filter(condition == con)

phon_lh_all <- cor.test(source_data_one_con$max_amp_lh, source_data_one_con$phon_proc, method = method)
phon_rh_all <- cor.test(source_data_one_con$max_amp_rh, source_data_one_con$phon_proc, method = method)
source_data_one_con_nan <- na.omit(source_data_one_con) 
read_lh_all <- cor.test(source_data_one_con_nan$max_amp_lh, source_data_one_con_nan$techn_read, method = method)
read_rh_all <- cor.test(source_data_one_con_nan$max_amp_rh, source_data_one_con_nan$techn_read, method = method)
mem_lh_all <- cor.test(source_data_one_con$max_amp_lh, source_data_one_con$work_mem, method = method)
mem_rh_all <- cor.test(source_data_one_con$max_amp_rh, source_data_one_con$work_mem, method = method)

# partial correlations separately for the groups --------------

source_data_con <- source_data_one_con[!(source_data_one_con$group=="dys"),]
source_data_dys <- source_data_one_con[!(source_data_one_con$group=="con"),]

# correlations for controls only
phon_lh_con <- cor.test(source_data_con$max_amp_lh, source_data_con$phon_proc, method = method)
phon_rh_con <- cor.test(source_data_con$max_amp_rh, source_data_con$phon_proc, method = method)
read_lh_con <- cor.test(source_data_con$max_amp_lh, source_data_con$techn_read, method = method)
read_rh_con <- cor.test(source_data_con$max_amp_rh, source_data_con$techn_read, method = method)
mem_lh_con <- cor.test(source_data_con$max_amp_lh, source_data_con$work_mem, method = method)
mem_rh_con <- cor.test(source_data_con$max_amp_rh, source_data_con$work_mem, method = method)

# correlations for dyslexics only
phon_lh_dys <- cor.test(source_data_dys$max_amp_lh, source_data_dys$phon_proc, method = method)
phon_rh_dys <- cor.test(source_data_dys$max_amp_rh, source_data_dys$phon_proc, method = method)
source_data_dys_nan <- na.omit(source_data_dys) 
read_lh_dys <- cor.test(source_data_dys_nan$max_amp_lh, source_data_dys_nan$techn_read, method = method)
read_rh_dys <- cor.test(source_data_dys_nan$max_amp_rh, source_data_dys_nan$techn_read, method = method)
mem_lh_dys <- cor.test(source_data_dys$max_amp_lh, source_data_dys$work_mem, method = method)
mem_rh_dys <- cor.test(source_data_dys$max_amp_rh, source_data_dys$work_mem, method = method)

wlt_lh_dys <- cor.test(source_data_dys$max_amp_lh, source_data_dys$word_list_time, method = method)
wla_lh_dys <- cor.test(source_data_dys$max_amp_lh, source_data_dys$word_list_acc, method = method)
plt_lh_dys <- cor.test(source_data_dys$max_amp_lh, source_data_dys$pseudoword_list_time, method = method)
pla_lh_dys <- cor.test(source_data_dys$max_amp_lh, source_data_dys$pseudoword_list_acc, method = method)

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
# phon_lh_con 
# mem_lh_con 
read_rh_dys 

#results step 3---------------
con
wlt_lh_dys 
wla_lh_dys 
plt_lh_dys 
pla_lh_dys

# collect signif correlations and make plots-------------
rm(list=ls())
# figure characteristics
element_text_size = 12
title_text_size = 18
fill = "group"
shape = 21
size = 2
add = "reg.line" #"reg.line" #"none"#
add.params = list(color = "group")
conf.int = TRUE 
cor.coef = FALSE
cor.method = "pearson"
palette = c("#0073C2FF", "orange") # "jco"
# geom_smooth
color_geom="black"
method="lm"
se=TRUE
linetype="solid"
fullrange=TRUE
legend.position = "none"

# control group
time = 1
# con = "vow"
type = "sub"
os = "windows" # "linux" or "windows"

if (os == "linux") {
  source_data <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned_matched.csv", 
                                sep = ""),
                          col_names = TRUE)
} else {
  source_data <- read_csv(paste("D:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned_matched.csv", 
                                sep = ""),
                          col_names = TRUE)
}

source_data$max_amp_lh <- source_data$max_amp_lh*1000 # unit pAm

# scatter plots
phon <- ggscatter(source_data, y = "max_amp_lh", x = "phon_proc", 
                         title = "",
                         fill = fill, shape = shape, size = size,
                         add = "none", conf.int = conf.int, 
                         cor.coef = cor.coef, cor.method = cor.method,
                         ylab = "MMF lh [pAm]", xlab = "phon proc [z]",
                         palette = palette) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(data = filter(source_data, group == "con"), method = "lm", fill="#0073C2FF") +
  theme(legend.position = legend.position) 

work_mem <- ggscatter(source_data, y = "max_amp_lh", x = "work_mem", 
                             title = "",
                             fill = fill, shape = shape, size = size,
                             add = "none", conf.int = conf.int, 
                             cor.coef = cor.coef, cor.method = cor.method,
                             ylab = "MMF lh [pAm]", xlab = "work mem [std]",
                             palette = palette) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(data = filter(source_data, group == "con"), method = "lm", fill="#0073C2FF") +
  theme(legend.position = legend.position) 

# dyslexic group 
# read

read <- ggscatter(source_data, y = "max_amp_rh", x = "techn_read", 
                          title = "",
                          fill = fill, shape = shape, size = size,
                          add = "none", conf.int = conf.int, 
                          cor.coef = cor.coef, cor.method = cor.method,
                          ylab = "MMF rh [pAm]", xlab = "tech read [z]",
                          palette = palette) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(data = filter(source_data, group == "dys"), method = "lm", colour="orange", fill="orange") +
  theme(legend.position = legend.position) 

# late MMF
time = 2
type = "sub"
os = "windows" # "linux" or "windows"

if (os == "linux") {
  source_data2 <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned_matched.csv", 
                                sep = ""),
                          col_names = TRUE)
} else {
  source_data2 <- read_csv(paste("D:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned_matched.csv", 
                                sep = ""),
                          col_names = TRUE)
}

# remove outlier
source_data2 <- source_data2[!source_data2$subject == "sme_031",]

source_data2$max_amp_rh <- source_data2$max_amp_rh*1000 # unit pAm
read2 <- ggscatter(source_data2, y = "max_amp_rh", x = "techn_read",
                   title = "",
                   fill = fill, shape = shape, size = size,
                   add = "none", add.params = add.params, conf.int = conf.int,
                   cor.coef = cor.coef, cor.method = cor.method,
                   ylab = "late MMF rh [pAm]", xlab = "tech read [z]",
                   palette = c("#0073C2FF", "orange")) +
  theme_set(theme_pubr(base_size = element_text_size)) +
  geom_smooth(data = filter(source_data2, group == "dys"), method = "lm", colour="orange", fill="orange") +
  theme(legend.position = legend.position)

empty <- ggplot(source_data, 
                mapping = aes(x = "amp_resid_dur", y = "phon_resid_dur")) + 
  theme_void() +
  geom_dotplot(alpha=1, color = "black", binwidth = 0)

legend <- ggplot(source_data, 
                 mapping = aes(x = "amp_resid_dur", y = "phon_resid_dur", fill = group)) + 
  theme_void() +
  geom_dotplot(alpha=1, color = "black", binwidth = 0) +
  scale_fill_manual(values=c("orange", "#0073C2FF"), name = "Group", labels = c("Dyslexic", "Control")) +
  theme(legend.position = c(0.5,0.5),
        legend.title = element_text(size=title_text_size),
        legend.text = element_text(size=element_text_size))

# plot all

ggarrange(phon, work_mem, read2, 
          labels = c("Phonological processing",  
                     "Working memory",  
                     "Technical Reading"),
          #label.x = -0.05, label.y = 1.025,
          label.x = 0, label.y = 1.025, hjust = c(-0.05,-0.4,-0.35),
          font.label = list(size = title_text_size, face = "plain"),
          nrow = 3,
          common.legend = TRUE, legend="bottom", align="hv")

if (os == "linux") {
  ggsave("/media/cbru/SMEDY_SOURCES/results/correlations/corr_matched.pdf", width = 31, height = 12, units = "cm")
  ggsave("/media/cbru/SMEDY_SOURCES/results/correlations/corr_matched.png", width = 31, height = 12, units = "cm")
} else {
  ggsave("D:/results/correlations/corr_matched.pdf", width = 7.5, height = 22.5, units = "cm")
  ggsave("D:/results/correlations/corr_matched.png", width = 7.5, height = 22.5, units = "cm")
}
