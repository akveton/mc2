#!/usr/bin/perl

# Copyright (c) 2003, Pavel Roskin
# This script is Free Software, and it can be copied, distributed and
# modified as defined in the GNU General Public License.  A copy of
# its license can be downloaded from http://www.gnu.org/copyleft/gpl.html

# Run this script on the map with cross-reference generated by GNU ld,
# and it will generate a list of symbols that don't need to be global.
# To create the map, run something like this:
# make LDFLAGS=-Wl,-Map,output.map,--cref

use strict;

my %symbols;
my %syms;
my %objs;

if ($#ARGV != 0) {
	print "Usage: unrefglobals.pl mapfile\n";
	exit 1;
}

if (!open (MAP, "$ARGV[0]")) {
	print "Cannot open file \"$ARGV[0]\"\n";
	exit 1;
}

my $line;
my $next_line = <MAP>;
while (1) {
	last unless $next_line;
	$line = $next_line;
	$next_line = <MAP>;
	next unless ($line =~ m{^[A-Za-z_][A-Za-z0-9_]*  +[^ /][^ ]+\.o$} or
		     $line =~ m{^[A-Za-z_][A-Za-z0-9_]*  +[^ /][^ ]+\.a\([^ ]+\.o\)$});
	if (!$next_line or ($next_line !~ /^ /)) {
		my @arr = split (' ', $line);
		$symbols{$arr[0]} = $arr[1];
		$syms{$arr[0]} = 1;
		$objs{$arr[1]} = 1;
	}
}

close(MAP);

foreach my $obj (sort keys %objs) {
	print "$obj\n";
	foreach my $sym (sort keys %syms) {
		print "\t$sym\n" if ($symbols{$sym} eq $obj);
	}
}