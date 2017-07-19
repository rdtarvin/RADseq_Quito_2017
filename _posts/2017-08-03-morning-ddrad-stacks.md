---
layout: default
order: 7
title:  "ddRAD data in stacks"
date:   2017-08-03
time:   "Day 4: Morning"
categories: main
instructor: "Pati"
materials: files/fakefile.txt
material-type: ""
---

WORKSHOP QUITO - DAY 4 
STACKS WITH ddRAD
===



4. First big computing task: Demultiplexing in STACKS
----

In order to know more about whether your library was successful, you need to demultiplex your individuals to know whether they were all sequenced and how much sequences you have for each, and it is always the first step in the pipeline. The files you need for this are: 

- barcodes+sample names (tab-delimited .txt file)

- process_radtags code (shell program from stacks)

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

The index primer is xxxxx, and the sample names occur in the same order as the barcodes in the example file.

**NOTE 1**: whenever editing text files, first, NEVER use what you exported from excel or word directly... always check in a simple text editor (TExt WRangler, BBEdit, etc) and using "view invisible characters" to avoid unnecesary headaches of hidden characters or extra spaces/tabs, etc! Biggest waste of time in anything computing... 

**NOTE 2**: For stacks, you need to have the appropriate barcode files within the appropriate library folders if demultiplexing libraries separately.

**NOTE 3**: Figure out how your barcodes are set up within your sequence file, in order to determine how to set up the process_radtags code (doing any of the commands we did earlier to look into the files).

Now that you know how your sequence file looks like (it will vary from one facility to another), then you can enter the option for whether the barcode occurs in line with the sequence or not, and the other options as well (see the process_radtags manual for more info).

The general code we will use for process_radtags, running it from within the raw-data folder, is the following: 

	module load stacks/1.35 ## this only applies to HPC... on local machines it will not be necessary

	mkdir process_rads_1e2

	process_radtags -P -p . -b ./path/to/folder/barcodes-Stef3-e.txt -o ./path/to/folder/process_rads_1e2/  -c -q -r -D --inline_index --renz_1 sphI --renz_2 mspI -i gzfastq 



5. 
----
