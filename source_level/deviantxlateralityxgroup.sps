* Encoding: UTF-8.
/* Read data, TW1 or TW3
PRESERVE.
SET DECIMAL DOT.
GET DATA  /TYPE=TXT
  /FILE="D:\results\source_amps_lat\sub_hemi_amp_lat_tw2_cleaned_matched.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  V1 AUTO
  subject AUTO
  group AUTO
  condition AUTO
  max_amp_lh AUTO
  max_amp_rh AUTO
  max_lat_lh AUTO
  max_lat_rh AUTO
  mean_amp_lh AUTO
  mean_amp_rh AUTO
  age AUTO
  gender AUTO
  music_years AUTO
  edu_time AUTO
  FIQ AUTO
  phon_proc AUTO
  techn_read AUTO
  work_mem AUTO
  pig_latin AUTO
  nonword_span AUTO
  RAS_time AUTO
  word_list_time AUTO
  word_list_acc AUTO
  pseudoword_list_time AUTO
  pseudoword_list_acc AUTO
  PIQ AUTO
  VIQ AUTO
  pig_latin_z AUTO
  nw_span_length_z AUTO
  ran_z AUTO
  wl_read_speed_z AUTO
  wl_read_acc_z AUTO
  pswl_read_speed_z AUTO
  pswl_read_acc_z AUTO
  phon_proc_z AUTO
  tech_read_z AUTO
  work_mem_z AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.

DATASET NAME DataSet1 WINDOW=FRONT.
USE ALL.

/* Filter for condition
COMPUTE filter_$=(condition =  "fre_sub").
VARIABLE LABELS filter_$ 'condition =  "fre_sub" (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

 * /* test MMFs for significance
SORT CASES  BY group.
 * SPLIT FILE LAYERED BY group.
 * T-TEST
  /TESTVAL=0
  /MISSING=ANALYSIS
  /VARIABLES=max_amp_lh max_amp_rh
  /CRITERIA=CI(.95).
 * SPLIT FILE OFF.

 * /* mean amplitudes ANOVA for condition without FIQ as covariate
GLM mean_amp_lh mean_amp_rh BY group
  /WSFACTOR=laterality 2 Polynomial
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality group*laterality)
  /EMMEANS=TABLES(group) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(laterality) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(group*laterality)
  /PRINT=ETASQ OPOWER
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality
  /DESIGN=group.

/* max amplitudes ANOVA for condition without FIQ as covariate
GLM max_amp_lh max_amp_rh BY group
  /WSFACTOR=laterality 2 Polynomial
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality group*laterality)
  /EMMEANS=TABLES(group) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(laterality) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(group*laterality)
  /PRINT=ETASQ OPOWER
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality
  /DESIGN=group.

/* latencies ANOVA for condition without FIQ as covariate
GLM max_lat_lh max_lat_rh BY group
  /WSFACTOR=laterality 2 Polynomial
  /METHOD=SSTYPE(3)
  /POSTHOC=group(BONFERRONI)
  /PLOT=PROFILE(group laterality group*laterality)
  /EMMEANS=TABLES(group) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(laterality) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(group*laterality)
  /PRINT=ETASQ OPOWER
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=laterality
  /DESIGN=group.