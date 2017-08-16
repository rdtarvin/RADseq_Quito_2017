---
layout: default
order: 14
title:  "ddRAD Data in AftrRAD"
date:   2017-08-04
time:   "Afternoon"
categories: main
instructor: "David"
materials: ""
material-type: ""
lesson-type: Interactive
---

## WORKSHOP QUITO - DAY 5 <br>
### ddRAD data in AftrRAD

AftrRAD (align from total reads) is a bioinformatic pipeline for the de novo assembly and genotyping of RADseq data. It was described by Sovic et al (2015), Molecular Ecology Resources 15:1163-1171, and you can get the program and documentation as a zip file [here](https://u.osu.edu/sovic.1/downloads/).

PART 0 Getting ready for AftrRAD
----

AftrRAD is a good alternative when you have single-end RADseq data and no access to multicore computing resources (i.e. you can perform these analyses efficiently on a personal laptop).

In order to run AftrRAD you need to unzip the file downloaded before and make sure the three dependencies (i.e. R, ACANA, and Mafft) mentioned in the manual are installed and working correctly. Also, if running AftrRAD version 5.0 or greater you can reduce run times with  parallel analyses by installing the Perl module Parallel:ForkManager.

**NOTE**: All of the steps mentioned above have already been taken care of when installing the Virtual Machine for this workshop.

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/basic-assembly-steps.png?raw=true)<br>

PART 1 Formatting data and steps 1, 2 and 3* (AftrRAD.pl)
----

Download data for this lesson and include the file in a folder called Data.
```
cd ~/Applications/AftrRADv5.0/Data/
wget -O RAD105_10M.txt.gz 'https://www.dropbox.com/s/tqctvehvbjk0qgt/RAD105_10M.txt.gz?dl=1'
gunzip RAD105_10M.txt.gz
ls
```

Create a text file containing the barcode and sample name information for each individual. Include the file in a folder called Barcodes.

Before running the first perl script make sure your working directory contains the following elements:

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/AftrRAD%20working%20directory.png?raw=true)<br>

Start running AftrRAD by typing perl AftrRAD.pl followed by any arguments you want to modify. Arguments and their values should be separated by a dash.

Arguments for this perl script are:

**re**  Restriction enzyme recognition sequence. Default: TGCAGG (corresponds to SbfI). If no restriction enzyme recognition site, enter 0.

**minQual** Minimum quality (Phred) score for retaining reads. Default: 20.

**minDepth**  Minimum mean nonzero read depth to retain read. Default: 5.

**minIden**	Minimum percent identity to consider two reads alternative alleles from same locus. Default: 90%.

**numIndels**	Maximum number indels allowed between any two reads to consider them alternative alleles from the same locus. Default: 3.

**P2**	Beginning of P2 adaptor sequence. Reads containing this are removed. Default: ATTAGATC.

**minParalog**	Minimum number reads that must occur at a third allele in an individual to flag a locus as paralogous. Default: 5.

**Phred**	Quality score methodology used in sequencing. Default: Phred33.

**dplexedData**	If data are demultiplexed prior to run, set to ‘1’.

**stringLength**	Reads containing strings of homopolymers of this length will be removed. Default: 15.

**DataPath**	Path to directory containing fastq data files for the run. Default: Data directory in AftrRAD working directory.

**BarcodePath**	Path to directory containing barcode files. Default: Barcodes directory in AftrRAD working directory.

**MaxH**	Maximum proportion of samples allowed to be heterozygous at a locus. Default: 90%.

**maxProcesses**	Maximum number of processors to use in a parallel run.

PART 2 Steps 4 and 5* (Genotype.pl)
----

For the next step in AftrRAD you will need to type perl Genotype.pl followed by any arguments you want to modify. As above, arguments and their values should be separated by a dash.

Arguments for this perl script are:

**MinReads**	Minimum coverage required at a locus in an individual to apply a binomial test and call a genotype. Default: 10.

**pvalLow**	For each locus in each individual, a binomial test is applied to score the sample as heterozygous or homozygous (assumption: two alleles in a heterozygote will be sequenced in equal frequencies). Default: 0.0001.

**pvalHigh**	Same as pvalLow, but allows for a different p-value threshold for loci that have relatively high total counts. Default: 0.00001.

**pvalThresh** Threshold number of reads at a locus in each binomial test that determines whether pvalLow or pvalHigh is used as the critical p-value. Default: 100.

**subset** Option to genotype only a subset of the individuals in dataset. Default: ‘0’, and includes all samples. If set to '1', a text file must be provided with the names of the samples to include. Default name for this file is 'SamplesForSubset.txt', and it should be located in the main AftrRAD directory.

**subsetfile** File name/path containing file with sample names to include in genotyping. Only applies if ‘1’ is set above. Default: file 'SamplesForSubset.txt', in the main AftrRAD directory.

**maxProcesses**	Maximum number of processors to use in a parallel run.

This script will ask whether to eliminate specific samples based on the amount of missing data at polymorphic loci in each of the samples. Name of samples provided as "bad samples" are suggestions and to make a decision check the "MissingDataProportions.txt" and "MissingDataCounts" files present in the "Output/RunInfo" directory.

PART 3 Steps 6 and 7* (FilterSNPs.pl and formatting scripts for downstream analyses)
----

Finally, you will need to type perl FilterSNPs.pl followed by any arguments you want to modify.

Arguments for this perl script are:

**pctScored**	Percent of individuals that must be genotyped in order to retain the locus. Default: 100.

**maxSNP**	Maximum location along the reads to score SNPs. Value should be chosen based on the file Output/RunInfo/SNPLocations.pdf. Default:0, which prints all SNPs.

**MinReads**	Minimum coverage required at a locus in an individual to score a genotype. Default is to use the value used in the most recent run of Genotypes.pl.

In AftrRAD, you can find different perl scripts to prepare input files for phylogenetic and population genetic analyses. Go to the Formatting folder located in the main AftrRAD directory and type perl ScriptNameThatYouAreInterested.pl.
