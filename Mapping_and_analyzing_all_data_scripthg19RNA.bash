#!/bin/bash

for FASTQFILE in $(ls -d *.fastq.gz); do
echo $FASTQFILE
star --runMode alignReads --genomeDir /data/Genomes/human/hg19/star/index101bp/ --readFilesIn $FASTQFILE --runThreadN 16 --genomeLoad LoadAndKeep --readFilesCommand zcat
head -23 Aligned.out.sam > Header.sam
awk '$2 == 0 || $2 == 16 { print $0 }' Aligned.out.sam > Mapped_reads.sam
cat Header.sam Mapped_reads.sam > ${FASTQFILE/.fastq.gz/.sam}
rm Aligned.out.sam 
rm Mapped_reads.sam
rm Header.sam
mv Log.final.out ${FASTQFILE/.fastq.gz/.map_stats.txt}
done

for FASTQFILE in $(ls -d *.fq.gz); do
echo $FASTQFILE
star --runMode alignReads --genomeDir /data/Genomes/human/hg19/star/index101bp/ --readFilesIn $FASTQFILE --runThreadN 16 --genomeLoad LoadAndKeep --readFilesCommand zcat
head -23 Aligned.out.sam > Header.sam
awk '$2 == 0 || $2 == 16 { print $0 }' Aligned.out.sam > Mapped_reads.sam
cat Header.sam Mapped_reads.sam > ${FASTQFILE/.fq.gz/.sam}
rm Aligned.out.sam 
rm Mapped_reads.sam
rm Header.sam
mv Log.final.out ${FASTQFILE/.fq.gz/.map_stats.txt}
done


for FASTQFILE in $(ls -d *.fq); do
echo $FASTQFILE
star --runMode alignReads --genomeDir /data/Genomes/human/hg19/star/index101bp/ --readFilesIn $FASTQFILE --runThreadN 16 --genomeLoad LoadAndKeep --readFilesCommand zcat
head -23 Aligned.out.sam > Header.sam
awk '$2 == 0 || $2 == 16 { print $0 }' Aligned.out.sam > Mapped_reads.sam
cat Header.sam Mapped_reads.sam > ${FASTQFILE/.fq/.sam}
rm Aligned.out.sam 
rm Mapped_reads.sam
rm Header.sam
mv Log.final.out ${FASTQFILE/.fq/.map_stats.txt}
done

for FASTQFILE in $(ls -d *.fastq); do
echo $FASTQFILE
star --runMode alignReads --genomeDir /data/Genomes/human/hg19/star/index101bp/ --readFilesIn $FASTQFILE --runThreadN 16 --genomeLoad LoadAndKeep --readFilesCommand zcat
head -23 Aligned.out.sam > Header.sam
awk '$2 == 0 || $2 == 16 { print $0 }' Aligned.out.sam > Mapped_reads.sam
cat Header.sam Mapped_reads.sam > ${FASTQFILE/.fastq/.sam}
rm Aligned.out.sam 
rm Mapped_reads.sam
rm Header.sam
mv Log.final.out ${FASTQFILE/.fastq/.map_stats.txt}
done


STAR --genomeLoad Remove --genomeDir /data/Genomes/human/hg19/star/index101bp/
rm Log.out
rm Log.progress.out
cat *.map_stats.txt > Map_stats_merged.txt

for MAPFILE in $(ls -d *.sam); do
echo $MAPFILE
makeTagDirectory ${MAPFILE/.sam/.TD/} $MAPFILE -format sam -genome hg19 -fragLength given
samtools view -bS $MAPFILE -o ${MAPFILE/.sam/.bam}
rm $MAPFILE
done

for TAGDIR in $(ls -d *.TD/); do
makeUCSCfile $TAGDIR -o `basename $TAGDIR .TD/`.bedgraph
done