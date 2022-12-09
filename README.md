# Simple Bio-Bench

A simple workflow demonstrating a variant calling analysis.

## Requirements
The pipeline functions require:

* fastqc

* trimmomatic

* bwa - 0.7.7

* samtools - 1.12

* bcftools - 1.15

## What does it do?

The pipelinefunc.sh shell script contains a number of functions:

* get_ena - this downloads the European Nucleotide Archive tool to get data

* download - downloads diamondback moth reference and sequences

* qc - uses trimmomatic and fastqc to do quality control

* align - uses bwa mem to align trimmed sequences to reference

* callvariants - uses bcftools mpileup to call variants and produce VCF file

## How do I use this?

You can use it as is by calling the sbatch scripts on a SLURM HPC system or on
the command line.

You will need to make sure you change the ADAPTERS_PATH variable for trimmomatic
prior to running the qc function.

If running the sbatch scripts, ensure you resource them appropriately for your
system and create the logs directory first in your working directory.

To run through the whole pipeline on the command line:

```
source pipelinefunc.sh

# Get the required sequence files - should take about 10 minutes
get_ena
download

# Do the analysis
qc
align
callvariants
```

