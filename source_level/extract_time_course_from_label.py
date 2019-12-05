"""
Extract time courses, max amplitudes and max coordinates from small self-created
functional label

Created on Wed Jul  3 15:47:03 2019
Author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import csv
import numpy as np
import matplotlib.pyplot as plt
import mne

#%matplotlib qt
#%matplotlib inline

# to fill
show_figs = 0 # 0 = no, 1 = yes
test = [1]
time = 1 # 1=MMF, 2=late MMF / time window

# paths etc
SUBJECTS_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MRI_data/MRI_orig/'
MEG_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'
label_path = '/media/cbru/SMEDY_SOURCES/results/labels/'
results_path = '/media/cbru/SMEDY_SOURCES/results/source_amps_lat/'
stc_results_path = '/media/cbru/SMEDY_SOURCES/results/'
src_fname = SUBJECTS_DIR + '/fsaverage/bem/fsaverage-ico-5-src.fif'
src = mne.read_source_spaces(src_fname)
SUBJECTS = np.arange(1, 51)
exclude = [17, 20, 29, 32, 40, 45, 46]
# exclusion reasons:
# SME018, SME021, SME030, SME041 no MRI, SME033 no MRI, no MEG
# SME046, SME047 low amount of epochs
SUBJECTS = np.delete(SUBJECTS, exclude)
DYS = [3, 4, 8, 10, 11, 13, 14, 15, 16, 17, 20, 22, 24, 25, 28, 31, 32,
       38, 40, 44, 45]
CON = [1, 2, 5, 6, 7, 9, 12, 19, 23, 26, 27, 29, 34, 35, 36, 37, 39, 42,
       43, 48, 49, 50]
cons = ['fre_sub', 'dur_sub', 'vow_sub']###['fre-ave','dur-ave','vow-ave']#['std-ave']#
typ = 'sub' # 'sub' or 'erf' or 'std'
test = [2]

# time windows
tw1 = [300, 400] #minimum across conditions and subject group
tw2 = [450, 650]

max_amp_all = []
max_lat_all = []
max_source_all = []
mni_all = []
all_results = []

for subject in SUBJECTS:
#for subject in test:
    SUBJECT = 'SME' + '%03d' %subject
    MEG_SUBJECT = 'sme_' + '%03d' %subject
    if subject in CON:
        group = "con"
    elif subject in DYS:
        group = "dys"
    else:
        group = "error"
    i = 1
    if show_figs == 1:
        fig = plt.figure(figsize=(13, 20))
        fig.subplots_adjust(hspace=0.4, wspace=0.4)
        fig.suptitle(SUBJECT + ' ROI source activity TW ' + str(time))
    for condition in cons:
        for hemi in ['lh', 'rh']: # lh 1, rh 0
            print(condition, hemi, i)
            STCFILE_AV = MEG_DIR + MEG_SUBJECT + '/tata_a_' + condition + '_MNE_fsav-' + hemi + '.stc'
            stc = mne.read_source_estimate(STCFILE_AV, subject='fsaverage')
            label = mne.read_label(label_path + 'func_label_45%_tw1' + '-' + hemi + '.label')
            stc_label = stc.in_label(label)
            mode = ('pca_flip')#, 'max')
            tcs = stc.extract_label_time_course(label, src, mode=mode)
            np.save(stc_results_path + MEG_SUBJECT + '/tc_in_label_' +
                    condition + '_TW' + str(time) + '-' + hemi, tcs)
            print("Number of vertices : %d" % len(stc_label.data))

            # View source activations
            if show_figs == 1:
                ax = fig.add_subplot(3, 2, i)
                t = 1e3 * stc_label.times
                ax.plot(t, stc_label.data.T, 'k', linewidth=0.5)
                ax.plot(t, tcs[0], linewidth=3)
                ax.set_ylim(-2e-11, 12e-11)
                ax.legend(loc='upper right')
                ax.set(xlabel='Time (ms)', ylabel='Source amplitude',
                       title='%s %s' % (condition, hemi))
                if time == 1:
                    ax.axvspan(tw1[0], tw1[1], facecolor='green', alpha=0.8)
                elif time == 2:
                    ax.axvspan(tw2[0], tw2[1], facecolor='green', alpha=0.8)
                else:
                    print('Sth went wrong')
            i = i+1
            # extract max amplitudes and latencies plus mean amplitude
            if time == 1:
                tmin = stc.time_as_index(tw1[0]/1000)[0]
                tmax = stc.time_as_index(tw1[1]/1000)[0]
                max_amp = np.max(tcs[0, tmin:tmax])
                max_lat = np.where(tcs[0] == max_amp)[0] #in time points
                max_lat_ms = max_lat[0]*2-100
                mean_amp = np.mean(tcs[0, tmin:tmax])
            elif time == 2:
                tmin = stc.time_as_index(tw2[0]/1000)[0]
                tmax = stc.time_as_index(tw2[1]/1000)[0]
                abs_amp = np.max(np.abs(tcs[0, tmin:tmax]))
                if np.where(tcs[0] == -abs_amp)[0].any(): # most are negative values
                    max_lat = np.where(tcs[0] == -abs_amp)[0]
                    max_amp = -abs_amp
                else:
                    max_lat = np.where(tcs[0] == abs_amp)[0] #in time points
                    max_amp = abs_amp
                max_lat_ms = max_lat[0]*2-100
                mean_amp = np.mean(tcs[0, tmin:tmax])
            # collect results
            if hemi == 'lh':
                max_amp_lh = max_amp
                max_lat_lh = max_lat_ms
                mean_amp_lh = mean_amp
            else:
                max_amp_rh = max_amp
                max_lat_rh = max_lat_ms
                mean_amp_rh = mean_amp

        all_results.append([MEG_SUBJECT, group, condition, max_amp_lh*1e9,
                            max_amp_rh*1e9, max_lat_lh, max_lat_rh,
                            mean_amp_lh*1e9, mean_amp_rh*1e9]) # *1e9 -> nAm

print('write results to csv')
with open(results_path + typ + '_hemi_amp_lat_tw' + str(time) + '.csv', "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(all_results)
