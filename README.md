# NAME

Nephia::Plugin::PocketIO - It's new $module

# SYNOPSIS

    package MyApp;
    use Nephia plugins => ['PocketIO'];
    

    pocketio_assets;
    pocketio '/io' => sub {
        my $c = shift;
        $c->on('message' => sub {
            my ($socket, $message) = @_;
            ...
        });
        $c->send({buffer => []});
    };

# DESCRIPTION

Nephia::Plugin::PocketIO is ...

# LICENSE

Copyright (C) ytnobody / satoshi azuma.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody / satoshi azuma <ytnobody@gmail.com>
