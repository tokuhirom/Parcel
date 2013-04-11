package Kattun;
use strict;
use warnings;
use 5.008005;
our $VERSION = "0.01";

package Kattun::Downloader;
use strict;
use warnings;
use utf8;

use Parse::CPAN::Packages;
use Kattun::Util;

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

package Kattun::Indexer;
use Kattun::Util;
use File::Path;
use File::Copy;

use Moo;

has target => ( is => 'rw', required => 1 );
has local_mirror => ( is => 'rw', required => 1 );

no Moo;

sub do_index {
    my $self = shift;

    if (-d $self->local_mirror) {
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
    run 'orepan_index.pl', '--repository' => $self->local_mirror;
}

sub reindex {
    my $self = shift;

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
    run 'orepan_index.pl', '--repository' => $new_mirror;

    my $old_mirror = $self->local_mirror . '.old';
    rmtree $self->local_mirror;
    rename $new_mirror, $self->local_mirror
        or die "$new_mirror: $!";
}

package Kattun::Installer;
use Kattun::Util;

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
__END__

=head1 NAME

Kattun - It's new $module

=head1 SYNOPSIS

    use Kattun;

=head1 DESCRIPTION

Kattun is ...

=head1 LICENSE

Copyright (C) tokuhirom

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

