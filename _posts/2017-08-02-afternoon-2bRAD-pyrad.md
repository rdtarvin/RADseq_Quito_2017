---
layout: default
order: 8
title:  "2bRAD data pipeline"
date:   2017-08-02
time:   "Afternoon"
categories: main
instructor: "Becca"
materials: files/fakefile.txt
material-type: ""
---

## WORKSHOP QUITO - DAY 3 
### 2bRAD data mixed pipeline: from raw reads to phylogenies


These data are part of a pilot project comparing ddRAD and 2bRAD data (**do NOT distribute**).<br>
There are twelve samples from three genera, with at least two individuals sampled per genus, and two technical replicates. 

### Download data for this lesson
```bash
cd # go to root of file system
mkdir workshop 
cd workshop
# use ctrl+shift+v to paste within the VM
wget -O 2bRAD.zip 'https://www.dropbox.com/sh/z2l0w2dq89oo55i/AAD_29lBe0MvLYLdxDB4Vm-2a?dl=1'
# wget is a way to transfer files using a url from the command line
# -O option makes sure the download doesn't have a wonky name like AAD_29lBe0MvLYLdxDB4Vm-2a
```

### Looking at your raw data in the linux environment

Your files will likely be gzipped and with the file extension **.fq.gz** or **fastq.gz**. The first thing you want to do is look at the beginning of your files while they are still gzipped.

```bash
ls # list all files in current directory
ls .. # list all files in one directory above
unzip 2bRAD.zip
cd 2bRAD
ls -lht # view all files with details and in order by when they were modified, with human-readable file sizes
rm 2bRAD.zip # IMPORTANT: removing files from the command line is permanent!!!! There is no trash
zless T36R59_I93_S27_L006_R1_sub12M.fastq.gz # press 'q' to exit
```

```bash
head T36R59_I93_S27_L006_R1_sub12M.fastq
```

This is the fastq format, which has four lines. 

```bash
@K00179:73:HJCTJBBXX:6:1101:25905:1226 1:N:0:TGTTAG 
TNGACCAACTGTGGTGTCGCACTCACTTCGCTGCTCCTCAGGAGACAGAT 
+ 
A!AFFJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 

# sequencer name:run ID:flowcell ID:flowcell lane:tile number in flow cell:x-coordinate of cluster :y-coordinate pair member:filtered?:control data:index sequence
# DNA sequence
# separator, can also sometimes (not often) hold extra information about the read
# quality score for each base
```

Ok, now lets look at the full file:

```bash
cat T36R59_I93_S27_L006_R1_sub12M.fastq
```

Uh oh... let's quit before the computer crashes... it's too much to look at! `Ctrl+C`<br><br>
This is the essential computational problem with NGS data that is so hard to get over. You can't
open a file in its entirety! Here are some alternative ways to view parts of a file at a time.

```bash
# print the first 10 lines of a file
head T36R59_I93_S27_L006_R1_sub12M.fastq 

# print the first 20 lines of a file
head -20 T36R59_I93_S27_L006_R1_sub12M.fastq # '-20' is an argument for the 'head' program

# print lines 190-200 of a file
head -200 T36R59_I93_S27_L006_R1_sub12M.fastq | tail # 'pipes' the first 200 lines to a program called tail, which prints the last 10 lines

# view the file interactively
less T36R59_I93_S27_L006_R1_sub12M.fastq # can scroll through file with cursor, page with spacebar; quit with 'q'
# NOTE: here we can use less because the file is not in gzipped (remember that required the 'zless' command)

# open up manual for less program
man less # press q to quit

# print only the first 10 lines and only the first 30 characters of each line
head -200 T36R59_I93_S27_L006_R1_sub12M.fastq | cut -c -30 

# count the number of lines in the file
wc -l T36R59_I93_S27_L006_R1_sub12M.fastq # (this takes a moment because the file is large)

# print lines with AAAAA in them
grep 'AAAAA' T36R59_I93_S27_L006_R1_sub12M.fastq # ctrl+c to exit

# count lines with AAAAA in them
grep -c 'AAAAA' T36R59_I93_S27_L006_R1_sub12M.fastq 

# save lines with AAAAA in them as a separate file
grep 'AAAAA' T36R59_I93_S27_L006_R1_sub12M.fastq > AAAAA # no file extensions necessary!!

# add lines with TTTTT to the AAAAA file: '>' writes or overwrites file; '>>' writes or appends to file
grep 'TTTTT' T36R59_I93_S27_L006_R1_sub12M.fastq >> AAAAA 

# print lines with aaaaa in them
grep 'aaaaa' T36R59_I93_S27_L006_R1_sub12M.fastq 
# why doesn't this produce any output?

# count number of uniq sequences in file with pattern 'AGAT'
grep 'AGAT' T36R59_I93_S27_L006_R1_sub12M.fastq | sort | uniq | wc -l

# print only the second field of the sequence information line
head T36R59_I93_S27_L006_R1_sub12M.fastq | grep '@' | awk -F':' '{ print $2 }' 
# awk is a very useful program for parsing files; here ':' is the delimiter, $2 is the column location
```


