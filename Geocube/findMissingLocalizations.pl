#!/usr/bin/perl

use strict;
use warnings;
use Encode qw/encode decode/;
use Data::Dumper;

my %strings = ();
while (my $line = <>) {
	chomp($line);
	# MATCH(RC_KEEPTRACK, _(@"menu-keep_track"));

	my @ws = split(/_\(@"/, $line);
	shift(@ws);
	foreach my $w (@ws) {
		# @"menu-keep_track", nil));

		$w =~ s/".*//;
		$strings{$w} = 1;
	}
}

my @langs = ();
opendir(my $dh, "Settings.bundle");
@langs = grep { /^.*.lproj/} readdir($dh);
closedir $dh;

foreach my $lang (@langs) {
	my @files = ();
	open(FIN, "find Settings.bundle/$lang -name Localizable-*strings |");
	while (my $line = <FIN>) {
		chomp($line);
		push(@files, $line);
	}

	my %foundstrings = ();
	my $shown = 0;
	foreach my $file (@files) {
		open(FIN, $file);
		while (my $line = <FIN>) {
			$line = decode("UTF-16BE", $line);
			chomp($line);

			# "Queries" = "nl-Queries";

			$line =~ /"([^"]+)" = "([^"]+)";/;
			next if (!defined $2);

			if (!defined $strings{$1}) {
				if ($shown == 0) {
					print "$lang - $file\n";
					$shown = 1;
				}
				print "Found unknown '$1'\n";
			}
			if (defined $foundstrings{$1}) {
				if ($shown == 0) {
					print "$lang - $file\n";
					$shown = 1;
				}
				print "Found duplicate '$1'\n";
			}
			$foundstrings{$1} = 1;
		}
	}

	foreach my $s (sort(keys(%strings))) {
		if (!defined $foundstrings{$s}) {
			if ($shown == 0) {
				print "$lang\n";
				$shown = 1;
			}
			print "\"$s\" = \"$s\";\n";
		}
	}

	print "\n" if ($shown != 0);
}

