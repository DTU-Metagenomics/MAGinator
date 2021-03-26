#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cu_10108 -A cu_10108
### Job name (comment out the next line to get the name of the script used as the job name)
#PBS -N gtdbtk
### Output files (comment out the next 2 lines to get the job name used instead)
#PBS -e $PBS_JOBID.gtdbtk.stderr
#PBS -o $PBS_JOBID.gtdbtk.stdout
### Only send mail when job is aborted or terminates abnormally
#PBS -m n
### Number of nodes
#PBS -l nodes=fatnode
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 30 days)
#PBS -l walltime=30:0:00:00
# V1.00 Written by Gisle Vestergaard (gislevestergaard@gmail.com)
# Go to the directory from where the job was submitted (initial directory is $HOME)
cd $PBS_O_WORKDIR
 
### Here follows the user commands:
# Define number of processors
# Load all required modules for the job
 
# This is where the work is done
[ $# != 2 ] && { echo "Usage: qsub -F '<Genome DIR> <OUTPUT DIR> qsub_gtdbtk.sh"; exit 1; }
export PATH=/home/projects/cu_10108/data/Bin/Programs/miniconda3/bin:$PATH
MAGDIR=$1
OUTDIR=$2
/home/projects/cu_10108/data/Bin/Programs/miniconda3/bin/gtdbtk classify_wf --genome_dir "$MAGDIR" --out_dir "$OUTDIR" --cpus 10 --force --debug --pplacer_cpus 5
