#!/bin/bash
#SBATCH -n 1
#SBATCH -t 30:00:00
#SBATCH --mem-per-cpu=3000
#SBATCH --array=0-1

module load mne
source $MNE_ROOT/bin/mne_setup_sh
module load freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=/m/nbe/scratch/braindata/thiedea/smedy/MRI_orig/
 
cd /m/nbe/scratch/braindata/thiedea/smedy/scripts/

readarray lines < "/m/nbe/scratch/braindata/thiedea/smedy/MRI_orig/files.txt"
srun ./freesurfer-synopsis-smedy.sh "${lines[$SLURM_ARRAY_TASK_ID]}"
