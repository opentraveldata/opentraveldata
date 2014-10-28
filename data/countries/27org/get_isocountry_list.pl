#!/usr/bin/perl -w

#
# Screenscrapes the ISO 3166 country code list off the web and makes a MySQL SQL
# insert file. Will create insert file only if content on web differs from SQL
# file, and so could be run periodically from cron if required.
#
# Copyright (C) 2003 Wm. Rhodes 
# 
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation at: <http://www.gnu.org/copyleft/gpl.html>.
#

use strict;
use File::Basename;
use Cwd;
use LWP::Simple;
use Geography::Countries;

# The ISO country list from the web
my $isourl = "http://www.iso.ch/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1-semic.txt";

# The location and name of current local ISO SQL file
my $isolist = cwd . "/iso_country_list.sql";

if ( !-e $isolist || (stat($isolist))[9] < (head($isourl))[1] ) {
	print "File $isolist requires updating.\n";

	my $content = get $isourl  || die "Couldn't get $isourl: $!\n";
	open(ISOLIST, ">$isolist") || die "Couldn't open $isolist: $!\n";

	print ISOLIST "# ". basename($isolist) ."\n".
			"#\n".
			"# This will create and then populate a MySQL table with a list of the names and\n".
			"# ISO 3166 codes for countries in existence as of the date below.\n".
			"#\n".
			"# Usage:\n".
			"#    mysql -u username -ppassword database_name < ./" . basename($isolist) ."\n".
			"#\n".
			"# For updates to this file, see http://27.org/isocountrylist/\n".
			"# For more about ISO 3166, see http://www.iso.ch/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html\n".
			"#\n".
			"# Created by ". basename($0) ." on ". scalar(localtime) .".\n".
			"# Wm. Rhodes <iso_country_list\@27.org>\n".
			"#\n\n".
			"CREATE TABLE IF NOT EXISTS country (\n".
			"  iso CHAR(2) NOT NULL PRIMARY KEY,\n".
			"  name VARCHAR(80) NOT NULL,\n".
			"  printable_name VARCHAR(80) NOT NULL,\n".
			"  iso3 CHAR(3),\n".
			"  numcode SMALLINT,\n".
			");\n\n";

	foreach (split(/\n/, $content)) {
		if (/^[A-Z]{2,}/) {
			my ($name, $code2) = split(/;/, $_);

			my $printable_name = $name;
			$printable_name =~ s/(\w+)/\u\L$1/g;
			$printable_name =~ s/\b(And|Of|The|S)\b/\l$1/g;
			$printable_name =~ s/'/\\'/;

			chop($code2);
			$name =~ s/'/\\'/g;

			my ($code3, $numcode)  = (country($code2))[1,2];   # ('PM', 'SPM', 666, 'Saint Pierre and Miquelon', 1)
			$code3   = defined($code3)   ? "'$code3'"   : "NULL";
			$numcode = defined($numcode) ? "'$numcode'" : "NULL";
			print ISOLIST "INSERT INTO country VALUES ('$code2','$name','$printable_name',$code3,$numcode);\n";
		}
	}

	close(ISOLIST);
	my $size = (stat($isolist))[7];
	print "Wrote $size bytes to $isolist at ". scalar(localtime) ."\n";
} else {
	print "The current ISO SQL file at $isolist is up to date.\n";
}


