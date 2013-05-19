package Parcel::Installer;
use strict;
use warnings;
use utf8;
use Parcel::Util;

use Moo;

has target => ( is => 'rw', required => 1 );
has local => ( is => 'rw', required => 1 );
has local_mirror => ( is => 'rw', required => 1 );

no Moo;

sub install {
    my $self = shift;

    my $pkgfile = catfile($self->local_mirror, 'modules/02packages.details.txt');
    unless (-f $pkgfile) {
        die "There is no '$pkgfile'\n";
    }
    run(
        'cpanm',
        '--notest',
        '--no-man-pages',
        '--mirror-only',
        '--mirror-index' => rel2abs($pkgfile),
        '--mirror' => 'file://' . rel2abs($self->local_mirror),
        '-L' => $self->local,
        '--installdeps',
        $self->target
    );
}

1;
