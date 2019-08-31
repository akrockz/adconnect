#!/usr/bin/perl

@acct= ("2343","1232");
@acctName= ("Automation","NonProd-SemiAuto");
@role= ("dummy", "ADMIN","READONLY","DEVOPS");


print "\nSelect role\n";
print "(1) Admin\n";
print "(2) Readonly\n";
print "(3) DevOps\n";
print "Option : ";

$roleIndex=<STDIN>;
chomp($roleIndex);

if($roleIndex == 3)
{
	$acctIndex=0; # automation account
	print "Selecting $acctName[$acctIndex] account=$acct[$acctIndex] for $role[$roleIndex] role\n";
}
else
{
	print "\nSelect account\n";
	print "(1) Prod\n";
	print "(2) NonProd\n";
	print "(3) Prod-Semi\n";
	print "(4) NonProd-Semi\n";
	$acctIndex=<STDIN>;
	chomp($acctIndex);
	print "Selecting $acctName[$acctIndex] account=$acct[$acctIndex] for $role[$roleIndex] role\n";
}

print "\nEnter Portfolio: ";
$portFolio=<STDIN>;
chomp($portFolio);

print "\nEnter App(Optional only required if you need permission to App level): ";
$app=<STDIN>;
chomp($app);

if(length($app) < 1)
{
	$pfa=uc($portFolio) . "_" . $role[$roleIndex];
	$ou="OU=" . uc($portFolio);
}
else
{
	$pfa=uc($portFolio) . "_" . uc($app) . "_" . $role[$roleIndex];
	$ou="OU=" . uc($app) . ",OU=" . uc($portFolio);
}

print "Enter filename containing list of users(can be a list of users emails\n";
$file=<stdin>;
chomp($file);

if( -e $file )
{
	buildFile();
}
else
{
	print "Cannot find file $file\n";
	print "Aborting\n";
	exit();
}


sub buildFile
{
	open(FILEH,">UserList.csv");
	print FILEH "CN,Username,Path\n";
	@rows=`cat $file`;
	foreach $line(@rows)
	{
		($userName,$email)=split(/\@/,$line);
		$userName =~ s/\_/ /g;
		print FILEH "AWSFS_$acct[$acctIndex]_$pfa,\"CN=$userName,OU=IT,DC=abc,DC=com\",\"$ou,OU=AWS,OU=Cloud,DC=abc,DC=com\"\n";
	}
}
