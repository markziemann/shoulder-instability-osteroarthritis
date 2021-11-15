#!/bin/bash

REF=mouse_rRNA.fa

for FQZ in *fastq.gz ; do
  echo $FQZ
  FQ=`echo $FQZ | sed 's/.gz//'`
  zcat $FQZ | head -4000000 | fastq_quality_trimmer -t 30 -l 20 -Q33 \
  | tee $FQ | bwa aln -t 8 $REF - | bwa samse $REF - $FQ \
  | samtools view -uSh - \
  | samtools sort -o ${FQ}.bam
done

wait

for i in *bam ; do samtools index $i & done ; wait

for i in *bam ; do samtools flagstat $i > ${i}.stats & done ; wait

head *stats | grep '%' | cut -d '%' -f1 | cut -d '(' -f2 > tmp

head *stats | grep == | cut -d ' ' -f2 | paste - tmp > rrna_res.txt

rm tmp
