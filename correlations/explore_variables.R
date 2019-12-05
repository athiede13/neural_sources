#----------------------------------------------------------------
#----------------------------------------------------------------#
# Explore data (background, neuropsychological tests, brain data) 
# and draw neuropsychological profile
# 
# Author: Anja Thiede <anja.thiede@helsinki.fi>
#----------------------------------------------------------------#

# load packages -------------
rm(list = ls()) # clean environment
if(!require(tidyverse)){
  install.packages(tidyverse) # install package if it is not yet installed
  library(tidyverse) # load package
}
if(!require(gridExtra)){
  install.packages('gridExtra')
  library(gridExtra)
}
if(!require(grid)){
  install.packages('grid')
  library(grid)
}
if(!require(readr)){
  install.packages('readr')
  library(readr)
}
if(!require(ggplot2)){
  install.packages('ggplot2')
  library(ggplot2)
}
if(!require(Hmisc)){
  install.packages('Hmisc')
  library(Hmisc)
}
if(!require(dplyr)){
  install.packages('dplyr')
  library(dplyr)
}
if(!require(tibble)){
  install.packages('tibble')
  library(tibble)
}
if(!require(reshape2)){
  install.packages('reshape2')
  library(reshape2)
}
if(!require(ggpubr)){
  install.packages('ggpubr')
  library(ggpubr)
}
if(!require(car)){
  install.packages('car')
  library(car)
}

# load data ------------
rm(list=ls())
time = 1
type = "sub" # "sub" for subtraction curves, "erf" for ERF averages, or "std"
os = "windows" # "linux" or "windows"

if (os == "linux") {
source_data <- read_csv(paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), ".csv",
                                sep = ""),
                          col_names = FALSE) # read_csv2 for ; delimited data
colnames(source_data) <- c("subject","group","condition", "max_amp_lh","max_amp_rh","max_lat_lh","max_lat_rh","mean_amp_lh","mean_amp_rh")#,
                       #      "mni_lh_x", "mni_lh_y", "mni_lh_z", "mni_rh_x", "mni_rh_y", "mni_rh_z")
edu_data <- read_csv2("/media//cbru/SMEDY_SOURCES/analyysi/stats/data/education_levels.csv",
                      col_names = TRUE) # read_csv2 for ; delimited data
nepsy <- read_csv("/media/cbru/SMEDY_SOURCES/analyysi/stats/data/group_edu_gender_etc.csv") # read_csv2 for ; delimited data
iq <- read_delim("/media/cbru/SMEDY_SOURCES/analyysi/stats/data/VIQ_PIQ_FIQ.csv", delim = ";",
                 col_names = TRUE) # read_csv2 for ; delimited data
} else {
source_data <- read_csv(paste("H:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), ".csv", 
                              sep = ""),
                        col_names = FALSE) # read_csv2 for ; delimited data
colnames(source_data) <- c("subject","group","condition","max_amp_lh","max_amp_rh","max_lat_lh","max_lat_rh","mean_amp_lh","mean_amp_rh")#,
#      "mni_lh_x", "mni_lh_y", "mni_lh_z", "mni_rh_x", "mni_rh_y", "mni_rh_z")
edu_data <- read_csv2("H:/analyysi/stats/data/education_levels.csv",
                     col_names = TRUE) # read_csv2 for ; delimited data
nepsy <- read_delim("H:/analyysi/stats/data/nepsy.csv", delim = ";",
                    col_names = TRUE)
iq <- read_delim("H:/analyysi/stats/data/VIQ_PIQ_FIQ.csv", delim = ";",
                 col_names = TRUE)
}
#View(edu_data)
head(source_data)
head(nepsy)
View(nepsy)
head(iq)
names(iq)[names(iq) == "Subject ID"] <- "subject" # rename

# merge source_data and nepsy
iq$subject <- tolower(iq$subject)
iq$subject <- str_replace_all(iq$subject, "sme", "sme_")
merged <- merge(nepsy, iq, by.x="subject", by.y="subject")
merged <- merge(source_data, merged, by.x="subject", by.y="subject")
# remove doubles
merged$group.y <- NULL # remove double column
names(merged)[names(merged) == "group.x"] <- "group" # rename
merged$FIQ.y <- NULL # remove double column
names(merged)[names(merged) == "FIQ.x"] <- "FIQ" # rename
names(merged)[names(merged) == "VIQ_SP"] <- "VIQ"
names(merged)[names(merged) == "PIQ_SP"] <- "PIQ"

