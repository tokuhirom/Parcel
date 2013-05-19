package Parcel::CLI::Exec;
use strict;
use warnings;
use utf8;
use Getopt::Long ();

sub new { bless {}, shift }

# Code taken from Carton::CLI::CMD_exec
sub run {
    my ( $self, @args ) = @_;

    # allows -Ilib
    @args = map { /^(-[I])(.+)/ ? ( $1, $2 ) : $_ } @args;

    my $system;    # for unit testing
    my @include;
    Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case auto_help)]
    )->getoptionsfromarray(
        \@args,
        'I=s@', \@include,
        "system", \$system,
    );

    my $path = 'local';
    my $lib = join ",", @include, "$path/lib/perl5", ".";

    local $ENV{PERL5OPT} = "-Mlib::core::only -Mlib=$lib";
    local $ENV{PATH}     = "$path/bin:$ENV{PATH}";

    $system ? system(@args) : exec(@args);
}

1;

