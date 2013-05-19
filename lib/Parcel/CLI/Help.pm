package Parcel::CLI::Help;
use strict;
use warnings;
use utf8;
use Pod::Usage;

sub new { bless {}, shift }
sub run {
    my $self = shift;
    pod2usage(1);
}

1;
