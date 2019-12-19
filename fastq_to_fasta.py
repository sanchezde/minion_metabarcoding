from Bio import SeqIO
import sys

fastq_file = sys.argv[1]
out_name = fastq_file.split(".")[0]

with open(fastq_file, "r") as input_handle:
    with open(out_name + ".fasta", "w") as output_handle:
        sequences = SeqIO.parse(input_handle, "fastq")
        count = SeqIO.write(sequences, output_handle, "fasta")
		
fastq_file = "test.fastq"

out_name = fastq_file.split(".")[0]