# # # remove outliers??
# merged %>%
#   group_by(group) %>%
#   dplyr::summarize(min_PIQ = min(PIQ, na.rm = TRUE), max_PIQ = max(PIQ, na.rm = TRUE))
# 
# # based on PIQ
# merged <- merged[!merged$subject == "sme_028",] # dys with very low PIQ (outlier)
# merged <- merged[!merged$subject == "sme_014",] # dys with very low PIQ (outlier)
# merged <- merged[!merged$subject == "sme_040",] # dys with very low PIQ (outlier)
# merged <- merged[!merged$subject == "sme_001",] # con with very high PIQ
# merged <- merged[!merged$subject == "sme_034",] # con with very high PIQ
# # now PIQ differences t-test results in p=0.064
# 
# # go on with PIQ
# merged <- merged[!merged$subject == "sme_002",]
# # now PIQ p-value = 0.1069, edu by levels p-value = 0.05378 (good enough)
# 
# # # based on years of education
# # merged <- merged[!merged$subject == "sme_029",] # con with 23 years of education and very high amplitudes
# # # PIQ fine, but edu not
# # merged <- merged[!merged$subject == "sme_012",] # con with 20 years of education
# # # PIQ fine, but edu not
# #
# # merged <- merged[!merged$subject == "sme_024",] # dys with 11 years of education
# # # merged <- merged[!merged$subject == "sme_011",] # dys with 11.5 years of edu
# 
# # sensor-level education levels exclude
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME033",]
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME046",]
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME047",]
# # same as above for PIQ/edu outlier exclusion
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME028",]
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME014",]
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME040",]
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME001",]
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME034",]
# edu_data <- edu_data[!edu_data$`Subject ID` == "SME002",]
# 
# # edu_data <- edu_data[!edu_data$`Subject ID` == "SME029",]
# # edu_data <- edu_data[!edu_data$`Subject ID` == "SME012",]
# # edu_data <- edu_data[!edu_data$`Subject ID` == "SME024",]
# 
# # # source-level education data exclude
# # edu_data <- edu_data[!edu_data$`Subject ID` == "SME018",]
# # edu_data <- edu_data[!edu_data$`Subject ID` == "SME021",]
# # edu_data <- edu_data[!edu_data$`Subject ID` == "SME030",]
# # edu_data <- edu_data[!edu_data$`Subject ID` == "SME041",]

# fix edu_time 0
merged$edu_time[merged$edu_time == 0] <- NA


# general background info -----------
merged_one_cond <- merged %>%
  filter(condition == "fre_sub")
coef=3 #for boxplot

# group sizes
merged_one_cond %>%
  group_by(group) %>%
  dplyr::count(group)

# age
# test for normality + hist
shapiro.test(merged_one_cond$age)
g = merged_one_cond$age
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="Age")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(mean_age = mean(age, na.rm = TRUE), std_age = sd(age, na.rm = TRUE))
t.test(age ~ group, data = merged_one_cond, paired = FALSE)

# gender
merged_one_cond %>%
  group_by(group) %>%
  dplyr::count(gender)
gender_count <- table(merged_one_cond$group, merged_one_cond$gender)
chisq.test(gender_count)

# education 
shapiro.test(merged_one_cond$edu_time)
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(mean_edu = mean(edu_time, na.rm = TRUE), std_edu = sd(edu_time, na.rm = TRUE))
t.test(edu_time ~ group, data = merged_one_cond, paired = FALSE) # this is not good
# merged[merged$edu_time == min(merged$edu_time, na.rm = TRUE),]
edutime <- ggplot(merged_one_cond,
       mapping = aes(x = group, y = edu_time)) +
  geom_violin(color = 'orange', fill = 'orange') +
  geom_jitter(color = 'darkgrey')
boxplot(edu_time~group, data=merged_one_cond)

# education by levels
edu_data %>%
  group_by(Group) %>%
  dplyr::count(Edu_cat)
edu_count <- table(edu_data$Group, edu_data$Edu_cat)
chisq.test(edu_count)

