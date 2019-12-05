#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Concatenate raw fif files

Created on Thu Sep  6 13:58:42 2018
@author: Anja Thiede <anja.thiede@helsinki.fi>
"""

import os.path as op
import mne

# find file paths and correct files
file_path = ('/media/cbru/SMEDY_SOURCES/DATA/MEG_orig_all/')
subject = ('sme_002/')
fname1 = ('tata_a1_bad_raw.fif')
fname2 = ('tata_a2_bad_raw_correct.fif')

# load data
raw1 = mne.io.read_raw_fif(op.join(file_path, subject, fname1))
raw2 = mne.io.read_raw_fif(op.join(file_path, subject, fname1))

raw_concat = mne.concatenate_raws([raw1, raw2], preload=None, events_list=None, verbose=None)
raw_concat.plot(lowpass=80, highpass=.58, remove_dc=True)

# save
out_fname = 'tata_a_bad_raw.fif'
out_folder = op.join(file_path, subject)
raw_concat.save(op.join(out_folder, out_fname))
