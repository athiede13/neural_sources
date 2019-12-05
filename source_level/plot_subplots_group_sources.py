"""
Plot subplots of the group averages/average of all participants

Created on Tue Sep  4 16:21:37 2018
Author: Anja Thiede <anja.thiede@helsinki.fi>
"""

#%matplotlib qt
#%matplotlib inline

import matplotlib.pyplot as plt

#read image
filepath = '/media/cbru/SMEDY_SOURCES/results/group_averages/'
mode = 'all_sub' # or 'group'

if mode == 'group':
    # separately for the groups
    tw = 'TW1'
    img1 = plt.imread(filepath + 'con_fre_MNE_' + tw + '-fsav-lh.png')
    img2 = plt.imread(filepath + 'con_fre_MNE_' + tw + '-fsav-rh.png')
    img3 = plt.imread(filepath + 'con_dur_MNE_' + tw + '-fsav-lh.png')
    img4 = plt.imread(filepath + 'con_dur_MNE_' + tw + '-fsav-rh.png')
    img5 = plt.imread(filepath + 'con_vow_MNE_' + tw + '-fsav-lh.png')
    img6 = plt.imread(filepath + 'con_vow_MNE_' + tw + '-fsav-rh.png')
    img7 = plt.imread(filepath + 'dys_fre_MNE_' + tw + '-fsav-lh.png')
    img8 = plt.imread(filepath + 'dys_fre_MNE_' + tw + '-fsav-rh.png')
    img9 = plt.imread(filepath + 'dys_dur_MNE_' + tw + '-fsav-lh.png')
    img10 = plt.imread(filepath + 'dys_dur_MNE_' + tw + '-fsav-rh.png')
    img11 = plt.imread(filepath + 'dys_vow_MNE_' + tw + '-fsav-lh.png')
    img12 = plt.imread(filepath + 'dys_vow_MNE_' + tw + '-fsav-rh.png')

elif mode == 'all_sub':
    # average across all participants
    tw = 'TW1'
    img1 = plt.imread(filepath + 'all_fre_sub_MNE_' + tw + '-fsav-lh.png')
    img2 = plt.imread(filepath + 'all_fre_sub_MNE_' + tw + '-fsav-rh.png')
    img3 = plt.imread(filepath + 'all_dur_sub_MNE_' + tw + '-fsav-lh.png')
    img4 = plt.imread(filepath + 'all_dur_sub_MNE_' + tw + '-fsav-rh.png')
    img5 = plt.imread(filepath + 'all_vow_sub_MNE_' + tw + '-fsav-lh.png')
    img6 = plt.imread(filepath + 'all_vow_sub_MNE_' + tw + '-fsav-rh.png')
    tw = 'TW2'
    img7 = plt.imread(filepath + 'all_fre_sub_MNE_' + tw + '-fsav-lh.png')
    img8 = plt.imread(filepath + 'all_fre_sub_MNE_' + tw + '-fsav-rh.png')
    img9 = plt.imread(filepath + 'all_dur_sub_MNE_' + tw + '-fsav-lh.png')
    img10 = plt.imread(filepath + 'all_dur_sub_MNE_' + tw + '-fsav-rh.png')
    img11 = plt.imread(filepath + 'all_vow_sub_MNE_' + tw + '-fsav-lh.png')
    img12 = plt.imread(filepath + 'all_vow_sub_MNE_' + tw + '-fsav-rh.png')

elif mode == 'all_ERF':
    # average across all participants
    tw = 'TW1'
    img1 = plt.imread(filepath + 'all_fre_MNE_' + tw + '-fsav-lh.png')
    img2 = plt.imread(filepath + 'all_fre_MNE_' + tw + '-fsav-rh.png')
    img3 = plt.imread(filepath + 'all_dur_MNE_' + tw + '-fsav-lh.png')
    img4 = plt.imread(filepath + 'all_dur_MNE_' + tw + '-fsav-rh.png')
    img5 = plt.imread(filepath + 'all_vow_MNE_' + tw + '-fsav-lh.png')
    img6 = plt.imread(filepath + 'all_vow_MNE_' + tw + '-fsav-rh.png')
    tw = 'TW2'
    img7 = plt.imread(filepath + 'all_fre_MNE_' + tw + '-fsav-lh.png')
    img8 = plt.imread(filepath + 'all_fre_MNE_' + tw + '-fsav-rh.png')
    img9 = plt.imread(filepath + 'all_dur_MNE_' + tw + '-fsav-lh.png')
    img10 = plt.imread(filepath + 'all_dur_MNE_' + tw + '-fsav-rh.png')
    img11 = plt.imread(filepath + 'all_vow_MNE_' + tw + '-fsav-lh.png')
    img12 = plt.imread(filepath + 'all_vow_MNE_' + tw + '-fsav-rh.png')

elif mode == 'std':
    tw = 'TW1'
    img1 = plt.imread(filepath + 'all_std_MNE_' + tw + '-fsav-lh.png')
    img2 = plt.imread(filepath + 'all_std_MNE_' + tw + '-fsav-rh.png')
    tw = 'TW2'
    img7 = plt.imread(filepath + 'all_std_MNE_' + tw + '-fsav-lh.png')
    img8 = plt.imread(filepath + 'all_std_MNE_' + tw + '-fsav-rh.png')

all_img = [img1, img2, img3, img4, img5, img6, img7, img8, img9, img10, img11, img12]
titles = ['lh', 'rh', 'lh', 'rh', 'lh', 'rh',
          '', '', '', '', '', '']

#plot image (2 subplots)

fig = plt.figure()
w = 40
h = 12
fig.set_size_inches(w, h)
#fig.suptitle("Sources to speech-sound changes in both groups", fontsize=50)
plt.subplots_adjust(wspace=0.02, hspace=0)

for i in range(1, len(all_img)+1):
   # i = i + 1 # grid spec indexes from 0
    plt.subplot(2, 6, i) # rows, columns
    plt.imshow(all_img[i-1], aspect='equal')
    plt.axis('off')
    plt.title(titles[i-1], loc='center', fontsize=35)
#              horizontalalignment='center',

plt.show()
#input("Press Enter to continue...")
fig.savefig(filepath + mode + '_MMFs_on_fsaverage.png')
