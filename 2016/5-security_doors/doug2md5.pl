package MD5;
use strict;
use integer;
require 5.000;


#
# Note: If you want to make your MD5 digests differ from others,
#       then uncomment and tune the "security feature" in the Digest
#       subroutine below.
#
#       This is useful if you want to get an undecodable digest for
#       security purposes. Standard MD5 can be decoded if the *set* 
#       of possible originals is small and known
#       (e.g. last two digits of an IP number)

require Exporter;

@MD5::ISA = qw( Exporter );
@MD5::EXPORT = qw( &Digest &HexDigest );

use integer;

#
# interface routine; returns a digest of a string passed as a parameter
#

# MD5 initialization. Begins an MD5 operation, writing a new context.

sub MD5Init {
    return {
	    'count' => [0, 0],
	    'buffer' => '',
	    'state' => [ 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476],
	   };
}


sub Digest {
    my $context = MD5Init();

    # security feature: uncomment and put your own "magic string"
    # note: MD5test.pl will not work with your magic string, of course
    # my $magicString = '!@#$%^';
    # MD5Update($context, $magicString, length($magicString));

    # this should be done always
    MD5Update($context, $_[0], length($_[0]));

    return MD5Final($context);
}

#
# same as Digest but returns digest in a printable (hex) form
#

sub HexDigest { unpack("H*", Digest(@_)) }


#
# MD5 implementation is below
#



# derived from the RSA Data Security, Inc. MD5 Message-Digest Algorithm

# Original context structure
# typedef struct {
#
#       UINT4 state[4];                                   /* state (ABCD) */
#       UINT4 count[2];        /* number of bits, modulo 2^64 (lsb first) */
#       unsigned char buffer[64];                         /* input buffer */
#
# } MD5_CTX;


# Constants for MD5Transform routine.

use constant S11 =>  7;
use constant S12 => 12;
use constant S13 => 17;
use constant S14 => 22;

use constant S21 =>  5;
use constant S22 =>  9;
use constant S23 => 14;
use constant S24 => 20;

use constant S31 =>  4;
use constant S32 => 11;
use constant S33 => 16;
use constant S34 => 23;

use constant S41 =>  6;
use constant S42 => 10;
use constant S43 => 15;
use constant S44 => 21;

my $PADDING = chr(0x80) . ("\000" x 63);


# FF, GG, HH, and II transformations for rounds 1, 2, 3, and 4.
# Rotation is separate from addition to prevent recomputation.

my $sub_FF = q{\$i = \$$1 + ((\$$2 & \$$3) | (~\$$2 & \$$4)) + \$$5 + $7;
 \$$1 = \$$2 + \$i <<< $6};

my $sub_GG = q{ \$i = \$$1 + ((\$$2 & \$$4) | (\$$3 & ~\$$4)) + \$$5 + $7;
 \$$1 = \$$2 + \$i <<< $6};

my $sub_HH = q{ \$i = \$$1 + (\$$2 ^ \$$3 ^ \$$4) + \$$5 + $7;
 \$$1 = \$$2 + \$i <<< $6};

my $sub_II = q{ \$i = \$$1 + (\$$3 ^ (\$$2 | ~\$$4)) + \$$5 + $7;
 \$$1 = \$$2 + \$i <<< $6};


my $sub_ROTATE_LEFT = q{ (($1 << $2) | ($1 >> (32 - $2) & ~(-1 << $2))); };

# MD5 basic transformation. Transforms state based on block.

