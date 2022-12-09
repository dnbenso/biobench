#!/bin/bash
#
# exit on error
#set -e
#
# GLOBAL VARS
export THREADS=4
# Can extend accession list if you want jobs to run for longer
export ACCESSIONLIST="SAMEA104724033,SAMEA1044899"
export REFERENCE=CAKOAA01
# Adapaters PATH - you will need to change this
export ADAPTERS_PATH=/apps/trimmomatic/0.39/adapters

#
# Maybe get ena-file-downloader
get_ena () {
    mkdir -p ena && cd ena
    wget http://ftp.ebi.ac.uk/pub/databases/ena/tools/ena-file-downloader.zip
    unzip ena-file-downloader.zip
    cd ..
}

# Downloading our datasets
download () {
    # Takes about 10 mins
    mkdir -p src tmp && cd tmp
    java -jar ../ena/ena-file-downloader.jar --accessions=${ACCESSIONLIST} --format=READS_FASTQ --protocol=FTP --location=. --asperaLocation=/apps/aspera/4.0.2.38
    find reads_fastq -type f -exec mv {} ../src \;
    # Get the reference genome
    cd ../src
    wget ftp://ftp.ebi.ac.uk/pub/databases/ena/wgs/public/cak/${REFERENCE}.fasta.gz
    cd ..
}

# Generate FastQC Report - allow 19 minutes with 4 cores
qc () {
    module load fastqc
    mkdir -p qc && cd qc
    fastqc -t $THREADS ../src/*.fq.gz -o .

    # Run Trimmomatic to trim the bad reads out.
    export INFILES_R1=( $(ls ../src/ERR*_1.fastq.gz) )
    export INFILES_R2=( $(ls ../src/ERR*_2.fastq.gz) )
    module load trimmomatic
    # Could do this in SLURM ARRAY we are running 2 single threaded trim processed at once
    for i in 0 1;do
        (
        trimmomatic PE ${INFILES_R1[$i]} ${INFILES_R2[$i]} \
            $(basename ${INFILES_R1[$i]} .fastq.gz).trim.fastq.gz $(basename ${INFILES_R1[$i]} .fastq.gz)un.trim.fastq.gz \
            $(basename ${INFILES_R2[$i]} .fastq.gz).trim.fastq.gz $(basename ${INFILES_R2[$i]} .fastq.gz)un.trim.fastq.gz \
            SLIDINGWINDOW:4:20 MINLEN:25 ILLUMINACLIP:$ADAPTERS_PATH/TruSeq3-PE-2.fa:2:40:15
        )&
        PID="${!} ${PID}"
    done
    wait ${PID}
    # Update FASTQC reports
    fastqc -t $THREADS *.trim.fastq.gz
    cd ..
}

# Align to reference - llow aobut 30 minutes with 16 cores 48G ram
align () {
    module load bwa
    mkdir -p align && cd align
    # Generate the genome index
    gunzip -k -c ../src/${REFERENCE}.fasta.gz >${REFERENCE}.fasta
    # This is not multi-threaded.... but takes about 3 mins
    bwa index ${REFERENCE}.fasta

    # Align reads to the genome
    module load samtools
    # RUN threaded bwa mem twice
    export INFILES_R1=( $(ls ../src/ERR*_1.fastq.gz) )
    export INFILES_R2=( $(ls ../src/ERR*_2.fastq.gz) )
    # Run bwa with threads, but samtools as well at the same time - samtools uses little cpu 
    #
    # # Note: for convenience we call the bam file PREFIX_1.bam (R1 version of prefix) - but should be called PREFIX.bam
    for i in 0 1;do
        (
        bwa mem -t $THREADS ${REFERENCE}.fasta ../qc/$(basename ${INFILES_R1[$i]} .fastq.gz).trim.fastq.gz ../qc/$(basename ${INFILES_R2[$i]} .fastq.gz).trim.fastq.gz \
            | samtools sort -O bam -o $(basename ${INFILES_R1[$i]} .fastq.gz).bam -@ $THREADS
        )&
        PID="${!} ${PID}"
    done
    wait ${PID}
    cd ..
}

# Call Variants
callvariants () {
    mkdir -p variants && cd variants
    module load bcftools
    export INFILES_R1=( $(ls ../src/ERR*_1.fastq.gz) )
    export INFILES_R2=( $(ls ../src/ERR*_2.fastq.gz) )
    bcftools mpileup --threads $THREADS -Ou -f ../align/${REFERENCE}.fasta \
        ../align/$(basename ${INFILES_R1[0]} .fastq.gz).bam ../align/$(basename ${INFILES_R1[1]} .fastq.gz).bam \
        | bcftools call --threads $THREADS -vmO z -o vcf.gz
    cd ..
}
