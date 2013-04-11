requires 'App::cpanminus', '1.6107';
requires 'OrePAN';
requires 'Parse::CPAN::Packages';

on test => sub {
    requires 'Test::More', 0.98;
};

on configure => sub {
};

on 'develop' => sub {
};

