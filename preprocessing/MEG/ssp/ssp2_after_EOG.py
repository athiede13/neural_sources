"""
Removal of eye-blink and heart-beat artefacts with SSP after EOG assignment correction

Modified on 31.10.2017
Author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import os
from os import walk
import datetime
import mne
from mne.preprocessing import compute_proj_eog
from mne.preprocessing import compute_proj_ecg

now = datetime.datetime.now()

def processedcount(file_list):
    n = 0
    for item in file_list:
        if item[-7:-4] == 'ssp':
            n = n+1
    return n

root_path = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'

f = []
for (dirpath, dirnames, filenames) in walk(root_path):
    f.extend(filenames)
    break

reject = dict(grad=3000e-13, # T / m (gradiometers)
              mag=5000e-15, # T (magnetometers)
              eeg=100, # uV (EEG channels)
              #eog=3000 # uV (EOG channels)
              )

log_path = root_path+'logs/ssp2_after_EOG_'+now.strftime("%Y-%m-%d")+'_summary.log'
log = open(log_path, 'w')

exclude = []#['sme_015', 'sme_021']
for i in range(0, len(exclude)):
    dirnames.remove(exclude[i])

j = 0
for subject in dirnames:
    subject_folder = root_path+subject+'/'
    subject_files = os.listdir(subject_folder)
    ssp_file_count = processedcount(subject_files)
    if ssp_file_count == 1: # if there is already an _ssp file, then skip
        continue
    for pieces in subject_files:
        if pieces[-15:] == 'tsss_mc_EOG.fif': #first do this for EOG-fixed files
            final_path = subject_folder+pieces
            print(final_path)
            j = j+1 # check the amount of files
            raw = mne.io.read_raw_fif(final_path, preload=True)
            projection_ecg, ecg_events = compute_proj_ecg(raw, reject=reject,
                                                          l_freq=1, h_freq=100,
                                                          tstart=5, ecg_h_freq=25,
                                                          ecg_l_freq=1, average=True,
                                                          ch_name='MEG1541'
                                                          )
            projection_eog, eog_events = compute_proj_eog(raw, reject=reject,
                                                          l_freq=1, h_freq=40, average=True)
            raw_ecg_removed = raw.add_proj(projection_ecg, remove_existing=True)
            raw_all_removed = raw_ecg_removed.add_proj(projection_eog)
            save_path = subject_folder+pieces[:-8]+'_ssp.fif'
            print(save_path)
            raw_all_removed.apply_proj().save(save_path, overwrite=True)
            del projection_ecg, ecg_events, projection_eog, eog_events
            del raw_ecg_removed, raw_all_removed
            log.write(subject+' processed\n')

k = 0
for subject in dirnames:
    subject_folder = root_path+subject+'/'
    subject_files = os.listdir(subject_folder)
    ssp_file_count = processedcount(subject_files)
    if ssp_file_count == 1: #check again
        continue
    for pieces in subject_files:
        if pieces[-11:] == 'tsss_mc.fif': #then for the rest
            final_path = subject_folder+pieces
            print(final_path)
            k = k+1 # check the amount of files
            raw = mne.io.read_raw_fif(final_path, preload=True)
            projection_ecg, ecg_events = compute_proj_ecg(raw, reject=reject,
                                                          l_freq=1, h_freq=100,
                                                          tstart=5, ecg_h_freq=25,
                                                          ecg_l_freq=1, average=True,
                                                          ch_name='MEG1541'
                                                          )
            projection_eog, eog_events = compute_proj_eog(raw, reject=reject,
                                                          l_freq=1, h_freq=40,
                                                          average=True)
            raw_ecg_removed = raw.add_proj(projection_ecg, remove_existing=True)
            raw_all_removed = raw_ecg_removed.add_proj(projection_eog)
            save_path = subject_folder+pieces[:-4]+'_ssp.fif'
            print(save_path)
            raw_all_removed.apply_proj().save(save_path, overwrite=True)
            del projection_ecg, ecg_events, projection_eog, eog_events
            del raw_ecg_removed, raw_all_removed
            log.write(subject+' processed\n')

log.close()
