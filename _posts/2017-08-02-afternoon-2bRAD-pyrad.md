---
layout: default
order: 4
title:  "2bRAD data in ipyrad"
date:   2017-08-02
time:   "Day 3: Afternoon"
categories: main
instructor: "Becca"
materials: files/fakefile.txt
---

## WORKSHOP QUITO - DAY 3 
### 2bRAD pipeline, with phylogenetic analyses


These data are part of a pilot project comparing ddRAD and 2bRAD data (**do NOT distribute**).<br>
There are twelve samples from three genera, with at least two individuals sampled per genus.<br>
In this pipeline, we will use the [2bRAD native pipeline](https://github.com/z0on/2bRAD_denovo) for filtering and trimming, 
[fastx-toolkit](http://hannonlab.cshl.edu/fastx_toolkit/) for quality control, 
and then [iPyrad](http://ipyrad.readthedocs.io/index.html) for the rest of the assembly.<br><br>

Download data for this lesson
```
wget xxx
```

## Looking at your data in unix

Your files will likely be zipped and with the termination **.fq.gz** or **fastq.gz**. The first thing you want to do is look at the beginning of your files while they are still zipped with the following command: 

```
gzless <<name of file>> #is this easy to see? 
zhead <<name of file>> iterations with diff Ncols etc 
```

Let's unzip one of the raw data files to look a bit more into it:

```
gunzip <<filename.fq.gz>>
```	
Hmmm.... ok, now lets look at the full file:

```
cat <<filename.fq>>
```
	
Uh oh.... let's quit before the computer crashes.... it's too much to look at! `Ctrl+C`

**Challenge**
<details> 
  <summary>How would you count the number of reads in your file? </summary>
   As you can see from the previous "head" command, each sequence line begins with @, so we can just count how many times the argument '@D3' appears, or in essence, how many "lines" of sequence data we have.<br> 
   <code>grep -c '@D3' Stef_3_ATCACG_L008_R1_001.fastq</code>
</details> 



Step 0. Use fastqc to check read quality.
---

download [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

```
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
unzip fastqc_v0.11.5.zip
fastqc -h
fastqc *.gz
```

fastqc quickly produces a nice .html file that can be viewed in any browser.<br>
Open the .html files, what can you see?


Step 1. Demultiplex by barcode in **2bRAD native pipeline**
---

Copy scripts to your computer via git
```
git clone https://github.com/z0on/2bRAD_denovo.git
```

Decompress data (only necessary for 2bRAD native, other pipelines can read .gz).
```
gunzip *.gz
```

Concatenate data that were run on multiple lanes, if necessary.
- T36R59_I93_S27_L006_R1_001.fastq and T36R59_I93_S27_L007_R1_001.fastq
- pattern "T36R59_I93_S27_L00" is common to both read files; program concatenates into one file with (.+) saved as file name

```
/home/user1/2bRAD_denovo/ngs_concat.pl "(.+)_S27_L00"
head T36R59_I93.fq

@K00179:73:HJCTJBBXX:7:1101:28006:1209 1:N:0:TGTTAG
TNGTCCACAAGAGTGTGTCGAGCGTTGTGCCCCCCCGCATCTCTACAGAT
+
A#AAFAFJJJJJJJJJJJJJFJJJJJJFJJJJJJJJJJJFJFJJJJJAJ<
@K00179:73:HJCTJBBXX:7:1101:28026:1209 1:N:0:TGTTAG
CNAACCCGTTGTCACGTCGCAAATAAGTCGGTGCGCTGGCAATCACAGAT
+
A#AFFJJJFJJFFJJJJJJJJFFJJJJJFJFJFJFJJJJJJJJJJJJJJF
@K00179:73:HJCTJBBXX:7:1101:28047:1209 1:N:0:TGTTAG
GNGTCCCAGTGATCCGGAGCAGCGACGTCGCTGCTATCCATAGTGAAGAT
```

Separate reads by barcode. Let's take a look at the structure of a 2bRAD read.
![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/2bRAD-read.png?raw=true)


- here we use ```trim2bRAD_2barcodes_dedup2.pl``` script, which is necessary for HiSeq4000 runs; otherwise use ```trim2bRAD_2barcodes_dedup.pl```
- adaptor is the last 4 characters of the reads, here 'AGAT'
```
/home1/02576/rdtarvin/2bRAD_denovo/trim2bRAD_2barcodes_dedup2.pl input=T36R59_I93.fq adaptor=AGAT sampleID=1
ls
```
output is 'tr0' format

Step 2. Filter reads by quality with the **fastx_toolkit**
---

```
fastq_quality_filter -h

usage: fastq_quality_filter [-h] [-v] [-q N] [-p N] [-z] [-i INFILE] [-o OUTFILE]
Part of FASTX Toolkit 0.0.14 by A. Gordon (assafgordon@gmail.com)

   [-h]         = This helpful help screen.
   [-q N]       = Minimum quality score to keep.
   [-p N]       = Minimum percent of bases that must have [-q] quality.
   [-z]         = Compress output with GZIP.
   [-i INFILE]  = FASTA/Q input file. default is STDIN.
   [-o OUTFILE] = FASTA/Q output file. default is STDOUT.
   [-v]         = Verbose - report number of sequences.
                  If [-o] is specified,  report will be printed to STDOUT.
                  If [-o] is not specified (and output goes to STDOUT),
                  report will be printed to STDERR.
                  
# 20 is typical number for q filter
for i in ls *.tr0; do fastq_quality_filter $i -q 20 -p 90 > ${i}_R1_.trim; done

# zip the files to save space
for i in *.trim; do gzip ${i}; done

# a note: ipyrad expects '_R1_' in the file name, so I've added it to the file names
```

Now we have our 2bRAD reads separated by barcode and trimmed (steps 1 & 2)!<br>

**TASK**.
The files need to be renamed for each species, and the characters '_R1_' must be added prior to the file extension. <br>
Using the barcode file and the command `mv`, rename all .fq files accordingly.<br>


Steps 34567. Complete pipeline in **iPyrad**
---

iPyrad is super easy, make sure you check out their extensive online documentation [here](http://ipyrad.readthedocs.io/index.html).

First, initiate a new analysis.
```
ipyrad -n 2brad-v1
cat params-2brad-v1.txt
```

Make a few changes to the params file.
- [4] [sorted_fastq_path]: add the location of the sorted fastqs; you must end this parameter with *.gz
- [7] [datatype]: change rad to gbs; gbs can take into account revcomp reads
- [8] [restriction_overhang]: don't worry about this, it will be ignored since we are starting from sorted reads
- [11] [mindepth_statistical]: lower to 5; data have been deduplicated (ipyrad assumes it has not been deduplicated)
- [12] [mindepth_majrule]: lower to 2; data have been deduplicated (ipyrad assumes it has not been deduplicated)
- [18] [max_alleles_consens]: keep at 2 for diploid
- [21] [min_samples_locus]: change to 3; lower number means more missing data but more loci recovered
- [27] [output_formats]: add ', u'; this will provide an output selecting single SNPs from each locus randomly

```
atom params-2brad-v1.txt
```

Your final params file should look like this:

```
------- ipyrad params file (v.0.7.1)--------------------------------------------
2brad-v1		               ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
./                             ## [1] [project_dir]: Project dir (made in curdir if not present)
                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
                               ## [3] [barcodes_path]: Location of barcodes file
./*.gz                         ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted fastq files
denovo                         ## [5] [assembly_method]: Assembly method (denovo, reference, denovo+reference, denovo-reference)
                               ## [6] [reference_sequence]: Location of reference sequence file
gbs                            ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
TGCAG,                         ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
5                              ## [9] [max_low_qual_bases]: Max low quality base calls (Q<20) in a read
33                             ## [10] [phred_Qscore_offset]: phred Q score offset (33 is default and very standard)
5                              ## [11] [mindepth_statistical]: Min depth for statistical base calling
2                              ## [12] [mindepth_majrule]: Min depth for majority-rule base calling
10000                          ## [13] [maxdepth]: Max cluster depth within samples
0.85                           ## [14] [clust_threshold]: Clustering threshold for de novo assembly
0                              ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
0                              ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
20                             ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                              ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
5, 5                           ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus (R1, R2)
8, 8                           ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus (R1, R2)
3                              ## [21] [min_samples_locus]: Min # samples per locus for output
20, 20                         ## [22] [max_SNPs_locus]: Max # SNPs per locus (R1, R2)
8, 8                           ## [23] [max_Indels_locus]: Max # of indels per locus (R1, R2)
0.5                            ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus (R1, R2)
0, 0, 0, 0                     ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                     ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
p, s, v, u                        ## [27] [output_formats]: Output formats (see docs)
                               ## [28] [pop_assign_file]: Path to population assignment file
```


Okay, it's that easy!! To run the pipeline, type the following command:
```
ipyrad -p params-2brad-v1.txt -s 1234567
```

To check on the results, you can open a new terminal window and type
```
ipyrad -p params-2brad-v1.txt -r
```

Let's look at the intermediate and final files created by iPyrad.


Step 3. 
---

Step 4.
---

Step 5.
---

Step 6.
---

Step 7.
---



<br><br><br>
Downstream phylogenetic analyses
===

### Phylogenetics with iPyrad is easy!!

Estimate a RAxML tree with concatenated loci
```
conda install raxml -c bioconda
python
import ipyrad.analysis as ipa
rax = ipa.raxml(data='2brad-epi-july17.phy',name='2brad-epi-july17',workdir='analysis-raxml')
```

Estimate a quartets-based tree in ```tetrad```, an ipython version of SVDquartets
```
tetrad -s 2brad-epi-july17.snps.phy -l 2brad-epi-july17.snps.map -m all -n tetrad-test
```

Estimate a tree based on a SNP matrix, using one SNP from each locus, in [RAxML-ng](raxml snps - https://github.com/amkozlov/raxml-ng).
```
cd
wget https://github.com/amkozlov/raxml-ng/releases/download/0.4.0/raxml-ng_v0.4.0b_linux_x86_64.zip
unzip raxml-ng_v0.4.0b_linux_x86_64.zip
/home1/02576/rdtarvin/raxml-ng --msa ../2brad-epi-july17.u.snps.phy --model GTR+G+ASC_LEWIS --search
```


This is the expected topology. 

```
        ___________________sp1
       |   
-25my--|          _________sp2
       |____15my_|
                 |      ___sp3
                 |_5my_|  
                       |  _sp4
                       |_|
                         |_sp5
                         
```
   
Do we see the correct tree in our results?


iPyrad offers the option to branch your pipeline with option -b. This allows you to access results from previous steps and use them in different downstream analyses.
One of the most convenient uses of this function is testing the effect of missing data on your downstream analyses.
So, let's execute some reiterations of Step 7, the step that generates the final SNP matrices.
**Remember, never edit file names or paths that are created by iPyrad. It needs them to keep track of analyses.**

```bash
for i in 4 6 8 10 12; do ipyrad -p params-2brad-v1.txt -b 2brad-v2-${i}l; do sed -i s/".*\[21\].*"/"${i}$(printf '\t')$(printf '\t')$(printf '\t')$(printf '\t') \#\# \[21\] \[min_samples_locus\]: Min \# samples per locus for output"/ params-2brad-v2-${i}l.txt;  done
for i in 4 6 8 10 12; do ipyrad -p params-2brad-v2-${i}l.txt -s 7 -f; done
```

