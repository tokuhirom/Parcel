package Parcel::Util;
use strict;
use warnings;
use utf8;
use parent qw(Exporter);

use File::Spec::Functions qw(catfile rel2abs);
use File::Temp qw(tempdir);

our @EXPORT = qw(tempdir catfile rel2abs run find_02packages);

sub run {
    my @args = @_;
    print "[run] @args\n";
    system(@args) == 0 or exit 1;
}

sub find_02packages {
    my $dir = shift;
    my ($pkgfile) = (
        grep { -f $_ }
        catfile($dir, 'modules/02packages.details.txt'),
        catfile($dir, 'modules/02packages.details.txt.gz')
    );
    return $pkgfile;
}

1;

