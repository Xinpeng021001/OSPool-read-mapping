# OSPool-read-mapping
Running a bunch of read mapping jobs on HTC (OSPool)


Pipeline and workflow for Prevalence calculations in metagenomics data using High-throughput Computing Center (OSPool) 

 

https://osg-htc.org/projects.html 

 

 

Limousia in 100k metagenomic samples 

Workflow: 

 
1. Data preparation 

	Fastq files (running, till now 8 bioprojects with around 1k fastq pair-end reads  files, from different metagenomics samples) and Reference genomes (Limousia MAGs, done) 

2.  Read mapping (on HTC) 

#Make index file: 
 

bowtie2-build $REFERENCE $REFERENCE _index 

 

#read mapping 

 

bowtie2 -x "$OUTPUT_DIR/${GENOME}_index" \ 

-1 "$SAMPLE_DIR/${SAMPLE_ID}_1.fastq" \ 

-2 "$SAMPLE_DIR/${SAMPLE_ID}_2.fastq" \ 

-S "$OUTPUT_DIR/${SAMPLE_ID}_output.sam" 

 

#samtools to convert files 

 

samtools view -Sb "$OUTPUT_DIR/${SAMPLE_ID}_output.sam" > "$OUTPUT_DIR/${SAMPLE_ID}_output.bam" 

samtools sort "$OUTPUT_DIR/${SAMPLE_ID}_output.bam" -o "$OUTPUT_DIR/${SAMPLE_ID}_sorted_output.bam" 

 

 

 

3.InStrin analysis 

inStrain profile "$OUTPUT_DIR/${SAMPLE_ID}_sorted_output.bam" "$GENOME_PATH" \ 

-p 24 \ 

-o "$OUTPUT_DIR/${SAMPLE_ID}_instrain_output" 2>> $LOG_FILE 

 

4. CoverM to calculate  

 # Run CoverM to calculate relative abundance 

coverm genome -b "$OUTPUT_DIR/${SAMPLE_ID}_sorted_output.bam" \ 

--min-covered-fraction 0.5 \ 

-m relative_abundance \ 

--genome-fasta-directory "$MAG_FOLDER" \ 

--output-file "$OUTPUT_DIR/coverm_output/coverm_output.txt" 2>> $LOG_FILE 

 

 