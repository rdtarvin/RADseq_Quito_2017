---
layout: default
order: 3
title:  "Shell, Git, & NGS data"
date:   2017-08-02
time:   "Day 3: Morning"
categories: main
instructor: "Becca and Pati"
materials: files/fakefile.txt
---


# WORKSHOP QUITO - DAY 3: Getting started in shell  <br>

## 0. The linux environment
`pwd`, relative versus absolute paths
see http://ccbbatut.github.io/Biocomputing_Spring2016/introduction_to_unix/

## 1. Getting started with github and downloading data

After a short lecture about why to work on git and what it is, we will get started on a quick unix/git exercise. 

```
mkdir workshop
cd workshop
git clone <<url>>
cd <<git-folder>>
ls
>>some other things.... 
```

Names of files, folders, etc., when computing, can NEVER have spaces in them, and you should really limit characters. This will save you headaches down the line. If you will be computing a lot in your career, change your ways and have it as a default to NEVER use spaces in names. 

Downloading your data through unix

```	
wget <<web-address>>	
ls ##are all your files in there? 
```

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