# compare MusicEd between groups
shapiro.test(merged_one_cond$music_years) # not normally distributed
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(med_music = median(music_years, na.rm = TRUE), iqr_edu = IQR(music_years, na.rm = TRUE))
wilcox.test(music_years ~ group, data = merged_one_cond, paired = FALSE)
musicedu <- ggplot(merged_one_cond,
       mapping = aes(x = group, y = music_years)) +
  geom_violin(color = 'orange', fill = 'orange') +
  geom_jitter(color = 'darkgrey')

# compare FIQ between groups
shapiro.test(merged_one_cond$FIQ)
g = merged_one_cond$FIQ
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="FIQ")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(mean_FIQ = mean(FIQ, na.rm = TRUE), std_FIQ = sd(FIQ, na.rm = TRUE))
t.test(FIQ ~ group, data = merged_one_cond, paired = FALSE)
fiq <- ggplot(merged_one_cond, 
       mapping = aes(x = group, y = FIQ)) + 
  geom_violin(color = 'orange', fill = 'orange') +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=.7, color = 'darkgrey')

# compare VIQ between groups
shapiro.test(merged_one_cond$VIQ) # not normally distributed
g = merged_one_cond$VIQ
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="VIQ")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(med_VIQ = median(VIQ, na.rm = TRUE), iqr_VIQ = IQR(VIQ, na.rm = TRUE))
#t.test(VIQ ~ group, data = merged_one_cond, paired = FALSE)
wilcox.test(VIQ ~ group, data = merged_one_cond, paired = FALSE)
viq <- ggplot(merged_one_cond, 
             mapping = aes(x = group, y = VIQ)) + 
  geom_violin(color = 'orange', fill = 'orange') +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=.7, color = 'darkgrey')

# compare PIQ between groups
shapiro.test(merged_one_cond$PIQ)
g = merged_one_cond$PIQ
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="PIQ")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(mean_PIQ = mean(PIQ, na.rm = TRUE), std_PIQ = sd(PIQ, na.rm = TRUE))
t.test(PIQ ~ group, data = merged_one_cond, paired = FALSE)
piq <- ggplot(merged_one_cond, 
              mapping = aes(x = group, y = PIQ)) + 
  geom_violin(color = 'orange', fill = 'orange') +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=0.7, color = 'darkgrey')
Boxplot(PIQ ~ group, id.method="y", data=merged_one_cond)

# compare phonological processing between groups
shapiro.test(merged_one_cond$phon_proc) 
g = merged_one_cond$phon_proc
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="Phonological processing")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(mean_phon = mean(phon_proc, na.rm = TRUE), std_phon = sd(phon_proc, na.rm = TRUE))
t.test(phon_proc ~ group, data = merged_one_cond, paired = FALSE)
phon_proc <- ggplot(merged_one_cond, 
       mapping = aes(x = group, y = phon_proc)) + 
  geom_violin(color = 'orange', fill = 'orange') +
  geom_jitter(color = 'darkgrey')
# outliers
phon_box <- ggplot(merged_one_con, aes(y = phon_proc, x=group)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE, coef=coef)
Boxplot(merged_one_cond$phon_proc~merged_one_cond$group, id.method="y", range=coef)

# compare technical reading between groups
shapiro.test(merged_one_cond$techn_read) # not normally distributed
g = merged_one_cond$techn_read
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="Technical Reading")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(med_read = median(techn_read, na.rm = TRUE), iqr_read = IQR(techn_read, na.rm = TRUE))
#t.test(techn_read ~ group, data = merged_one_cond, paired = FALSE)
wilcox.test(techn_read ~ group, data = merged_one_cond, paired = FALSE)
read <- ggplot(merged_one_cond, 
       mapping = aes(x = group, y = techn_read)) + 
  geom_violin(color = 'orange', fill = 'orange') +
  geom_jitter(color = 'darkgrey')
read_box <- ggplot(merged_one_cond, aes(y = techn_read, x=group)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE, coef=coef)
Boxplot(merged_one_cond$techn_read~as.factor(merged_one_cond$group), id.method="y", range=coef)
merged_one_cond$subject[28] # "sme_031"
# remove outlier
# merged_one_cond <- merged_one_cond[!merged_one_cond$subject == merged_one_cond$subject[28],]
# View(merged_one_cond)
# Boxplot(merged_one_cond$techn_read~merged_one_cond$group, id.method="y", range=coef)

