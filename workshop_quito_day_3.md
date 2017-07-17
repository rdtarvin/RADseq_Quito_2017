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

- barcodes+sample names (.txt)

- process_radtags code (unix)

We had a total of two libraries for this project, and they both used the same adapters but different illumina primers. I've made one of the barcodes files for you to work with, which can be found [here](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/STACKS/demultiplexing/barcodes-Stef-3.txt). 

<<You now have to build the second barcode file, using the SAME barcodes as the other library, the same format, the **different** index primer and sample names. Here are the sample names: 

	Er_413
	Er_414
	Er_416
	Er_418
	Er_419
	Er_420
	Er_422
	Er_423
	Er_424
	Er_425
	Er_426
	Er_427
	Er_428
	Er_429
	Er_431
	Er_432
	Er_433
	Er_434
	Er_435
	Er_436
	Er_467
	Er_468
	Er_469
	Er_470
	TNHC05833

**NOTE 1**: whenever editing text files, first, NEVER use what you exported from excel or word directly... always check in a simple text editor (TExt WRangler, BBEdit, etc) and using "view invisible characters" to avoid unnecesary headaches of hidden characters or extra spaces/tabs, etc! Biggest waste of time in anything computing... 


**NOTE 2**: You need to have the appropriate barcode files within the appropriate library folders if demultiplexing libraries separately.

**NOTE 3**: Figure out how your barcodes are set up within your sequence file, in order to determine how to set up the process_radtags code (doing any of the commands we did earlier to look into the files).

Now that you know how your sequence file looks like (it will vary from one facility to another), then you can enter the option for whether the barcode occurs in line with the sequence or not, and the other options as well (see the process_radtags manual for more info).

The general code we will use for process_radtags, running it from within the raw-data folder, is the following: 

	module load stacks/1.35

	mkdir process_rads_1e2

	process_radtags -P -p . -b ./path/to/folder/barcodes-Stef3-e.txt -o ./path/to/folder/process_rads_1e2/  -c -q -r -D --inline_index --renz_1 sphI --renz_2 mspI -i gzfastq 



5. 
----
