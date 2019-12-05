# -*- coding: utf-8 -*-
"""
EOG channel assignment/fix

Created on Mon Jan  8 15:55:09 2018
@author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import os
from os import walk
import datetime
import mne

now = datetime.datetime.now()

test = ['sme_023'] # subjects with uncorrectly assigned EOG channels

root_path = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'
log_path = root_path+'logs/EOG_fix_'+now.strftime("%Y-%m-%d")+'.log'
log = open(log_path, 'w')

f = []
for (dirpath, dirnames, filenames) in walk(root_path):
    f.extend(filenames)
    break

for subject in test:
#for subject in dirnames:
    #subject_folder = '/localdir/SMEDY/MEG_prepro/'+subject+'/'
    subject_folder = root_path+subject+'/'
    subject_files = os.listdir(subject_folder)
    for pieces in subject_files:
        if pieces[-15:] == 'tsss_mc_ref.fif':
            final_path = subject_folder+pieces
            print(final_path)
            raw = mne.io.read_raw_fif(final_path, preload=False) # read preprocessed data
            #print(raw.info)
            print(raw.info['ch_names'][0:2]) # are both EOG channels here?
            if raw.info['ch_names'][0:2] == [u'EOG001', u'EOG002']:
                print('everything cool with subject ', subject)
                log.write(subject+' EOG ok\n')
            else:
                print('better check EOGs of subject ', subject)
                log.write(subject+' check EOG\n')
                log.write(str(raw.info['ch_names'][0:2])+'\n')
                # the following two lines are only relevant,
                # if the EOG channels were not mapped correctly
                raw.set_channel_types({'BIO003' : 'eog'})
                mne.rename_channels(raw.info, {u'BIO003' : u'EOG002'})
                #print(raw.info)
                print(raw.info['ch_names'][0:2]) # are both EOG channels here?
                root, ext = os.path.splitext(final_path)
                raw.save(root+'_EOG'+ext)
                print('[done]')
                log.write('[done]')

log.close()
