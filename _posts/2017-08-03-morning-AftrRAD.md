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

WORKSHOP QUITO - DAY 4 
AftrRAD WITH ddRAD
===


AftrRAD (align from total reads) is a bioinformatic pipeline for the de novo assembly and genotyping of RADseq data. It was described by Sovic et al (2015), Molecular Ecology Resources 15:1163-1171, and you can get the program and documentation as a zip file [here](https://u.osu.edu/sovic.1/downloads/).

STEP 1 Getting ready for AftrRAD
----

Download data for this lesson
```
wget -O RAD105_10M.txt.zip 'https://www.dropbox.com/s/zt3zdjgus7tmw0u/RAD105_10M.txt.zip?dl=1'
unzip RAD105_10M.txt.zip
mv RAD105_10M.txt ~/Applications/AftrRADv5.0/Data/
cd ~/Applications/AftrRADv5.0/Data/
ls
```


