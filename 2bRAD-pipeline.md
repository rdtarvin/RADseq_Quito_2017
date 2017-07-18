WORKSHOP QUITO - DAY 3 
2bRAD
===

Use native pipeline for filtering and trimming, then use iPyrad.<br>
Download data
```
wget xxx
```

Step 1. Filter reads by barcode, remove barcodes from dataset in ```2bRAD native pipeline```
---

* Copy scripts to your computer via git
```
git clone https://github.com/z0on/2bRAD_denovo.git
```

* Decompress data (only necessary for 2bRAD native, other pipelines can read .gz)
```
gunzip *.gz
```

* Concatenate data that were run on multiple lanes, if necessary
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

* separate reads by barcode
	- here we use ```trim2bRAD_2barcodes_dedup2.pl``` script, which is necessary for HiSeq4000 runs; otherwise use ```trim2bRAD_2barcodes_dedup.pl```
	- adaptor is the last 4 characters of the reads, here 'AGAT'
```
/home1/02576/rdtarvin/2bRAD_denovo/trim2bRAD_2barcodes_dedup2.pl input=T36R59_I93.fq adaptor=AGAT sampleID=1
ls
```
output is 'tr0' format

Step 2. Filter reads by quality with the ```fastx_toolkit```.
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

Now we have our 2bRAD reads separated by barcode and trimmed (steps 1 & 2)!

Steps 34567. Complete pipeline in ```iPyrad```.
---

iPyrad is super easy, make sure you check out their extensive online documentation [here](http://ipyrad.readthedocs.io/index.html).

* First, initiate a new analysis.
```
ipyrad -n 2brad-v1
cat params-2brad-v1.txt
```

* Make a few changes to the params file.
	- parameter [4]: add the location of the sorted fastqs; you must end this parameter with *.gz
	- parameter [7]: change rad to gbs; gbs can take into account revcomp reads
	- parameter [8]: don't worry about this, it will be ignored since we are starting from sorted reads
	- parameter [11] lower to 5; data have been deduplicated (ipyrad assumes it has not been deduplicated)
	- parameter [12] lower to 2; data have been deduplicated (ipyrad assumes it has not been deduplicated)
	- parameter [18] keep at 2 for diploid
	- parameter [21] change to 3; lower number means more missing data but more loci recovered
	- parameter [27] add ', u'; this will provide an output selecting single SNPs from each locus randomly

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

* Okay, it's that easy!! To run the pipeline, type the following command:
```
ipyrad -p params-2brad-v1.txt -s 1234567
```

Let's look at the intermediate and final files of ipyrad


Step 7 reiterations. Perhaps you want to create a number of output files to test the effect of missing data on your inferences
---

```bash
for i in 4 6 8 10 12; do ipyrad -p params-2brad-v1.txt -b 2brad-v2-${i}l; do sed -i s/".*\[21\].*"/"${i}$(printf '\t')$(printf '\t')$(printf '\t')$(printf '\t') \#\# \[21\] \[min_samples_locus\]: Min \# samples per locus for output"/ params-2brad-v2-${i}l.txt;  done
for i in 4 6 8 10 12; do ipyrad -p params-2brad-v2-${i}l.txt -s 7 -f; done
```

Downstream phylogenetic analyses
===

Phylogenetics with iPyrad is easy!!

```
## raxml-concat
conda install raxml -c bioconda
python
import ipyrad.analysis as ipa
rax = ipa.raxml(data='2brad-epi-july17.phy',name='2brad-epi-july17',workdir='analysis-raxml')

## tetrad
tetrad -s 2brad-epi-july17.snps.phy -l 2brad-epi-july17.snps.map -m all -n tetrad-test

## raxml snps - https://github.com/amkozlov/raxml-ng
wget https://github.com/amkozlov/raxml-ng/releases/download/0.4.0/raxml-ng_v0.4.0b_linux_x86_64.zip
unzip raxml-ng_v0.4.0b_linux_x86_64.zip
/home1/02576/rdtarvin/raxml-ng --msa ../2brad-epi-july17.u.snps.phy --model GTR+G+ASC_LEWIS --search
```






