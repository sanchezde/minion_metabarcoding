import skbio.io
import qiime2
import sys

### Author: Greg Caporaso ###

### Takes comma-delimited input that includes `sample-id` and associated fasta
### Concatenates separate fasta files into single file formatted for QIIME2

sample_metadata = sys.argv[1]

# See https://docs.qiime2.org/2018.11/tutorials/metadata/
# and https://dev.qiime2.org/latest/metadata/
md = qiime2.Metadata.load(sample_metadata)
metadata_column = md.get_column('fasta-filename').to_series()

# see the skbio docs:
# http://scikit-bio.org/docs/latest/generated/skbio.io.format.fasta.html

output_filename = 'seqs.fasta'
output_file = open(output_filename, 'w')

for sample_id, fasta_filename in metadata_column.items():
    for seq_record in skbio.io.read(open(fasta_filename), format='fasta'):
        seq_id = seq_record.metadata['id']
        seq = str(seq_record)
        output_file.write('>%s_%s\n%s\n' % (sample_id, seq_id, seq))

output_file.close()