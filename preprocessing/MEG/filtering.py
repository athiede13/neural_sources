"""
Filtering of MEG data

Created on 13.9.2017
@author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import os
from os import walk
import datetime
import numpy as np
import mne

now = datetime.datetime.now()

def processedcount(file_list):
    n = 0
    for item in file_list:
        if item[-8:-4] == 'filt':
            n = n+1
    return n

# set up data paths
root_path = ('/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/')

f = []
for (dirpath, dirnames, filenames) in walk(root_path):
    f.extend(filenames)
    break

log_path = root_path+'logs/logs_filt_'+now.strftime("%Y-%m-%d")
log = open(log_path, 'w')

#sub = ['sme_028'] # for testing or filtering single files
i = 0

for subject in dirnames: #sub: #
    subject_folder = root_path+subject+'/'
    subject_files = os.listdir(subject_folder)
#    filt_file_count = processedcount(subject_files)
#    if filt_file_count == 2:
#        continue
    for pieces in subject_files:
        if pieces[-11:] == 'ref_ssp.fif':
            final_path = subject_folder+pieces
            print(final_path)
            i = i+1
            raw = mne.io.read_raw_fif(final_path, preload=True) # read preprocessed data
            # raw.set_eeg_reference()
            order = np.arange(raw.info['nchan'])
            # filter the data
            raw.load_data()
            hp = 0.5
            lp = 25.0
            raw.filter(hp, None, n_jobs=8, method='fir')
            # high-pass filter, default hamming window is used
            raw.filter(None, lp, n_jobs=8, method='fir') # low-pass filter
            fsave = subject_folder+pieces[:-4]+'_filt.fif'
            print(fsave)
            raw.save(fsave, overwrite=True) # save filtered file to disk
            log.write(subject+' processed\n')

log.close()
