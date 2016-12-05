#!/usr/bin/env perl

use strict;
use warnings;

# Load the AnnotatedUtteranceFile module from this tools directory.
use FindBin;
FindBin::again();
use lib "$FindBin::RealBin";

use MD5 qw/ HexDigest /;

my $door_id = "ugkcyxxp";
my $i = 0;
my $chars_found = 0;
my @key = split(//, "........");
my ($hash, $pos, $char);
while ($chars_found < 8) {
	$hash = HexDigest("$door_id$i");
	if (substr($hash, 0, 5) eq "00000") {
		$pos = substr($hash, 5, 1);
		$char = substr($hash, 6, 1);
		if ($pos =~ /[0-7]/ && $key[$pos] eq ".") {
			$key[$pos] = $char;
			$chars_found++;
		}
	}
	if ($i % 1000 == 0) {
		my $keystr = join('', @key);
		print "$i $keystr\n";
	}
	$i++;
}

print join("", @key);

# outputs: f2c730e5
# 976.92user 8.19system 16:31.06elapsed 99%CPU (0avgtext+0avgdata 4416maxresident)k
# 0inputs+0outputs (0major+1332minor)pagefaults 0swaps
