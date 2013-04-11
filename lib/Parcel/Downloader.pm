package Parcel::Downloader;
use strict;
use warnings;
use utf8;

use Parse::CPAN::Packages;
use Parcel::Util;

use Moo;

has local_mirror => ( is => 'rw' );

no Moo;

sub download {
    my ($self) = @_;


    my @distributions = do {
        my $p = Parse::CPAN::Packages->new(catfile($self->local_mirror, 'modules/02packages.details.txt.gz'));
        my @d = map { $_->prefix } $p->distributions;
        @d = grep { ! -f catfile($self->local_mirror, 'authors', 'id', $_) } @d;
        @d;
    };
    unless (@distributions) {
        return 0;
    }

    my $tmpdir = tempdir(CLEANUP => 1);
    # I need '--download-only'.
    run(
        'cpanm',
        '--notest',
        '--no-man-pages',
        '-L' => $tmpdir,
        '--mirror' => 'file://' . rel2abs($self->local_mirror),
        '--mirror' => 'http://cpan.metacpan.org/',
        '--mirror' => 'http://backpan.perl.org/',
        '--save-dists' => $self->local_mirror,
        '--installdeps',
        @distributions
    );
    return 1;
}

1;
