---
layout: default
order: 12
title:  "ddRAD data in stacks"
date:   2017-08-03
time:   "Afternoon"
categories: main
instructor: "Pati"
materials: files/fakefile.txt
material-type: ""
lesson-type: Interactive
---

WORKSHOP QUITO - DAY 4 


STACKS WITH ddRAD data
===

**DOWNLOAD THE RAW DATA FOR THIS LESSON [HERE](https://my.pcloud.com/publink/show?code=XZxojcZzaPwbwoStDk7Do00Rhezeu7w3Xey)**

The first thing to know about stacks is that the online manual is very useful but not completely straighforward to navigate, so let's get familiar with their [manual](http://catchenlab.life.illinois.edu/stacks/) first and the program in general. 


![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/basic-assembly-steps.png?raw=true)<br>


Demultiplexing in STACKS (process_radtags)
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

So many steps!! 
	

Genotyping with denovo_map.pl
---

First, let's grab four [additional sequences](https://my.pcloud.com/publink/show?code=kZYoScZyhvt7h2OCCbB0SteaI7KNfFIKVqk) that we had demultiplexed from another sequencing library; they had the same barcodes, but different Illumina index primers so were demultiplexed separately. Make sure these sequences end up in your working directory. > can you tell what the index primer was?

We should now have five additional individuals for the third population for which we only had one before. 

Let's make a list of the filenames that have sequences in them using the following command:

	ls | awk '/fq/' > sequence_files.txt

This list of filenames will be a part of the input for running *denovo_map.pl*, since you have to list all of the sequence files that will be used for input, rather than a directory containing them. To learn more about **awk** basics, a very powerful tool for editing/rewriting text files, you can [start here](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/files/AWK-cheatsheet.md).

Let's start setting up denovo_map runs. Here is the general code we will use:


	denovo_map.pl -T 8 -m 2 -M 3 -n 2 -S -b 2 -o ./path/to/denovo-map/denovo/ \
	-s ./path/to/denovo-map/filename.fq \
	-s ./path/to/denovo-map/filename.fq \

**Q: what does the backslash '\' mean here?**

The denovo code needs to have every single sequence that you will genotype listed in a single line. Thus, you need to build your **denovo_map** file with EVERY sequence that you will use separately.... **How should we do this?** 

OK, let's start **denovo_map**!!! Look at the terminal window as it runs.... what's happening currently...? While we wait, let's look more into the **STACKS** manual.

#####
#####


One thing that is very important in stacks is troubleshooting parameter settings. The defaults in STACKS are **NOT GOOD** to use, and depending on the specifics of the dataset (divergence, number of populations, samples, etc) these parameters will vary a lot from one study to the other. The main parameters to mess with are: 

	m — specify a minimum number of identical, raw reads required to create a stack.
	M — specify the number of mismatches allowed between reads when processing a single individual (default 2).
	n — specify the number of mismatches allowed between reads (among inds.) when building the catalog (default 1).

**Note 1**: The higher the coverage, the higher the m parameter can be. 

**Note 2**: M should not be 1 (diploid data) but also should not be very high since it will begin to stack paralogs. 

**Note 3**: n will depend on how divergent our individuals/populations are. It should not be zero, since that would essentially allow zero SNPs, but 1 also seems unrealistically low (only a single difference between individuals in any given locus), so in these kinds of datasets we should have permutations that start from 2.  If you use n 1 it is likely to oversplit loci among populations that are more divergent. 

The same paper that discussed the issues with *ref_map.pl* that I mentioned previously, also mentions some tips for picking the ideal parameter settings for stacks... but, in general my recommendation would be: explore your dataset!!! Some general suggestions from it: 

- Setting the value of *m* in essence is choosing how much "error" you will include/exclude from your dataset. This parameter creates a trade-off between including error and excluding actual alleles/polymorphism. Higher values of *m* increase the average sample coverage, but decreases the number of assembled loci. After m=3 loci number is more stable.
- Setting the value *M* is a trade-off between overmerging (paralogs) and undermerging (splitting) loci.  It is **VERY dataset-specific** since it depends on polymorphism in the species/populations and in the amount of error (library prep and sequencing). 
- Setting the value *n* is also critical when it comes to overmerging and undermerging loci. There seems to be an unlimited number of loci that can be merged with the catalog wiht increasing n!! 
- Finally, authors suggest that a general rule for setting parameters is n=M, n=M-1, or n=M+1, and that M is the main parameter that needs to be explored for each dataset. 



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

You can evaluate the number of loci, SNPs, and Fsts that you get from these parameters to assess "stability" of genotyping and pick optimal parameter settings. 

**NOW BACK TO OUR GENOTYPING IN STACKS....**

#####

#####




Uh oh.... our denovo run seems to have failed!! What do you think happened? Let's find the logfile for denovo. First, navigate into your **denovo** output directory, then do: 

	ls -ltrh 
	tail denovo_map.log

What does the logfile say....? Why did the run fail??  

We need to re-make our denovo_map shell script, eliminating all individuals that failed to recover RADtags, and [get over](https://giphy.com/gifs/movie-crying-johnny-depp-hAt4kMHnaVeNO) the fact that we lost those individuals. You can either move the failed individuals to a different directory AND exclude them from the script, or simply exclude them from the script (either works!).

Now we have our new **denovo_map** script ready to go.... let's set it up and see if it doesn't fail!


Getting the output with **populations**
----

The final step in the stacks pipeline is to run the program **populations**. Similar to step 7 in ipyrad, it outputs/summarizes your data into formats you specify. However, another super nice thing about this program is that it runs populations stats for you and puts them in a nice excel-readable output!! :D yay easy pogen stats!!  

To run **populations**, we first need to develop a popmap file, which simply contains names of sequences (first column)and some population code (second column)that they belong to, tab delimited. Our sample/file names alrady contain the population information, so try to build it yourself.... how do you want to do it???

 

Now, let's run **populations** using the following command:

	populations -b 2 -P . -M ./popmap.txt -k -p 1 -r 0.2 -t 36 --structure --genepop --vcf --write_random_snp


Before we move on to the next steps.... let's [talk a bit](https://docs.google.com/presentation/d/1ZfCd0jIuNm4MwdCTw0MOXtyLBBlpRB3Xt_jHWhOcQhk/pub?start=false&loop=false&delayms=60000) about post-genotyping filters and the nature of RADseq datasets and SNP matrices... 


Post-filtering in **plink**
----
We are now going to filter our matrix to reduce biases and incorrect inferences due to missing data (in individuals and SNPs)and by Minor Allele Frequency. 


1. First, we filter loci with less than 60% individuals sequenced

		./plink --file filename --geno 0.4 --recode --out filename_a --noweb


2. Second, we filter individuals that have less than 50% data

		./plink --file filename_a --mind 0.5 --recode --out filename_b --noweb


3. Third, we filter loci with MAF < 0.02 in remaining individuals

		/.plink --file filename_b --maf 0.02 --recode --out filename_c --noweb


Second output from stacks *populations*
----

Now we are going to re-run the last step of the **STACKS** pipeline, so that we can get the nice population stats with out cleaner matrix. 

We need to make a ***whitelist*** file, which is a list of the loci to include based on the plink results (i.e. on amount of missing data in locus). The whitelist file format is ordered as a simple text file containing one catalog locus per line: 

		% more whitelist
		3
		7
		521
		11
		46
		103
		972
		2653
		22
		
		
In order to get from the .map file to the whitelist file format, open *_c.map file in Text Wrangler, and do find and replace arguments using **grep**:


	search for \d\t(\d*)_\d*\t\d\t\d*$
	replace with \1



Using the **.irem** file from the second iteration of *plink* (in our example named with termination **"_b"**), remove any individuals from the first popmap if they did not pass **plink** filters so that they are excluded from the analysis (i.e. individuals with too much missing data). 


Now we can run populations again using the whitelist of loci and the updated popmap file for loci and individuals to retain based on the plink filters.

	populations -b 1 -P ./ -M ./popmap.txt  -p 1 -r 0.5 -W Pr-whitelist --write_random_snp --structure --plink --vcf --genepop --fstats --phylip
	

We will use many of these outputs for downstream analyses. Outputs are: 

	batch_2.hapstats.tsv
	batch_2.phistats.tsv
	batch_2.phistats_1-2.tsv
	batch_2.phistats_1-3.tsv
	batch_2.phistats_2-3.tsv
	batch_2.sumstats.tsv
	batch_2.sumstats_summary.tsv
	batch_2.haplotypes.tsv
	batch_2.genepop
	batch_2.structure.tsv
	batch_2.plink.map
	batch_2.plink.ped
	batch_2.phylip
	batch_2.phylip.log
	batch_2.vcf
	batch_2.fst_1-2.tsv
	batch_2.fst_1-3.tsv
	batch_2.populations.log
	batch_2.fst_summary.tsv
	batch_2.fst_2-3.tsv



