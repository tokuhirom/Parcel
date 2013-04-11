package Kattun::Util;
use strict;
use warnings;
use utf8;
use parent qw(Exporter);

use File::Spec::Functions qw(catfile rel2abs);
use File::Temp qw(tempdir);

our @EXPORT = qw(tempdir catfile rel2abs run);

sub run {
    my @args = @_;
    print "[run] @args\n";
    system(@args) == 0 or exit;
}

1;

