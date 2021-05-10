#!/usr/bin/env python
# Made for Python 3.7
# V1.00 Written by Gisle Vestergaard (gislevestergaard@gmail.com)
# This script will sum the total sequence length of each .fna file in a directory and 
# select according to size criteria provided using flags -L and -S, the >= or <= total 
# length respectively. Option -l outputs a file containing bin name and size.

import argparse
import Bio
import glob
import os
from Bio import SeqIO
import subprocess

parser = argparse.ArgumentParser(description='Select fasta files by lenght')
parser.add_argument("-i", "--indir", required = True, 
					help="Input directory containing fasta files")
parser.add_argument("-L", "--large",  
					help="Select larger or equal to this number of basepairs", type=int)
parser.add_argument("-S", "--small",  
					help="Select smaller or equal to this number of basepairs", type=int)
parser.add_argument("-o", "--output", required = True, 
					help="Directory to copy selected fasta files")
parser.add_argument("-l", "--list", required = False, 
					help="Output file name for list of bin sizes")
parser.parse_args()
args = parser.parse_args()

# Exit and print help if neither flags -S or -L are provided
if args.large is None and args.small is None:
	parser.print_help()

# Create dictionary of bin sizes if needed and check if output file already exists
if args.list is not None:
	dic={}
	if os.path.isfile(args.list):
		print(args.list, "already exists")
		quit()

# Create output directory
subprocess.call(['mkdir', '-p', args.output])

# If we are looking for larger than or equal to, this part opens each fna file and
# sums the length of each fasta entry. If the total length of that file satisfies
# the provided -L value, the file is copied to output directory.
if args.large:
	for filename in glob.glob(os.path.join(args.indir, '*.fna')):
		with open(filename, 'r') as handle:
			length = 0
			for record in Bio.SeqIO.parse(handle, "fasta") :
				if length == 0:
					length = len(record)
				else:
					length = length + len(record)
		if args.list is not None:
			sample=filename.split("/")[-1].split(".")[0]
			dic[sample] = length
		if length >= args.large:
			output = args.output + "/"
			subprocess.call(['scp', filename , output])
		handle.close
   
# If we are looking for smaller than or equal to, this part opens each fna file and
# sums the length of each fasta entry. If the total length of that file satisfies
# the provided -S value, the file is copied to output directory.
if args.small:
	for filename in glob.glob(os.path.join(args.indir, '*.fna')):
		with open(filename, 'r') as handle:
			length = 0
			for record in Bio.SeqIO.parse(handle, "fasta") :
				if length == 0:
					length = len(record)
				else:
					length = length + len(record)
		if args.list is not None:
			sample=filename.split("/")[-1].split(".")[0]
			dic[sample] = length
		if length <= args.small:
			output = args.output + "/"
			subprocess.call(['scp', filename , output])
		handle.close

if args.list is not None:
	with open (args.list, "a") as f:
		for key, value in dic.items():
			f.write("{}\t{}\n".format(key, value))
	f.close
