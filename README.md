[https://rdtarvin.github.io/RADseq_Quito_2017/](https://rdtarvin.github.io/RADseq_Quito_2017/)

Welcome!
==

This is the official website for the RADseq workshop following the XI Congreso Latinoamericano de Herpetologia in Quito, Ecuador, sponsored by <a href="http://zoologia.puce.edu.ec/Vertebrados/">QCAZ @ PUCE</a>.  <br>
The workshop will take place in room xx at PUCE (address) from July 31 until August 4. We will cover theory and experimental design of RADseq projects as well as laboratory methods and bioinformatic pipelines.      <br>
Before the workshop, please complete the following three tasks, in this order:
1. **fill out this [survey](https://www.surveymonkey.com/r/H6NDCHG)** 
2. **install the virtual machine as described below**
3. **complete lessons 1-3 of this [software carpentry course](https://swcarpentry.github.io/shell-novice/) on bash/shell, unless you are certain that you feel comfortable in the shell environment** <br>


Installation and Setup Instructions
==

So we are all working in the same computing environment, please follow these instructions:
1. Download and install [VirtualBox 5.1.24 and VirtualBox 5.1.24 Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads) for your operating system.
2. Download the [virtual machine image](http://download.lab7.io/UT-BioComputing-RadSEQ.ova) with RADseq software. **This file is 4.7GB, so make sure you have space on your hard drive and a good internet connection before downloading.**
3. Double-click on the .ova file to import it into the virtual machine. (This may take a few minutes)
4. When Virtual Machine program opens, select "UT Biocomputing RadSEQ" and click Import. (This takes >1hr). The login user and password are "user1" and "password", respectively.
5. Click Settings, then Shared Folders. Click on the New Folder symbol, click "Auto-mount" and add a path to your Applications/Programs folder and then to your Documents (and to anything else you may want to access from the VM).
6. Start the VM by clicking the green arrow. Once the machine loads, click the blue deer in the upper left corner, then click the light switch icon ("All Settings"). Scroll down and click Users and Groups, then Manage Groups. Scroll down and select vboxsf and then click Properties. Make sure the box for "Biocomputing User 1" is checked. Click OK, enter your password ("password"), and then shut down the machine and restart it.
7. Install the Atom text editor with the following steps
```
sudo add-apt-repository ppa:webupd8team/atom
sudo apt update
sudo apt install atom
```
8. To test whether your installation worked, click on the black box in the upper left corner ("Terminal Emulator"). Once the program opens, copy the following commands.
```
touch testfile
atom testfile
```
Add some text to the file, save it, and then exit atom. Go back to the Terminal and type
```
cat testfile
```
If the installation worked, the text you saved to the file should print to the screen.


Stacks, iPyrad, dDocent, R, cd-hit-est, fastx-toolkit, and fastqc are all installed in $HOME/Applications/BioBuilds and should be accessible via $PATH. AftrRAD is installed in $HOME/Applications/AftrRADv5.0. 


---
If you have a Mac computer, everything we are doing in this workshop you can install at a later date to your root system (Mac OS). Windows users will always require a linux VM to run these programs. For Mac OS text editors, we recommend [Text Wrangler](http://www.barebones.com/products/textwrangler/), [Sublime Text](http://www.sublimetext.com/2), or [Atom](https://atom.io/). If you do want to use a text editor on Windows outside of the ubuntu environment, we recommend [Notepad++](https://notepad-plus-plus.org/).

