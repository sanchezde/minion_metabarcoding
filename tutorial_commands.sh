
source activate qiime2-2018.11

# Map and rename

cd pass

python3 ../map_and_rename_files.py ../sample_info.csv ../barcode_map.csv

for i in *; do cat "$i"/* > $i.fastq; done
rm *.csv.fastq

# convert to fasta

for i in *.fastq; do python3 ../fastq_to_fasta.py "$i"; done

# merge fasta for qiime2 and batch for canu

python3 ../merge_fasta_for_qiime2.py ../sample_metadata.txt

# filter target sequence length

python3 ../length_filter.py seqs.fasta 691 950 # min max

# Error correction in Canu 1.9
 
~/canu-1.9/Darwin-amd64/bin/canu -correct -minOverlapLength=10 \
 -nanopore-raw seqs.filtered.fasta \
 -p zambiaEC \
  useGrid=false \
 -genomeSize=1063 stopOnReadQuality=false \
 -minReadLength=100

gzip -d zambiaEC.correctedReads.fasta.gz

# Removing primers in cutadapt 2.1 as elegantly as my little primate brain can handle
# MinION sequences sequences that are both 5'-3' and 3'-5'
# Each command below targets each flanking primer in the order below
# It is important to retain untrimmed reads in each step to keep reads trimmed in a previous step or reads that will be trimmed in a following step
# 1.) 5' positive 2.) 3' positive 3.) 5' antisense 4.) 3' antisense
# for loop useful for multiple batches of corrected reads if needed

for i in *correctedReads.fasta; do cutadapt -g TTCTCAACCAACCACAAAGACATTGG -e 0.3 -O 12 "$i" > for.cut."$i"; done ## 5'
for i in *for.cut.*; do cutadapt -a TGATTCTTTGGCCACCCAGAAGTCTA -e 0.3 -O 12 "$i" > rev."$i"; done ### 3'
for i in *rev.for.cut.*; do cutadapt -g TAGACTTCTGGGTGGCCAAAGAATCA -e 0.3 -O 12 "$i" > rcfor."$i"; done ## 5' antisense
mkdir qiime_dir
for i in *rcfor.rev.for.cut.*; do cutadapt -a CCAATGTCTTTGTGGTTGGTTGAGA -e 0.3 -O 12 "$i" > qiime_dir/trimmed."$i"; done ### 3' antisense
rm *cut.*
cd qiime_dir
for x in *rcfor.rev.for.cut.*; do mv -- "$x" "${x//rcfor.rev.for.cut./}"; done

# QIIME 2.2018.11

## import data
qiime tools import \
  --input-path trimmed.zambiaEC.correctedReads.fasta \
  --output-path sequences.qza \
  --type 'SampleData[Sequences]'

## Dereplicate sequences
qiime vsearch dereplicate-sequences \
  --i-sequences sequences.qza \
  --o-dereplicated-table table.qza \
  --o-dereplicated-sequences rep-seqs.qza

## Cluster and generate feature table of OTUs
qiime vsearch cluster-features-de-novo \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --p-perc-identity 0.95 \
  --o-clustered-table table-dn-95.qza \
  --o-clustered-sequences rep-seqs-dn-95.qza

### Use a metadata file to tabulate summaries of OTU clustering

## OTU sequence and table summaries
qiime feature-table summarize \
  --i-table table-dn-95.qza \
  --o-visualization table-dn-95.qzv \
  --m-sample-metadata-file ../../qiime_metadata_file.txt
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dn-95.qza \
  --o-visualization rep-seqs-dn-95.qzv
  
## Classify taxonomy using blast.
  
qiime feature-classifier classify-consensus-blast \
  --i-query rep-seqs-dn-95.qza \
  --i-reference-reads ../../chordatabase_seqs.qza \
  --i-reference-taxonomy ../../chordatabase_taxonomy.qza \
  --p-perc-identity 0.9 \
  --o-classification taxonomy.qza
  
## Raw taxonomy table

qiime taxa barplot \
  --i-table table-dn-95.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file ../../qiime_metadata_file.txt \
  --o-visualization taxa-bar-plots.qzv
  
#### Visualize ####

### extract level-6.csv; can be any level from 1 - 6

cp taxa-bar-plots.qzv taxa-bar-plots.zip

unzip taxa-bar-plots.zip

find . -name "*level-6.csv" -exec cp {} ./ ";"

Rscript ../../make_barplots.R level-6.csv





