#!/bin/bash
#
# ==============================================================
# Create individual scalp surfaces from MRIs for coregistration
# ==============================================================
#
# 
# Author: Anja Thiede <anja.thiede@helsinki.fi>

###############################################################################

for subject in SME{001..050};
do 
echo $subject
mne make_scalp_surfaces -s $subject -v -f
done
exit
