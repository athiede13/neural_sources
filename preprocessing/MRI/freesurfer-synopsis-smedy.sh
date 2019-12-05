#!/bin/bash
#
# ==============================================================
# Run the freesurfer pipeline in a batch
# ==============================================================
#
# Reads in a list of files for MRI anatomical raw data and preprocesses it in the freesurfer automatic pipeline. Attention: Checkups are needed for each step of the pipeline, although the whole process is run in one go.
#
#
# Authors: Anja Thiede, 2016 <anja.thiede@helsinki.fi>
#
# batch usage: create a .txt file with infiles and read it in a loop line by line

###############################################################################

if [ $# -lt 1 ]
then
  echo "Usage: $0 <infile1> [<infile2> ...]"
# infiles are stc files
  exit 1
fi

infiles=$*

# check, if all needed files exist
for f in $infiles
do
	if [ ! -f $f ]
	then
		echo "The file $f does not exist."
	fi
done

# after all check-ups computation can start
        
for d in $infiles
do
	export SUBJECT=$d
	echo "$SUBJECT"
	cd $SUBJECTS_DIR
	mkdir "$SUBJECT"_orig
	cd "$SUBJECT"_orig
	mkdir slices
	mv $SUBJECTS_DIR/$SUBJECT/*/* $SUBJECTS_DIR/$SUBJECT"_orig"/slices/
	cd $SUBJECTS_DIR  
	rm -r $SUBJECT  
	nice recon-all -s $SUBJECT -i $SUBJECTS_DIR/"$SUBJECT"_orig/slices/00002/MR00001 -autorecon-all
	#nice recon-all -s $SUBJECT -autorecon3 -no-isrunning #only step three of freesurfer pipeline
done
