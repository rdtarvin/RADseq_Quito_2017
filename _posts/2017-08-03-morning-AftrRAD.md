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

In order to run AftrRAD you need to unzip the file downloaded before and make sure the three dependencies (i.e. R, ACANA, and Mafft) mentioned in the manual are installed and working correctly. Also, if running AftrRAD version 5.0 or greater you can reduce run times by doing parallel analyses by installing the Perl module Parallel:ForkManager.

**NOTE**: All of the steps mentioned above have already been taken care of when installing the Virtual Machine for this workshop.

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/basic-assembly-steps.png?raw=true)<br>

PART 1 Formatting data and steps 1, 2 and 3* (AftrRAD.pl)
----

Download data for this lesson
```
cd ~/Applications/AftrRADv5.0/Data/
wget -O RAD105_10M.txt.gz 'https://www.dropbox.com/s/tqctvehvbjk0qgt/RAD105_10M.txt.gz?dl=1'
gunzip RAD105_10M.txt.gz
ls
rm RAD105_10M.txt.gz
```

Arguments for this perl script are:
```
re  Restriction enzyme recognition sequence. Default: TGCAGG (corresponds to SbfI). If no restriction enzyme recognition site, enter 0.
minQual Minimum quality (Phred) score for retaining reads. Default: 20.
minDepth  Minimum mean nonzero read depth to retain read. Default: 5.
minIden The minimum percent identity (after alignment) to consider two reads
to be alternative alleles from the same locus. The default is 90%.
numIndels The maximum number of indels allowed between any two reads to
consider them alternative alleles from the same locus. The default is 3.
P2 The beginning of the P2 adaptor sequence. Reads containing this string
are removed from the analysis. If you don’t want to search for the P2
adaptor, you can enter “noP2” here, or any other string of characters that
will not be found in any of your reads. The default is ATTAGATC.
minParalog The minimum number of reads that must occur at a third allele in an
individual to flag a locus as paralogous. Default is 5.
Phred The quality score methodology used in the sequencing. Most often
Phred33, which is the default. An alternative is Phred64.
dplexedData If data are demultiplexed prior to the AftrRAD run, set this to ‘1’. In this
case, the data files must be stored in a folder named ‘DemultiplexedFiles’.
If running demultiplexed data, use the default for “DataPath”.
stringLength Reads containing strings of homopolymers of this length will be removed.
Default is 15.
DataPath Path to directory containing fastq data files for the run. Default is the Data
directory in the AftrRAD working directory.
BarcodePath Path to directory containing barcode files. Default is the Barcodes
directory in the AftrRAD working directory.
MaxH Maximum proportion of samples allowed to be heterozygous at a locus.
Loci for which heterozygosity exceeds this value will be flagged as
paralogous. Default is 90%.
maxProcesses The maximum number of processors to use in a parallel run.
```

PART 2 Steps 4 and 5* (Genotype.pl)
----

PART 3 Steps 6 and 7* (FilterSNPs.pl and different formatting scripts for downstream analyses)
----
