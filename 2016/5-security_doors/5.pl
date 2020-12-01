#!/usr/bin/env perl

use strict;
use warnings;

# Load the AnnotatedUtteranceFile module from this tools directory.
use FindBin;
FindBin::again();
use lib "$FindBin::RealBin";

use MD5 qw/ HexDigest /;

sub hash_key {
	my $hash = HexDigest($_[0]);
	return (substr($hash, 0, 5) eq "00000") ? substr($hash, 5, 1) : "";
}

my $door_id = "ugkcyxxp";
my $i = 0;
my $next_char = "";
my $chars_found = 0;
while ($chars_found < 8) {
	$next_char = hash_key "$door_id$i";
	if ($next_char ne "") {
		$chars_found++;
		print $next_char;
	}
	# print "$i\n" if ($i % 1000 == 0);
	$i++;
}

# outputs: d4cd2ee1
# 376.25user 0.57system 6:17.62elapsed 99%CPU (0avgtext+0avgdata 4420maxresident)k
# 0inputs+0outputs (0major+1333minor)pagefaults 0swaps
