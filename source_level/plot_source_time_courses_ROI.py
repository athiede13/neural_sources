"""
Plot source time courses at group level at the functional ROI

Author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import numpy as np
import matplotlib.pyplot as plt
import mne

#%matplotlib qt
#%matplotlib inline

# to fill
time = 1 # 1=both!, 2=late MMN / time window
#test = [29, 1, 2]
# time windows based on peak latencies of groups
tw1 = [300, 400] 
tw2 = [450, 650] 

# paths etc
SUBJECTS_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MRI_data/MRI_orig/'
MEG_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'
label_path = '/media/cbru/SMEDY_SOURCES/results/labels/'
results_path = '/media/cbru/SMEDY_SOURCES/results/source_amps_lat/'
stc_results_path = '/media/cbru/SMEDY_SOURCES/results/'
CON = [1, 2, 5, 6, 7, 9, 12, 19, 23, 26, 27, 29, 34, 35, 36, 37, 39, 42,
       43, 48, 49, 50]
DYS = [3, 4, 8, 10, 11, 13, 14, 15, 16, 17, 20, 22, 24, 25, 28, 31, 32,
       38, 40, 44, 45]
tcs_con = {}
tcs_all_con = []
tcs_dys = {}
tcs_all_dys = []
STCFILE_AV = MEG_DIR + 'sme_001/tata_a_fre_sub_MNE_fsav-lh.stc'
stc = mne.read_source_estimate(STCFILE_AV, subject='fsaverage')
cons = ['fre_sub', 'dur_sub', 'vow_sub']#['fre-ave', 'dur-ave', 'vow-ave']#['std-ave']#
typ = 'sub'

#for subject in SUBJECTS:
for subject in CON:
    SUBJECT = 'SME' + '%03d' %subject
    MEG_SUBJECT = 'sme_' + '%03d' %subject
    for condition in cons:
        for hemi in ['lh', 'rh']: # lh 1, rh 0
            tcs_con = np.load(stc_results_path + MEG_SUBJECT +
                              '/tc_in_label_' + condition + '_TW' +
                              str(time) + '-' + hemi + '.npy')
            tcs_all_con.append((subject, condition, hemi, tcs_con))

for subject in DYS:
    SUBJECT = 'SME' + '%03d' %subject
    MEG_SUBJECT = 'sme_' + '%03d' %subject
    for condition in cons:#['std']:#['fre', 'dur', 'vow']:
        for hemi in ['lh', 'rh']:
            tcs_dys = np.load(stc_results_path + MEG_SUBJECT +
                              '/tc_in_label_' + condition + '_TW' +
                              str(time) + '-' + hemi + '.npy')
            tcs_all_dys.append((subject, condition, hemi, tcs_dys))

conhemi = []
dyshemi = []
average_con = {}
average_dys = {}
for con in cons:#['std']:#['fre', 'dur', 'vow']:
    for hemi in ['lh', 'rh']:
        for i in tcs_all_con:
            if i[1] == con and i[2] == hemi:
                conhemi.append(i[3])
            average_con[con, hemi] = np.mean(conhemi, axis=0)
        for j in tcs_all_dys:
            if j[1] == con and j[2] == hemi:
                dyshemi.append(j[3])
            average_dys[con, hemi] = np.mean(dyshemi, axis=0)

fig, axs = plt.subplots(1, 6, sharex=True, sharey=True, figsize=(23, 3))
fig.add_subplot(111, frameon=False)
# hide tick and tick label of the big axes
plt.tick_params(labelcolor='none', top='off', bottom='off', left='off', right='off')
plt.grid(False)
plt.xlabel('Time [ms]', fontsize=18)
plt.ylabel('Source amplitude [pAm]', fontsize=18)

l1 = axs[0].plot(1e3 * stc.times, 1e12 * average_con[cons[0], 'rh'][0],
                 1e3 * stc.times, 1e12 * average_dys[cons[0], 'lh'][0], linewidth=3)
l2 = axs[1].plot(1e3 * stc.times, 1e12 * average_con[cons[0], 'rh'][0],
                 1e3 * stc.times, 1e12 * average_dys[cons[0], 'rh'][0], linewidth=3)
l3 = axs[2].plot(1e3 * stc.times, 1e12 * average_con[cons[1], 'lh'][0],
                 1e3 * stc.times, 1e12 * average_dys[cons[1], 'lh'][0], linewidth=3)
l4 = axs[3].plot(1e3 * stc.times, 1e12 * average_con[cons[1], 'rh'][0],
                 1e3 * stc.times, 1e12 * average_dys[cons[1], 'rh'][0], linewidth=3)
l5 = axs[4].plot(1e3 * stc.times, 1e12 * average_con[cons[2], 'lh'][0],
                 1e3 * stc.times, 1e12 * average_dys[cons[2], 'lh'][0], linewidth=3)
l6 = axs[5].plot(1e3 * stc.times, 1e12 * average_con[cons[2], 'rh'][0],
                 1e3 * stc.times, 1e12 * average_dys[cons[2], 'rh'][0], linewidth=3)

# add vertical lines at change onset
for i in [0,1,4,5]:
    axs[i].axvline(180, alpha=0.2, linestyle='dashed')
    
for i in [2,3]:
    axs[i].axvline(225, alpha=0.2, linestyle='dashed')

for ax in axs.flat:
    if time == 1:
        ax.axvspan(tw1[0], tw1[1], facecolor='grey', alpha=0.2)
        ax.axvspan(tw2[0], tw2[1], facecolor='grey', alpha=0.2)
    elif time == 2:
        ax.axvspan(tw2[0], tw2[1], facecolor='green', alpha=0.2)
fig.legend(l1, ('con', 'dys'), 'upper right')

fig.show()

if time == 1:
    fig.savefig(results_path+'/summary_source_'+typ+'.svg', bbox_inches='tight')
elif time == 2:
    fig.savefig(results_path+'/summary_source_late_'+typ+'.pdf', bbox_inches='tight')
