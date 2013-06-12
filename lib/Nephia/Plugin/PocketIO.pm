package Nephia::Plugin::PocketIO;
use 5.008005;
use strict;
use warnings;
use PocketIO;
use File::Spec;
use Furl;

our $VERSION = "0.01";
our $SOURCE_URL = 'https://raw.github.com/LearnBoost/socket.io-client/master/socket.io-client.js';
our $CLIENT_PATH = '/static/socket.io-client.js';

sub pocketio ($&) {
    my ($path, $code) = @_;
    my $pio = PocketIO->new(handler => $code);
    $Nephia::Core::MAPPER->connect($path, {action => $pio});
}

sub pocketio_assets (;$) {
    my $path = shift;
    my $file = File::Spec->catfile($FindBin::Bin, 'root', pocketio_client_path($path));
    my $furl = Furl->new(agent => __PACKAGE__.'/'.$VERSION);
    my $res = $furl->get($SOURCE_URL);
    die 'could not fetch assets' unless $res->is_success;
    unless (-e $file) {
        open my $fh, '>', $file or die "could not open file $file : $!";
        print $fh $res->content;
        close $fh;
    }
}

sub pocketio_client_path {
    my $path = shift;
    $path ||= $Nephia::Plugin::PocketIO::CLIENT_PATH;
    return File::Spec->catfile($path);
}


1;
__END__

=encoding utf-8

=head1 NAME

Nephia::Plugin::PocketIO - It's new $module

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Nephia::Plugin::PocketIO is ...

=head1 LICENSE

Copyright (C) ytnobody / satoshi azuma.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody / satoshi azuma E<lt>ytnobody@gmail.comE<gt>

=cut

