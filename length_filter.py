from Bio import SeqIO
import sys

fasta_file = sys.argv[1]
minlength = sys.argv[2]
maxlength = sys.argv[3]

out_name = fasta_file.split(".")[0]

with open(fasta_file, "r") as input_handle:
    with open(out_name + ".filtered.fasta", "w") as output_handle:
        sequences = SeqIO.parse(input_handle, "fasta")
        filtered = []
        for record in sequences:
            if len(record.seq) > int(minlength) and len(record.seq) < int(maxlength):
                filtered.append(record)
        count = SeqIO.write(filtered, output_handle, "fasta")