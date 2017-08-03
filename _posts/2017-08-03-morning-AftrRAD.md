---
layout: default
order: 12
title:  "ddRAD Data in AftrRAD"
date:   2017-08-03
time:   "Morning"
categories: main
instructor: "David"
materials: ""
material-type: ""
lesson-type: Interactive
---

WORKSHOP QUITO - DAY 4 
AftrRAD WITH ddRAD
===


AftrRAD (align from total reads) is a bioinformatic pipeline for the de novo assembly and genotyping of RADseq data. It was described by Sovic et al (2015), Molecular Ecology Resources 15:1163-1171, and you can get the program and documentation as a zip file [here](https://u.osu.edu/sovic.1/downloads/).

STEP 1 Getting ready for AftrRAD
----

Demultiplexing your sequencing pools is always the first step in any pipeline. In stacks, the files you need for demultiplexing are: 

- barcodes+sample names (tab-delimited .txt file)

- process_radtags code (shell program from stacks)

First, let's take a look at the Stacks Manual for [process_radtags](http://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php) to see how to set up our barcodes file. 

So, let's build the barcodes file for demultiplexing, where the first column will be the unique adapter sequence using this [text file](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/files/STACKS/demultiplexing/Pool_1_barcodes.txt), the second column is the index primer sequence (in this case, ATCACG), and the third column is the individual sample names, found [here](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/files/STACKS/demultiplexing/Pool_1_sample_names.txt).The sample names occur in the same order as the barcodes in the example file.

**There are MANY ways to build this file.... how do you want to do it?**

**NOTE 1**: whenever editing text files, first, NEVER use what you exported from excel or word directly... always check in a simple text editor (Text Wrangler, BBEdit, etc) and using "view invisible characters" to avoid unnecesary headaches of hidden characters or extra spaces/tabs, etc! Biggest waste of time in anything computing... 

**NOTE 2**: For stacks, you need to have the appropriate barcode files within the appropriate library folders if demultiplexing libraries separately.

**NOTE 3**: Figure out how your barcodes are set up within your sequence file, in order to determine how to set up the process_radtags code (doing any of the commands we did earlier to look into the files).

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ddRAD-read.png?raw=true)

To triple-check your barcode layout, look into your **gzipped** file to see how barcodes are setup and figure out the stacks code with whether the barcode occurs in line with the sequence or not. This is not super simple, and usually takes a couple of tries before it works! 



The general code we will use for process_radtags, running it from within the raw-data folder, is the following: 


	process_radtags -p . -b ./barcodes_pool1.txt -o ./demultiplexing-test -c -q -r -D --inline_index --renz_1 sphI --renz_2 mspI -i gzfastq


**What do our demultiplexed files look like...?**

Let's make a directory of the "removed" files and move them there:

	mkdir bad_rads
	mv *rem*



STEP 2 Demultiplexing, quality filtering, and aligning in AftrRAD (AftrRAD.pl)
----

Demultiplexing your sequencing pools is always the first step in any pipeline. In stacks, the files you need for demultiplexing are: 

- barcodes+sample names (tab-delimited .txt file)

- process_radtags code (shell program from stacks)

First, let's take a look at the Stacks Manual for [process_radtags](http://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php) to see how to set up our barcodes file. 

So, let's build the barcodes file for demultiplexing, where the first column will be the unique adapter sequence using this [text file](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/files/STACKS/demultiplexing/Pool_1_barcodes.txt), the second column is the index primer sequence (in this case, ATCACG), and the third column is the individual sample names, found [here](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/files/STACKS/demultiplexing/Pool_1_sample_names.txt).The sample names occur in the same order as the barcodes in the example file.

**There are MANY ways to build this file.... how do you want to do it?**

**NOTE 1**: whenever editing text files, first, NEVER use what you exported from excel or word directly... always check in a simple text editor (Text Wrangler, BBEdit, etc) and using "view invisible characters" to avoid unnecesary headaches of hidden characters or extra spaces/tabs, etc! Biggest waste of time in anything computing... 

**NOTE 2**: For stacks, you need to have the appropriate barcode files within the appropriate library folders if demultiplexing libraries separately.

**NOTE 3**: Figure out how your barcodes are set up within your sequence file, in order to determine how to set up the process_radtags code (doing any of the commands we did earlier to look into the files).

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ddRAD-read.png?raw=true)

To triple-check your barcode layout, look into your **gzipped** file to see how barcodes are setup and figure out the stacks code with whether the barcode occurs in line with the sequence or not. This is not super simple, and usually takes a couple of tries before it works! 



The general code we will use for process_radtags, running it from within the raw-data folder, is the following: 


	process_radtags -p . -b ./barcodes_pool1.txt -o ./demultiplexing-test -c -q -r -D --inline_index --renz_1 sphI --renz_2 mspI -i gzfastq


**What do our demultiplexed files look like...?**

Let's make a directory of the "removed" files and move them there:

	mkdir bad_rads
	mv *rem*



Genotyping in stacks
----

