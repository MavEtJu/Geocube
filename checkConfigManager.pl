#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

## .h
open(FIN, $ARGV[0]. ".h");
my @lines = <FIN>;
close(FIN);
chomp(@lines);

my %property_fields = ();
my %prototype_fields = ();
foreach my $line (@lines) {
	# @property (nonatomic) NSInteger orientationsAllowed;
	# @property (nonatomic) NSString *mapBrandDefault;
	if ($line =~ /^\@property .*?([a-zA-Z]+);/) {
		$property_fields{$1} = 1;
		next;
	}

	# - (void)distanceMetricUpdate:(BOOL)value;
	if ($line =~ /^.*void.([a-zA-Z]+)Update:/) {
		$prototype_fields{$1} = 1;
		next;
	}
	
	# PROTO_N (BOOL, sendTweets);
	if ($line =~ /^PROTO_[^(]+\([^,]+, ([a-zA-Z]+)/) {
		$prototype_fields{$1} = 1;
		$property_fields{$1} = 1;
		next;
	}

}

## .m
open(FIN, $ARGV[0]. ".m");
@lines = <FIN>;
close(FIN);
chomp(@lines);

my %check_keys = ();
my %init_keys = ();
my %init_fields = ();
my %update_fields = ();
my %update_keys = ();
foreach my $line (@lines) {
	# CHECK(@"send_tweets", @"1");
	if ($line =~ /CHECK...([^\"]+)"/) {
		$check_keys{$1} = 1;
		next;
	}

	# LOAD_BOOL   (self.sendTweets, @"send_tweets");
	if ($line =~ /LOAD_.[^(]+\(self.([^,]+), \@"([^"]+)"/) {
		$init_fields{$1} = 1;
		$init_keys{$2} = 1;
		next;
	}

	# self.sendTweets = [[dbConfig dbGetByKey:@"send_tweets"].value boolValue];
	# but not:
	# self.__field__ = [dbConfig dbGetByKey:__key__].value
	if ($line !~ /__field__/ &&
	    $line =~ /self.([^ ]+) = .+dbGetByKey:..([^"]+)/) {
		$init_fields{$1} = 1;
		$init_keys{$2} = 1;
		next;
	}

	# UPDATE3(BOOL, distanceMetric, @"distance_metric")
	if ($line =~ /UPDATE3.*, ([^,]+), ..([^"]+)"/) {
		$update_fields{$1} = 1;
		$update_keys{$2} = 1;
		next;
	}

	# UPDATE4(NSString *, NSString, currentWaypoint, @"waypoint_current")
	if ($line =~ /UPDATE4.*, ([^,]+), ..([^"]+)"/) {
		$update_fields{$1} = 1;
		$update_keys{$2} = 1;
		next;
	}

	# UPDATE5(dbTrack *, NSId, currentTrack, @"track_current", _id)
	if ($line =~ /UPDATE5.*, ([^,]+), ..([^"]+)", /) {
		$update_fields{$1} = 1;
		$update_keys{$2} = 1;
		next;
	}

	# UPDATECOLOUR(distanceMetric, @"distance_metric")
	if ($line =~ /UPDATECOLOUR.([^,]+), ..([^"]+)"/) {
		$update_fields{$1} = 1;
		$update_keys{$2} = 1;
		next;
	}

	# - (void)mapTrackColourUpdate:(NSString *)value
	# but not:
	# - (void)doubleUpdate:(NSString *)key value:(double)value
	if ($line !~ /- .void.([a-zA-Z]+)Update:.*key value/ &&
	    $line =~ /- .void.([a-zA-Z]+)Update:/) {
		$update_fields{$1} = 1;
		next;
	}

	#     [self NSStringUpdate:@"map_track_colour" value:value];
	if ($line =~ /Update:."([^"]+)/) {
		$update_keys{$1} = 1;
		next;
	}

}

sub check_fields {
	my $type = shift;
	my @fields = @_;
	foreach my $field (@fields) {
		if (!defined $property_fields{$field}) {
			print "Found field $type '$field', no property.\n";
		}
		if (!defined $prototype_fields{$field}) {
			print "Found field $type '$field', no prototype.\n";
		}
		if (!defined $init_fields{$field}) {
			print "Found field $type '$field', no init.\n";
		}
		if (!defined $update_fields{$field}) {
			print "Found field $type '$field', no update.\n";
		}
	}
}

check_fields("property", sort(keys(%property_fields)));
check_fields("prototype", sort(keys(%prototype_fields)));
check_fields("init", sort(keys(%init_fields)));
check_fields("update", sort(keys(%update_fields)));

sub check_keys {
	my $type = shift;
	my @keys = @_;
	foreach my $key (@keys) {
		if (!defined $check_keys{$key}) {
			print "Found key $type '$key', no check.\n";
		}
		if (!defined $init_keys{$key}) {
			print "Found key $type '$key', no init.\n";
		}
		if (!defined $update_keys{$key}) {
			print "Found key $type '$key', no update.\n";
		}
	}
}

check_keys("check", sort(keys(%check_keys)));
check_keys("init", sort(keys(%init_keys)));
check_keys("update", sort(keys(%update_keys)));
