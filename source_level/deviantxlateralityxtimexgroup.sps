* Encoding: UTF-8.
* Mixed ANOVA with two groups and three within-subjects factors with post-hoc comparisons
* 20.5.2010
* Anja Thiede <anja.thiede@helsinki.fi>

SET LOCALE = 'en_US'

* load data N=43

GET
  FILE='Z:\proj\smedy_sources\results\SPSS\big_ANOVA_wide.sav'.
DATASET NAME big_ANOVA WINDOW=FRONT.

* load data N=37

GET
  FILE='Z:\proj\smedy_sources\results\SPSS\big_ANOVA_wide.sav'.
DATASET NAME big_ANOVA WINDOW=FRONT.
USE ALL.
FILTER BY PIQ_match.
EXECUTE.
DATASET ACTIVATE big_ANOVA.

* AMPLITUDES
* run big ANOVA

GLM max_amp_lh_TW1.fre_sub max_amp_lh_TW2.fre_sub max_amp_lh_TW1.dur_sub max_amp_lh_TW2.dur_sub
    max_amp_lh_TW1.vow_sub max_amp_lh_TW2.vow_sub max_amp_rh_TW1.fre_sub max_amp_rh_TW2.fre_sub
    max_amp_rh_TW1.dur_sub max_amp_rh_TW2.dur_sub max_amp_rh_TW1.vow_sub max_amp_rh_TW2.vow_sub BY group
  /WSFACTOR=laterality 2 Polynomial deviant 3 Polynomial time 2 Polynomial
  /MEASURE=amplitude
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality deviant time laterality*deviant*time) TYPE=LINE ERRORBAR=CI
    MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS = TABLES(group) COMPARE(group) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(deviant) COMPARE (deviant) ADJ(BONFERRONI)
  /EMMEANS = TABLES(time) COMPARE(time) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant*time) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant*time) COMPARE(deviant) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant*time) COMPARE(time) ADJ(BONFERRONI)
  /PRINT=DESCRIPTIVE ETASQ OPOWER HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality deviant time laterality*deviant laterality*time deviant*time
    laterality*deviant*time
  /DESIGN=group.

* run ANOVAs separately for time 1 and 2

GLM max_amp_lh_TW1.fre_sub max_amp_lh_TW1.dur_sub max_amp_lh_TW1.vow_sub 
    max_amp_rh_TW1.fre_sub max_amp_rh_TW1.dur_sub max_amp_rh_TW1.vow_sub BY group
  /WSFACTOR=laterality 2 Polynomial deviant 3 Polynomial 
  /MEASURE=amplitude
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality deviant laterality*deviant) TYPE=LINE ERRORBAR=CI
    MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS = TABLES(group) COMPARE(group) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(deviant) COMPARE (deviant) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant) COMPARE(deviant) ADJ(BONFERRONI)
  /PRINT=DESCRIPTIVE ETASQ OPOWER HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality deviant laterality*deviant
  /DESIGN=group.

GLM max_amp_lh_TW2.fre_sub max_amp_lh_TW2.dur_sub max_amp_lh_TW2.vow_sub 
    max_amp_rh_TW2.fre_sub max_amp_rh_TW2.dur_sub max_amp_rh_TW2.vow_sub BY group
  /WSFACTOR=laterality 2 Polynomial deviant 3 Polynomial 
  /MEASURE=amplitude
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality deviant laterality*deviant) TYPE=LINE ERRORBAR=CI
    MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS = TABLES(group) COMPARE(group) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(deviant) COMPARE (deviant) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant) COMPARE(deviant) ADJ(BONFERRONI)
  /PRINT=DESCRIPTIVE ETASQ OPOWER HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality deviant laterality*deviant
  /DESIGN=group.


* LATENCIES
* run two big ANOVAs per time window

GLM max_lat_lh_TW1.fre_sub max_lat_lh_TW1.dur_sub max_lat_lh_TW1.vow_sub 
    max_lat_rh_TW1.fre_sub max_lat_rh_TW1.dur_sub max_lat_rh_TW1.vow_sub BY group
  /WSFACTOR=laterality 2 Polynomial deviant 3 Polynomial 
  /MEASURE=amplitude
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality deviant laterality*deviant) TYPE=LINE ERRORBAR=CI
    MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS = TABLES(group) COMPARE(group) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(deviant) COMPARE (deviant) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*deviant) COMPARE(deviant) ADJ(BONFERRONI)
  /PRINT=DESCRIPTIVE ETASQ OPOWER HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality deviant laterality*deviant
  /DESIGN=group.

GLM max_lat_lh_TW2.fre_sub max_lat_lh_TW2.dur_sub max_lat_lh_TW2.vow_sub 
    max_lat_rh_TW2.fre_sub max_lat_rh_TW2.dur_sub max_lat_rh_TW2.vow_sub BY group
  /WSFACTOR=laterality 2 Polynomial deviant 3 Polynomial 
  /MEASURE=amplitude
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality deviant group*laterality) TYPE=LINE ERRORBAR=CI
    MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS = TABLES(group) COMPARE(group) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(deviant) COMPARE (deviant) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*group) COMPARE(laterality) ADJ(BONFERRONI)
  /EMMEANS = TABLES(laterality*group) COMPARE(group) ADJ(BONFERRONI)
  /PRINT=DESCRIPTIVE ETASQ OPOWER HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality deviant laterality*deviant
  /DESIGN=group.
