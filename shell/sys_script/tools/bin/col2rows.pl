#!/usr/bin/perl 

# col2rows.pl

# By Isaac Loven isaac_loven@hotmail.com   June 1999

# When too many fields from an Informix Database are selected in an SQL query, 
# the output is displayed as rows and not in a nice table format. 

# This program reformats SQL output from columns to rows.

# If the output is already in columns, no change is made.

# The first line is the location of Your perl interpreter. 
# You may have to change this to the location of your perl  
# ie   #!/usr/local/perl

# If a field is Null,  choose what character you wish will replace it: 
# choose fill value:
$fill=" ";       ## if value is blank print a space.  I prefer a 0 for my applications, 
#  $fill=0;         ## if value is blank print 0.

while($in=<>)   # read one line in std buffer 
{	$line++;
	if ( $line == 3 )
		{
   		if ( $in =~ /\w/ )  
				{  $passthrough = "Y";
					print "\n";
					print "\n";
				}
			else
				{  $passthrough="N";
					print "\n";
				}
		}

	if (  $passthrough eq "Y" ) {  print $in ; }
	if (  $passthrough eq "N" ) 
		{
			my @fields = split ('\s+', $in);  # split std buffer 
			#( $name , $value) = split ('\s+', $in);  # split std buffer 
			
			my $name = $fields[0];
			my $value = "@fields[1 .. $#fields]";
			
			if ( $name ne  ""  ) 
				{
				$value=$fill if ( $value eq "" );    
				###### Now if the data id a fraction ie 3.123456778  Cut off 
				###### the least significant digits after the 3rd decimal place:
				#$value =~s/(\d+\.\d\d\d)\d+/$1/;  

				$val_str .= $value;

				}
 
			if ( $name eq "" ) { print "$val_str\n";  $blank++; $val_str="";  }
		}
}

