#!/bin/bash

for FASTQFILE in $(ls -d *.fastq.gz); do
zcat $FASTQFILE | fastx_clipper -a GATCGGAAGAGCACACGTCTGAACTCCAGTCA -C -Q33 -z -o ${FASTQFILE/.fastq.gz/.clip.fastq.gz}
done

mkdir fastqc_reports
fastqc *.clip.fastq.gz -o fastqc_reports/ -q -t 16

for FASTQFILE in $(ls -d *.clip.fastq.gz); do

echo "Mapping" $FASTQFILE
STAR --genomeLoad LoadAndRemove --genomeDir /references/mm9star/index101bp/ --readFilesCommand zcat --runThreadN 16 --readFilesIn $i ${i%_R1_001.fastq.gz}_R2_001.fastq.gz --outSJfilterIntronMaxVsReadN 0 --outFilterMatchNmin 25 --alignIntronMax 1 --alignSJDBoverhangMin 200 --outFileNamePrefix ${i%_R1_001.fastq.gz}
done


for SAMFILE in $(ls -d *.sam); do

grep ^@ $SAMFILE > header.tmpsam
awk '($2 == "0" || $2 == "16") {print}' $SAMFILE > reads.tmpsam
cat header.tmpsam reads.tmpsam > ${SAMFILE/.sam/.tmpsam}
rm $SAMFILE

echo "Sam to bamming " $SAMFILE
samtools view -bS -@16 ${SAMFILE/.sam/.tmpsam} > ${SAMFILE/.sam/.bam}
rm *.tmpsam
done

for BAMFILE in $(ls -d *.bam); do

echo "Making TD based on " $BAMFILE
makeTagDirectory ${BAMFILE/.bam/.TD\/} $BAMFILE -read1 -tbp 1

done

echo "Script ran to end!"
exit 0
