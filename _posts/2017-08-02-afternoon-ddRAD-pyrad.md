---
layout: default
order: 10
title:  "ddRAD data in ipyrad"
date:   2017-08-02
time:   "Afternoon"
categories: main
instructor: "Becca"
materials: files/fakefile.txt
material-type: ""
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
You may need to right click in order to paste
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

Because these loci are long, we can't finish this lesson in class. Instead, you can download the files from 
a finished run [here](). 

**Note**: If you need to rerun a step of iPyrad, you will have to add the force flag to your command, as such: `ipyard -p params-ddrad-v1.txt -s 1 -f`
<br>

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
## Downstream phylogenetic analyses


Estimate a **RAxML** tree with concatenated loci
```bash
# conda install raxml -c bioconda # already done
python
```
```python
import ipyrad.analysis as ipa
rax = ipa.raxml(data='ddrad-v1.phy',name='ddrad-v1',workdir='analysis-raxml')
```
```bash
# Or run it straight from the command line
/home1/02576/rdtarvin/raxml-ng --msa ddrad-v1_outfiles/ddrad-v1.u.snps.phy --model GTR+G+ASC_LEWIS --search
```

Estimate a quartets-based tree in **tetrad**, an ipython version of [SVDquartets](http://evomics.org/learning/phylogenetics/svdquartets/)

```python
import ipyrad.analysis as ipa
import toytree

tet = ipa.tetrad(name='ddrad-v1',seqfile='ddrad-v1.snps.phy',mapfile='ddrad-v1.snps.map',nboots=100)
loading seq array [12 taxa x 77966 bp]
max unlinked SNPs per quartet (nloci): 5183
```

```bash
# from command line
tetrad -n ddrad-v1 -s ddrad-v1.snps.phy -b 100 -l ddrad-v1.snps.map -o analysis-tetrad -c 24
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
   
**Challenge**
<details> 
  <summary>What's different between the expected tree and the tree we obtained? Why do you think that is?</summary>
   The branches in genus 3 are way longer than they should be. This is because there are relatively more
   loci recovered in these closely related lineages.
</details> 
 
How can we fix this issue?








<a href="https://rdtarvin.github.io/RADseq_Quito_2017/"><button>Home</button></a>    <a href="https://rdtarvin.github.io/RADseq_Quito_2017/main/2017/08/03/morning-ddrad-stacks.html"><button>Next Lesson</button></a>



