requires 'App::cpanminus', '1.6107';
requires 'OrePAN2';
requires 'Parse::CPAN::Packages';
requires 'File::Temp';
requires 'Getopt::Long';
requires 'Moo';
requires 'parent';

on test => sub {
    requires 'Test::More', 0.98;
    requires 'File::pushd';
};

on configure => sub {
};

on 'develop' => sub {
};

