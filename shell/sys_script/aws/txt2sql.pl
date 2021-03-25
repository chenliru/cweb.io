#!/usr/bin/perl 
#my $fieldnum = 0;
#my $fieldfix = 0;
#my $vaxfile = $ARGV[0];

#print "ARGV $ARGV[0]\n";

open(ERROR, ">> $ARGV[0].error") ;

while($in=<>)   # read one line in std buffer 
{	
	$in =~ s/\n//;		#remove newline char of the line string
	my @fields = split /[~=]/,$in;		#split line string to fields by "~" and "="
	
	if ( $#fields <= 1 ) {next;}
	
	#Added for tariff table error
	#chomp($fields[0]);
	if ( $fields[0] eq "TARIFF" && $#fields != 8 )
	{ 
		my @tarfields = split /~/,$in;		#split line string to fields by "~" 
		#print $#tarfields;
		if ( $#tarfields != 4 ) {
			print ERROR "$in\n";
			next;
		}
		print "SELECT_CLAUSE\n";		#Just place holder for SELECT CLAUSE in sql
		
		print "FROM TARIFF\n";
		$tarfields[1] =~ s/'/''/g;
		$tarfields[1] =~ s/=/ = '/;
		print "WHERE $tarfields[1]'\n";
		$tarfields[2] =~ s/'/''/g;
		$tarfields[2] =~ s/=/ = '/;
		print "AND $tarfields[2]'\n";
		$tarfields[3] =~ s/'/''/g;
		$tarfields[3] =~ s/=/ = '/;
		print "AND $tarfields[3]'\n";
		$tarfields[4] =~ s/'/''/g;
		$tarfields[4] =~ s/=/ = '/;
		print "AND $tarfields[4]'\n";
		print ";\n";
		
		next; 
	}

	#Normal tables
	print "SELECT_CLAUSE\n";		#Just place holder for SELECT CLAUSE in sql
	foreach my $cnum (0..$#fields/2) 
	{
		if ( $cnum == 0 ) { print "FROM $fields[0]\n" };
		if ( $cnum == 1 ) { print "WHERE $fields[1] = '$fields[2]'\n" };
			
		if ($cnum >= 2 ) 
		{ 
			if ( $fields[$cnum*2-1] =~ /date$/ ) 
			{  
				# For cloumn name including date$ with (example: hs_nmon table)
				# HS_DUTY_RATE~hsno=7318150029~hstarifftrtmnt=29~effdate=20150101
				#	-> effdate like '2015/01/01'

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
		
		if ( $cnum >= $#fields/2 ) { print ";\n" };
		$cnum=$cnum+1;
		
	}

}

close(ERROR);

