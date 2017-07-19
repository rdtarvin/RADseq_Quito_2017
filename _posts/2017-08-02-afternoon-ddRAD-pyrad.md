---
layout: default
order: 5
title:  "ddRAD data in ipyrad"
date:   2017-08-02
time:   "Day 3: Afternoon"
categories: main
instructor: "Becca"
materials: files/fakefile.txt
---

WORKSHOP QUITO - DAY 3 <br>
ddRAD data in ipyrad: from filtered data to phylogenies
===

These data are part of a pilot project comparing ddRAD and 2bRAD data (**do NOT distribute**).<br>
There are twelve samples from three genera, with at least two individuals sampled per genus, and two technical replicates.<br><br>

Download data
```
wget xxx
```

### Step 0. Use fastqc to check read quality.
```
fastqc *.gz
```
Open the .html files, what can you see?



### Step 1. Demultiplex in ```ipyrad``` [done]

Data have been demultiplexed previously so that they can be subsampled evenly across samples. This step is rather easy in ipyrad, it just requires filling in options for parameters 1-3 rather than 4.

```
## initialize new ipyrad analysis
ipyrad -n ddrad-v1
cat params-ddrad-v1.txt

------- ipyrad params file (v.0.7.1)--------------------------------------------
ddrad-v1                       ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
./                             ## [1] [project_dir]: Project dir (made in curdir if not present)
                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
                               ## [3] [barcodes_path]: Location of barcodes file
                               ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted fastq files
denovo                         ## [5] [assembly_method]: Assembly method (denovo, reference, denovo+reference, denovo-reference)
                               ## [6] [reference_sequence]: Location of reference sequence file
rad                            ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
TGCAG,                         ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
5                              ## [9] [max_low_qual_bases]: Max low quality base calls (Q<20) in a read
33                             ## [10] [phred_Qscore_offset]: phred Q score offset (33 is default and very standard)
6                              ## [11] [mindepth_statistical]: Min depth for statistical base calling
6                              ## [12] [mindepth_majrule]: Min depth for majority-rule base calling
10000                          ## [13] [maxdepth]: Max cluster depth within samples
0.85                           ## [14] [clust_threshold]: Clustering threshold for de novo assembly
0                              ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
0                              ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
35                             ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                              ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
5, 5                           ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus (R1, R2)
8, 8                           ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus (R1, R2)
4                              ## [21] [min_samples_locus]: Min # samples per locus for output
20, 20                         ## [22] [max_SNPs_locus]: Max # SNPs per locus (R1, R2)
8, 8                           ## [23] [max_Indels_locus]: Max # of indels per locus (R1, R2)
0.5                            ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus (R1, R2)
0, 0, 0, 0                     ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                     ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
p, s, v                        ## [27] [output_formats]: Output formats (see docs)
                               ## [28] [pop_assign_file]: Path to population assignment file
```

Be sure to review the [beautiful documentation](http://ipyrad.readthedocs.io/outline.html) for ipyrad.

One particularly handy feature is that they list the different parameters which are used in each step. 
For example, in step one, we use these parameters:

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ipyrad_step1-variables.png?raw=true)

In step two, we use these parameters:

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ipyrad_step2-variables.png?raw=true)

So, you can predict which parameters I have already altered for our data

### Step 1:
- [0] [*assembly_name]: default, created when ipython is initiated
- [1] [*project_dir]: keep in working directory, './'
- [2] [raw_fastq_path]: /path/to/raw/prefix*.gz
- [3] [barcodes_path]: /path/to/ddRAD-barcodes.txt
- [4] [sorted_fastq_path]: not changed if filtering in python; we will change in a moment
- [7] [*datatype]: pairddrad
- [8] [restriction_overhang]: changed to our restriction overhangs CATCG,AATT (see figure below)
- [15] [max_barcode_mismatch]: kept as default (0)

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ddRAD-read.png?raw=true)

### Step 2:

- [0] [*assembly_name]: no change
- [1] [*project_dir]: no change
- [3] [barcodes_path]: no change
- [7] [*datatype]: no change
- [8] [restriction_overhang]: no change
- [9] [max_low_qual_bases]: keep default
- [16] [filter_adapters]: change to 2 (filters by quality and by sequencing error)
- [17] [filter_min_trim_len]: keep default
- [xx] [edit_cut_sites]: feature not available yet


The barcode file has a very simple layout. See the one I used [here]().

I subsampled my original dataset to provide 1000000 reads per sample for you. Let's take a look.
```
cd 
ls
gzless xx | head
```
Can you find the location of the restriction overhangs?


### Steps 34567. We will complete the remaining steps of the pipeline together.

