"""
Plot source activations at group level on the brain and save

Created on Mon May 28 11:33:24 2018
Author: Anja Thiede <anja.thiede@helsinki.fi>
"""

from datetime import datetime
import csv
import numpy as np
import mne

#%matplotlib qt
#%matplotlib inline

# to fill
method = "MNE"
time = 1 # 1 or 2
show_plots = 1 # 0 no, 1 yes
show_label = 0

# path etc
SUBJECTS_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MRI_data/MRI_orig/'
MEG_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'
results_path = ('/media/cbru/SMEDY_SOURCES/results/')
label_path = '/media/cbru/SMEDY_SOURCES/results/labels/'
if method == "dSPM":
    kind = 'value'
    lims = [8, 12, 15]
else:
    kind = 'value'
    lims = [10e-12, 20e-12, 30e-12]

# time windows
if time == 1:
    tw = [300, 400]
elif time == 2:
    tw = [450, 650]

# labels
if show_label == 1:
    all_labels = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s',
                                            subjects_dir=SUBJECTS_DIR)[64:66]
    labels_temp_G = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s',
                                               subjects_dir=SUBJECTS_DIR)[64:76]
    labels_temp_S = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s',
                                               subjects_dir=SUBJECTS_DIR)[142:148]
    ins_S = mne.read_labels_from_annot(subject='fsaverage', parc='aparc.a2009s')[94:96]

start_time = datetime.now()
SUBJECT = 'fsaverage'
MEG_SUBJECT = 'group_averages'
groups = {'con', 'dys'}

with open(results_path + 'MNI/mni_corrdinates_out.csv', mode='w') as file_out:
    mni_out = csv.writer(file_out, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    for condition in {'fre_sub', 'dur_sub', 'vow_sub'}:#{'std', 'fre', 'dur', 'vow'}:#
        # for all
        STCFILE_FSAV = [MEG_DIR + '/' + MEG_SUBJECT + '/average_all-' + condition]
        stc_fsaverage = mne.read_source_estimate(STCFILE_FSAV[0])

        # source activations
        for hemi in {'lh', 'rh'}:
            # labels
            if show_label == 1:
                if hemi == 'lh':
                    label_combined = [labels_temp_G[2] +
                                      labels_temp_S[2]]
                else:
                    label_combined = [labels_temp_G[3] +
                                      labels_temp_S[3]]

            # Plot in source space on fsaverage brain
            print('Condition: ' + condition + ', hemi: ' + hemi)
            print(tw)
            tmin = float(tw[0]/1000)
            tmax = float(tw[1]/1000)
            vertno_max_tw, time_max_tw = stc_fsaverage.get_peak(hemi=hemi,
                                                                tmin=tmin,
                                                                tmax=tmax)
            # transform to mni coordinates
            if hemi == 'lh':
                heminum = 0
            else:
                heminum = 1
            mni = mne.vertex_to_mni(vertno_max_tw, heminum, 'fsaverage',
                                    subjects_dir=SUBJECTS_DIR)[0]
            mni_out.writerow([condition, mni.astype(np.str)])
            surfer_kwargs = dict(
                hemi=hemi, subject='fsaverage', subjects_dir=SUBJECTS_DIR,
                clim=dict(kind=kind, lims=lims),
                views='lateral',
                initial_time=time_max_tw, time_unit='s', size=(800, 800),
                smoothing_steps=5, colorbar=False,
                time_viewer=False, time_label=None, background='white')
            brain = stc_fsaverage.plot(**surfer_kwargs)
            #        brain.add_label(label_combined[0], borders=True)
            # see whether labels fit
            if show_label == 1:
                if time == 1:
                    label = mne.read_label(label_path + 'func_label_45%_tw' +
                                           str(time) + '-' + hemi + '.label')
                elif time == 2:
                    label = mne.read_label(label_path + 'func_label_45%_tw1' +
                                           '-' + hemi + '.label')
                else:
                    print('Sth went wrong')
                brain.add_label(label, borders=True)
            # only for the colorbar
    #        brain.data['colorbars'][0].number_of_labels = 3
    #        brain.add_foci(vertno_max_tw, coords_as_verts=True, hemi=hemi,
    #                       color='blue',
    #                       scale_factor=0.6, alpha=0.5)
            # fix for look-through visualization of the brain
            brain.data['surfaces'][0].actor.property.backface_culling = True
            brain.save_single_image(results_path + MEG_SUBJECT + '/all_' +
                                    condition + '_' +
                                    method + '_TW' + str(time) + '-fsav-' +
                                    hemi + '.png')
            # only for the colorbar
            #brain.save_single_image(results_path + MEG_SUBJECT + '/legend.png')
            print('Image saved to ' + results_path + MEG_SUBJECT + '/all_' +
                  condition + '_' + method + '_TW' +
                  str(time) + '-fsav-' + hemi + '.png')
            if show_plots == 0:
                brain.close()

        del stc_fsaverage
    #    # for groups
    #    for group in groups:
    #        STCFILE_FSAV = [MEG_DIR + '/' + MEG_SUBJECT + '/average_' +
    #                        group + '-' + condition]
    #        stc_fsaverage = mne.read_source_estimate(STCFILE_FSAV[0])
    #
    #        # source activations
    #        for hemi in {'lh', 'rh'}:
    #            # Plot in source space on fsaverage brain
    #            print('Condition: ' + condition + ', hemi: ' + hemi)
    #            print(tw)
    #            tmin = float(tw[0]/1000)
    #            tmax = float(tw[1]/1000)
    #            vertno_max_tw, time_max_tw = stc_fsaverage.get_peak(hemi=hemi,
    #                                                                tmin=tmin,
    #                                                                tmax=tmax)
    #            surfer_kwargs = dict(
    #                hemi=hemi, subject='fsaverage', subjects_dir=SUBJECTS_DIR,
    ##                clim='auto',
    #                clim=dict(kind=kind, lims=lims),
    #                views='lateral',
    #                initial_time=time_max_tw, time_unit='s', size=(800, 800),
    #                smoothing_steps=5, colorbar=False,
    #                time_viewer=False, time_label=None, background='white')
    #            brain = stc_fsaverage.plot(**surfer_kwargs)
    #            # see whether labels fit
    #            if show_label == 1:
    #                if time == 1:
    #                    label = mne.read_label(label_path + 'func_label_45%_tw' +
    #                                           str(time) + '-' + hemi + '.label')
    #                elif time == 2:
    #                    label = mne.read_label(label_path + 'func_label_45%_tw1' +
    #                                           '-' + hemi + '.label')
    #                else:
    #                    print('Sth went wrong')
    #                brain.add_label(label)
    ##            brain.add_foci(vertno_max_tw, coords_as_verts=True, hemi=hemi,
    ##                           color='blue',
    ##                           scale_factor=0.6, alpha=0.5)
    #            # fix for look-through visualization of the brain
    #            brain.data['surfaces'][0].actor.property.backface_culling = True
    #            brain.save_single_image(results_path + MEG_SUBJECT + '/' +
    #                                    group + '_' + condition + '_' +
    #                                    method + '_TW' + str(time) + '-fsav-' +
    #                                    hemi + '.png')
    #            print('Image saved to ' + results_path + MEG_SUBJECT + '/' +
    #                  group + '_' + condition + '_' + method + '_TW' +
    #                  str(time) + '-fsav-' + hemi + '.png')
    #            if show_plots == 0:
    #                brain.close()
    #
    #        del stc_fsaverage

end_time = datetime.now()
print('The processing for subject ' +
      SUBJECT + ' took: {}'.format(end_time - start_time))
