requires 'perl', '5.008001';
requires 'Nephia', '0';
requires 'PocketIO', '0';
requires 'Plack::Handler::Twiggy', '0';
requires 'Sub::Recursive';
requires 'HTML::Escape';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

