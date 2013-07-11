package MyApp;
use strict;
use warnings;
use Nephia plugins => ['PocketIO'];

our $VERSION = 0.03;

path '/' => sub {
    my $req = shift;
    my $asset = pocketio_asset_path();
    return {
        template => 'index.html',
        title    => config->{appname},
        envname  => config->{envname},
        apppath  => 'lib/' . __PACKAGE__ .'.pm',
    };
};

pocketio 'message' => sub {
    my($socket, $mes) = @_;
    $socket->emit('server_message', 'yahoo!!');
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

