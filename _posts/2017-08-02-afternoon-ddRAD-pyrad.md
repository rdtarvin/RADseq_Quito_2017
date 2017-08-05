---
layout: default
order: 10
title:  "ddRAD Data in iPyrad"
date:   2017-08-02
time:   "Extra"
categories: main
instructor: "Becca"
materials: files/fakefile.txt
material-type: ""
lesson-type: Interactive
---

## WORKSHOP QUITO - DAY 3 <br>
### ddRAD data in ipyrad: from filtered data to phylogenies

These data are part of a pilot project comparing ddRAD and 2bRAD data (**do NOT distribute**).<br>
There are twelve samples from three genera, with at least two individuals sampled per genus, and two technical replicates.
We will use [iPyrad](http://ipyrad.readthedocs.io/index.html) for all steps of this assembly.<br><br><br>

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/basic-assembly-steps.png?raw=true)


Download data for this lesson
```
wget -O ddRAD-ipyrad.zip 'https://www.dropbox.com/s/9vd1eb3kkt0i0jk/ddRAD-ipyrad.zip?dl=1'
unzip ddRAD-ipyrad.zip
cd ddRAD-ipyrad
ls
```

### Step 0. Use fastqc to check read quality.
```
fastqc *.gz
sensible-browser <>.html
```

You might notice here that the reads in R2 files have pretty low quality for the last ~10 bases. This is pretty common for Illumina reads, and we will want to trim these before clustering loci.
<br>
When you're done looking at these files, move them to a new folder so they are out of the way.

### Step 1. Demultiplex in **iPyrad** [done]

First, use conda to install iPyrad and its dependencies

If you haven't followed the previous lesson, install ipyrad as below; otherwise, skip this step
```bash
conda install ipyrad -c ipyrad
# type 'y' when it asks to install dependencies
cp ~/Applications/miniconda2/bin/* ~/Applications/BioBuilds/bin/
```

Data have been demultiplexed previously so that they can be subsampled evenly across samples. 
This step is rather easy in ipyrad, it just requires filling in options for parameters 1-3 rather than 4.
Let's get you caught up - first make a new iPyrad params file and look at what's in it.

**Challenge**
<details> 
  <summary>How do you initiate a new ipyrad analysis with name 'ddrad-v1'? </summary>
   <code>ipyrad -n ddrad-v1</code>
</details><br>

```
## print file to screen
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

<a href="http://ipyrad.readthedocs.io/outline.html#demultiplexing-loading-fastq-files">![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ipyrad_step1-variables.png?raw=true)</a>

In step two, we use these parameters:

<a href="http://ipyrad.readthedocs.io/outline.html#filtering-editing-reads">![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ipyrad_step2-variables.png?raw=true)</a>

So, you can predict which parameters I have already altered for our data

### Step 1:
- `[0] [*assembly_name]`: default, created when ipython is initiated
- `[1] [*project_dir]`: keep in working directory, './'
- `[2] [raw_fastq_path]`: /path/to/raw/prefix*.gz (the *.gz must be included!!)
- `[3] [barcodes_path]`: /path/to/ddRAD-barcodes.txt
- `[4] [sorted_fastq_path]`: not changed if filtering in python; we will change in a moment
- `[7] [*datatype]`: pairddrad
- `[8] [restriction_overhang]`: changed to our restriction overhangs CATCG,AATT (see figure below)
- `[15] [max_barcode_mismatch]`: change to 1, as many barcodes have an 'N' at the second position

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/ddRAD-read.png?raw=true)

iPyrad has a very nice explanation of how to identify the restriction overhang sequences [here](http://ipyrad.readthedocs.io/parameters.html#restriction-overhang).

### Step 2:

- `[0] [*assembly_name]`: no change
- `[1] [*project_dir]`: no change
- `[3] [barcodes_path]`: no change
- `[7] [*datatype]`: no change
- `[8] [restriction_overhang]`: no change
- `[9] [max_low_qual_bases]`: keep default
- `[16] [filter_adapters]`: change to 2 (filters by quality and by sequencing error)
- `[17] [filter_min_trim_len]`: keep default
- `[xx] [edit_cut_sites]`: feature not available yet


The barcode file has a very simple layout. See the one I used [here](https://raw.githubusercontent.com/rdtarvin/RADseq_Quito_2017/master/files/ddRAD-ipyrad_barcodes.txt).
<br>

**TASK**: Copy this file (directly via wget or create a new file and insert the text). Save it as ddRAD-ipyrad_barcodes.txt

I subsampled my original dataset to provide 1000000 reads per sample for you. Let's take a look.


```bash
# use the -S option to prevent soft text wrap
zless -S sp1_ind1a_R1_.fastq.gz 

