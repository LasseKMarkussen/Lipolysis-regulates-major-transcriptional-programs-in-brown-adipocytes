#!/bin/bash

for FASTQFILE in $(ls -d *.fastq.gz); do

echo "Mapping" $FASTQFILE
STAR --genomeLoad LoadAndRemove --genomeDir /data/Genomes/mouse/mm9/star/index101bp/ --runThreadN 8 --readFilesCommand zcat --readFilesIn $FASTQFILE --outSJfilterIntronMaxVsReadN 0 --alignIntronMax 1 --alignSJDBoverhangMin 200 --outFileNamePrefix ${FASTQFILE/.fastq.gz/.star_}
done

STAR --genomeLoad Remove --genomeDir /data/Genomes/human/hg19/star/index101bp/

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
makeTagDirectory ${BAMFILE/.bam/.TD\/} $BAMFILE -tbp 1

done

for TD in $(ls -d *.TD); do

echo "Peakfiles" $TD 
findPeaks $TD -style factor -o ${TD}.peak
done

echo "Peakfiles located in tagdirectories"

echo "Script ran to end!"
exit 0