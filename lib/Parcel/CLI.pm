package Parcel::CLI;
use strict;
use warnings;
use utf8;

sub new {
    my $class = shift;
    bless {
    }, $class;
}

sub run {
    my ($self, @args) = @_;
    my $cmd = shift @args || 'help';
       $cmd = 'help' if $cmd eq '-h';
    if ($cmd eq 'install') {
        require Parcel::CLI::Install;
        Parcel::CLI::Install->new->run(@args);
    } elsif ($cmd eq 'index') {
        require Parcel::CLI::Index;
        Parcel::CLI::Index->new->run(@args);
    } elsif ($cmd eq 'exec') {
        require Parcel::CLI::Exec;
        Parcel::CLI::Exec->new->run(@args);
    } else {
        require Parcel::CLI::Help;
        Parcel::CLI::Help->new->run(@args);
    }
}

1;

