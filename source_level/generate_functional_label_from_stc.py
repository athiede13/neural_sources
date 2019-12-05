"""
Generate a functional label from source estimates

Authors: Luke Bloy <luke.bloy@gmail.com>
         Alex Gramfort <alexandre.gramfort@telecom-paristech.fr>
Edited by Anja Thiede <anja.thiede@helsinki.fi>
"""
# License: BSD (3-clause)

from datetime import datetime
import numpy as np
import matplotlib.pyplot as plt
import mne

#%matplotlib qt
#%matplotlib inline

print(__doc__)

SUBJECTS_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MRI_data/MRI_orig/'
MEG_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'
SUBJECTS = np.arange(1, 51)
exclude = [17, 20, 29, 32, 40, 45, 46]
# exclusion reasons:
# SME018, SME021, SME030, SME041 no MRI, SME033 no MRI, no MEG
# SME046, SME047 low amount of epochs
SUBJECTS = np.delete(SUBJECTS, exclude)
tw_path = '/media/cbru/SMEDY_SOURCES/analyysi/time_windows/'
results_path = '/media/cbru/SMEDY_SOURCES/results/labels/'

# to fill
#test = [SUBJECTS[19]]
plot_time_courses = 0 # 0 = no, 1 = yes
plot_brains = 0 # 0 = no, 1 = yes
time = 1 # time window, 1 = first TW, 2 = second TW
#test = [3, 4]

# time windows
if time == 1:
    tw = [300, 400]
elif time == 2:
    tw = [500, 700]
tmin = float(tw[0]/1000)
tmax = float(tw[1]/1000)

all_labels = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s',
                                        subjects_dir=SUBJECTS_DIR)[64:66]
labels_temp_G = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s',
                                           subjects_dir=SUBJECTS_DIR)[64:76]
labels_temp_S = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s',
                                           subjects_dir=SUBJECTS_DIR)[142:148]
ins_S = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s')[94:96]

# load source space
src_fname = SUBJECTS_DIR + '/fsaverage/bem/fsaverage-ico-5-src.fif'
src = mne.read_source_spaces(src_fname)

for subject in SUBJECTS:
#for subject in test:
    start_time = datetime.now()
    SUBJECT = 'SME' + '%03d' %subject
    MEG_SUBJECT = 'sme_' + '%03d' %subject
    print(SUBJECT)

    for hemi in {'lh', 'rh'}:
        # labels
        if hemi == 'lh':
            label_combined = [labels_temp_G[2] +
                              labels_temp_S[2]]
        else:
            label_combined = [labels_temp_G[3] +
                              labels_temp_S[3]]

        for condition in {'dur', 'fre', 'vow'}:
            # read stc file
            STCFILE_AV = MEG_DIR + MEG_SUBJECT + '/tata_a_' + condition + '_sub_MNE_fsav-lh.stc'
            stc = mne.read_source_estimate(STCFILE_AV, subject='fsaverage')

            _, peak_time = stc.get_peak(hemi=hemi, vert_as_index=False,
                                        time_as_index=False, tmin=tmin, tmax=tmax,
                                        mode='pos')

            # Make a STC around the individual peak time
            stc_max = stc.copy().crop(peak_time-0.001, peak_time+0.001).mean()

            # use the stc_max to generate a functional label
            # region growing is halted at 60% of the peak value within the
            # anatomical label / ROI specified by aparc_label_name
            stc_max_label = stc_max.in_label(label_combined[0])
            data = np.abs(stc_max_label.data)
            stc_max_label.data[data < 0.6 * np.max(data)] = 0.

            func_labels = mne.stc_to_label(stc_max_label, src=src, smooth=True,
                                           subjects_dir=SUBJECTS_DIR, connected=True)

            # search biggest label
            label_lengths = []
            if label_combined[0].hemi == 'rh':
                for i in range(0, len(func_labels[1])):
                    label_lengths.append(len(func_labels[1][i].vertices))
                max_id = np.where(label_lengths == np.max(label_lengths))
                func_label = func_labels[1][max_id[0][0]]
            else:
                for i in range(0, len(func_labels[0])):
                    label_lengths.append(len(func_labels[0][i].vertices))
                max_id = np.where(label_lengths == np.max(label_lengths))
                func_label = func_labels[0][max_id[0][0]]

            func_label.subject = 'fsaverage'
            func_label.name = 'func ROI ' + condition
            # load the anatomical ROI for comparison
            anat_label = label_combined[0]

            # extract the anatomical time course for each label
            stc_anat_label = stc.in_label(anat_label)
            pca_anat = stc.extract_label_time_course(anat_label, src, mode='pca_flip')[0]

            stc_func_label = stc.in_label(func_label)
            pca_func = stc.extract_label_time_course(func_label, src, mode='pca_flip')[0]

            # flip the pca so that the max power between tmin and tmax is positive
            pca_anat *= np.sign(pca_anat[np.argmax(np.abs(pca_anat))])
            pca_func *= np.sign(pca_func[np.argmax(np.abs(pca_anat))])

            ###############################################################################
            # plot the time courses....
            if plot_time_courses == 1:
                plt.figure()
                plt.plot(1e3 * stc_anat_label.times, pca_anat, 'k',
                         label='Anatomical STG+STS')
                plt.plot(1e3 * stc_func_label.times, pca_func, 'b',
                         label='Functional STG+STS')
                plt.legend()
                plt.title(SUBJECT + ' ' + condition + ' ' + hemi)
                plt.show()

            ###############################################################################
            # plot brain in 3D with PySurfer if available
            if plot_brains == 1:
                brain = stc_max.plot(subject='fsaverage', hemi=hemi,
                                     subjects_dir=SUBJECTS_DIR,
                                     figure=None, title=SUBJECT + ' ' + condition + ' ' + hemi)
                brain.show_view('lateral')

                # show both labels
                #brain.add_label(anat_label, borders=True, color='black')
                brain.add_label(func_label, borders=True, color='red')

            # collect labels
            all_labels.append(func_label)