# compare working memory between groups
shapiro.test(merged_one_cond$work_mem)
g = merged_one_cond$work_mem
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="Working memory")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")
merged_one_cond %>%
  group_by(group) %>%
  dplyr::summarize(mean_mem = mean(work_mem, na.rm = TRUE), std_mem = sd(work_mem, na.rm = TRUE))
t.test(work_mem ~ group, data = merged_one_cond, paired = FALSE)
work_mem <- ggplot(merged_one_cond, 
       mapping = aes(x = group, y = work_mem)) + 
  geom_violin(color = 'orange', fill = 'orange') +
  geom_jitter(color = 'darkgrey')
mem_box <- ggplot(merged_one_con, aes(y = work_mem, x=group)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE, coef=coef)
Boxplot(merged_one_cond$work_mem~merged_one_cond$group, id.method="y", range=coef)

# make many subplots with background variables
edutime
grid.arrange(phon_proc, phon_box, read, read_box, work_mem, mem_box, ncol=2)
grid.arrange(fiq, viq, piq)

# load split_violin_plot extension--------------
GeomSplitViolin <- ggproto("GeomSplitViolin", GeomViolin, 
                           draw_group = function(self, data, ..., draw_quantiles = NULL) {
                             data <- transform(data, xminv = x - violinwidth * (x - xmin), xmaxv = x + violinwidth * (xmax - x))
                             grp <- data[1, "group"]
                             newdata <- plyr::arrange(transform(data, x = if (grp %% 2 == 1) xminv else xmaxv), if (grp %% 2 == 1) y else -y)
                             newdata <- rbind(newdata[1, ], newdata, newdata[nrow(newdata), ], newdata[1, ])
                             newdata[c(1, nrow(newdata) - 1, nrow(newdata)), "x"] <- round(newdata[1, "x"])
                             
                             if (length(draw_quantiles) > 0 & !scales::zero_range(range(data$y))) {
                               stopifnot(all(draw_quantiles >= 0), all(draw_quantiles <=
                                                                         1))
                               quantiles <- ggplot2:::create_quantile_segment_frame(data, draw_quantiles)
                               aesthetics <- data[rep(1, nrow(quantiles)), setdiff(names(data), c("x", "y")), drop = FALSE]
                               aesthetics$alpha <- rep(1, nrow(quantiles))
                               both <- cbind(quantiles, aesthetics)
                               quantile_grob <- GeomPath$draw_panel(both, ...)
                               ggplot2:::ggname("geom_split_violin", grid::grobTree(GeomPolygon$draw_panel(newdata, ...), quantile_grob))
                             }
                             else {
                               ggplot2:::ggname("geom_split_violin", GeomPolygon$draw_panel(newdata, ...))
                             }
                           })

geom_split_violin <- function(mapping = NULL, data = NULL, stat = "ydensity", position = "identity", ..., 
                              draw_quantiles = NULL, trim = TRUE, scale = "area", na.rm = FALSE, 
                              show.legend = NA, inherit.aes = TRUE) {
  layer(data = data, mapping = mapping, stat = stat, geom = GeomSplitViolin, 
        position = position, show.legend = show.legend, inherit.aes = inherit.aes, 
        params = list(trim = trim, scale = scale, draw_quantiles = draw_quantiles, na.rm = na.rm, ...))
}
# profile figure with z scores -----------------
pig_latin_z <- scale(merged$pig_latin, center = TRUE, scale = TRUE)
nw_span_length_z <- scale(merged$nonword_span, center = TRUE, scale = TRUE)
ran_z <- scale(merged$RAS_time*-1, center = TRUE, scale = TRUE)
wl_read_speed_z <- scale(merged$word_list_time*-1, center = TRUE, scale = TRUE)
wl_read_acc_z <- scale(merged$word_list_acc, center = TRUE, scale = TRUE)
pswl_read_speed_z <- scale(merged$pseudoword_list_time*-1, center = TRUE, scale = TRUE)
pswl_read_acc_z <- scale(merged$pseudoword_list_acc, center = TRUE, scale = TRUE)
phon_proc_z <- scale(merged$phon_proc, center = TRUE, scale = TRUE)
tech_read_z <- scale(merged$techn_read, center = TRUE, scale = TRUE)
work_mem_z <- scale(merged$work_mem, center = TRUE, scale = TRUE)

