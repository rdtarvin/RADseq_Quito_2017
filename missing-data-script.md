####ideas for a short (and easy??) custom missing data filtering program

so, a common thing that I do when handing SNP matrices is that I end up manually filtering them by population depending on the question/method to be used. For example, if you want to run iterations of population assignment algorithms hierarchically and by population. Because there are issues that you can run into when transforming a matrix over and over in PGDSpider where loci get all screwed up, then it's always better to avoid going back to plink and then back again to continue per-population iterations of an analysis. 

So then: **is there an easy way to filter**, I presume with awk (one day I'll learn...), **all the loci that have 100% missing data?** There are weird errors in some programs when missing data in loci is 100% (but fine if 99% missing), and this is more common than you'd think for some datasets, especially if some populations were poorly genotyped and also if some are highly divergent from the rest of the dataset. 

my notes of what I'd want (I think...) of the program  below... I haven't even started on the code!! 





my notes on the missing data program (before starting to work on the code):
	
	#search by column
	#if every single row of the column (skipping row 1) equals zero, then don't write, if at least one is not zero, then write. 
	#computation time can be saved by having it so that the first row that is different to zero, you print in new file.
	#for .stru file format, organized similar to nexus phased haplotypes, the first two columns are data that need to be kept/printed (ind.names, pops), third row begins loci.






 