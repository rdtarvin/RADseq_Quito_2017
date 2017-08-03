---
layout: default
order: 14
title:  "ddRAD Data in AftrRAD"
date:   2017-08-04
time:   "Afternoon"
categories: main
instructor: "David"
materials: ""
material-type: ""
lesson-type: Interactive
---

## WORKSHOP QUITO - DAY 5 <br>
### ddRAD data in AftrRAD

AftrRAD (align from total reads) is a bioinformatic pipeline for the de novo assembly and genotyping of RADseq data. It was described by Sovic et al (2015), Molecular Ecology Resources 15:1163-1171, and you can get the program and documentation as a zip file [here](https://u.osu.edu/sovic.1/downloads/).

PART 0 Getting ready for AftrRAD
----

AftrRAD is a good alternative when you have single-end RADseq data and no access to multicore computing resources (i.e. you can perform these analyses efficiently on a personal laptop).

In order to run AftrRAD you need to unzip the file downloaded before and make sure the three dependencies (i.e. R, ACANA, and Mafft) mentioned in the manual are installed and working correctly. Also, if running AftrRAD version 5.0 or greater you can reduce run times by doing parallel analyses by installing the Perl module Parallel:ForkManager.

**NOTE**: All of the steps mentioned above have already been taken care of when installing the Virtual Machine for this workshop.

![](https://github.com/rdtarvin/RADseq_Quito_2017/blob/master/images/basic-assembly-steps.png?raw=true)<br>

PART 1 Formatting data and steps 1, 2 and 3* (AftrRAD.pl)
----

Download data for this lesson
```
wget -O RAD105_10M.txt.gz 'https://www.dropbox.com/s/tqctvehvbjk0qgt/RAD105_10M.txt.gz?dl=1'
gzip RAD105_10M.txt.gz
mv RAD105_10M.txt ~/Applications/AftrRADv5.0/Data/
cd ~/Applications/AftrRADv5.0/Data/
ls
```

PART 2 Steps 4 and 5* (Genotype.pl)
----

PART 3 Steps 6 and 7* (FilterSNPs.pl and different formatting scripts for downstream analyses)
----
