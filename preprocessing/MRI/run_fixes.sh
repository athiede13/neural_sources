#!/bin/bash
#
# ==============================================================
# Run fixes in freesurfer after manual edits
# ==============================================================
#
# 
# Author: Anja Thiede, 2.8.2017 <anja.thiede@helsinki.fi>
#
# note: two different scenarios after manual edits with example subjects IDs

###############################################################################

export SUBJECTS_DIR=/media/thiede/SMEDY/SMEDY_DATA/MRI_data/MRI_orig
export SUBJECT=SME010
#Manual edit of white matter surface by adding control points. After that, run (takes a while, 2-3- hours):
recon-all -autorecon2-cp -autorecon3 -subjid $SUBJECT

#Manual edit of the pial surface, if none of the above help. After that, run (takes a while, 2-3 hours):
export SUBJECT=SME012
recon-all -autorecon-pial -subjid $SUBJECT -no-isrunning

