# Preprocessing of MEG and MRI data

Files in the MEG/ folder: 

1. concatenate_raws.py - Merge two parts of continuous MEG data that belong to the same recording.
1. mark_bad.py - Assign bad channels to raw data after visual inspection.
1. maxfilter_tsss_mc_hp_ref.sh - Maxfilter (signal space separation, SSS) with temporal extension + movement correction with cHPI
1. ssp/EOG_fix.py - fix assignment of EOG channels
1. ssp/ssp2_after_EOG.py - Removal of eye blinks and heart beat artifacts with signal space separation (SSP) after EOG fix
1. ssp/ssp2.py - Removal of eye blinks and heart beat artifacts with signal space separation (SSP)
1. filtering.py - Filter MEG data for event-related analysis.
1. epoching_noise_cov_source.py - Epoch data for all stimulus types of interest, save averages and deviant-minus-standard subtractions, and compute noise covariance from pre-stimulus baseline.

Files in the MRI/ folder: 

1. freesurfer-synopsis-smedy.sh - Run complete [Freesurfer](https://surfer.nmr.mgh.harvard.edu/) pipeline.
1. freesurfer_pipeline_triton.sh - Wrapper to run Freesurfer pipeline on computing cluster.
1. run_fixes.sh - Rerun part of the Freesurfer pipeline after manual edits.
