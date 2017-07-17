WORKSHOP QUITO - DAY 3
===

1. Getting started with github and downloading your data
---

After a short lecture about why to work on git and what it is, we will get started on a quick unix/git exercise. 

	mkdir
	git installing
	git clone <<url>>
	cd to folder
	ls
	>>some other things.... 


Downloading your data through unix

	mkdir Quito-workshop
	cd Quito-workshop
	
Names of files, folders, etc., when computing, can NEVER have spaces in them, and you should really limit characters. This will save you headaches down the line. If you will be computing a lot in your career, change your ways and have it as a default to NEVER use spaces in names. 

	wget <<web-address>>	
	ls ##are all your files in there? 
	
Alternatively, you can copy the files (or "secure" copy <scp> from a protected computer/cluster) into your working directory: 

	scp filename.gz . ##this is done directly from your working directory. 

Copy and move commands are always done in the following way: 

	COPY <THIS_FILE> <INTO_THIS_PLACE>
	MOVE <THIS_THING> <THERE>

Move can also be used for a quick "renaming" of a single file. 

	mv filename newfilename

Let's say we'd like to rename our downloaded data files to reove unnecesary info from the name. 

	mv Stef_3_ATCACG_L008_R1_001.fastq Stef_3_ATCACG_R1.fastq

This way we are keeping important info (pool number, barcode, read) and eliminating extra things (lane, something else... haha). 

We've decided that the way we organized our raw data is not appropriate for all we'll do. So first, let's make some folders: one for raw data, one for stacks, one for ipyrad, and one for (**?? whichever the other program is**). Remember we hate spaces!! 

Then, let's copy ALL of our raw data files into our raw-data folder with one command: 

	mv Stef* raw-data

The asterisk is a wildcard that autocompletes anything that follows that text. 


2. Looking at your data in unix
---


**2.a.What do your files look like?**

Your files will likely be zipped and with the termination **.fq.gz** or **fastq.gz**. The first thing you want to do is look at the beginning of your files while they are still zipped with the following command: 

	gzless <<name of file>> #is this easy to see? 
	zhead <<name of file>> iterations with diff Ncols etc 

Let's unzip one of the raw data files to look a bit more into it:

	gunzip <<filename.fq.gz>>
	
Hmmm.... ok, now lets look at the full file:

	cat <<filename.fq>>
	
Uh oh.... let's quit before the computer crashes.... it's too much to look at! MAc: Control C, PC:?? 
		

how many reads do you have?

We can write really simple unix code to fetch the number of sequences per file. As you can see from the previous "head" command, each sequence line begins with @, so we can just count how many times the argument '@D3' appears, or in essence, how many "lines" of sequence data we have. 

	grep -c '@D3' Stef_3_ATCACG_L008_R1_001.fastq

>BECCA, can you add other things to this previous section??? 

3. Looking at your data in fastQC
----
>Becca, have you used FASTQC a lot? 


4. First big computing task: Demultiplexing in STACKS
----

In order to know more about whether your library was successful, you need to demultiplex your individuals to know whether they were all sequenced and how much sequences you have for each, and it is always the first step in the pipeline. The files you need for this are: 

- barcodes+sample names (txt)

- process_radtags code








5. 
----
