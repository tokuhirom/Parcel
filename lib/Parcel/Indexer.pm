package Parcel::Indexer;
use strict;
use warnings;
use utf8;

use Parcel::Util;
use File::Path;
use File::Copy;
use Parcel::Downloader;
use File::Spec ();

use Moo;

has target => ( is => 'rw', required => 1 );
has local_mirror => ( is => 'rw', required => 1 );

no Moo;

sub do_index {
    my $self = shift;

    if (-f File::Spec->catfile($self->local_mirror, 'modules/02packages.details.txt.gz')) {
        $self->reindex();
    } else {
        $self->create_index();
    }
}

sub create_index {
    my $self = shift;

    # Create local mirror
    my $tmpdir = tempdir(CLEANUP => 1);
    run
        'cpanm',
        '--notest',
        '--no-man-pages',
        '--mirror' => 'http://cpan.metacpan.org/',
        '--mirror' => 'http://backpan.perl.org/',
        '--no-skip-satisfied',
        '-L' => $tmpdir,
        '--save-dists' => $self->local_mirror,
        '--installdeps' => $self->target,
    ;
    # And make index file
    run 'orepan2-indexer', '--repository' => $self->local_mirror;
}

sub reindex {
    my $self = shift;

    Parcel::Downloader->new(local_mirror => $self->local_mirror)->download();

    my $new_mirror = $self->local_mirror . '.new';

    # Create local mirror
    my $tmpdir = tempdir(CLEANUP => 1);
    run
        'cpanm',
        '--notest',
        '--no-man-pages',
        '--mirror' => 'file://' . rel2abs($self->local_mirror),
        '--mirror' => 'http://cpan.metacpan.org/',
        '--mirror' => 'http://backpan.perl.org/',
        '--no-skip-satisfied',
        '-L' => $tmpdir,
        '--save-dists' => $new_mirror,
        '--installdeps' => $self->target,
    ;
    # And make index file
    run 'orepan2-indexer', '--repository' => $new_mirror;

    my $old_mirror = $self->local_mirror . '.old';
    rmtree $self->local_mirror;
    rename $new_mirror, $self->local_mirror
        or die "$new_mirror: $!";
}

1;
