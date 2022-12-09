# Simple Bio-Bench

A simple workflow demonstrating a variant calling analysis.

## Requirements
The pipeline functions require:

* fastqc

* trimmomatic

* bwa - 0.7.7

* samtools - 1.12

* bcftools - 1.15

Additionally you will need to be able to download about 8GB of data from the
internet, and you will need about 20GB file system space.

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

If running the sbatch scripts:
* ensure you resource them appropriately for your system
* the functions assume that you are using the modules system - if you aren't
  just remove the module load calls from the pipelinefunc.sh script and ensure
  the binaries are your path.
* If you want to just run one script with dependencies on a SLURM HPC system
  then you can just execute ./master_sbatch.sh to run the entire workflow.

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

