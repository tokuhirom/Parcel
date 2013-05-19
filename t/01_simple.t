use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use File::pushd;
use File::Spec;

my $libdir = File::Spec->rel2abs('lib');
my $parcel = File::Spec->rel2abs('script/parcel');

my $tmp = tempdir(CLEANUP => 1);
my $guard = pushd($tmp);

open my $fh, '>', 'cpanfile' or die;
print $fh <<'...';
requires 'Module::Functions';
...

is(system($^X, "-I$libdir", $parcel, 'index'), 0);
ok -f 'cpan/modules/02packages.details.txt';

# re-index
is(system($^X, "-I$libdir", $parcel, 'index'), 0);
ok -f 'cpan/modules/02packages.details.txt';

# install
is(system($^X, "-I$libdir", $parcel, 'install'), 0);
system 'tree';
ok -f 'local/lib/perl5/Module/Functions.pm';

done_testing;

