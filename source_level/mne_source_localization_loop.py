"""
Source localization with MNE

@author: Anja Thiede <anja.thiede@helsinki.fi>
"""

from datetime import datetime
import numpy as np
import mne

#%matplotlib qt
#%matplotlib inline

# prepare files that are needed
# TO FILL
SUBJECTS_DIR = '/media/cbru/SMEDY/DATA/MRI_data/MRI_orig/'
SUBJECTS = np.arange(1, 51)
SRCSPACING = "oct6"
ICO_NTRI = 4 # Number of triangles in the BEM. Note that the Watershed algorithm always yields
# a 20480-triangle mesh which is here decimated by ICO_NTRI to give BEM_NTRI,
# e.g. 5=20484, 4=5120, 3=1280.
BEM_NTRI = 5120
MEG_DIR = '/media/cbru/SMEDY_SOURCES/DATA/MEG_prepro/'
results_path = ('/media/cbru/SMEDY_SOURCES/results/')
RAW_FILE = 'tata_a_bad_raw_tsss.fif'
#preflood=47 # for watershed algorithm subject 35 / 45 not enough, 50 too much, 47 worked!
conductivity = [0.3]  # forward solution computation for one layer
mindist = 5.0 # for forward solution
baseline = (-0.100, 0.0) # baseline for evoked responses -100 to 0
loose = 0 # loose orientation constraint for inverse operator / 0 = fixed orientation
depth = 0.8 # depth weighting for inverse operator
method = "MNE" #"dSPM" # # method to compute inverse solution
snr = 3. # for inverse solution computation
lambda2 = 1. / snr ** 2 # for inverse solution computation
redo_BEM = 0
redo_stc = 1

# SUBJECTS
exclude = [17, 20, 29, 32, 40] # no MRI
SUBJECTS = np.delete(SUBJECTS, exclude)
test = [2]

#for subject in test: #SUBJECTS: ##
for subject in SUBJECTS:
    start_time = datetime.now()
    SUBJECT = 'SME' + '%03d' %subject
    MEG_SUBJECT = 'sme_' + '%03d' %subject
    CRGFILE = MEG_DIR + '/' + MEG_SUBJECT + '/' + SUBJECT + '-trans.fif'
    # coregistration with mne coreg will create this file

    # these files will be created from this script
    SRCFILE = SUBJECTS_DIR + '/'+ SUBJECT + '/bem/' + SUBJECT + '-' + SRCSPACING + '-src.fif'
    BEMFILE = SUBJECTS_DIR + '/' + SUBJECT + '/bem/' + SUBJECT + '-' + str(BEM_NTRI) + '-bem.fif'
    SOLFILE = SUBJECTS_DIR + '/' + SUBJECT + '/bem/' + SUBJECT + '-' + str(BEM_NTRI) + '-bem-sol.fif'
    COVFILE = MEG_DIR + '/' + MEG_SUBJECT + '/source/tata_a-cov.fif'

    if redo_BEM == 1:
        # create BEM with watershed algorithm
        #mne.bem.make_watershed_bem(SUBJECT, SUBJECTS_DIR, atlas=True,
        # show=False, preflood=preflood, verbose=True, overwrite=True)

        # Setup of Source Space
        src = mne.setup_source_space(SUBJECT, spacing=SRCSPACING,
                                     subjects_dir=SUBJECTS_DIR, add_dist=False)
        #mne.viz.plot_bem(SUBJECT, SUBJECTS_DIR, src=src, show=True)
        print(src)
        mne.write_source_spaces(SRCFILE, src, overwrite=True)

        # Compute the forward solution part 1 (MEG-data independent)
        model = mne.make_bem_model(subject=SUBJECT, ico=ICO_NTRI,
                                   conductivity=conductivity)
        mne.write_bem_surfaces(BEMFILE, model)
        bem = mne.make_bem_solution(model)
        mne.write_bem_solution(SOLFILE, bem)

    conditions = {'fre_sub', 'dur_sub', 'vow_sub'}
#    conditions = {'std', 'fre', 'dur', 'vow'}
    for condition in conditions:
        if condition == 'dur_sub':
            MEG_FILE = 'tata_a_dur_sub-ave.fif'
        elif condition == 'fre_sub':
            MEG_FILE = 'tata_a_fre_sub-ave.fif'
        elif condition == 'vow_sub':
            MEG_FILE = 'tata_a_vow_sub-ave.fif'
        elif condition == 'std':
            MEG_FILE = 'tata_a_std-ave.fif'
        elif condition == 'fre':
            MEG_FILE = 'tata_a_fre-ave.fif'
        elif condition == 'dur':
            MEG_FILE = 'tata_a_dur-ave.fif'
        elif condition == 'vow':
            MEG_FILE = 'tata_a_vow-ave.fif'
        else:
            print('Please insert a valid stimulus condition!')

        # these files will be created from this script
        FWDFILE = MEG_DIR + '/' + MEG_SUBJECT + '/' + MEG_FILE[:14] + '-' + SRCSPACING + '-fwd.fif'
        INVFILE = MEG_DIR + '/' + MEG_SUBJECT + '/' + MEG_FILE[:14] + '-' + SRCSPACING + '-meg-inv.fif'
        STCFILE_IND = MEG_DIR + '/' + MEG_SUBJECT + '/' + MEG_FILE[:14] + '_' + method + '_ind'
        STCFILE_FSAV = MEG_DIR + '/' + MEG_SUBJECT + '/' + MEG_FILE[:14] + '_' + method + '_fsav'

        if redo_stc == 1:
            # Compute the forward solution part 2 (MEG-data dependent)
            fwd = mne.make_forward_solution(MEG_DIR + MEG_SUBJECT + '/source/' +
                                            MEG_FILE, trans=CRGFILE, src=SRCFILE, bem=SOLFILE,
                                            meg=True, eeg=False, mindist=mindist, n_jobs=8)
            print(fwd)
            mne.write_forward_solution(FWDFILE, fwd, overwrite=True)

            # Read the forward solution and compute the inverse operator
            fwd = mne.read_forward_solution(FWDFILE)

            # make an MEG inverse operator
            evoked = mne.read_evokeds(MEG_DIR + MEG_SUBJECT + '/source/' + MEG_FILE,
                                      condition=None, baseline=baseline, kind='average', proj=True)
            info = evoked[0].info
            noise_cov = mne.read_cov(COVFILE)
            inverse_operator = mne.minimum_norm.make_inverse_operator(info, fwd, noise_cov,
                                                                      loose=loose, depth=depth,
                                                                      fixed=True)
            del fwd
            mne.minimum_norm.write_inverse_operator(INVFILE,
                                                    inverse_operator)

            # Compute inverse solution
            stc = mne.minimum_norm.apply_inverse(evoked[0], inverse_operator, lambda2=lambda2,
                                                 method=method, pick_ori=None)
            stc.save(STCFILE_IND)

            # Morph data to average brain
            morph = mne.compute_source_morph(stc, subject_from=SUBJECT,
                                             subject_to='fsaverage',
                                             subjects_dir=SUBJECTS_DIR)
            stc_fsaverage = morph.apply(stc)
            stc_fsaverage.save(STCFILE_FSAV, ftype='stc')
    end_time = datetime.now()
    print('The processing for subject ' + SUBJECT + ' took: {}'.format(end_time - start_time))
