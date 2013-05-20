package Parcel::Indexer;
use strict;
use warnings;
use utf8;

use Parcel::Util;
use File::Path;
use File::Copy;
use Parcel::Downloader;
use File::Spec ();
use OrePAN2::Indexer;

use Moo;

has target => ( is => 'rw', required => 1 );
has local_mirror => ( is => 'rw', required => 1 );

no Moo;

sub do_index {
    my $self = shift;

    $self->reindex();
}

sub cpanm_install {
    my ($self, @args) = @_;

    run_funny
        'cpanm',
        '--notest',
        '--no-man-pages',
        @args,
        '--no-skip-satisfied',
        '--installdeps' => $self->target,
    ;
}

sub reindex {
    my $self = shift;

    my $pkgfile = catfile($self->local_mirror, 'modules/02packages.details.txt');
    my $tmpdir = tempdir(CLEANUP => 0);
    my $new_mirror = $self->local_mirror . '.new';

    # Install from existed parcel repo first.
    if (-f $pkgfile) {
        Parcel::Downloader->new(local_mirror => $self->local_mirror)->download();

        $self->cpanm_install(
            '--mirror-only',
            '--mirror-index' => rel2abs($pkgfile),
            '--mirror' => 'file://' . rel2abs($self->local_mirror),
            '--save-dists' => $new_mirror,
            '-L' => $tmpdir,
        );
    }
    $self->cpanm_install(
        '--mirror-only',
        '--mirror' => 'file://' . rel2abs($self->local_mirror),
        '--mirror' => 'http://cpan.metacpan.org/',
        '--mirror' => 'http://backpan.perl.org/',
        '--save-dists' => $new_mirror,
        '-L' => $tmpdir,
    )==0 or die "BAIL OUT\n";

    # And make index file
    my $indexer = OrePAN2::Indexer->new(directory => $new_mirror);
    $indexer->make_index(no_compress => 1);

    my $old_mirror = $self->local_mirror . '.old';
    rmtree $self->local_mirror;
    rename $new_mirror, $self->local_mirror
        or die "$new_mirror: $!";
}

1;
