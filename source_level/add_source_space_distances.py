"""
Add source space distances to oct6 source spaces

Created on Thu May  2 13:46:43 2019
@author: Anja Thiede <anja.thiede@helsinki.fi>
"""

from datetime import datetime
import numpy as np
import mne

print(__doc__)

SUBJECTS_DIR = '/media/cbru/SMEDY/DATA/MRI_data/MRI_orig/'
MEG_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'

SUBJECTS = np.arange(1, 18), np.arange(19, 21), np.arange(22, 30), np.arange(31, 33), np.arange(34, 41), np.arange(42, 46), np.arange(47, 51)
SUBJECTS = np.concatenate((SUBJECTS[0], SUBJECTS[1], SUBJECTS[2],
                           SUBJECTS[3], SUBJECTS[4], SUBJECTS[5], SUBJECTS[6]), axis=0)

for subject in SUBJECTS:
    start_time = datetime.now()
    SUBJECT = 'SME' + '%03d' %subject
    MEG_SUBJECT = 'sme_' + '%03d' %subject

    # Load data
    src_fname = SUBJECTS_DIR + SUBJECT + '/bem/' + SUBJECT + '-oct6-src.fif'
    src = mne.read_source_spaces(src_fname)
    src = mne.add_source_space_distances(src, n_jobs=4)
    src.save(src_fname, overwrite=True)

    end_time = datetime.now()
    print('The processing for subject ' + SUBJECT + ' took: {}'.format(end_time - start_time))