**Challenge**
<details> 
  <summary>How would you count the number of reads in your file? </summary>
   There are lots of answers for this one. One example: in the fastq format, the character '@' occurs once per sequence, so we can just count how many lines contain '@'.<br> 
   <code>grep -c '@' T36R59_I93_S27_L006_R1_sub12M.fastq</code>
</details> 



# Assembling 2bRAD data using iPyrad

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/basic-assembly-steps.png?raw=true)<br>

In this workflow, we will use the [2bRAD native pipeline](https://github.com/z0on/2bRAD_denovo) for filtering and trimming, 
[fastx-toolkit](http://hannonlab.cshl.edu/fastx_toolkit/) for quality control, 
and then [iPyrad](http://ipyrad.readthedocs.io/index.html) for the rest of the assembly.<br><br>

Step 0. Use fastqc to check read quality.
---

```bash
# fastqc is already installed, but if you wanted to download it, this is how: 
# wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
# unzip fastqc_v0.11.5.zip

# let's take a look at fastqc options
fastqc -h
fastqc *.fastq
```

When the program is finished, take a look at what files are in the directory using `ls`.
fastqc produces a nice .html file that can be viewed in any browser. 
Since we are trying to get comfortable with the command line, let's open the file directly.

```bash
sensible-browser T36R59_I93_S27_L006_R1_sub12M.fastq
```

Sequencing quality scores, "Q", run from 20 to 40. In the fastq file, these are seen as ASCII characters. 
The values are log-scaled: 20 = 1/100 errors; 30 = 1/1000 errors. Anything below 20 is garbage and anything between 20 and 30 should be reviewed.
There appear to be errors in the kmer content, but really these are just showing where the barcodes and restriction enzyme sites are. 
Let's take a look at what 2bRAD reads look like:

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/2bRAD-read.png?raw=true)

Ok, we can see that overall our data are of high quality (high Q scores, no weird tile patterns, no adaptor contamination). Time to move on to the assembly!!

Step 1. Demultiplex by barcode in **2bRAD native pipeline**
---

Copy scripts to your virtual machine Applications folder via git
```bash
cd ~/Applications
git clone https://github.com/z0on/2bRAD_denovo.git
ls
cd ../workshop/2bRAD/
```
Git is an important programming tool that allows developers to trace changes made in code. Let's take a look online.
```bash
sensible-browser https://github.com/z0on/2bRAD_denovo
```

Okay, before we start the pipeine let's move our fastqc files to their own directory
```bash
mkdir 2bRAD_fastqc
mv *fastqc* 2bRAD_fastqc # shows error stating that the folder couldn't be moved into the folder
ls # check that everything was moved
```

First we need to concatenate data that were run on multiple lanes.
- T36R59_I93_S27_L00**6**_R1_001.fastq and T36R59_I93_S27_L00**7**_R1_001.fastq
- pattern "T36R59_I93_S27_L00" is common to both read files; program concatenates into one file with (.+) saved as file name

```bash
~/Applications/2bRAD_denovo/ngs_concat.pl fastq "(.+)_S27_L00" # this takes a few minutes so let's take a quick break while it does its thing.
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

Now that our read files are concatenated, we need to separate our reads by barcode. 
Let's take a look again at the structure of a 2bRAD read.<br>

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/2bRAD-read.png?raw=true)


From the 2bRAD native pipeline we will use ```trim2bRAD_2barcodes_dedup2.pl``` script to separate by barcode. 
If your data are not from HiSeq4000 you would use ```trim2bRAD_2barcodes_dedup.pl```. This takes <10 min
```bash
# adaptor is the last 4 characters of the reads, here 'AGAT'
perl ~/Applications/2bRAD_denovo/trim2bRAD_2barcodes_dedup2.pl input=T36R59_I93.fq adaptor=AGAT sampleID=1
.
.
.
T36R59_ACCA: goods: 295784 ; dups: 1178405
T36R59_AGAC: goods: 260575 ; dups: 987301
T36R59_AGTG: goods: 325595 ; dups: 956574
T36R59_CATC: goods: 432507 ; dups: 1732082
T36R59_CTAC: goods: 311897 ; dups: 1837423
T36R59_GACT: goods: 322958 ; dups: 1877945
T36R59_GCTT: goods: 266101 ; dups: 1040723
T36R59_GTGA: goods: 483664 ; dups: 1871167
T36R59_GTGT: goods: 328948 ; dups: 1298015
T36R59_TCAC: goods: 274208 ; dups: 1494727
T36R59_TCAG: goods: 309572 ; dups: 1109505
T36R59_TGTC: goods: 310155 ; dups: 1800440

T36R59: total goods : 3921964 ; total dups : 17184307

```

You can see that there are a ton of duplicate reads in these files. This is OK and means that you have high 
coverage across loci. Don't confuse these duplicates with PCR duplicates, which may be a source of error (more on this later).

```bash
ls
```

Now you can see that the demultiplexed and deduplicated files are listed by barcode and have the file extension **.tr0**.


Step 2. Filter reads by quality with a program from the **fastx_toolkit**
---

```bash
fastq_quality_filter -h

# Use typical filter values, i.e., 90% of bases in a read should have a q-value aboce 20
# This is a for loop, which allows you to execute the same command with arguments across multiple files
# The 'i' variable is a place holder 
for i in ls *.tr0; do fastq_quality_filter -i $i -q 20 -p 90 > ${i}_R1_.trim; done

# zip the files to save space
for i in *.trim; do gzip ${i}; done

# a note: ipyrad expects '_R1_' in the file name, so I've added it to the file names in the command above
```

Now we have our 2bRAD reads separated by barcode and trimmed (steps 1 & 2)!<br>


**TASK**: <mark>The files need to be renamed for each species. 
Using the barcode file [here](https://raw.githubusercontent.com/rdtarvin/RADseq_Quito_2017/master/files/2bRAD-ipyrad_barcodes.txt) and the command `mv`, rename all .gz files accordingly.</mark><br>



Steps 34567. Complete pipeline in **iPyrad**
---

iPyrad is relatively easy when it comes to command line programs. Make sure you check out their extensive online documentation [here](http://ipyrad.readthedocs.io/index.html).

We need to update our virtual machines before running iPyrad.
```bash
conda update -p "$HOME/Applications/BioBuilds" -y fastx-toolkit libgd
conda install -p "$HOME/Applications/BioBuilds" -y -c ipyrad ipyrad=0.7.1
```

Now we can initiate a new analysis.
```bash
ipyrad -n 2brad-v1

# Let's take a look at the file.
cat params-2brad-v1.txt
```

Make a few changes to the params file.
- `[4] [sorted_fastq_path]`: add the location of the sorted fastqs; you must end this parameter with *.gz
- `[7] [datatype]`: change rad to gbs; gbs can take into account revcomp reads
- `[8] [restriction_overhang]`: don't worry about this, it will be ignored since we are starting from sorted reads
- `[11] [mindepth_statistical]`: lower to 5; data have been deduplicated (ipyrad assumes it has not been deduplicated)
- `[12] [mindepth_majrule]`: lower to 2; data have been deduplicated (ipyrad assumes it has not been deduplicated)
- `[18] [max_alleles_consens]`: keep at 2 for diploid
- `[21] [min_samples_locus]`: change to 3; lower number means more missing data but more loci recovered
- `[27] [output_formats]`: add ', u'; this will provide an output selecting single SNPs from each locus randomly

**TASK**: <mark>Make these changes in the params file using the atom text editor.</mark>
```bash
atom params-2brad-v1.txt
```

Your final params file should look like this:

```bash
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
```bash
ipyrad -p params-2brad-v1.txt -s 1234567
```

To check on the results, you can open a new terminal window and type
```bash
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
## Downstream phylogenetic analyses


### Phylogenetics with iPyrad is easy!!

Estimate a **RAxML** tree with concatenated loci
```bash
conda install raxml -c bioconda
python # start python
```
```python
import ipyrad.analysis as ipa
rax = ipa.raxml(data='2brad-epi-july17.phy',name='2brad-epi-july17',workdir='analysis-raxml')
```

Estimate a quartets-based tree in **tetrad**, an iPyrad version of [SVDquartets](http://evomics.org/learning/phylogenetics/svdquartets/)
```bash
tetrad -s 2brad-epi-july17.snps.phy -l 2brad-epi-july17.snps.map -m all -n tetrad-test
```

Estimate a tree based on a SNP matrix, using one SNP from each locus, in **[RAxML-ng]**(raxml snps - https://github.com/amkozlov/raxml-ng).
```bash
cd
wget https://github.com/amkozlov/raxml-ng/releases/download/0.4.0/raxml-ng_v0.4.0b_linux_x86_64.zip
unzip raxml-ng_v0.4.0b_linux_x86_64.zip
/home1/02576/rdtarvin/raxml-ng -h

.
.
.

/home1/02576/rdtarvin/raxml-ng --msa ../2brad-epi-july17.u.snps.phy --model GTR+G+ASC_LEWIS --search
```
Note that there are three options for ascertainment bias correction. 


This is the expected topology and estimated divergence timing. 

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


iPyrad offers the option to branch your pipeline with argument -b. This allows you to access results from previous steps and use them in different downstream analyses.
One of the most convenient uses of this function is testing the effect of missing data on your downstream analyses.
So, let's execute some reiterations of Step 7, the step that generates the final SNP matrices.
**Remember, never edit file names or paths that are created by iPyrad. It needs them to keep track of analyses.**

First, check when the [21] missing data parameter is used in the analysis, to be sure that you don't need to rerun other steps in addition to 7.
This information can be found in the iPyrad documents [parameters page](http://ipyrad.readthedocs.io/parameters.html#). Scroll down to [21], what does it say?

```Affected steps = 7. Example entries to params.txt```<br>

Great, so we can just redo Step 7 with new values for [21]. The basic command to use here is

```bash
ipyrad -p params-2brad-v1.txt -b 2brad-v2-6min
## provide new, informative prefix
```

Then you would need to open the new params file (`params-2brad-v2-6min.txt`) and manually edit parameter [21]. Below I have included code to automate this task.

```bash
for i in 4 6 8 10 12; do ipyrad -p params-2brad-v1.txt -b 2brad-v2-${i}l; do sed -i s/".*\[21\].*"/"${i}$(printf '\t')$(printf '\t')$(printf '\t')$(printf '\t') \#\# \[21\] \[min_samples_locus\]: Min \# samples per locus for output"/ params-2brad-v2-${i}l.txt;  done
# for i in 4 6 8 10 12; do ipyrad -p params-2brad-v2-${i}l.txt -s 7 -f; done

## use the '-f' option when you have already run that step, to force it to rerun
```
**TASK**: <mark>Choose one params file that is different from your neighbor and run it so we can compare results as a class.</mark>

**TASK**: <mark>It's a good idea to run iPyrad using both a range of [21] missing data (as above)
and of [14] clustering threshold. Choose one value lower and one value higher than 0.85 for parameter [21], create two new branches, and run these analyses using the -b option in iPyrad.</mark><br>
**Hint**: First, be sure to check when the clustering threshold was incorporated into the analysis before deciding where to restart the pipeline.






<a href="https://rdtarvin.github.io/RADseq_Quito_2017/"><button>Home</button></a>    <a href="https://rdtarvin.github.io/RADseq_Quito_2017/main/2017/08/02/afternoon-ddRAD-pyrad.html"><button>Next Lesson</button></a>



Appendix.
---

If you get "Segmentation Errors", exit Virtual Box and close the program. You may need to allocate more memory to the system.


Step 1. Allocate more space to the drive.<br>
Run the following commands through the native OSX Terminal program. [Source](https://www.jeffgeerling.com/blogs/jeff-geerling/resizing-virtualbox-disk-image)
```bash
# in OSX (for Windows the commands will be slightly different)
cd /Users/<your user name>/VirtualBox\ VMs/UT\ Biocomputing/
# Clone the .vmdk image to a .vdi.
vboxmanage clonehd 'UT Biocomputing-disk001.vmdk' 'new_UT Biocomputing-disk001.vdi' --format vdi
# Resize the new .vdi image (51200 == 50 GB).
vboxmanage modifyhd "new_UT Biocomputing-disk001.vdi" --resize 51200 
```

Step 2. Tell the VM how to access that space. [Source]([here](https://www.howtoforge.com/partitioning_with_gparted)). If your cursor gets stuck, press the Command key.

1. Open the Virtual Box program and go to Settings, then Storage, and click on SATA. Click on the option to add a new hard disk, select the 'new' disk that you created and press OK. 
2. Download [gparted](http://gparted.org/download.php)
3. In Virtual Box, click Settings, then Storage, then click on Controller: IDE and select ... Click the box that says 'Live CD/DVD'
4. Now go to Storage and unclick the box that says Hard Disk.
5. Start the VM and click enter through the language settings, selecting those that are appropriate for you.
6. On the upper right hand corner, make sure the new disk is selected (you'll see one bar with linux-swap, another called extended, and an open grey box with dashed outline)
7. Click 'New', allow 1MB to remain unallocated, and press OK. Then press Apply.
8. Turn off the VM. Go to Settings, Storage, right click on the GParted disk and click Remove. 
9. Click on System, click Hard Disk, and make sure it is on the top of the list, using the arrows. Make sure there is a Hard Drive assigned to Port 1.
10. Start the VM again!