# add columns to merged
merged <- add_column(.data = merged, pig_latin_z, nw_span_length_z, ran_z, wl_read_speed_z,
                     wl_read_acc_z, pswl_read_speed_z, pswl_read_acc_z, phon_proc_z, tech_read_z,
                     work_mem_z)

# violin plots
merged_select_phon_single <- dplyr::select(merged, subject, group, pig_latin_z, nw_span_length_z, ran_z)
merged_select_read_single <- dplyr::select(merged, subject, group, wl_read_speed_z,
                                           wl_read_acc_z, pswl_read_speed_z, pswl_read_acc_z)
merged_select_phon_comp <- dplyr::select(merged, subject, group, phon_proc_z)
merged_select_read_comp <- dplyr::select(merged, subject, group, tech_read_z)
merged_select_mem_comp <- dplyr::select(merged, subject, group, work_mem_z)
x_labels_phon_single <- c("Pig Latin (acc)", "Nonword span length (acc)", "RAN (sp of second trial)")
x_labels_read_single <- c("Word list reading (sp)",
              "Word list reading (acc)", "Psd.word list reading (sp)",
              " Psd.word list reading (acc)")
x_labels_phon_comp <- c("Phonological processing")
x_labels_read_comp <- c("Technical reading")
x_labels_mem_comp <- c("Working memory")
merged_long_phon_single <- melt(merged_select_phon_single, 
                    id.vars = c("subject", "group"), # these variables will not be extended (they will stay constant)
                    variable.name = "neuropsych_variables")
merged_long_read_single <- melt(merged_select_read_single, 
                    id.vars = c("subject", "group"), # these variables will not be extended (they will stay constant)
                    variable.name = "neuropsych_variables")
merged_long_phon_comp <- melt(merged_select_phon_comp, 
                    id.vars = c("subject", "group"), # these variables will not be extended (they will stay constant)
                    variable.name = "neuropsych_variables")
merged_long_read_comp <- melt(merged_select_read_comp, 
                              id.vars = c("subject", "group"), # these variables will not be extended (they will stay constant)
                              variable.name = "neuropsych_variables")
merged_long_mem_comp <- melt(merged_select_mem_comp, 
                              id.vars = c("subject", "group"), # these variables will not be extended (they will stay constant)
                              variable.name = "neuropsych_variables")
ylim_low = -4.8
ylim_high = 2.4
element_text_size = 15
title_text_size = 20

#View(merged_long)
phon_single <- ggplot(merged_long_phon_single, 
       mapping = aes(x = neuropsych_variables, y = value, fill = group)) + 
  geom_split_violin() +
  scale_fill_manual(values=c("#EFC000FF", "#0073C2FF"), name = "Group", labels = c("Dyslexic", "Control")) +
  # geom_boxplot(width=0.1)
  # stat_summary(fun.y="mean", geom="line", aes(group=factor(group))) 
  stat_summary(fun.y=mean, geom="point", shape=23, size=3) +
  theme_classic() +
  theme(text = element_text(size=element_text_size), legend.position='none', axis.text.x = element_blank()) +
  labs(x = "", y = "", subtitle = x_labels_phon_comp) +
  scale_x_discrete(labels = x_labels_phon_single) +
  ylim(ylim_low, ylim_high) +
  coord_flip()

read_single <- ggplot(merged_long_read_single, 
                      mapping = aes(x = neuropsych_variables, y = value, fill = group)) + 
  geom_split_violin() +
  scale_fill_manual(values=c("#EFC000FF", "#0073C2FF"), name = "Group", labels = c("Dyslexic", "Control")) +
  stat_summary(fun.y=mean, geom="point", shape=23, size=3) +
  theme_classic() +
  theme(legend.position='none', text = element_text(size=element_text_size)) +
  labs(x = "", y = "", subtitle = x_labels_read_comp) +
  scale_x_discrete(labels = x_labels_read_single) +
  ylim(ylim_low, ylim_high) +
  coord_flip()

