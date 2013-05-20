use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use File::pushd;
use File::Spec;
use File::Path;
use File::Copy;
use OrePAN2::Indexer;

my $libdir = File::Spec->rel2abs('lib');
my $parcel = File::Spec->rel2abs('script/parcel');
my $base = File::Spec->rel2abs('.');

my $tmp = tempdir(CLEANUP => 1);
my $guard = pushd($tmp);

{
    open my $fh, '>', 'cpanfile' or die;
    print $fh <<'...';
requires 'Acme::Hoge';
...
}

{
    mkpath 'cpan/modules/';
    mkpath 'cpan/authors/id/M/MA/MAHITO/';
    copy "$base/t/dat/Acme-Hoge-0.02.tar.gz", 'cpan/authors/id/M/MA/MAHITO/' or die $!;
    OrePAN2::Indexer->new(directory => 'cpan')->make_index(no_compress => 1);
    system 'tree';
    my $pkg = slurp('cpan/modules/02packages.details.txt');
    note $pkg;
    like $pkg, qr{M/MA/MAHITO/Acme-Hoge-0.02.tar.gz};
}

{
    is(system($^X, "-I$libdir", $parcel, 'index'), 0);
    my $pkg = slurp('cpan/modules/02packages.details.txt');
    note $pkg;
    like $pkg, qr{M/MA/MAHITO/Acme-Hoge-0.02.tar.gz};
    unlike $pkg, qr{M/MA/MAHITO/Acme-Hoge-0.03.tar.gz};
}

done_testing;

sub slurp {
    my $fname = shift;
    open my $fh, '<', $fname
        or Carp::croak("Can't open '$fname' for reading: '$!'");
    do { local $/; <$fh> }
}
