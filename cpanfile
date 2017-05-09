requires 'perl', '5.008001';
requires 'Test::More', '0.98';
requires 'Time::HiRes';

on 'test' => sub {
};

on 'develop' => sub {
    requires 'Perl::Critic', '1.126';
    requires 'Test::Perl::Critic', '1.03';
};