phon_comp <- ggplot(merged_long_phon_comp, 
                      mapping = aes(x = neuropsych_variables, y = value, fill = group)) + 
  geom_split_violin() +
  scale_fill_manual(values=c("#EFC000FF", "#0073C2FF"), name = "Group", labels = c("Dyslexic", "Control")) +
  stat_summary(fun.y=mean, geom="point", shape=23, size=3) +
  theme_classic() +
  theme(text = element_text(size=element_text_size), legend.position='none', 
        plot.subtitle = element_text(hjust = 0.5), axis.text.x = element_blank(),) +
  labs(x = "", y = "", subtitle = "composite score") +
  scale_x_discrete(labels = "") +
  ylim(ylim_low, ylim_high) +
  coord_flip()

read_comp <- ggplot(merged_long_read_comp, 
                      mapping = aes(x = neuropsych_variables, y = value, fill = group)) + 
  geom_split_violin() +
  scale_fill_manual(values=c("#EFC000FF", "#0073C2FF"), name = "Group", labels = c("Dyslexic", "Control")) +
  stat_summary(fun.y=mean, geom="point", shape=23, size=3) +
  theme_classic() +
  theme(text = element_text(size=element_text_size), legend.position='none', axis.text.x = element_blank()) +
  labs(x = "", y = "") +
  scale_x_discrete(labels = "") +
  ylim(ylim_low, ylim_high) +
  coord_flip()

mem_comp <- ggplot(merged_long_mem_comp, 
                      mapping = aes(x = neuropsych_variables, y = value, fill = group)) + 
  geom_split_violin() +
  scale_fill_manual(values=c("#EFC000FF", "#0073C2FF"), name = "Group", labels = c("Dyslexic", "Control")) +
  stat_summary(fun.y=mean, geom="point", shape=23, size=3) +
  theme_classic() +
  theme(text = element_text(size=element_text_size), legend.position='none') +
  labs(x = "", y = "", subtitle = x_labels_mem_comp) +
  scale_x_discrete(labels = "") +
  ylim(ylim_low, ylim_high) +
  coord_flip()

empty <- ggplot(merged_long_mem_comp, 
                mapping = aes(x = neuropsych_variables, y = value, fill = group)) + 
  theme_void() +
  geom_split_violin(alpha=0, color = NA) +
  scale_fill_manual(values=c("#EFC000FF", "#0073C2FF"), name = "Group", labels = c("Dyslexic", "Control")) +
  stat_summary(fun.y=mean, geom="point", shape=23, size=3, alpha=0) +
  guides(fill = guide_legend(override.aes = list(alpha=1))) +
  theme(legend.position = c(0.9,0.6),
        legend.title = element_text(size=title_text_size),
        legend.text = element_text(size=element_text_size))

# combine single plots into one big arrangement
figure <- ggarrange(phon_single, phon_comp,
          read_single, read_comp, 
          empty, mem_comp,
          widths = c(3, 1),
          labels = c("A", "", "B", "", "", "C"),
          ncol = 2, nrow = 3, 
          common.legend = FALSE)

annotate_figure(figure,
                left = text_grob("neuropsychological variable", size = 20, rot = 90, hjust = 0),
                bottom = text_grob("z-score", size = 20, rot = 0, vjust = -17, hjust = 0.5))

ggsave("/media/cbru/SMEDY_SOURCES/results/nepsy_profiles/profiles.pdf", width = 25, height = 25, units = "cm")
ggsave("/media/cbru/SMEDY_SOURCES/results/nepsy_profiles/profiles.png", width = 25, height = 25, units = "cm")

# single components + hist

shapiro.test(wl_read_speed_z)
g = wl_read_speed_z
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="wl_read_speed_z")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")

shapiro.test(wl_read_acc_z)
g = wl_read_acc_z
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="wl_read_acc_z")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")

shapiro.test(pswl_read_speed_z)
g = pswl_read_speed_z
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="pswl_read_speed_z")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")

shapiro.test(pswl_read_acc_z)
g = pswl_read_acc_z
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="pswl_read_acc_z")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")

shapiro.test(pig_latin_z)
g = pig_latin_z
m<-mean(g)
std<-sqrt(var(g))
hist(g, density=10, breaks = 10, prob=TRUE, 
     main="pig_latin_z")
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")

# compare max amplitudes between groups separately for deviants--------------
# con="fre_sub"
coef=3

