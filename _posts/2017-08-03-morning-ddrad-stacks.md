---
layout: default
order: 10
title:  "ddRAD data in stacks"
date:   2017-08-03
time:   "Morning"
categories: main
instructor: "Pati"
materials: files/fakefile.txt
material-type: ""
---

WORKSHOP QUITO - DAY 4 
STACKS WITH ddRAD
===


The first thing to know about stacks is that the online manual is very useful but not completely straighforward to navigate, so let's get familiar with their [manual](http://catchenlab.life.illinois.edu/stacks/) first and the program in general. 


Demultiplexing in STACKS (process_radtags)
----

Demultiplexing your sequencing pools is always the first step in any pipeline. In stacks, the files you need for this are: 

- barcodes+sample names (tab-delimited .txt file)

- process_radtags code (shell program from stacks)

We had a total of two libraries for this project, and they both used the same adapters but different illumina primers. Let's take a look at the Stacks Manual for [process_radtags](http://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php) to see how to set up our barcodes file. 

KEEPING? I've made one of the barcodes files for you to work with, which can be found [here](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/STACKS/demultiplexing/barcodes-Stef-3.txt). 

<<You now have to build the second barcode file, using the SAME barcodes as the other library, the same format, the **different** index primer and sample names. Here are the sample names: 

	pop1_413
	pop1_414
	pop1_416
	pop1_418
	pop1_419
	pop1_420
	pop1_422
	pop1_423
	pop1_424
	pop1_425
	pop1_426
	pop1_427
	pop1_428
	pop1_429
	pop1_431
	pop1_432
	pop1_433
	pop1_434
	pop1_435
	pop1_436
	pop1_467
	pop1_468
	pop1_469
	pop1_470

The index primer is xxxxx, and the sample names occur in the same order as the barcodes in the example file.

**NOTE 1**: whenever editing text files, first, NEVER use what you exported from excel or word directly... always check in a simple text editor (Text Wrangler, BBEdit, etc) and using "view invisible characters" to avoid unnecesary headaches of hidden characters or extra spaces/tabs, etc! Biggest waste of time in anything computing... 

**NOTE 2**: For stacks, you need to have the appropriate barcode files within the appropriate library folders if demultiplexing libraries separately.

**NOTE 3**: Figure out how your barcodes are set up within your sequence file, in order to determine how to set up the process_radtags code (doing any of the commands we did earlier to look into the files).

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ddRAD-read.png?raw=true)

Now that you know how your sequence file looks like (it will vary from one facility to another), then you can enter the option for whether the barcode occurs in line with the sequence or not, and the other options as well.

The general code we will use for process_radtags, running it from within the raw-data folder, is the following: 


	process_radtags -P -p . -b ./path/to/folder/barcodes-Stef3-e.txt -o ./path/to/folder/process_rads_1e2/  -c -q -r -D --inline_index --renz_1 sphI --renz_2 mspI -i gzfastq 



Genotyping in stacks
----

In most cases, having a reference genome is a bad thing. However, stacks is designed for non-model organisms, so in fact their [denovo_map](http://catchenlab.life.illinois.edu/stacks/comp/denovo_map.php) algorithm is superior and more self-contained than their [ref_map](http://catchenlab.life.illinois.edu/stacks/comp/ref_map.php). 

In **ref_map.pl** you need to use [another alignment tool](https://github.com/lh3/bwa) prior to running stacks. So then, the pipeline workflow would have one extra step: 

	process_radtags
	bwa
	ref_mal.pl

*"The ref_map.pl program takes as input aligned reads. It does not provide the assembly parameters that denovo_map.pl does and this is because the job of assembling the loci is being taken over by your aligner program (e.g. BWA or GSnap). You must take care that you have good alignmnets -- discarding reads with multiple alignments, making sure that you do not allow too many gaps in your sequences (otherwise loci with repeat elements can easily be collapsed during alignments), and take care not to allow soft-masking in the alignments. This occurs when an aligner can not make a full alignment and instead soft-masks the portion of the read that could not be aligned (pretending that this part of the read does not exist). **These factors, if not cared for, can cause spurious SNP calls and problems in the downstream analysis."***


Genotyping with denovo_map.pl
---

First, let's grab some other sequences that we had demultiplexed from another sequencing pool, like this: 

	wget <<add url here>>

We should have five more individuals for the third population that we only had one before. 

Let's make a list of the filenames that have sequences in them:

	ls WRITE CODE FOR THIS

This list of filenames will be a part of the input for running denovo_map.pl, since you have to list all of the equence files that will be used for input, rather than a directory. 

