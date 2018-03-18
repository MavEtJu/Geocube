#!/usr/bin/perl

use strict;
use warnings;
use Encode;
use Encode::Detect;
use Encode::Guess;
use Data::Dumper;

# Find the localized strings
my %strings = ();
while (my $line = decode('UTF-8', <>)) {
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

# Find all languages, *.lproj for now
my @langs = ();
opendir(my $dh, "Geocube/Settings.bundle");
@langs = grep { /^.*.lproj/} readdir($dh);
closedir $dh;

my %foundstrings = ();
my $shown = 0;
my @files = ();

foreach my $langcc (@langs) {
	findfiles($langcc);

	%foundstrings = ();
	$shown = 0;

	# Load everything from en_US.lproj
	foreach my $file (@files) {
		loadfile($file, $langcc, 0);
	}

	# Merge now from en.lproj
	if ($langcc =~ /(.*?)_(.*).lproj/) {
		my $lang = "$1.lproj";
		findfiles($lang);
		foreach my $file (@files) {
			loadfile($file, $langcc, 1);
		}
	}

	foreach my $s (sort(keys(%strings))) {
		if (!defined $foundstrings{$s}) {
			if ($shown == 0) {
				print "$langcc\n";
				$shown = 1;
			}
			print encode('UTF-8', "\"$s\" = \"$s\";\n");
		}
	}

	print "\n" if ($shown != 0);
}


sub loadfile {
	my $file = shift;
	my $lang = shift;
	my $silent = shift;

	open(FIN, $file);
	my @lines = <FIN>;
	my $lines = Encode::decode("UTF-8", join("", @lines));
	@lines = split("\n", $lines);

	foreach my $line (@lines) {
		# "Queries" = "nl-Queries";

		# // comments
		$line =~ s/^;.*//;
		# /* comments */
		$line =~ s/\/\*.*\*\///;

		# chop from and back
		$line =~ s/^ +//;
		$line =~ s/ +$//;

		next if ($line eq "");

		if ($line !~ /"([^"]+)" = "([^"]+)";/) {
			if ($shown == 0) {
				print "$lang - $file\n";
				$shown = 1;
			}
			print encode('UTF-8', "Found weird line: $line\n");
			next;
		}

		if ($silent == 0 && !defined $strings{$1}) {
			if ($shown == 0) {
				print "$lang - $file\n";
				$shown = 1;
			}
			print encode('UTF-8', "Found unknown '$1' - $file\n");
		}
		if ($silent == 0 && defined $foundstrings{$1}) {
			if ($shown == 0) {
				print "$lang - $file\n";
				$shown = 1;
			}
			print encode('UTF-8', "Found duplicate '$1' in $foundstrings{$1}\n");
		}
		$foundstrings{$1} = $file;
	}
}

sub findfiles {
	my $lang = shift;

	@files = ();
	open(FIN, "find Geocube/Settings.bundle/$lang -name Localizable-*strings |");
	while (my $line = <FIN>) {
		chomp($line);
		push(@files, $line);
	}
}
