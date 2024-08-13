#!/bin/bash

# prepare for the env
SAMPLE_ID=$1

source /opt/conda/etc/profile.d/conda.sh
conda activate readmapping

# tar reference genome
tar xzvf GCF_002160515.1.tar.gz

# download data
iseq -i ${SAMPLE_ID} -g

# check if the download succeed
if [[ -f ${SAMPLE_ID}_1.fastq.gz && -f ${SAMPLE_ID}_2.fastq.gz ]]; then
    echo "DOWNLOAD FINISHED"
    
    echo "Start bowtie2"
    #  Bowtie2 

    bowtie2 -x GCF_002160515.1/GCF_002160515.1.fna_index -p 1 \
      -1 ${SAMPLE_ID}_1.fastq.gz \
      -2 ${SAMPLE_ID}_2.fastq.gz | \
      samtools view -@ 1 -Sb - | \
      samtools sort -@ 1 -o ${SAMPLE_ID}_sorted_output.bam


    echo "Start samtools"
    # Samtools

    samtools index  -@ 1 ${SAMPLE_ID}_sorted_output.bam

    echo "Read mapping finished"

    # InStrain
    echo "Start inStrain"
    inStrain profile ${SAMPLE_ID}_sorted_output.bam GCF_002160515.1/GCF_002160515.1.fna \
      -p 1 \
      -o ${SAMPLE_ID}_instrain_output

    # CoverM
    echo "Start CoverM"
    coverm genome \
      -b ${SAMPLE_ID}_sorted_output.bam \
      --min-covered-fraction 0.5 \
      -m relative_abundance \
      --threads 1 \
      --genome-fasta-files GCF_002160515.1/GCF_002160515.1.fna \
      --output-file coverm_output.txt

    mkdir ${SAMPLE_ID}_result
    mv coverm_output.txt ${SAMPLE_ID}_result
    mv ${SAMPLE_ID}_instrain_output ${SAMPLE_ID}_result
    mv ${SAMPLE_ID}_1.fastq.gz ${SAMPLE_ID}_result
    mv ${SAMPLE_ID}_2.fastq.gz ${SAMPLE_ID}_result
    mv ${SAMPLE_ID}_sorted_output.bam ${SAMPLE_ID}_result

else
    echo "Download failed, creating empty result directory."
    mkdir ${SAMPLE_ID}_result
fi

# final results
tar -zcvf ${SAMPLE_ID}_result.tar.gz ${SAMPLE_ID}_result/

