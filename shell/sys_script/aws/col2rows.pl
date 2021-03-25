#!/usr/bin/perl 

# If a field is Null, choose what character you wish to replace it
# choose fill value:
$fill=" ";       ## if value is blank print a space.
# $fill=0;      ## example, if value is blank print 0.

while($in=<>)   # read one line in std buffer 
{	
	$line++;
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
			
			my $name = $fields[0];
			my $value = "@fields[1 .. $#fields]";
			
			if ( $name ne  ""  ) 
				{
				$value=$fill if ( $value eq "" );    

				$val_str .= $value;

				}
 
			if ( $name eq "" ) { print "$val_str\n";  $blank++; $val_str="";  }
		}
}

