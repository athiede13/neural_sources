# neural_sources

Code used for **Thiede et al. Neuromagnetic responses during speech discrimination are associated with reading-related skills in dyslexic and typical readers, 2020. Heliyon. [https://doi.org/10.1016/j.heliyon.2020.e04619]** Most of the code makes use of the [MNE Python](https://github.com/mne-tools/mne-python) software package.

DOI for the code: [10.5281/zenodo.3874389](https://doi.org/10.5281/zenodo.3874389)

## Preprocessing

Removal of noisy channels, maxfilter and removal of physiological artifacts from MEG data, followed by filtering and epoching. [Freesurfer](https://surfer.nmr.mgh.harvard.edu/) pipeline for MRI data.

## Source modeling

Setup of source space, forward and inverse operators in individual cortically-constrained source space. Set up of functional region of interest (ROI).

## Correlations

Step-wise correlational analysis of mismatch-field source amplitudes with neuropsychological test scores.
