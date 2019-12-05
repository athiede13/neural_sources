"""
Group average on source level after morphing to ``fsaverage`` brain

Author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import os.path as op
from datetime import datetime
import numpy as np
import mne

# subjects list with exclusions
SUBJECTS_DIR = '/media/cbru/SMEDY/DATA/MRI_data/MRI_orig/'
SUBJECTS = np.arange(1, 51)
exclude = [17, 20, 29, 32, 40, 45, 46]# edu could excl , 1, 11, 28, 10, 23]
# exclusion reasons:
# SME018, SME021, SME030, SME041 no MRI, SME033 no MRI, no MEG
# SME046, SME047 low amount of epochs
# see below bc of edu
SUBJECTS = np.delete(SUBJECTS, exclude)
MEG_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'
results_path = ('/media/cbru/SMEDY_SOURCES/results/')
CON = [1, 2, 5, 6, 7, 9, 12, 19, 23, 26, 27, 29, 34, 35, 36, 37, 39,
       42, 43, 48, 49, 50]
# could 2, 12, 29 exlc due to edu
DYS = [3, 4, 8, 10, 11, 13, 14, 15, 16, 17, 20, 22, 24, 25, 28, 31,
       32, 38, 40, 44, 45]
# could 11, 24 excl due to edu, 46,47 due to low amount of epochs
method = "MNE"
groups = [CON, DYS]
group_names = {'con', 'dys'}
test = [5, 6]

# import morphed stc files and organize them
for condition in {'fre_sub', 'dur_sub', 'vow_sub'}: #{'std-ave', 'fre-ave', 'dur-ave', 'vow-ave'}: #
    start_time = datetime.now()
    MEG_FILE = 'tata_a_' + condition + '-ave.fif'
    stcs = []

    for group, group_name in zip(groups, group_names):
        subjects = group
        for subject in subjects:
#        for subject in test:
            MEG_SUBJECT = 'sme_' + '%03d' %subject
            STCFILE_FSAV = MEG_DIR + '/' + MEG_SUBJECT + '/' + MEG_FILE[:-8] + '_' + method + '_fsav'
            stc = mne.read_source_estimate(STCFILE_FSAV)
            stcs.append(stc)
        # organize stcs
        #stcs = [stc for stc, SUBJECTS in zip(stcs, SUBJECTS)]
        data = np.average([s.data for s in stcs], axis=0)
        stc = mne.SourceEstimate(data, stcs[0].vertices,
                                 stcs[0].tmin, stcs[0].tstep, stcs[0].subject)
        stc.save(op.join(MEG_DIR, 'group_averages/average_' + group_name +
                         '-%s' % condition))
        print(op.join(MEG_DIR, 'group_averages/average_' + group_name +
                      '-%s' % condition) + ' saved')

    for subject in SUBJECTS:
        MEG_SUBJECT = 'sme_' + '%03d' %subject
        STCFILE_FSAV = MEG_DIR + '/' + MEG_SUBJECT + '/' + MEG_FILE[:-8] + '_' + method + '_fsav'
        stc = mne.read_source_estimate(STCFILE_FSAV)
        stcs.append(stc)
    # organize stcs
    #stcs = [stc for stc, SUBJECTS in zip(stcs, SUBJECTS)]
    data = np.average([s.data for s in stcs], axis=0)
    stc = mne.SourceEstimate(data, stcs[0].vertices,
                             stcs[0].tmin, stcs[0].tstep, stcs[0].subject)
    stc.save(op.join(MEG_DIR, 'group_averages/average_all' + '-%s' % condition))
    print(op.join(MEG_DIR, 'group_averages/average_all' + '-%s' % condition) + ' saved')