# try searching for a specific pattern in the file by typing
/AATT

# press the space bar to find the next instance of your search
# type 'q' to quit
```

**Challenge**
<details> 
  <summary>Can you find the location of the restriction overhangs? </summary>
   Recall what the sequence for the overhangs are (see picture above). Where should they be? **Hint**: 
   You should notice them even without knowing the sequence because they appear in every line and have the same sequence!
</details> 


### Steps 34567. We will complete the remaining steps of the pipeline together.

Aside from the changes I made to the params file previously, make the following changes
- `[11] [mindepth_statistical]`: lower to 5 to obtain more loci
- `[21] [max_SNPs_locus]`: change to 4; lower number means more missing data but more loci recovered
- `[25] [trim_reads]`: let's go ahead and trim the first 10 bases of R2, as they have pretty poor quality
- `[27] [output_formats]`: add ', u'; this will provide an output selecting single SNPs from each locus randomly


The finalized params file should look like this: <br>

```bash
------- ipyrad params file (v.0.7.1)--------------------------------------------
ddrad-v1        ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
./                             ## [1] [project_dir]: Project dir (made in curdir if not present)
                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
./ddRAD-ipyrad_barcodes.txt        ## [3] [barcodes_path]: Location of barcodes file
./*-1*.gz                 ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted fastq files
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
1                              ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
2                              ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
35                             ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                              ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
5, 5                           ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus (R1, R2)
8, 8                           ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus (R1, R2)
4                              ## [21] [min_samples_locus]: Min # samples per locus for output
20, 20                         ## [22] [max_SNPs_locus]: Max # SNPs per locus (R1, R2)
8, 8                           ## [23] [max_Indels_locus]: Max # of indels per locus (R1, R2)
0.5                            ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus (R1, R2)
0, 0, 10, 0                     ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                     ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
p, s, v, u                        ## [27] [output_formats]: Output formats (see docs)
                               ## [28] [pop_assign_file]: Path to population assignment file
```

Save with `ctrl+S`, and exit Atom.
Now you can run the pipeline, starting from Step 3, clustering! 
```bash
ipyrad -p params-ddrad-v1.txt -s 34567
```

Oops, what happened? iPyrad requires that you run all steps, even if the data have been sorted. 
When reads are already demultiplexed, steps 1 and 2 read in the data.

```bash
ipyrad -p params-ddrad-v1.txt -s 1234567
```

This might take a little while. To check on the results, you can open a new terminal window and type
```bash
ipyrad -p params-2brad-v1.txt -r

Summary stats of Assembly ddrad-v1
------------------------------------------------
           state  reads_raw
sp1_ind1a      1    1000000
sp1_ind1b      1    1000000
sp1_ind2       1    1000000
sp2_ind1       1    1000000
sp2_ind2       1    1000000
sp3_ind1       1    1000000
sp3_ind2       1    1000000
sp4_ind1       1    1000000
sp4_ind2a      1    1000000
sp4_ind2b      1    1000000
sp5_ind1       1    1000000
sp5_ind2       1    1000000


Full stats files
------------------------------------------------
step 1: ./ddrad-v1_s1_demultiplex_stats.txt
step 2: None
step 3: None
step 4: None
step 5: None
step 6: None
step 7: None
```

You'll notice that the program has finished the first step, which was simply to read in the reads. You can see there are 1000000 per sample.
Once step 3 starts, you can run the same command, and you'll see that there is another column now from Step 2 and that
we can find more stats for Step 2 in the file `./ddrad-v1_edits/s2_rawedit_stats.txt`. Let's take a look.

```bash
# use -S option to avoid text wrapping
less -S ./ddrad-v1_edits/s2_rawedit_stats.txt 

reads_raw  trim_adapter_bp_read1  trim_adapter_bp_read2  trim_quality_bp_read1  trim_quality_bp_read2  reads_filtered_by_Ns  reads_filtered_by_minlen  reads_passed_filter
sp1_ind1a    1000000                  21164                  27297                1047173                2749515                    19                      5130               994851
sp1_ind1b    1000000                  20981                  27563                1011094                2718923                    28                      5142               994830
sp1_ind2     1000000                  21292                  27309                1019379                2757645                    23                      5202               994775
sp2_ind1     1000000                  29241                  21441                1119683                2611745                    24                      4785               995191
sp2_ind2     1000000                  28364                  21249                1162015                2638046                    25                      4572               995403
sp3_ind1     1000000                  25737                  20268                 640502                2526122                    26                      4513               995461
sp3_ind2     1000000                  26722                  20481                 670498                2451657                    21                      4309               995670
sp4_ind1     1000000                  27431                  28673                 689969                2525972                    28                      4505               995467
sp4_ind2a    1000000                  28315                  28325                 665626                2427105                    20                      4281               995699
sp4_ind2b    1000000                  28130                  28646                 698904                2467419                    23                      4186               995791
sp5_ind1     1000000                  25260                  24428                 644703                2393125                    14                      4330               995656
sp5_ind2     1000000                  25906                  24379                 667064                2410386                    31                      4422               995547
```

What do the reads look like during step 2?

```bash
zcat gen1_sp1-1a.trimmed_R1_.fastq.gz | head
@K00179:78:HJ2KFBBXX:5:2215:23754:4075 1:N:0:TGACCA+AGATCT
CATGCCCTATGCGGCGCAGCAGCGATGCTGTGGGCGACCTGAGAGCCCTATGTCCAGAATGGCAGATCGCACAAAATACATCGCTGAGCTCCTGTCACACGCAGCGATGCACACTTTGCCACACCCAAATATTGTCGGTGAAATG
+
JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJFJJJJJJJJJJJJFJJJ
@K00179:78:HJ2KFBBXX:5:2215:5994:4110 1:N:0:TGACCA+AGATCT
CATGCAAAAGAAGCACAGATGAAACTATTGTGTTTGGAACACTACATAGTAAAAATGGATGTCAATGTTACCTTTTCAAATGGATGCCACTGTTACGCTTACATTATGCTTTAGTAAAGAGATATGTTTTATTTACATTCTCCTC
+
JFJJFFJJJJJJJJJJJJJJJJFJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ<FJJJFFFJFFJJJJFFJJJFJJJFJJJJJJJJJJFJJJJJJJ-AAFFJJ<F7
@K00179:78:HJ2KFBBXX:5:2215:22272:4110 1:N:0:TGACCA+AGATCT
CATGCATACTGAGGATGGGAGATAAATGGGCCATGCATACTGGGAATGAGGGATGAAGGGGTCTTGCATACTGGGATTAGGGGATGAAGGGGGCTTGCATACTGGGATTGGGGGTTGAAGGGGCCATGCATACTGAGATTGGGGG
```

Because these loci are long, we can't finish this lesson in class. Instead, you can download the files from 
a finished run [here](https://www.dropbox.com/s/tqr7gusl6godhkt/ddRAD-ipyrad-full-run.zip?dl=1). 

**Note**: If you need to rerun a step of iPyrad, you will have to add the force flag to your command, as such: `ipyard -p params-ddrad-v1.txt -s 1 -f`
<br>

Let's look at the intermediate and final files created by iPyrad.

iPyrad: Step 3. Clusters reads within individuals.
---

```bash
cd ../ddrad-v1_clust_0.85/
ls
cat s3_cluster_stats.txt
            clusters_total  hidepth_min clusters_hidepth avg_depth_total avg_depth_mj avg_depth_stat sd_depth_total sd_depth_mj sd_depth_stat filtered_bad_align
gen1_sp1-1a         323186          5.0            33040            2.57        13.72          13.72          17.82       54.44         54.44                  0
gen1_sp1-1b         342560          5.0            32181            2.44        13.45          13.45          16.76       53.39         53.39                  0
gen2_sp1-1          288330          5.0            31997            2.87        15.42          15.42          17.73       51.51         51.51                  0
gen3_sp1-1          262801          5.0            32517            2.91        14.02          14.02          22.58       63.07         63.07                  0
gen3_sp2-1          312096          5.0            33276            2.61        13.67          13.67          17.82       53.28         53.28                  0
gen3_sp3-1          304184          5.0            31472            2.58        13.86          13.86          38.85      120.18        120.18                  0
```
You can use this file to see the coverage of your sequences. `avg_depth_total` shows us that the coverage is between 2x and 3x for the samples,
but that when we remove clusters with coverage less than 4 (the value we set for `[21] [min_samples_locus]`), average coverage is actually 13-15x.
What do you think this means about the distribution of sequenced loci across individuals?
<br><br>

iPyrad: Step 4. Jointly estimates heterozygosity and error in the clusters from step 3.
---

```bash
cat s4_joint_estimate.txt
             hetero_est  error_est
gen1_sp1-1a    0.015128   0.007712
gen1_sp1-1b    0.015559   0.007736
gen2_sp1-1     0.012305   0.005440
gen3_sp1-1     0.013777   0.006523
gen3_sp2-1     0.014627   0.005991
gen3_sp3-1     0.013499   0.006250
```
What do the files from this step look like?

```bash
zcat gen1_sp1-1a.clustS.gz | head -50
000090680864c279b2240fe768e0ef34;size=3;*
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACCGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGATCCCCTGCAAAAAAATT
3988a1c5cae1a90d513652f8fa10406f;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACCGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnn-CTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGATCCCCTGCAAAAAAATT
0f50b9f093970c45541c8a72f33d8ee0;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACTGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGATCCCCTGCAAAAAAATT
f3b6a6f2fb8d7ad8adc7d3b9ee28a14b;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACCGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnn-CTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCATGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGATAAAATG-AAAAAAATT
2545f24fa60797fd70ed4adf70691183;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACCGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGATGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGAACCACTGCAAAAAAATT
3441a398f75bfe976e0aff67d43f8385;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACTGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnn-CTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGAAAAAAAAAAAAAAAATT
eddd4540630243f88d1ebb6a605690f0;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACCGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGACAGAGCCTGTGCAAAAAGATAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGATCCCCTGCAAAAAAATT
792518114f1d9659d9a1bebc268cacd2;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACCGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGATCCCATGCAAAAAAATT
705a34b3900e38757d87723c26c67b2d;size=1;+
-ATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACTGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTAAACAAAAAAAAAAAAATT
05e508bfba224becce43ee82310e82e0;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACTGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATGGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGAAAAACTAAAAAAAAATT
b6f6e4f471afff4a809d7e1750f6742d;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACTGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnn-CTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGGAGCTGTAGTCTCATCCGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCCTGATAAAAAAAAAAAAAATT
4668b45b12511be953f979c6c647df78;size=1;+
CATGCAGACAGAAATACCAGTGTGAAAGCAGCCTTAGATCGATACCACCAGTCAGAGAGCTGCAGGATCACCCTGTCACATGTCAGTGACAGTGACTCAGGTAAAAAGCTTACTGGGGTCATAGGTGCCAGCAGATGGGACTACTnnnnCCTGTCATTATACACAGCAGTGCAGGTATTGACGGATGGAAGCTGTAGTCTCATCAGCCAGAGCCTGTGCTCAAAGTTAAAAAAATAAAATAAAACATTATACTCATCTCCACCTTGTCATAAAAAAAAAAAAAAAAATT
//
//
00009ed9f55b3614b9b8ca94783853ef;size=9;*
CATGCTATGCACGCCTGGGGCGACCACACTCCCTTTGGGGGGCAAAGAATAACTTTCCTCTCCTGGCGATACCCTGCAAGTCTTCTGGTGAAGGTGACAGTCAGGAGCCACAGTCCATGTCTGTTGCCGGAAGTGGAGCAGCAGGnnnnATGAGCGCCGCCACTGCTGGTGGTGCAATAAATATTTATTGCAATCTGGCCATGGACCTCCCCCAAGTTTTGGGCCTCGGGTTTTAGCCCAGATTGCCCTCATTATAAGCCACCCTTGTTGGTAATGGTATTAGTAAATT
a9161ea587c28d5c550dd9205a6bf1c0;size=1;+
CATGCTATGCACGCCTGGGGCGACCACACTCCCTTTGGGGGGCAAAGAATAACTTTCCTCTCCTGGCGATACCCTGCAAGTCTTCTGGTGAAGGTGACAGTCAGGAGCCACAGTCCATGTCTGTTGCCGGAAGTGGAGCAGCAGGnnnn-TGAGCGCCGCCACTGCTGGTGGTGCAATAAGTATTTATTGCAATCTGGCCATGGACCTCCCCCAAGTTTTGGGCCTCGGGTTTTAGCCCAGATTGCCCTCATTATAAGCCACCCTTGTTGGTAATGGTATTAGTAAATT
f4fdfd7f249d78e59b815c4f830357ef;size=1;+
CATGCTATGCACGCCTGGGGCGACCACACTCCCTTTGGGGGGCAAAGAATAACTTTCCTCTCCTGGCGATACCCTGCAAGTCTTCTGGTGAAGGTGACAGTCAGGAGCCACAGTCCATGTCTGTTGCCGGAAGTGGAGCAGCAGGnnnnATCAGCGCCGCCACTGCGGGTGGTGCAATAAATATTTATTGCAATCTGGCCATGGACCTCCCCCAAGTTTTGGGCCTCGGGTTTTAGCCCAGATTGCCCTCATTATAAGCCACCCTTGTTGGTAATGGTATTAGTAAATT
//
//
00022aaab1016af7353f8dce5ee82b17;size=1;*
CATGCGCGCTTAACAGCGCTGCTCAAAGAAAAAAAAAAAAAGAGAAACTTACATTTAAATCCGTGGGCGNNNNAGTCGCATGTTATGTGTGGCTGTGCTAAACATGGGATCTTCGTGGGACAATCGCATTTTTGGACTCTGCGAAGGGTAGGTATATTTTGTGGTTTGTTATCTTTACTTTTATTTCAGGTGAACGAGGGCTTCGGGGAATT
9999c084689c3571ce13d6b741efd92e;size=1;+
------------------------------------------------------------------------------CATGCTATATGCGGCTGTGCTAAACATTAGATCTTCGTGGGACACTCGCATTTTTGGGCTCTGCGGACTGTAGGTATATTTTGTGGTTTGTTATTTTTACTTTTATTTCAGGTGAACGAGGTCTTCGGGGAATT
//
//
0002401a00fb03bf5d8d3b1bdbccace3;size=1;*
CATGCGTATGCGTGCGTCCCTGCGCACCATAAGCTTTCATTGTAAATGCAATGCCTTTATTAGGCCGGCGTTTGTCTGCGTTTGCGTATGGGTGCGTCGTTTAGACGCCCCGAAAAGTACAAATTCCCCGAAGCCGTCGTTCCCCnnnn--CAAACCACAAAATATACCTACCCTCCACAGAGTCCAAAAATGCGATTGTCCCACGAAGATCTAATGTTTAGGACAGCTGCATAACATGCGACTGTCCTAAGCAACTCCCGACGCTACAATGAGCGGAGCCGTAAATT
3c2d049810319a1971264c1de1fb2aa8;size=1;+
CATGCGTATGCGTGCGTCCCTGCGCACCATAAGCTTTCATTGTAAATGCAATGCCTTTATTAGGCCGGCGTTTGTCTGCGTTTGCGTATGGGTGCGTCGTTTAGACGCCCCGAAAAGTACAAATTCCCCGAAGCCGTCGTTCCCCnnnnAACAAACCACAAAATATACCTACCCTCCACAGAGTCCAAAAATGCGATTGTCCCACGAAGATCTAATGTTTAGGACAGCTGCATAACATGCGACTGTCCTAAGCAACTCCCGACGCTACAATGAGCGGAGCCGTAAATT
//
//
```
The first cluster looks like some kind of messy error. Any idea what it might be? It could be some PCR-related
error, where the Taq slipped. It could also be a region of the genome that occurs in various places (i.e.,
transposon or repeat region). The second cluster looks like it is homozygous with two erroneous reads. The third
and fourth clusters don't have enough information to judge. The '+' and '-' indicate whether the reads are reverse complemented.
<br><br>

iPyrad: Step 5. Uses the estimates from step 4 and filters the clusters.
---

```bash
cd ../ddrad-v1_consens/
ls
cat s5_consens_stats.txt 

            clusters_total filtered_by_depth filtered_by_maxH filtered_by_maxN reads_consens  nsites nhetero heterozygosity
gen1_sp1-1a         323186            290146             2233             2951         27856 8018867   26210        0.00327
gen1_sp1-1b         342560            310379             2228             2994         26959 7760839   25176        0.00324
gen2_sp1-1          288330            256333             1529             2199         28269 8140290   24631        0.00303
gen3_sp1-1          262801            230284             1560             2298         28659 8257072   33638        0.00407
gen3_sp2-1          312096            278820             1629             2579         29068 8388447   42020        0.00501
gen3_sp3-1          304184            272713             1595             2300         27576 7953497   33488        0.00421
```

Here we get a more accurate measurement of heterozygosity (i.e., with errors removed). You can note that many 
clusters were removed from having too many Ns or too many heterozygous sites. Also note the number of clusters - 
~300,000 - pretty close to our estimated number of sites in 1% of a 9GB genome! Do you recall the calculation? 
[(9,000,000,000 x 0.001)/275]
<br><br>

iPyrad: Step 6. Cluster loci among individuals.
---

```bash
cat s6_cluster_stats.txt  
vsearch v2.0.3_linux_x86_64, 3.9GB RAM, 1 cores
/home/user1/Applications/BioBuilds/lib/python2.7/site-packages/bin/vsearch-linux-x86_64 -cluster_smallmem /home/user1/workshop-test/ddrad-v1_consens/ddrad-v1_catshuf.tmp -strand plus -query_cov 0.75 -minsl 0.5 -id 0.85 -userout /home/user1/workshop-test/ddrad-v1_consens/ddrad-v1.utemp -notmatched /home/user1/workshop-test/ddrad-v1_consens/ddrad-v1.htemp -userfields query+target+qstrand -maxaccepts 1 -maxrejects 0 -fasta_width 0 -threads 0 -fulldp -usersort -log /home/user1/workshop-test/ddrad-v1_consens/s6_cluster_stats.txt 
Started  Sat Jul 29 09:45:25 201748519012 nt in 168387 seqs, min 35, max 327, avg 288


      Alphabet  nt
    Word width  8
     Word ones  8
        Spaced  No
        Hashed  No
         Coded  No
       Stepped  No
         Slots  65536 (65.5k)
       DBAccel  100%

Clusters: 129233 Size min 1, max 17, avg 1.3
Singletons: 95553, 56.7% of seqs, 73.9% of clusters


Finished Sat Jul 29 10:02:32 2017
Elapsed time 17:07
Max memory 256.2MB
```


Of all this output, probably the only thing we are interested in is the number of clusters and singletons (i.e., clusters with only one read).
There are a number of other files produced during this step as part of the clustering process:
- *.consens.gz are consensus reads for each individual
- ddrad-v1_catclust.gz contains the clusters created across individuals.
- *.catg are arrays used to estimate the clusters
- ddrad-v1.utemp.sort is a table used to sort the reads
<br><br>

iPyrad: Step 7. Filters the data and creates all the final output files.
---

```bash
cd ../ddrad-v1_outfiles/
ls
head -30 ddrad-v1.loci | cut -c -150 # cut shows only the first 150 characters of the locus
gen1_sp1-1a     CTTGAAGACCAGGTGGACCTTGAGCACCATTTGGACCAGTTGGGCCACCAGCACCCTACAAGGCATATACATGATACATAACTAAAAAGTTCAAACATTTTGTTAGGCCATGCATACTGACATCTCTAGAAATA
gen1_sp1-1b     CTTGAAGACCAGGTGGACCTTGAGCACCATTTGGACCAGTTGGGCCACCAGCACCCTACAAGGCATATACATGATACATAACTAAAAAGTTCAAACATTTTGTTAGGCCATGCATACTGACATCTCTAGAAATA
gen2_sp1-1      CTTGAAGACCAGGTGGACCTTGAGCACCATTTGGACCAGATGGGCCACCAGCACCCTACAAAGCGTATRCATGACACATAACCAAAAAGTTCAAACACATTGTTAGGCCWTGCATACCGGCATCTCTAGAAATA
gen3_sp1-1      CTTGAAGACCAGGTGGACCTTGAGCACCATTTGGACCAGATGGGCCACCAGCACCCTACAAAGCATATGCATGACACATAACCAAAAAGTTCAAACACATTGTTAGGCCATGCATACTGGCATCTCTAGAAATA
gen3_sp3-1      CTTGAAGACCAGGTGGACCTTGAGCACCATTTGGACCAGATGGGCCACCAGCACCCTACAAAGCGTATACATGACACATAACCAAAAAGTTCAAACACATTGTTGGGCCATGCATACCGGCATCTCTAGAAATA
//                                                     *                     *  *   *     *       *              **     -    -       * *              
gen1_sp1-1a     TGTACAGAGGTAATGGAGGCAGCAGATACTGGGGTTGGTGCTTGCTGAATATGTATAGGCTGGAGGGTTGGTGTAGCAGGCTGCAAGGCCTGGGGAATAGCTCCGGCTGGGAAGTTCTTCACTTGCTTGGCTAG
gen1_sp1-1b     TGTACAGAGGTAATGGAGGCAGCAGATACTGGGGTTGGTGCTTGCTGAATATGTATAGGCTGGAGGGTTGGTGTAGCAGGCTGCAAGGCCTGGGGAATAGCTCCGGCTGGGAAGTTCTTCACTTGCTTGGCTAG
gen2_sp1-1      TGTACAGTGGTAATGGAGGCAGCAGATACTGGAGTTGGAGCTTGCTGAATATGTATAGGCTGCAGGGTTTGTGTAACAGGCTGCAATGCTTGGGGGATAAGTCCGGCTGGGAAGTTCTTAACTTGTTTGGCTAG
gen3_sp1-1      TGTACAGTGGTAATGGAGGCAGCAGATACTGGAGTTGGAGCTTGCTGAATATGTATAGGCTGCAGGGTTGGTGTAATAGGCTGCAGGGCTTGGGGGATAGCTCCAGCTGGGAAGTTCTTAACTTGCTTGGCTAG
gen3_sp2-1      TGTACAGTGGTAATGGAGGCAGCAGATACTGGAGTTGGAGCTTGCTGAATATGTATAGGCTGCAGGGTTTGTGTAACAGGCTGCAGGGCTTGGGGGATAGCTCCGGCTGGGAAGTTCTTAACTTGCTTGGCTAG
gen3_sp3-1      TGTACAGTGGTAATGGAGGCAGCAGATACTGGAGTTGGAGCTTGCTGAATATGTATAGGCTGCAGGGTTGGTGTAACAGGCTGCAGGGCTTGGGGGATAGCTCCGGCTGGGAAGTTCTTAACTTGCTTGGCTAG
//                     *                        *     *                       *      *     *-        *-  *     *   --   -              *     -        
gen1_sp1-1a     CTCCGAATCTGCAAGTTTCACATTTTTANCTGTTTCTAGGAGGTCGTCTCCATCACAATCGATNGTGATGGCATCTTCAGCCTGGAGTGTGACAGATACATTGTCGTCCTCTACTTTCTTCAGANAAGTGCTAG
gen1_sp1-1b     CTCCGAATCTGCAAGTTTCACATTTTTACCTGTTTCTAGGAGGTCGTCTCCATCACAATCGATAGTGATGGCATCTTCAGCCTGGAGTGTGACAGATACATNGTCGTCCTCTACTTTCTTCAGAGAAGTGCTAG
gen3_sp1-1      CTCCGAATCTGCAAGTTTCATATTTTTACCTGTTTCTAGGAGGTCGTCTCCATCACAATCGATAGTGATGGCATCTTCAGCCTGGAGTGTGACAGATACGTTATCATCCTCTACTTCTTTCAGAGAACTGCTAG
gen3_sp2-1      CTCCGAATCTGCAAGTTTCATATTTTTACCTGTTTCTAGGAGGTCGTCTCCATCACAATCGATAGTGATGGCATCTTCAGCCTGGAGTGTGACAGATACGTTATCGTCCTCTACTTCTTTCAGAGAAGTGCTAG
gen3_sp3-1      CTCCGAATCTGCAAGTTTCATATTTTTACCTGTTTCTAGGAGGTCGTCTCCATCACAATCGATAGTGATGGCATCTTCAGCCTGGAGTGTGACAGATACGTTATCGTCCTCTACTTCTTTCAGAGAAGTGCTAG
//                                  *                                                                              *  *  -          **         -      
gen1_sp1-1a     AGGAAGGAGAAGTGGCTACGAGGGGNATAGGTATTGTAGTCAGTCAATCATGATTAGAGCAGAGGGATTATCAAGGGAAGTATTTGAAGACCAGGTTATAGACGTAACAAAGGCCAACATGATAAAATGATGCA
gen1_sp1-1b     AGGAAGGAGAAGTGGCTACGAGGGGCATAGGTATTGTAGTCAGTCAATCATGATTAGAGCAGAGGGATTATCAAGGGAAGTATTTGAAGACCAGGTTATAGACGTAACAAAGGCCAACATGATAAAATGATGCA
gen3_sp1-1      AGGAAGGAGTGGTGGCTACGAGGAGGATAGGTATTGT----AGTCAATCATGATTAGAGCAGAGGGATTATCAAGGGAAGCATTTGAAGACCAGGTTATAGAAGTAGCAAAGGCCAATATGATAAAATAATGCA
gen3_sp2-1      AGGAAGGAGAGGTGGCTACGAGGAGGATAGGTATTGT----AGTCAATCATGATTAGAGCAGAGGGATTATCAAGGGAAGCATTTGAAGACCAGGTTATAGAAGTAGCAAAGGCCAACATGATAAAATGATGCA
gen3_sp3-1      AGGAAGGAGAGGTGGCTACGAGGAGGATAGGTATTGT----AGTCAATCATGATTAGAGCAGAGGGATTATCAAGGGAAGCATTTGAAGACCAGGCTATAGAAGTAGCAAAGGCCAACATGATAAAATGATGCA
//                       -*            * -                                                      *              -      *   *          -          -     
```

The `.loci` format is unique to iPyrad and is a nice visualization of the final loci.
`-` denotes variable sites; `*` denotes phylogenetically informative sites. Here you can see
that in the fourth locus there was an insertion og AGTC in genus 1 (or a deletion in genus 3).


<br><br><br>
## Downstream phylogenetic analyses


Estimate a **RAxML** tree with concatenated loci
```bash
# conda install raxml -c bioconda # already done
cd ddrad-v1_outfiles/
python
```
```python
import ipyrad.analysis as ipa
rax = ipa.raxml(data='ddrad-v1.phy',name='ddrad-v1',workdir='analysis-raxml')
rax.command # type to see the command
rax.run(force=True)
.
.
.
from Bio import Phylo
tree = Phylo.read('analysis-raxml/ddrad-v1.tree', 'newick')
tree.root_at_midpoint()
Phylo.draw(tree) # is ultrametric
quit()
```
Estimate a **RAxML-ng** tree with unique SNPs from each locus

```bash
$HOME/Applications/raxml-ng --msa ddrad-v1.u.snps.phy --model GTR+G+ASC_LEWIS --search
python
```
```python
from Bio import Phylo
tree = Phylo.read('ddrad-v1.u.snps.phy.raxml.bestTree', 'newick')
# tree.root_at_midpoint()
Phylo.draw(tree)
quit()
```

Estimate a quartets-based tree in **tetrad**, an ipython version of [SVDquartets](http://evomics.org/learning/phylogenetics/svdquartets/)

```bash
# Run directly from the command line
tetrad -n ddrad-v1 -s ddrad-v1.snps.phy -l ddrad-v1.snps.map -o analysis-tetrad
# add -b 100 for bootstrapping
# some errors may occur, but don't worry, the output is still good

python
```

```python
from Bio import Phylo
tree = Phylo.read('analysis-tetrad/ddrad-v1.tree', 'newick')
Phylo.draw(tree) # is ultrametric
quit()
```



This is the expected topology and estimated divergence timing.

```
        ___________________gen1_sp1
       |   
-25my--|          _________gen2_sp1
       |____15my_|
                 |      ___gen3_sp1
                 |_5my_|  
                       |  _gen3_sp2
                       |_|
                         |_gen3_sp3
                                                  
```


A full run of these analyses can be downloaded [here](https://www.dropbox.com/s/tqr7gusl6godhkt/ddRAD-ipyrad-full-run.zip?dl=1)



<a href="https://rdtarvin.github.io/RADseq_Quito_2017/"><button>Home</button></a>    <a href="https://rdtarvin.github.io/RADseq_Quito_2017/main/2017/08/03/afternoon-ddrad-stacks.html"><button>Next Lesson</button></a>



