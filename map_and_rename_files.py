#!/usr/bin/env python

#### Re-names demultiplexed Nanopore directories (e.g., "barcode01")
#### to project sample IDs
#### exports csv of dataframe joining samples used and targeted indexing barcodes

import pandas as pd
import os
import sys

sample_file = sys.argv[1]    # comma delimited file with sample ID, its 96-well plate location, and amplicon marker
barcode_file = sys.argv[2]   # comma delimited file with 96-well plate location for each index (Well, Barcode, file-label)

samples = pd.read_csv(sample_file, usecols = ["Sample", "Well", "Marker"])
barcodes = pd.read_csv(barcode_file, usecols = [0, 1, 2])

merged = pd.merge(samples, barcodes, how = "inner")
merged['Sample'] = merged['Sample'].str.cat(merged['Marker'], sep = "_")
merged.to_csv("samples_and_barcodes.csv", index = False)


label = merged['Label'].tolist()
sample_name = merged['Sample'].tolist()


### Making dictionary to change file names

dict = {label[i]: sample_name[i] for i in range(len(label))}

for i in dict:
    try:
        os.rename(i, dict[i])
    except:
        pass