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

	mkdir raw-data ##make new directory for your data
	cd raw-data
	wget <<web-address>>	
	ls ##are all your files in there? 
	

2. Looking at your data in unix
---


**2.a.What do your files look like?**

Your files will likely be zipped and with the termination **.fq.gz** or **fastq.gz**. The first thing you want to do is look at the beginning of your files while they are still zipped with the following command: 

	zless <<name of file>> #is this easy to see? 
	zhead <<name of file>> Ncols etc 

Let's unzip one of the raw data files to look a bit more into it:

	gunzip <<filename.fq.gz>>
	
Hmmm.... ok, now lets look at the full file:

	cat <<filename.fq>>
	
Uh oh.... let's quit before the computer crashes.... it's too much to look at! MAc: Option Z, PC
		

how many reads do you have?

3. Looking at your data in fastQC
----

4. First big computing task: Demultiplexing
----

In order to know more about whether your library was successful, you need to demultiplex your individuals to know whether they were all sequenced and how much sequences you have for each. 

5. 
----
