
First output from stacks *populations*
-------
Run populations on the mapped dataset using the following code: 

	populations -b (batchnumber_you_used) -P ./input_sequences -M ./popmap_by_island -p 1 -r 0.2 --write_random_snp --plink 

and we use the .ped and .map files from the output.


After that, filter in plink and then back to stacks.


Filtering in plink
----

same filters as Pseudacris/Xantusia

1. filter loci with less than 60% sequenced

		./plink --file filename --geno 0.4 --recode --out filename_a --noweb


2. filter individuals that have less than 50% data

		./plink --file filename_a --mind 0.5 --recode --out filename_b --noweb


3. filter loci with MAF < 0.02 in remaining individuals

		/.plink --file filename_b --maf 0.02 --recode --out filename_c --noweb

Second output from stacks *populations*
----

Make a ***whitelist*** file, which is a list of the loci to include based on the plink results (i.e. on amount of missing data in locus). The whitelist file is ordered as a simple file containing one catalog locus per line: 

		% more whitelist
		3
		7
		521
		11
		46
		103
		972
		2653
		22
In order to get from the .map file to the whitelist file format, open *_c.map file in Text Wrangler, and do find and replace arguments using **grep**:

	search for \d\t(\d*)_\d*\t\d\t\d*$
	replace with \1



Using the **.irem** file from the second iteration of *plink* (in our example named with termination **"_b"**), remove individuals from old popmap so that they are excluded from the analysis (i.e. individuals with too much missing data). 


Run populations again using the whitelist of loci and the updated popmap file for loci and individuals to retain based on the plink filters. Also, make sure your popmap has each island as a single population.

	populations -b 1 -P ./ -M ./popmap.txt  -p 1 -r 0.5 -W Pr-whitelist --write_random_snp --structure --plink --vcf --genepop --fstats --phylip
	

We will use many of these outputs for downstream analyses. Outputs are: 

	batch_2.hapstats.tsv
	batch_2.phistats.tsv
	batch_2.phistats_1-2.tsv
	batch_2.phistats_1-3.tsv
	batch_2.phistats_2-3.tsv
	batch_2.sumstats.tsv
	batch_2.sumstats_summary.tsv
	batch_2.haplotypes.tsv
	batch_2.genepop
	batch_2.structure.tsv
	batch_2.plink.map
	batch_2.plink.ped
	batch_2.phylip
	batch_2.phylip.log
	batch_2.vcf
	batch_2.fst_1-2.tsv
	batch_2.fst_1-3.tsv
	batch_2.populations.log
	batch_2.fst_summary.tsv
	batch_2.fst_2-3.tsv

