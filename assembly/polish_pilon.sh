#! /bin/bash
# three rounds of Pilon polishing

# job parameters
sp="D.melanogaster"                             # species/sample name
threads="78"                                    # number of threads to use
memory="200G"                                   # amount of RAM to use

input="${sp}.assembly.medaka.fasta"             # input medaka assembly
output="${sp}.assembly.pilon.fasta"             # output file name
read1="${sp}_R1.fastq"                          # forward reads (PE Illumina)
read2="${sp}_R2.fastq"                          # reverse reads (PE Illumina)

# copy sample to temp file
cp ${input} temp_draft.fa

# map short reads to draft
minimap2 -ax sr -t ${threads} temp_draft.fa ${read1} ${read2} \
  | samtools sort -o reads_to_draft.bam --threads ${threads}
samtools index reads_to_draft.bam

# run pilon
java -Xmx${memory} -jar /tools/pilon.jar --genome temp_draft.fasta \
    --frags reads_to_draft.bam --outdir pilon --threads ${threads}

# rename contigs to get rid of "_pilon"s introduced after contig names
cat ./pilon/pilon.fasta \
  | awk '/^>/{print ">contig_" ++i; next}{print}' \
  > ${output}

# clean up
rm  -r ./pilon
rm reads_to_draft.bam
rm reads_to_draft.bam.bai