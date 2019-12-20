# Menu à la MinION: a simple process to QC and classify taxonomy in field settings

## Metabarcoding from Nanopore sequence data: from raw reads to taxonomy

### Overview

This project provides utilities I put together to take demultiplexed amplicon data from the Oxford Nanopore Technologies MinION sequencer and produce a species level report. I'm not a programmer but mostly use computer science tools for a means to an end (I apologize in advance for any coding faux paux). In a field setting opposite the globe (>60 hours of travel), our goal was to sequence DNA and generate host ID and diet from the feces of large African mammals. That way, we could discuss the results with management partners before we get back on the airplane. This was a very rewarding proof-of-concept study that we detail in a manuscript we prepared entitled: *Menu à la MinION: DNA sequencing in the field for diet of large African mammals* (Faith M. Walker, Daniel E. Sanchez, Crystal M. Hepp; Northern Arizona University).

Simply follow the commands in `tutorial_commands.sh` from the pass directory. The data includes MinION pass reads that we demultiplexed using Albacore 2.3.4 (commands provided) into fastq formatted sequences. Due to demultiplexing error, it is possible that some reads will sort into barcode directories the user did not intend. Furthermore, the samples are sorted into into individual directories generically named "barcode01", "barcode02" ... `map_and_rename_files.py` handles that. The rest of the process puts the fastq sequences in a format ammenable for some awesome bioinformatics tools in **Canu 1.9**, **cutadapt 2.1**, and **QIIME2.2018.11**. When following the tutorial_commands in the `/pass` directory, directories containing fastqs are renamed and concatenated. For convenience, fastqs are converted to fasta format and then filtered to retain reads of the length of the targeted amplicon (Cytochrome c oxidase subunit I; or COI). Reads are then error corrected in canu and primers are removed in cutadapt. Finally, we cluster and BLAST classify taxonomy to representative operational taxonomic units (OTUs) against a database of chordates from the Barcode of Life Database. There is also an R script to summarize taxonomy and produce a barplot.

#### Required modules and programs

* [Miniconda installation of QIIME 2](https://docs.qiime2.org/2019.10/install/native/)
* [Canu 1.9](https://canu.readthedocs.io/en/latest/)
* [Cutadapt 2.1](https://cutadapt.readthedocs.io/en/stable/)
* [Tidyverse](https://www.tidyverse.org/) installation in R only for running R script at end
  * readr 1.3.1
  * tidyr 0.8.3
  * dyplr 0.8.3
  * ggplot2 3.2.1

#### Acknowledgements

I would like to thank [Greg Caporaso](https://github.com/gregcaporaso) for putting together the `merge_fasta_for_qiime2.py` script.
