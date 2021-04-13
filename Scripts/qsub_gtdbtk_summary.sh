#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cu_10108 -A cu_10108
### Job name (comment out the next line to get the name of the script used as the job name)
#PBS -N qsub_gtdbtk_summary
### Output files (comment out the next 2 lines to get the job name used instead)
#PBS -e $PBS_JOBID.qsub_gtdbtk_summary.stderr
#PBS -o $PBS_JOBID.qsub_gtdbtk_summary.stdout
### Only send mail when job is aborted or terminates abnormally
#PBS -m n
### Number of nodes
#PBS -l nodes=1:ppn=1:thinnode
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 30 days)
#PBS -l walltime=30:00:00:00
# V1.00 Written by Gisle Vestergaard (gislevestergaard@gmail.com)

# This is where the work is done
# This merges the results from the previously split CheckM runs and makes a figure of all bins.
[ $# != 1 ] && { echo "Usage: qsub -F '<bin DIR> ' qsub_gtdbtk_summary.sh"; exit 1; }
INDIR=$1
cd $INDIR
rm -f allbins_gtdbtk_bac120_summary.tsv allbins_gtdbtk_ar122_summary.tsv
cat bins_0*_gtdbtk/gtdbtk.bac120.summary.tsv | awk '!x[$0]++' >> allbins_gtdbtk_bac120_summary.tsv
cat allbins_gtdbtk_bac120_summary.tsv | cut -f1,2 | cut -f 2- -d _ | sort -gk1,1 > allbins_gtdbtk_bac120_summary_per_cluster.tsv
cat bins_0*_gtdbtk/gtdbtk.ar122.summary.tsv | awk '!x[$0]++' >> allbins_gtdbtk_ar122_summary.tsv
cat allbins_gtdbtk_ar122_summary.tsv | cut -f1,2 | cut -f 2- -d _ | sort -gk1,1 > allbins_gtdbtk_ar122_summary_per_cluster.tsv