for (con in c("fre_sub", "dur_sub", "vow_sub")){ #c("fre-ave", "dur-ave", "vow-ave")){#c("std-ave")){#
  merged_one_con <- merged[merged$condition == con,]
  lh <- ggplot(merged_one_con, 
         mapping = aes(x = group, y = max_amp_lh)) + 
    geom_violin(color = 'orange', fill = 'orange') +
    geom_jitter(color = 'darkgrey')
  
  rh <- ggplot(merged_one_con, 
                   mapping = aes(x = group, y = max_amp_rh)) + 
    geom_violin(color = 'orange', fill = 'orange') +
    geom_jitter(color = 'darkgrey')

  merged_one_con_select <- merged_one_con %>%
    dplyr::select(subject, max_amp_lh, max_amp_rh)
  both2 <- melt(merged_one_con_select,
                id.vars = c("subject"), # these variables will not be extended (they will stay constant)
                variable.name = "max_amp")
  both <- ggplot(both2, 
                 mapping = aes(x = 1, y = value)) + 
    geom_violin(color = 'orange', fill = 'orange') +
    geom_jitter(color = 'darkgrey')
  #boxplot(merged$max_amp_rh)
  
  # mean and std of fre
  merged_one_con %>% 
    group_by(group) %>% 
    dplyr::summarize(mean_lh = mean(max_amp_lh, na.rm = TRUE),
              std_lh = sd(max_amp_lh, na.rm = TRUE),
              mean_rh = mean(max_amp_rh, na.rm = TRUE),
              std_rh = sd(max_amp_rh, na.rm = TRUE))
  
  # hists
  g <- merged_one_con$max_amp_lh
  con_lh <- ggplot(merged_one_con, aes(x = g)) + 
    geom_histogram(aes(y =..density..),
                   bins = 15,
                   colour = "black", 
                   fill = "white") +
    stat_function(fun = dnorm, args = list(mean = mean(g), sd = sqrt(var(g))), 
                  colour = "darkblue", size = 1) +
    labs(x = "amp lh")
  h <- merged_one_con$max_amp_rh
  con_rh <- ggplot(merged_one_con, aes(x = h)) + 
    geom_histogram(aes(y =..density..),
                   bins = 15,
                   colour = "black", 
                   fill = "white") +
    stat_function(fun = dnorm, args = list(mean = mean(h), sd = sqrt(var(h))), 
                  colour = "darkblue", size = 1) +
    labs(x = "amp rh")
  l <- both2$value
  print(shapiro.test(l))
  con_both <- ggplot(both2, aes(x = l)) + 
    geom_histogram(aes(y =..density..),
                   bins = 15,
                   colour = "black", 
                   fill = "white") +
    stat_function(fun = dnorm, args = list(mean = mean(l), sd = sqrt(var(l))), 
                  colour = "darkblue", size = 1) +
    labs(x = "max amp both hemi")
  
  # box plots showing outliers
  b1 <- ggplot(merged_one_con, aes(y = g)) + 
    geom_boxplot(outlier.colour="black", outlier.shape=16,
                     outlier.size=2, notch=FALSE, coef=coef)
  # Boxplot(g)
  b2 <- ggplot(merged_one_con, aes(y = h)) + 
    geom_boxplot(outlier.colour="black", outlier.shape=16,
                 outlier.size=2, notch=FALSE, coef=coef)
  # Boxplot(h)
  b3 <- ggplot(both2, aes(y = value)) + 
    geom_boxplot(outlier.colour="black", outlier.shape=16,
                 outlier.size=2, notch=FALSE, coef=coef)
  b3_outl <- Boxplot(l, range=coef)
  
  # outliers?
  print(both2$subject[b3_outl])
  # make subplots with max amplitudes
  grid.arrange(lh, con_lh, b1, rh, con_rh, b2, both, con_both, b3, ncol = 3, top = textGrob(con,gp=gpar(fontsize=20)))
}

# compare max amplitudes between groups for deviants pooled together--------------
coef=3

# box plots showing outliers
b1 <- ggplot(merged, aes(y = max_amp_lh)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE, coef=coef)
# Boxplot(g)
b2 <- ggplot(merged, aes(y = max_amp_rh)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE, coef=coef)
# Boxplot(h)
merged_select <- merged %>%
  dplyr::select(subject, max_amp_lh, max_amp_rh)