my $sub_MD5Transform = q{
    my ($state, $block) = @_;
    my ($A,$B,$C,$D) = @{$state};
    my @x = unpack("L16", $block);

    my $i;
    # Round 1
    FF A B C D x[0]  S11 0xd76aa478
    FF D A B C x[1]  S12 0xe8c7b756
    FF C D A B x[2]  S13 0x242070db
    FF B C D A x[3]  S14 0xc1bdceee
    FF A B C D x[4]  S11 0xf57c0faf
    FF D A B C x[5]  S12 0x4787c62a
    FF C D A B x[6]  S13 0xa8304613
    FF B C D A x[7]  S14 0xfd469501
    FF A B C D x[8]  S11 0x698098d8
    FF D A B C x[9]  S12 0x8b44f7af
    FF C D A B x[10] S13 0xffff5bb1
    FF B C D A x[11] S14 0x895cd7be
    FF A B C D x[12] S11 0x6b901122
    FF D A B C x[13] S12 0xfd987193
    FF C D A B x[14] S13 0xa679438e
    FF B C D A x[15] S14 0x49b40821

    # Round 2
    GG A B C D x[1]  S21 0xf61e2562
    GG D A B C x[6]  S22 0xc040b340
    GG C D A B x[11] S23 0x265e5a51
    GG B C D A x[0]  S24 0xe9b6c7aa
    GG A B C D x[5]  S21 0xd62f105d
    GG D A B C x[10] S22 0x2441453
    GG C D A B x[15] S23 0xd8a1e681
    GG B C D A x[4]  S24 0xe7d3fbc8
    GG A B C D x[9]  S21 0x21e1cde6
    GG D A B C x[14] S22 0xc33707d6
    GG C D A B x[3]  S23 0xf4d50d87
    GG B C D A x[8]  S24 0x455a14ed
    GG A B C D x[13] S21 0xa9e3e905
    GG D A B C x[2]  S22 0xfcefa3f8
    GG C D A B x[7]  S23 0x676f02d9
    GG B C D A x[12] S24 0x8d2a4c8a

    # Round 3
    HH A B C D x[5]  S31 0xfffa3942
    HH D A B C x[8]  S32 0x8771f681
    HH C D A B x[11] S33 0x6d9d6122
    HH B C D A x[14] S34 0xfde5380c
    HH A B C D x[1]  S31 0xa4beea44
    HH D A B C x[4]  S32 0x4bdecfa9
    HH C D A B x[7]  S33 0xf6bb4b60
    HH B C D A x[10] S34 0xbebfbc70
    HH A B C D x[13] S31 0x289b7ec6
    HH D A B C x[0]  S32 0xeaa127fa
    HH C D A B x[3]  S33 0xd4ef3085
    HH B C D A x[6]  S34 0x4881d05
    HH A B C D x[9]  S31 0xd9d4d039
    HH D A B C x[12] S32 0xe6db99e5
    HH C D A B x[15] S33 0x1fa27cf8
    HH B C D A x[2]  S34 0xc4ac5665

    # Round 4
    II A B C D x[0]  S41 0xf4292244
    II D A B C x[7]  S42 0x432aff97
    II C D A B x[14] S43 0xab9423a7
    II B C D A x[5]  S44 0xfc93a039
    II A B C D x[12] S41 0x655b59c3
    II D A B C x[3]  S42 0x8f0ccc92
    II C D A B x[10] S43 0xffeff47d
    II B C D A x[1]  S44 0x85845dd1
    II A B C D x[8]  S41 0x6fa87e4f
    II D A B C x[15] S42 0xfe2ce6e0
    II C D A B x[6]  S43 0xa3014314
    II B C D A x[13] S44 0x4e0811a1
    II A B C D x[4]  S41 0xf7537e82
    II D A B C x[11] S42 0xbd3af235
    II C D A B x[2]  S43 0x2ad7d2bb
    II B C D A x[9]  S44 0xeb86d391

    $state -> [0] += $A;
    $state -> [1] += $B;
    $state -> [2] += $C;
    $state -> [3] += $D;
};


eval qq{\$sub_MD5Transform =~
  s/FF (\\S+) (\\S+) (\\S+) (\\S+) (\\S+) +(\\S+) (\\S+)/$sub_FF/g;};
eval qq{\$sub_MD5Transform =~
  s/GG (\\S+) (\\S+) (\\S+) (\\S+) (\\S+) +(\\S+) (\\S+)/$sub_GG/g;};
eval qq{\$sub_MD5Transform =~
  s/HH (\\S+) (\\S+) (\\S+) (\\S+) (\\S+) +(\\S+) (\\S+)/$sub_HH/g;};
eval qq{\$sub_MD5Transform =~
  s/II (\\S+) (\\S+) (\\S+) (\\S+) (\\S+) +(\\S+) (\\S+)/$sub_II/g;};

eval qq{\$sub_MD5Transform =~ s/(\\S+) <<< (\\S+)/$sub_ROTATE_LEFT/g;};

eval qq{ sub MD5Transform { $sub_MD5Transform } };

# MD5 block update operation. Continues an MD5 message-digest
# operation, processing another message block, and updating the context.

sub MD5Update {
    my ($context, $input, $inputLen) = @_;

    # Compute number of bytes mod 64
    my $index = (($context->{count}[0] >> 3) & 0x3F);

    # Update number of bits
    if (($context->{count}[0] += ($inputLen << 3)) < ($inputLen << 3)) {
	$context->{count}[1] += ($inputLen >> 29) + 1;
    }

    my $partLen = 64 - $index;

    # Transform as many times as possible.

    my $i;
    if ($inputLen >= $partLen) {

	substr($context -> {buffer}, $index, $partLen) = substr($input, 0, $partLen);

	MD5Transform(\@{$context -> {state}}, $context -> {buffer});

	my $max = $inputLen - 63;
	for ($i = $partLen; $i < $max; $i += 64) {
	    MD5Transform($context-> {state}, substr($input,$i,64));
	}

	$index = 0;
    } else {
	$i = 0;
    }

    # Buffer remaining input
    substr($context->{buffer}, $index, $inputLen-$i) = substr($input, $i, $inputLen-$i);
}

# MD5 finalization. Ends an MD5 message-digest operation, writing the
#	the message digest and zeroizing the context.

sub MD5Final {
    my $context = shift;

    # Save number of bits
    my $bits = pack("L2", @{$context->{count}});

    # Pad out to 56 mod 64.
    my ($index, $padLen);
    $index = ($context->{count}[0] >> 3) & 0x3f;
    $padLen = ($index < 56) ? (56 - $index) : (120 - $index);

    MD5Update($context, $PADDING, $padLen);

    # Append length (before padding)
    MD5Update($context, $bits, 8);

    # Store state in digest
    my $digest = pack("L4", @{$context-> {state}});

    # MD5_memset ($context, 0);

    return $digest;
}

1;
