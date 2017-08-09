#!/usr/bin/perl

use strict;
use warnings;
use Encode;
use Encode::Detect;
use Encode::Guess;
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
		my @lines = <FIN>;
		my $lines = Encode::decode("Guess", join("", @lines));
		@lines = split("\n", $lines);

		foreach my $line (@lines) {
			# "Queries" = "nl-Queries";

			next if ($line !~ /"([^"]+)" = "([^"]+)";/);

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
				print "Found duplicate '$1' in $foundstrings{$1}\n";
			}
			$foundstrings{$1} = $file;
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

