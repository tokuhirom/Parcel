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

    run(
        'cpanm',
        '--notest',
        '--no-man-pages',
        '--mirror-only',
        '--mirror' => 'file://' . rel2abs($self->local_mirror),
        '-L' => $self->local,
        '--installdeps',
        $self->target
    );
}

1;
