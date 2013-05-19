package Parcel::CLI::Install;
use strict;
use warnings;
use utf8;
use Parcel;
use Parcel::Installer;
use Parcel::Downloader;
use Getopt::Long;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run {
    my ($self, @args) = @_;

    my $local = 'local/';
    my $target = '.';
    my $local_mirror_dir = 'cpan/';

    Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case auto_help)]
    )->getoptionsfromarray(
        \@args,
        version => sub {
            print "Parcel: $Parcel::VERSION\n";
            exit 0;
        },
        local          => \$local,
        target         => \$target,
        'local-mirror' => \$local_mirror_dir,
    );

    # Download tar balls
    my $downloader = Parcel::Downloader->new(
        local_mirror => $local_mirror_dir
    );
    $downloader->download();

    # And install it.
    my $installer = Parcel::Installer->new(
        local_mirror => $local_mirror_dir,
        target => $target,
        local => $local
    );
    $installer->install();
}

1;

__END__

=head1 NAME

parcel-install - Install modules

=head1 SYNOPSIS

    % parcel install
        
        --local=local/         local library directory
        --target=.             application directory
        --local-mirror=cpan/   local mirror directory 

=head1 What?

Yet another library manager for Perl applications.

