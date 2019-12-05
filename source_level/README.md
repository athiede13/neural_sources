# Source modeling

Files in this folder: 

1. mne_make_scalp_surfaces_loop.sh - Create scalp surfaces with mne make_scalp_surfaces, required for coregistration with MNE. 
1. mne_source_localization_loop.py - Compute MNE forward and inverse operators and morph to common brain template.
1. group_average_source.py - Make group averages in source space.
1. plot_source_activation_group_av_tws.py - Plot source activations on common brain template.
1. plot_subplots_group_sources.py - Plot subplots of the group averages/average of all participants in left and right hemisphere and for all deviant types.
1. add_source_space_distances.py - Add exact distances to individual source spaces, needed to create functional label/ROI. 	
1. generate_functional_label_from_stc.py - Create functional label/ROI based on most consistent activations between participants within a larger pre-selected anatomical ROI. 	
1. extract_time_course_from_label.py - Take source time course within functional ROI for each group, hemisphere, and deviant type.
1. plot_source_time_courses_ROI.py - Plot source time courses at group level at the functional ROI. 	
1. MNI_to_brain_area.R - Extract brain areas from MNI coordinates according to AAL atlas.
1. deviantxlateralityxgroup.sps - Run statistics with ANOVA in [SPSS](https://www.ibm.com/analytics/spss-statistics-software).	
