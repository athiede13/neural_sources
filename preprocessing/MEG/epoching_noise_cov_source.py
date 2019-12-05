"""
MEG evoked data epoching plus computation of noise covariance

Created on 13.9.2017
Author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import os.path as op
import os
from os import walk
import datetime
import numpy as np
import mne

#%matplotlib qt
#%matplotlib inline

now = datetime.datetime.now()

def processedcount(file_list):
    n = 0
    for item in file_list:
        if item[-22:] == 'tata_a_vow_sub-ave.fif':
            n = n+1
    return n

# set up data paths
root_path = ('/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/')
results_path = ('/media/cbru/SMEDY_SOURCES/results/')
analyysi = ('source') # or ('sensor')

f = []
for (dirpath, dirnames, filenames) in walk(root_path):
    f.extend(filenames)
    break

log_path = root_path+'logs/logs_ep_'+now.strftime("%Y-%m-%d")
log = open(log_path, 'w')

test = ['sme_010']

for subject in dirnames:#sub: # #
#for subject in test:
    subject_folder = root_path+subject+'/'
    if not os.path.exists(subject_folder+analyysi): #create dir "source" for each subject
        os.makedirs(subject_folder+analyysi)
    subject_files = os.listdir(subject_folder)
    filt_file_count = processedcount(subject_files)
    if filt_file_count == 0: # 1 means if file from above already exists,
        # then don't run again, 0 means overwrite
        continue
    for pieces in subject_files:
        if pieces[-15:] == 'mc_ssp_filt.fif': # for analyysi=('source')
            final_path = subject_folder+pieces
            print(final_path)
            raw = mne.io.read_raw_fif(final_path, preload=True) # read preprocessed data
            log.write('Processing '+subject+'\n')
            log.write('Reading in raw data\n')
            order = np.arange(raw.info['nchan'])

            # extract epochs
            # raw.plot(n_channels=10, order=order, block=True)
            events = mne.find_events(raw, stim_channel='STI101', uint_cast=True,
                                     shortest_event=1, mask_type='not_and', mask=100000000)
            print('Found %s events, first five:' % len(events))
            print(events[:5])

            # Plot the events to get an idea of the paradigm
            # Specify colors and an event_id dictionary for the legend.
            event_id = {'standard': 11, 'duration': 12,
                        'frequency': 13, 'vowel': 14,
                        'standard after deviant': 15}
            color = {11: 'green', 12: 'red', 13: 'green', 14: 'blue', 15: 'grey'}
            #mne.viz.plot_events(events, raw.info['sfreq'], raw.first_samp, color=color,
            #                    event_id=event_id)
            # raw.plot(events=events, n_channels=10, order=order)
            tmin, tmax = -0.1, 0.85
            # Only pick MEG and EOG channels.
            picks = mne.pick_types(raw.info, meg=True, eeg=False, eog=True)

            # Epoch data
            baseline = (-0.1, 0.0)
            reject = dict(grad=4000e-13, # T / m (gradiometers)
                          mag=4e-12 # T (magnetometers)
                          #eog=250e-6 # V (EOG channels)
                          )
            epochs = mne.Epochs(raw, events=events, event_id=event_id, tmin=tmin,
                                tmax=tmax, baseline=baseline, reject=reject,
                                proj=True, picks=picks)
            log.write('Epoched data with baseline '+str(baseline)+
                      ' and rejection criteria: '+str(reject)+'\n')
            epochs.drop_bad()
            epochs.load_data()
            log.write('Accepted epochs: '+str(epochs)+'\n')
            print('Original sampling rate:', epochs.info['sfreq'], 'Hz')
            print('No downsampling')
            rejected_epochs = epochs.plot_drop_log(show=False)
            if not os.path.exists(results_path+subject+'/' + analyysi):
                os.makedirs(results_path+subject+'/' + analyysi)
            rejected_epochs.savefig(results_path+subject+'/' + analyysi
                                    + '/rejected_epochs.pdf', bbox_inches='tight')

            # Compute regularized noise covariance
            #
            # For more details see :ref:`tut_compute_covariance`.

            # for all trials, no matter whether it is std or dev
            noise_cov = mne.compute_covariance(
                epochs, tmax=0., method='shrunk', rank='info', n_jobs=8)

            fig_cov, fig_spectra = mne.viz.plot_cov(noise_cov, raw.info)

            evoked = epochs.average()
            evoked.plot_white(noise_cov, time_unit='s')

            fsave = subject_folder + analyysi + '/tata_a-cov.fif'
            print(fsave)
            noise_cov.save(fsave)
            del noise_cov

            log.write(subject+' noise covariance computed\n')

            # extract different types of events
            picks = mne.pick_types(epochs.info, meg=True, eog=False,
                                   eeg=False, selection=None)
            standard = epochs['standard'].average(picks=picks)
            duration = epochs['duration'].average(picks=picks)
            frequency = epochs['frequency'].average(picks=picks)
            vowel = epochs['vowel'].average(picks=picks)
            # all
            #evokeds = [epochs_resampled[name].average(picks=picks) for
            # name in ('standard', 'duration','frequency','vowel')]
#==============================================================================
#             # plot evoked responses
#             standard.plot()
#             duration.plot()
#             frequency.plot()
#             vowel.plot()
#==============================================================================
            # save evoked responses
            fsave = op.join(subject_folder, analyysi, 'tata_a_std-ave.fif')
            standard.save(fsave)  # save evoked data to disk
            fsave = op.join(subject_folder, analyysi, 'tata_a_dur-ave.fif')
            duration.save(fsave)  # save evoked data to disk
            fsave = op.join(subject_folder, analyysi, 'tata_a_fre-ave.fif')
            frequency.save(fsave)  # save evoked data to disk
            fsave = op.join(subject_folder, analyysi, 'tata_a_vow-ave.fif')
            vowel.save(fsave)  # save evoked data to disk
            log.write('evoked responses saved\n')

            # create subtraction curves
            dur_sub = mne.combine_evoked([-standard, duration], weights='equal')
            f = dur_sub.plot_joint(title=subject + ' duration MMF')
            f[0].savefig(results_path+subject+ '/' + analyysi + '/dur_MMF_grads.pdf',
                         bbox_inches='tight')
            f[1].savefig(results_path+subject+'/' + analyysi + '/dur_MMF_mags.pdf',
                         bbox_inches='tight')
            fre_sub = mne.combine_evoked([-standard, frequency], weights='equal')
            f = fre_sub.plot_joint(title=subject + ' frequency MMF')
            f[0].savefig(results_path+subject+'/' + analyysi + '/fre_MMF_grads.pdf',
                         bbox_inches='tight')
            f[1].savefig(results_path+subject+'/' + analyysi + '/fre_MMF_mags.pdf',
                         bbox_inches='tight')
            vow_sub = mne.combine_evoked([-standard, vowel], weights='equal')
            f = vow_sub.plot_joint(title=subject + ' vowel MMF')
            f[0].savefig(results_path+subject+'/' + analyysi + '/vow_MMF_grads.pdf',
                         bbox_inches='tight')
            f[1].savefig(results_path+subject+'/' + analyysi + '/vow_MMF_mags.pdf',
                         bbox_inches='tight')

            # save subtraction curves
            fsave = op.join(subject_folder, analyysi, 'tata_a_dur_sub-ave.fif')
            dur_sub.save(fsave)  # save evoked data to disk
            fsave = op.join(subject_folder, analyysi, 'tata_a_fre_sub-ave.fif')
            fre_sub.save(fsave)  # save evoked data to disk
            fsave = op.join(subject_folder, analyysi, 'tata_a_vow_sub-ave.fif')
            vow_sub.save(fsave)  # save evoked data to disk
            log.write('mismatch fields saved\n')

            log.write(subject+' processed\n')

log.close()
