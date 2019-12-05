#!/bin/sh
#
# Batch script for maxfiltering a number of files
#
# Author: Lauri Parkkonen <lauri@neuro.hut.fi>
# modified by Anja Thiede <anja.thiede@helsinki.fi>

if [ $# -lt 1 ]
then
  echo "Usage: bash $0 <infile1> [<infile2> ...]"
  exit 1
fi

infiles=$*

prog="maxfilter-2.2"
args="-force -v"
suff="_ref"

echo "About to run MaxFilter on $infiles"
#echo "Press <enter> to continue"
#read a

basepath="/l/thiedea1/MEG_prepro/"

for f in $infiles
do
  barefile=`basename $f .fif`
  abspath=`dirname $f`
  echo "Found abspath $abspath"
  relpath=${abspath##$basepath}
  echo "and relpath $relpath"
  outpath="/l/thiedea1/MEG_prepro/"$relpath
  echo "and outpath $outpath"
  mkdir -p $outpath
  outfile=$outpath/${barefile}$suff".fif"
  logfile=$outpath/${barefile}$suff".log"
  reffile=$basepath/mean_head_pos/av_head_transf_49.fif
  echo "----------------------------------------"
  echo "Processing $f --> $outfile"
  $prog $args -f $f -o $outfile -trans $reffile > $logfile
done
echo "[done]"
exit $?
