#!/usr/bin/perl 

while($in=<>)   # read one line in std buffer 
{	
	$in =~ s/\n//;		#remove newline char of the line string
	my @fields = split /[,=]/,$in;		#split line string to fields by [,=]
	
	print "SELECT_CLAUSE\n";		#Just place holder for SELECT CLAUSE in sql
	
	foreach my $cnum (0..$#fields/2) {
		if ( $cnum == 0 ) { print "FROM $fields[0]\n" };
		if ( $cnum == 1 ) { print "WHERE $fields[1] = '$fields[2]'\n" };
			
		if ($cnum >= 2 ) { 
		
			if ( $fields[$cnum*2-1] =~ /date$/ ) 
				{  
					my $year = substr($fields[$cnum*2],0,4);
					my $month = substr($fields[$cnum*2],4,2);
					my $day = substr($fields[$cnum*2],6,2);
		
					my $date_val = "$year/$month/$day%";
		
					print "AND $fields[$cnum*2-1] like '$date_val'\n";
				}
			else
				{  
					$fields[$cnum*2] =~ s/'/''/;
					print "AND $fields[$cnum*2-1] = '$fields[$cnum*2]'\n" ;
				}
		
		};
			
		if ( $cnum == $#fields/2 ) { print ";\n" };
		
		$cnum=$cnum+1;
	}

}