In most cases, having a reference genome is a bad thing. However, STACKS is designed for non-model organisms, so in fact their [denovo_map](http://catchenlab.life.illinois.edu/stacks/comp/denovo_map.php) algorithms are superior and more self-contained than their [ref_map](http://catchenlab.life.illinois.edu/stacks/comp/ref_map.php) algorithms. 

In **ref_map.pl** you need to use [another alignment tool](https://github.com/lh3/bwa) prior to running stacks. So then, the pipeline workflow would have one extra step: 

	process_radtags
	GSNAP or bwa
	ref_mal.pl

*"The ref_map.pl program takes as input aligned reads. It does not provide the assembly parameters that denovo_map.pl does and this is because the job of assembling the loci is being taken over by your aligner program (e.g. BWA or GSnap). You must take care that you have good alignmnets -- discarding reads with multiple alignments, making sure that you do not allow too many gaps in your sequences (otherwise loci with repeat elements can easily be collapsed during alignments), and take care not to allow soft-masking in the alignments. This occurs when an aligner can not make a full alignment and instead soft-masks the portion of the read that could not be aligned (pretending that this part of the read does not exist). **These factors, if not cared for, can cause spurious SNP calls and problems in the downstream analysis."***

A recent paper that came out, [Lost in Parameter Space: a roadmap for STACKS](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12775/full), shows how building *ref_map* loci in STACKS is not very efficient, and loses too much data, which complicates the pipeline even more! Thus, the pipeline for *ref_map.pl*, using their so-called *"integrated"* method should be: 

	process_radtags #demultiplex
	denovo_map.pl #initial genotyping
	GSNAP or bwa #align raw reads to catalog loci from denovo
	integrate_alignments.py #integrate alignment information back into denovo ouput
	populations


	

Genotyping with denovo_map.pl
---

First, let's grab five additional  sequences that we had demultiplexed from another sequencing pool; they had the same barcodes, but different Illumina index primers so were demultiplexed separately. 

We should now have five additional individuals for the third population for which we only had one before. Also, notice how these individuals had a different Illumina index primer... 

Let's make a list of the filenames that have sequences in them:

	ls | awk '/fq/' > sequence_files.txt

This list of filenames will be a part of the input for running *denovo_map.pl*, since you have to list all of the equence files that will be used for input, rather than a directory. 

One thing that is very important in stacks is troubleshooting parameter settings. The defaults in STACKS are **NOT GOOD** to use, and depending on the specifics of the dataset (divergence, number of populations, samples, etc) these parameters will vary a lot from one study to the other. The main parameters to mess with are: 

	m — specify a minimum number of identical, raw reads required to create a stack.
	M — specify the number of mismatches allowed between loci when processing a single individual (default 2).
	n — specify the number of mismatches allowed between loci when building the catalog (default 1).

**Note 1**: The higher the coverage, the higher the m parameter can be. 

**Note 2**: M should not be 1 (diploid data) but also should not be very high since it will begin to stack paralogs. 

**Note 3**: n will depend on how divergent our individuals/populations are. It should not be zero, since that would essentially create zero SNPs, but 1 also seems unrealistically low (only a single difference between individuals in any given locus), so in these kinds of datasets we should start permutations starting from 2.  If you use n 1 it is likely to oversplit loci among populations that are more divergent. 

The same paper that discussed the issues with *ref_map.pl* that I mentioned previously, also mentions some tips for picking the ideal parameter settings for stacks... but, in general my recommendation would be: explore your dataset!!! Some general suggestions from it: 

- Setting the value of *m* in essence is choosing how much "error" you will include/exclude from your dataset. This parameter creates a trade-off between including error and excluding actual alleles/polymorphism. Higher values of *m* increase the average sample coverage, but decreases the number of assembled loci. After m=3 loci number is more stable.
- Setting the value *M* is a trade-off between overmerging (paralogs) and undermerging (splitting) loci.  it is **VERY dataset-specific** since it depends on polymorphism in the species/populations and in the amount of error (library prep and sequencing). 
- Setting the value *n* is also critical when it comes to overmerging and undermerging loci. There seems to be an unlimited number of loci that can be merged with the catalog wiht increasing n!! 
- Finally, authors suggest to use a general rule of parameter settings is n=M, n=M-1, or n=M+1, and that M is the main parameter that needs to be explored for each dataset. 



However, given that these methods are still very new and that we still don't know how to "Easily" and properly assess error, the more permutations you do with the parameter settings, the more you will understand what your dataset is like, and the better/more "real" your loci/alleles will be. Here are some recommended permutations to run wiht your dataset:

Permutations | -m | -M | -n | --max_locus_stacks 
------------ | ------------- | ------------ | ------------- | ------------ |
a | 3 | 2 | 2 | 3 | 
b | 5 | 2 | 2 | 3 |
c | 7 | 2 | 2 | 3 | 
d | 3 | 3 | 2 | 3 |
e | 3 | 4 | 2 | 3 |
f | 3 | 5 | 2 | 3 |
g | 3 | 2 | 3 | 3 |
h | 3 | 2 | 4 | 3 |
i | 3 | 2 | 5 | 3 |
j | 3 | 2 | 2 | 4 |
k | 3 | 2 | 2 | 5 |

Now we can start setting up denovo_map runs. Here is the general code for doing that. 

	mkdir ./path/to/denovo-map/denovo-test-1/

	denovo_map.pl -T 8 -m 2 -M 3 -n 2 -S -b 2 -o ./path/to/denovo-map/denovo-test-1/ \
	-s ./path/to/denovo-map/Ab_372.1.fq \
	-s ./path/to/denovo-map/Ab_372.2.fq \

Etc.... (as in, followed by all your other sequences). So, the final file should look like [this](). Thus, you need to build your denovo_map file with EVERY sequence that you will use separately.... **How do you want to do this?** 


