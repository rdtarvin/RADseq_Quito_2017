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

### File systems
- your computer contains a nested hierarchy of directories
- **directory** is a *folder* on your computer which contains files
- keeping track of where you are in the file structure of your computer is an important component of computing
- highest level is the **root** (denoted: `/`)
- forward slashes divide levels in the nested hierarchy of directories, e.g. `/top_level_directory/second_level_directory`
- there are several high-level directories that users don't usually go into where program files are stored
	- /usr/bin
	- /usr/lib
- every file on your computer has an address; if you are going to do an operation on a file, you need its address
- **path**: the *address* to a directory or file on your computer. There are, generally, two types of paths:
	- **absolute/full path** represents the path of a given directory or file beginning at the root directory
    - **relative path** represents the path of a given directory/file relative to the working/current directory
- for example, say you have a file "my\_favorite\_file.txt" located in the directory `/Users/myname/Desktop/my_directory`.
	- the **full path** to this file  is `/Users/myname/Desktop/my_directory/my_favorite_file.txt`
    - the **relative path** to this file depends on where you are on the computer
	- if you are calling this file from Desktop, the relative path would be `my_directory/my_favorite_file.txt`
	- if you are in `/Users/myname/`, the relative path becomes `Desktop/my_directory/my_favorite_file.txt`
    
Remember - *Whenever you call the full path, you can reach the file from anywhere on your computer. Relative paths will change based on your current location.*

### Unix
- commands are small programs
	- type the name of a command and hit enter
	- Unix searches for the program's text file and executes it
- programs have preset arguments which change their behavior
	- these can be found in the program's manual
- programs interact with files that are in the directory that you are in
- we use a "shell" to interact with Unix: it exchanges information between user and program through *standard streams*
- **standard input**: input to programs
- **standard output**: information on screen, i.e. what the program outputs
- standard text editor for Unix is nano
	- type `nano` to access it
	- opens a text editor within the shell
	- saving, exiting, and other functions are controlled with ctrl + letter keys
	- we will be using primarily the Atom text editor instead of nano


### Here are some commands you will use all the time, we will review them as we proceed with the lesson

Command | Translation | Examples
--------|-------------|---------
`cd` | **c**hange **d**irectory | `cd /absolute/path/of/the/directory/` <br> Go to the home directory by typing simply  `cd` or `cd ~` <br> Go up (back) a directory by typing `cd ..`
`pwd` | **p**rint **w**orking **d**irectory | `pwd`
`mkdir` | **m**ake **dir**ectory | `mkdir newDirectory` creates newDirectory in your current directory <br> Make a directory one level up with `mkdir ../newDirectory`
`cp` | **c**o<b>p</b>y | `cp file.txt newfile.txt` (and file.txt will still exist!)
`mv` | **m**o<b>v</b>e | `mv file.txt newfile.txt` (but file.txt will *no longer* exist!)
`rm` | **r**e<b>m</b>ove | `rm file.txt` removes file.txt <br> `rm -r directoryname/` removes the directory and all files within
`ls` | **l**i<b>s</b>t | `ls *.txt` lists all .txt files in current directory <br> `ls -a` lists all files including hidden ones in the current directory <br> `ls -l` lists all files in current directory including file sizes and timestamps <br> `ls -lh` does the same but changes file size format to be **h**uman-readable <br> `ls ../` lists files in the directory above the current one
`man` | **man**ual | `man ls` opens the manual for command `ls` (use `q` to escape page)
`grep` | **g**lobal **r**egular <br> **e**xpression **p**arser |  `grep ">" seqs.fasta` pulls out all sequence names in a fasta file <br> `grep -c ">" seqs.fasta` counts the number of those sequences <br> 
`cat` | con<b>cat</b>enate | `cat seqs.fasta` prints the contents of seqs.fasta to the screen (ie stdout)
`head` | **head** | `head seqs.fasta` prints the first 10 lines of the file <br> `head -n 3 seqs.fasta` prints first 3 lines
`tail` | **tail** | `tail seqs.fasta` prints the last 10 lines of the file <br> `tail -n 3 seqs.fasta` prints last 3 lines
`wc` | **w**ord **c**ount | `wc filename.txt` shows the number of new lines, number of words, and number of characters <br> `wc -l filename.txt` shows only the number of new lines <br> `wc -c filename.txt` shows only the number of characters
`sort` | **sort** | `sort filename.txt` sorts file and prints output
`uniq` | **uniq**ue | `uniq -u filename.txt` shows only unique elements of a list <br> (must use sort command first to cluster repeats)

<br>
<br>

### Handy dandy shortcuts

Shortcut | Use|
----------|-----|
Ctrl + C | kills current process
Ctrl + L <br> (or `clear`) | clears screen
Ctrl + A | Go to the beginning of the line
Ctrl + E | Go to the end of the line
Ctrl + U | Clears the line before the cursor position
Ctrl + K | Clear the line after the cursor
`*` | wildcard character
tab | completes word
Up Arrow | call last command
`.` | current directory
`..` | one level up 
`~` | home
`>` | redirects stdout to a file, *overwriting* file if it already exists
`>>` | redirects stdout to a file, *appending* to the end of file if it already exists
pipe (<code>&#124;</code>) | redirects stdout to become stdin for next command

<br>

## 1. Getting started with github and downloading data

After a short lecture about why to work on git and what it is, we will get started on a quick unix/git exercise. 

{% highlight bash %}
mkdir workshop
cd workshop
git clone <<url>>
cd <<git-folder>>
ls
>>some other things.... 
{% endhighlight %}

Names of files, folders, etc., when computing, can NEVER have spaces in them, and you should really limit characters. This will save you headaches down the line. If you will be computing a lot in your career, change your ways and have it as a default to NEVER use spaces in names. 

Downloading your data through unix

{% highlight bash %}
wget <<web-address>>	
ls 
# are all your files in there? 
{% endhighlight %}

Alternatively, you can copy the files (or "secure" copy <scp> from a protected computer/cluster) into your working directory: 

{% highlight bash %}
scp filename.gz . ##this is done directly from your working directory. 
{% endhighlight %}

Copy and move commands are always done in the following way: 

{% highlight bash %}
cp <THIS_FILE> <INTO_THIS_PLACE>
mv <THIS_THING> <THERE>
{% endhighlight %}

Move can also be used for a quick "renaming" of a single file. 

{% highlight bash %}
mv filename newfilename
{% endhighlight %}

Let's say we'd like to rename our downloaded data files to remove unnecesary info from the name. 

{% highlight bash %}
mv <> <>
{% endhighlight %}

This way we are keeping important info (pool number, barcode, read) and eliminating extra things (lane, something else... haha). 

We've decided that the way we organized our raw data is not appropriate for all we'll do. So first, let's make some folders: one for raw data, one for stacks, one for ipyrad, and one for (**?? whichever the other program is**). Remember we hate spaces!! 

Then, let's copy ALL of our raw data files into our raw-data folder with one command: 

{% highlight bash %}
mv Stef* raw-data
{% endhighlight %}
The asterisk is a wildcard that autocompletes anything that follows that text. 

<br><br>

<a href="https://rdtarvin.github.io/RADseq_Quito_2017/"><button>Home</button></a>    <a href="https://rdtarvin.github.io/RADseq_Quito_2017/main/2017/08/02/afternoon-2bRAD-pyrad.html"><button>Next Lesson</button></a>