both2 <- melt(merged_select,
              id.vars = c("subject"), # these variables will not be extended (they will stay constant)
              variable.name = "max_amp")
b3 <- ggplot(both2, aes(y = value)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE, coef=coef)
grid.arrange(b1, b2, b3, ncol = 3, top = textGrob(con,gp=gpar(fontsize=20)))
b3_outl <- Boxplot(both2$value, range=coef)

# outliers?
print(both2$subject[b3_outl])
# # # remove outliers
# merged <- merged[!merged$subject == "sme_005",]
# merged <- merged[!merged$subject == "sme_043",]
# merged <- merged[!merged$subject == "sme_045",]

# compare mean amplitudes between groups --------------
for (con in c("fre_sub", "dur_sub", "vow_sub")){ #c("fre-ave", "dur-ave", "vow-ave")){#c("std-ave")){#
  merged_one_con <- merged[merged$condition == con,]
  lh <- ggplot(merged_one_con, 
               mapping = aes(x = group, y = mean_amp_lh)) + 
    geom_violin(color = 'orange', fill = 'orange') +
    geom_jitter(color = 'darkgrey')
  
  rh <- ggplot(merged_one_con, 
               mapping = aes(x = group, y = mean_amp_rh)) + 
    geom_violin(color = 'orange', fill = 'orange') +
    geom_jitter(color = 'darkgrey')
  
  merged_one_con_select <- merged_one_con %>%
    dplyr::select(subject, mean_amp_lh, mean_amp_rh)
  both2 <- melt(merged_one_con_select,
                id.vars = c("subject"), # these variables will not be extended (they will stay constant)
                variable.name = "mean_amp")
  both <- ggplot(both2, 
                 mapping = aes(x = 1, y = value)) + 
    geom_violin(color = 'orange', fill = 'orange') +
    geom_jitter(color = 'darkgrey')
  #boxplot(merged$max_amp_rh)
  
  # mean and std of fre
  merged_one_con %>% 
    group_by(group) %>% 
    dplyr::summarize(mean_lh = mean(mean_amp_lh, na.rm = TRUE),
                     std_lh = sd(mean_amp_lh, na.rm = TRUE),
                     mean_rh = mean(mean_amp_rh, na.rm = TRUE),
                     std_rh = sd(mean_amp_rh, na.rm = TRUE))
  
  # hists
  g <- merged_one_con$mean_amp_lh
  con_lh <- ggplot(merged_one_con, aes(x = g)) + 
    geom_histogram(aes(y =..density..),
                   bins = 15,
                   colour = "black", 
                   fill = "white") +
    stat_function(fun = dnorm, args = list(mean = mean(g), sd = sqrt(var(g))), 
                  colour = "darkblue", size = 1) +
    labs(x = "amp lh")
  h <- merged_one_con$mean_amp_rh
  con_rh <- ggplot(merged_one_con, aes(x = h)) + 
    geom_histogram(aes(y =..density..),
                   bins = 15,
                   colour = "black", 
                   fill = "white") +
    stat_function(fun = dnorm, args = list(mean = mean(h), sd = sqrt(var(h))), 
                  colour = "darkblue", size = 1) +
    labs(x = "amp rh")
  l <- both2$value
  print(shapiro.test(l))
  con_both <- ggplot(both2, aes(x = l)) + 
    geom_histogram(aes(y =..density..),
                   bins = 15,
                   colour = "black", 
                   fill = "white") +
    stat_function(fun = dnorm, args = list(mean = mean(l), sd = sqrt(var(l))), 
                  colour = "darkblue", size = 1) +
    labs(x = "mean amp both hemi")
  # make subplots with max amplitudes
  grid.arrange(lh, con_lh, rh, con_rh, both, con_both, ncol = 2, top = textGrob(con,gp=gpar(fontsize=20)))
}

# save datasets for R usage ------------

if (os == "linux") {
write.csv(merged, paste("/media/cbru/SMEDY_SOURCES/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned_matched.csv",
                         sep = ""))
  } else {
write.csv(merged, paste("H:/results/source_amps_lat/", type, "_hemi_amp_lat_tw", toString(time), "_cleaned.csv",
                         sep = ""))
  }
  