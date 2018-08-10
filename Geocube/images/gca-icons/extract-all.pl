#!/usr/bin/perl

=comment


1. Get the file https://geocaching.com.au/pics/icon.svg or https://geocaching.com.au/pics/gmapmarker.svg or 
2. Rename it to gca-icons.svg
3. Run ./extract.pl

4. And convert:

for i in icon_geocache*.svg; do
	f=$(echo $i | sed -e 's/.svg$//');
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z -w 90 -h 90 -e $(pwd)/gca-$f@3x.png $(pwd)/$f.svg
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z -w 60 -h 60 -e $(pwd)/gca-$f@2x.png $(pwd)/$f.svg
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z -w 30 -h 30 -e $(pwd)/gca-$f.png $(pwd)/$f.svg
done
for i in icon_log*.svg; do
	f=$(echo $i | sed -e 's/.svg$//');
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z -w 90 -h 90 -e $(pwd)/gca-$f@3x.png $(pwd)/$f.svg
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z -w 60 -h 60 -e $(pwd)/gca-$f@2x.png $(pwd)/$f.svg
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z -w 30 -h 30 -e $(pwd)/gca-$f.png $(pwd)/$f.svg
done

=cut

use strict;
use warnings;
use XML::Parser;
use Data::Dumper;

$| = 1;
my $onlyfile = "";
$onlyfile = $ARGV[0] if ($#ARGV != -1);

my $input = "gca-icons.svg";
#$input = "gmapmarker.svg";

my %symbols = ();
my $parser = XML::Parser->new(
		Handlers => {
		    Start => \&handle_start_symbols,
		});
$parser->parsefile($input);

sub handle_start_symbols {
	my $expat = shift;
	my $element = shift;
	my @attrs = @_;

	my %attrs = ();
	while ($#attrs != -1) {
	    my $key = shift(@attrs);
	    my $value = shift(@attrs);
	    $attrs{$key} = $value;
	}

	if ($element eq "symbol") {
		$symbols{$attrs{id}} = $attrs{viewBox};
		return;
	}
}

my $currentsymbol;
my $originx;
my $originy;
my $printsymbol = 0;
foreach my $cs (sort(keys(%symbols))) {
	$currentsymbol = $cs;
	next if ($onlyfile ne "" && $currentsymbol ne $onlyfile);
	open(FOUT, ">$currentsymbol.svg");
	print FOUT "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n";

	$parser = XML::Parser->new(
			Handlers => {
			    Start => \&handle_start_symbol,
			    End => \&handle_end_symbol,
			});
	$printsymbol = 0;
	$parser->parsefile($input);

	close(FOUT);
}

sub handle_start_symbol {
	my $expat = shift;
	my $element = shift;
	my @attrs = @_;

	my %attrs = ();
	while ($#attrs != -1) {
		my $key = shift(@attrs);
		my $value = shift(@attrs);
		$attrs{$key} = $value;
	}
	
	if ($element eq "svg") {
		print FOUT "<svg\n";
		foreach my $k (keys(%attrs)) {
			print FOUT "$k=\"$attrs{$k}\"\n";
		}
		print FOUT ">\n";
		return;
	}

	if ($element eq "symbol") {
		if ($attrs{id} eq $currentsymbol) {
			print "Found $currentsymbol\n";
			$printsymbol = 1;
			my @a = split(" ", $attrs{viewBox});
			$originx = $a[0];
			$originy = $a[1];
		} else {
			$printsymbol = 0;
		}
		return;
	}

	return if ($printsymbol == 0);

	if ($element eq "path") {
		$attrs{d} = path_translate($attrs{d});

		print FOUT "<path\n";
		foreach my $k (keys(%attrs)) {
			print FOUT "$k=\"$attrs{$k}\"\n";
		}
		print FOUT "/>\n";

		return;
	}
	if ($element eq "rect") {
		$attrs{x} -= $originx;
		$attrs{y} -= $originy;

		print FOUT "<rect\n";
		foreach my $k (keys(%attrs)) {
			print FOUT "$k=\"$attrs{$k}\"\n";
		}

		print FOUT "/>\n";
		return;
	}
	if ($element eq "ellipse") {
		$attrs{cx} -= $originx;
		$attrs{cy} -= $originy;

		print FOUT "<ellipse\n";
		foreach my $k (keys(%attrs)) {
			print FOUT "$k=\"$attrs{$k}\"\n";
		}

		print FOUT "/>\n";
		return;
	}
	if ($element eq "circle") {
		$attrs{cx} -= $originx;
		$attrs{cy} -= $originy;

		print FOUT "<circle\n";
		foreach my $k (keys(%attrs)) {
			print FOUT "$k=\"$attrs{$k}\"\n";
		}

		print FOUT "/>\n";
		return;
	}
	if ($element eq "line") {
		$attrs{x1} -= $originx;
		$attrs{x2} -= $originx;
		$attrs{y1} -= $originy;
		$attrs{y2} -= $originy;

		print FOUT "<line\n";
		foreach my $k (keys(%attrs)) {
			print FOUT "$k=\"$attrs{$k}\"\n";
		}

		print FOUT "/>\n";
		return;
	}
	if ($element eq "g") {
		print FOUT "<g\n";
		foreach my $k (keys(%attrs)) {
			print FOUT "$k=\"$attrs{$k}\"\n";
		}

		print FOUT ">\n";
		return;
	}

	print ">$element\n";
}

sub handle_end_symbol {
	my $expat = shift;
	my $element = shift;

	if ($element eq "svg") {
		print FOUT "</svg>\n";
		return;
	}

	return if ($printsymbol == 0);

	if ($element eq "symbol") {
		$printsymbol = 0;
		return;
	}
	if ($element eq "g") {
		print FOUT "</g>\n";
		return;
	}
}

sub path_translate
{
	my $d = shift;

	my @d = split(" ", $d);

	my $i = 0;
	while ($i <= $#d) {
		if ($d[$i] le "Z" && $d[$i] ge "A") {
			if ($d[$i] eq "A") {
				$i++;
				while ($d[$i] !~ /^[A-Za-z]$/) {
					my @v = split(/,/, $d[$i + 4]);
					$v[0] -= $originx;
					$v[1] -= $originy;
					$d[$i + 4] = join(",", @v);
					$i += 5;
				}
				next;
			}
			if ($d[$i] eq "C") {
				$i++;
				while ($d[$i] !~ /^[A-Za-z]$/) {
					my @v = split(/,/, $d[$i]);
					$v[0] -= $originx;
					$v[1] -= $originy;
					$d[$i] = join(",", @v);
					$i++;
				}
				next;
			}
			if ($d[$i] eq "L") {
				$i++;
				while ($d[$i] !~ /^[A-Za-z]$/) {
					my @v = split(/,/, $d[$i]);
					$v[0] -= $originx;
					$v[1] -= $originy;
					$d[$i] = join(",", @v);
					$i++;
				}
				next;
			}
			if ($d[$i] eq "M") {
				$i++;
				while ($d[$i] !~ /^[A-Za-z]$/) {
					my @v = split(/,/, $d[$i]);
					$v[0] -= $originx;
					$v[1] -= $originy;
					$d[$i] = join(",", @v);
					$i++;
				}
				next;
			}
			if ($d[$i] eq "Q") {
				$i++;
				while ($d[$i] !~ /^[A-Za-z]$/) {
					my @v = split(/,/, $d[$i]);
					$v[0] -= $originx;
					$v[1] -= $originy;
					$d[$i] = join(",", @v);
					$i++;
				}
				next;
			}
			if ($d[$i] eq "Z") {
				$i++;
				next;
			}
			print "$d[$i]\n";
			next;
		}
		if ($d[$i] le "z" && $d[$i] ge "a") {
			if ($d[$i] eq "m" && $i == 0) {
				my @v = split(/,/, $d[$i + 1]);
				$v[0] -= $originx;
				$v[1] -= $originy;
				$d[$i + 1] = join(",", @v);
				$i += 2;
				next;
			}
		}
		$i++;
	}

	# print join(" ", @d), "\n";
	return join(" ", @d);
}
