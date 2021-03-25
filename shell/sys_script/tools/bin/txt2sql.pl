#!/usr/bin/perl 
my $fieldnum = 0;
my $fieldfix = 0;
my $vaxfile = $ARGV[0];

#print "ARGV $ARGV[0]\n";

open(ERROR, ">> $ARGV[0].error") ;

while($in=<>)   # read one line in std buffer 
{	
	$in =~ s/\n//;		#remove newline char of the line string
	my @fields = split /[~=]/,$in;		#split line string to fields by "~" and "="
	
	#print "#fields $#fields\n\n";
	
	if ( $fieldnum == 0 ) 
	{ 
		$fieldfix = $#fields;
		$fieldnum=$fieldnum+1;
	}
	#print "fieldfix $fieldfix \n";
	#print "fieldnum $fieldnum \n";
	
	if ( $fieldfix != $#fields )  
		{ 
			print ERROR "$in\n";
			next; 
		}

	print "SELECT_CLAUSE\n";		#Just place holder for SELECT CLAUSE in sql
	foreach my $cnum (0..$#fields/2) 
	{
		if ( $cnum == 0 ) { print "FROM $fields[0]\n" };
		if ( $cnum == 1 ) { print "WHERE $fields[1] = '$fields[2]'\n" };
			
		if ($cnum >= 2 ) 
		{ 
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
				#To make it search/replace through the entire string, 
				#use the g option after the last forward slash
				$fields[$cnum*2] =~ s/'/''/g;
				print "AND $fields[$cnum*2-1] = '$fields[$cnum*2]'\n" ;
			}
		};
		
		if ( $cnum == $#fields/2 ) { print ";\n" };
		$cnum=$cnum+1;
		
	}

}

close(ERROR);