Aside from the changes I made to the params file previously, make the following changes
- [11] [mindepth_statistical]: lower to 5 to obtain more loci
- [21] [max_SNPs_locus]: change to 4; lower number means more missing data but more loci recovered
- [25] [trim_reads]: # introduce before or after?
- [27] [output_formats]: add ', u'; this will provide an output selecting single SNPs from each locus randomly


#### finalized params file should look like this
```
------- ipyrad params file (v.0.7.1)--------------------------------------------
ddrad-v1        ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
./                             ## [1] [project_dir]: Project dir (made in curdir if not present)
                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
/path/to/ddRAD-ipyrad_barcodes.txt        ## [3] [barcodes_path]: Location of barcodes file
/path/to/ddRAD/reads/*.gz                 ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted fastq files
denovo                         ## [5] [assembly_method]: Assembly method (denovo, reference, denovo+reference, denovo-reference)
                               ## [6] [reference_sequence]: Location of reference sequence file
pairddrad                            ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
CATCG,AATT                         ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
5                              ## [9] [max_low_qual_bases]: Max low quality base calls (Q<20) in a read
33                             ## [10] [phred_Qscore_offset]: phred Q score offset (33 is default and very standard)
5                              ## [11] [mindepth_statistical]: Min depth for statistical base calling
5                              ## [12] [mindepth_majrule]: Min depth for majority-rule base calling
10000                          ## [13] [maxdepth]: Max cluster depth within samples
0.85                           ## [14] [clust_threshold]: Clustering threshold for de novo assembly
0                              ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
2                              ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
35                             ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                              ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
5, 5                           ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus (R1, R2)
8, 8                           ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus (R1, R2)
4                              ## [21] [min_samples_locus]: Min # samples per locus for output
20, 20                         ## [22] [max_SNPs_locus]: Max # SNPs per locus (R1, R2)
8, 8                           ## [23] [max_Indels_locus]: Max # of indels per locus (R1, R2)
0.5                            ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus (R1, R2)
0, 0, 15, 0                     ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                     ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
p, s, v, u                        ## [27] [output_formats]: Output formats (see docs)
                               ## [28] [pop_assign_file]: Path to population assignment file
```

Now you can run the pipeline, starting from Step 3, clustering! 
```
ipyrad -p params-ddrad-v1.txt -s 34567
```

Oops, what happened? Ipyrad requires that you run all steps, even if the data have been sorted. 
When reads are already demultiplexed, steps 1 and 2 read in the data.

```
ipyrad -p params-ddrad-v1.txt -s 1234567
```



############### run svdquartets, tetrad


>>> import ipyrad.analysis as ipa
>>> import ipyparallel as ipp
>>> import toytree

tet = ipa.tetrad(name='epi-dd-july15',seqfile='epi-dd-july14-trimloci.snps.phy',mapfile='epi-dd-july14-trimloci.snps.map',nboots=100)
loading seq array [12 taxa x 77966 bp]
max unlinked SNPs per quartet (nloci): 5183

# from command line
tetrad -n epi-dd-july14-subsample-trim15 -s epi-dd-july14-subsample-trim15.snps.phy -b 100 -l epi-dd-july14-subsample-trim15.snps.map -o analysis-tetrad -c 24


########### run raxml-ng

/home1/02576/rdtarvin/raxml-ng --msa epi-dd-july14-subsample-lm15-s7_outfiles/epi-dd-july14-subsample-lm15-s7.u.snps.phy --model GTR+G+ASC_LEWIS --search
((((Ebou_R0153:0.000001,Ebou_R0156:0.000001):0.000005,(((Ahah_R0090:0.000001,Ahah_R0089a:0.000001):0.000001,Ahah_R0089b:0.000001):0.000001,(Snub_R0158:0.000001,Snub_R0159:0.000001):0.000001):0.000001):0.000005,((Eant_T6859a:0.000001,Eant_T6859b:0.000001):0.000001,Eant_T6857:0.000001):0.000012):0.000008,Etri_T6842:0.000001,Etri_T6836:0.000001):0.0;


but there is a ton of missing data, especially in Ameerega
install: https://github.com/amkozlov/raxml-ng
manual ('wiki'): https://github.com/amkozlov/raxml-ng/wiki/Input-data#analysis-type


# good copy of results
epi-dd-july14-subsample-trim15_outfiles/

# with .u.snps.phy file
epi-dd-july14-subsample-lm15-s7_outfiles





### its a good idea to run on a range of [21] missing data and [14] clustering threshold. Graph results and then decide how to best move forward




This is the expected topology and estimated divergence.

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
   