#for i in range(2, len(all_labels)):
#    all_labels[i].morph(subject_from = all_labels[i].subject, subject_to = 'fsaverage')

np.save(results_path + 'func_ROI_43_subjects_TW' + str(time), all_labels[2:])

#%% combine labels
labels_combined_lh = all_labels[2] + all_labels[3]
labels_combined_rh = all_labels[5] + all_labels[6]
for i in range(2, len(all_labels)):
    if all_labels[i].hemi == 'lh':
        labels_combined_lh = labels_combined_lh + all_labels[i]
        labels_combined_lh.name = 'func ROI combined'
    else:
        labels_combined_rh = labels_combined_rh + all_labels[i]
        labels_combined_rh.name = 'func ROI combined'

# show label on brain
hemi = 'lh'
brain = stc_max.plot(subject='fsaverage', hemi=hemi, subjects_dir=SUBJECTS_DIR,
                     figure=None, title='functional label combined ' + hemi)
brain.show_view('lateral')
brain.add_label(labels_combined_lh, borders=True, color='red')
hemi = 'rh'
brain = stc_max.plot(subject='fsaverage', hemi=hemi, subjects_dir=SUBJECTS_DIR,
                     figure=None, title='functional label combined ' + hemi)
brain.show_view('lateral')
brain.add_label(labels_combined_rh, borders=True, color='red')

# save labels
labels_combined_lh.save(results_path + 'func_label_combined-lh')
labels_combined_rh.save(results_path + 'func_label_combined-rh')

#%% combine labels, if vertices of labels existed in at least "bigger_than" of
# the files
if time == 1:
    bigger_than = 27
elif time == 2:
    bigger_than = 26
all_vertices_lh = []
all_vertices_rh = []
for i in range(2, len(all_labels)):
    if all_labels[i].hemi == 'lh':
        all_vertices_lh.append(all_labels[i].vertices)
    else:
        all_vertices_rh.append(all_labels[i].vertices)

all_vertices_arr_lh = np.concatenate(all_vertices_lh)
unique_lh, counts_lh = np.unique(all_vertices_arr_lh, return_counts=True)
small_label_lh = mne.Label(vertices=unique_lh[np.where(counts_lh > bigger_than)],
                           hemi='lh', subject='fsaverage')
small_label_lh.smooth(subject='fsaverage', subjects_dir=SUBJECTS_DIR)

all_vertices_arr_rh = np.concatenate(all_vertices_rh)
unique_rh, counts_rh = np.unique(all_vertices_arr_rh, return_counts=True)
small_label_rh = mne.Label(vertices=unique_rh[np.where(counts_rh > bigger_than)],
                           hemi='rh', subject='fsaverage')
small_label_rh.smooth(subject='fsaverage', subjects_dir=SUBJECTS_DIR)

# show label on brain
hemi = 'lh'
brain = stc_max.plot(subject='fsaverage', hemi=hemi, subjects_dir=SUBJECTS_DIR,
                     figure=None, title='functional label in 45% '+hemi)
brain.show_view('lateral')
brain.add_label(small_label_lh, borders=True, color='red')
hemi = 'rh'
brain = stc_max.plot(subject='fsaverage', hemi=hemi, subjects_dir=SUBJECTS_DIR,
                     figure=None, title='functional label in 45% '+hemi)
brain.show_view('lateral')
brain.add_label(small_label_rh, borders=True, color='red')

# save labels
if time == 1:
    small_label_lh.save(results_path + 'func_label_45%_tw1-lh')
    small_label_rh.save(results_path + 'func_label_45%_tw1-rh')
#elif time == 2:
#    small_label_lh.save(results_path + 'func_label_45%_tw2-lh')
#    small_label_rh.save(results_path + 'func_label_45%_tw2-rh')
