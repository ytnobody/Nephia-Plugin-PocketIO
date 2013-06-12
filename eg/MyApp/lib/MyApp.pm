package MyApp;
use strict;
use warnings;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, qw/.. .. lib/);
use Nephia plugins => ['PocketIO'];

our $VERSION = 0.01;

pocketio_assets;

path '/' => sub {
    my $req = shift;
    return {
        template => 'index.html',
        title    => config->{appname},
        envname  => config->{envname},
        client   => pocketio_client_path(),
        apppath  => 'lib/' . __PACKAGE__ .'.pm',
    };
};

use Data::Dumper;
pocketio '/io' => sub {
    my $c = shift;
    $c->on('message' => sub {
        warn Dumper(@_);
        my ($socket, $mes) = @_;
        $socket->emit('server_message', time. $mes);
    });
};

1;

=head1 NAME

MyApp - Web Application

=head1 SYNOPSIS

  $ plackup

=head1 DESCRIPTION

MyApp is web application based Nephia.

=head1 AUTHOR

clever guy

=head1 SEE ALSO

Nephia

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

