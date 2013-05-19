package Parcel::CLI::Index;
use strict;
use warnings;
use utf8;

use Parcel;
use Parcel::Indexer;
use Getopt::Long;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run {
    my ($self, @args) = @_;

    my $local_mirror_dir = 'cpan';
    my $target = '.';
    Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case auto_help)]
    )->getoptionsfromarray(
        \@args,
        'v|version' => sub {
            print "Parcel: $Parcel::VERSION\n";
            exit 0;
        },
        target         => \$target,
        'local-mirror' => \$local_mirror_dir,
    );

    Parcel::Indexer->new(local_mirror => $local_mirror_dir, target => $target)->do_index();
}

1;
__END__

=head1 NAME

parcel-index - Create local mirror from CPAN

=head1 SYNOPSIS

    % parcel-index

=head1 What?

Yet another library manager for Perl applications.

=head1 FAQ

=over 4

=item Should I include tar balls in repository?

Parcel downloads tar balls from CPAN/BackPAN if it does not exist.

=item How do I display diffs from 02packages.details.txt.gz?

Run following command.

    $ git config --global diff.gzcat.textconv gzcat

And put following contents to C<.gitattributes> or C<~/.config/git/attributes>.

    /02packages.details.txt.gz diff=gzcat

=back

