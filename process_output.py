#!/usr/bin/env python

# summarize and plot results from SHMprep and PRESTO

import glob
import os
import csv
import pandas as pd
import matplotlib.pyplot as plt

plt.close('all')

# set the working directory to process the shmprep results

os.chdir("./shmprep_stern_out_16_cpus")

# get a list of fastq output files

fastqs = glob.glob("*.fastq")

#get a list of the shmprep conscounts

shmprep_conscount = []

for fastq in fastqs:
    file =  open(fastq, 'r')
    for line in file:
        if line.startswith('@SRR'):
            cluster_count = int(line.split('=')[-1].rstrip())
            shmprep_conscount.append(cluster_count)

# set the working directory to process presto results

os.chdir("../stern2014_out_16cpu")

# get a list of the presto conscounts

presto_conscount = []

results = glob.glob("*atleast-2_headers.tab")

for result in results:
    file = open(result, 'r')
    next(file, None) # skip header
    for line in file:
        cluster_count = int(line.split('\t')[2].rstrip())
        presto_conscount.append(cluster_count)


df = pd.DataFrame(list(zip(shmprep_conscount,presto_conscount)), columns = ['Shmprep', 'Presto'])

presto_hist = df['Presto'].hist(range = (0,50), color='k', bins =20, density=False,figsize=(16, 8)).get_figure()

presto_hist.savefig('Presto_conscount_hist.pdf')


Shmprep_hist = df['Shmprep'].hist(range = (0,50), color='k', bins =20, density=False,figsize=(16, 8)).get_figure()

Shmprep_hist.savefig('Shmprep_conscount_hist.pdf')
