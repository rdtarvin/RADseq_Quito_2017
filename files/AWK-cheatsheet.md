counting and printing a matched pattern
----

	awk '/a/{++cnt} END {print "Count = ", cnt}' filename.txt

which produces the output

	Count = 4

printing a column by pattern
----

	awk '/a/ {print $3 "\t" $4} filename.txt

which finds pattern 'a' in each line but then only prints columns 3 and 4 for the found pattern. 

printing lines with more than 18 characters
----

	awk 'length($0) > 18' filename.txt

when given argument/variable $0, it defaults to print action, so if more than 18 characters are present in line then the comparison is true and gets printed. 

match character set 
----

	echo -e "Call\nTall\nBall" | awk '/[CT]all/'

which finds names from the echo list that match the pattern "all" but only contain C and T, and prints:

	Call
	Tall

exclusive set
----

	echo -e "Call\nTall\nBall" | awk '/[^CT]all/'
	
the carat negates the set of characters in the square braquets, which prints only 
	
	Ball

zero or one occurrence
----

	echo -e "Colour\ncolor" | awk '/Colou?r/'

which matches zero or one occurence of the preceding character (so matches and prints both). 

zero or more occurrences
----

	echo -e "ca\ncat\ncatt" | awk '/cat*/'

which matches zero or more occurrences of the preceding character. 

one or more occurrence
----

	echo -e "111\n22\n123\n234\n456\n222" | awk '/2+/'

which matches one or more occurrences of the preceding character. 

grouping 
----

	echo -e "Apple Juice\nApple Pie\nApple Tart\nApple Cake" | awk '/Apple (Juice|Cake)/'

the above matches the lines containing either Apple Juice or Apple Cake

