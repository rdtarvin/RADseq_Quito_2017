---
layout: default
title: {{ site.name }}
---



Virtual Machine Installation and Setup Instructions
==

So we are all working in the same computing environment, please follow these instructions:
1. Download and install [VirtualBox 5.1.24 and VirtualBox 5.1.24 Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads) for your operating system.
2. Download the [virtual machine image](http://download.lab7.io/UT-BioComputing-RADSeq.ova) with RADseq software. **This file is 4.7GB, so make sure you have space on your hard drive and a good internet connection before downloading.** Back-up Download Link [Here](https://my.pcloud.com/publink/show?code=XZuFGrZQiTiVzhKRTbaj4E6LHBetSQj6wjy)
3. Install both the box and the extension pack, then double-click on the .ova file to import it into the virtual machine. (This may take a few minutes)
4. When Virtual Machine program opens, select "UT Biocomputing RADSeq" and click Import. (This can take >1hr). The login user and password are "user1" and "password", respectively.
5. Click Settings, then Shared Folders. Click on the New Folder symbol, click "Auto-mount" and add a path 
to your Applications/Programs folder and then to your Documents (and to anything else you may want to access 
from the VM).
6. Start the VM by clicking the green arrow. Once the machine loads, click the blue deer in the upper 
left corner, then click the light switch icon ("All Settings"). Scroll down and click Users and Groups, 
then Manage Groups. Scroll down and select vboxsf and then click Properties. Make sure the box for 
"Biocomputing User 1" is checked. Click OK, enter your password ("password"), and then shut down the VM 
and restart it.
7. Click on the black box in the upper left corner ("Terminal Emulator"). 
Once the program opens, install the Atom text editor by copying the following text into the terminal, one line at a time. Answer 'y' if it asks.
```bash
sudo add-apt-repository ppa:webupd8team/atom
sudo apt update
sudo apt install atom
```
8. To test whether your installation worked, type:
```bash
touch testfile # creates an empty file in the directory where you are
atom testfile # opens the file in atom
```
Add some text to the file, save it (from within the VM), and then exit atom. Go back to the Terminal and type
```bash
cat testfile
```
If the installation worked, the text you saved to the file should print to the screen. If you want to remove the file, type `rm testfile`.

One note - on the VM, copy is Ctrl+Shift+C and paste is Ctrl+Shift+V<br> 
<br>
**TROUBLESHOOTING**<br>
If when starting your VM, you get a black box with an underscore and the machine doesn't ever start, you may need to enable hardware virtualization technology (VT-x).
This is probably the case if you have a 64-bit Windows operating system. To make this change, follow these steps:
1. Start BIOS at boot up by holding F10 during start-up (the specific F key may be different for your computer).
2. Go to Advanced Settings then Device Configurations, then click the box next to VTx
3. Click Save, then Exit. Save changes.
4. Once the computer starts, open Virtual Box, click on Settings. Under the General menu, change the Version to Ubuntu (64-bit).
5. Start the VM, it should be working fine!

---
If you have a Mac computer, everything we are doing in this workshop you can install at a later date to your root system (Mac OS). Windows users will always require a linux VM to run these programs. For Mac OS text editors, we recommend [Text Wrangler](http://www.barebones.com/products/textwrangler/), [Sublime Text](http://www.sublimetext.com/2), or [Atom](https://atom.io/). If you do want to use a text editor on Windows outside of the ubuntu environment, we recommend [Notepad++](https://notepad-plus-plus.org/).

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-105631258-1', 'auto');
  ga('send', 'pageview');

</script>

